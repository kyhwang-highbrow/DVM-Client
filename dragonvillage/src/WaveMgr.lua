-------------------------------------
-- class WaveMgr
-------------------------------------
WaveMgr = class(IEventDispatcher:getCloneClass(), {
        m_world = 'GameWorld',
        m_currWave = 'number',
        m_maxWave = 'number',
        
		m_scriptData = 'table',

        m_waveTimer = 'number', -- 현재 웨이브의 흘러간 시간

		-- wave list 들
		m_lDynamicWave = 'list',
		m_lSummonWave = 'list',

		m_stageName = '',
        m_bDevelopMode = '',
        
        m_highestRarity = 'number',         -- 현재 웨이브에서 가장 높은 rarity
        m_bDeadHighestRarity = 'boolean',   -- 가장 높은 rarity가 죽었는지 여부

        -- 보스 정보
        m_bossId = 'number',
        m_bossLv = 'number',
        m_lBoss = '',

		-- regen 전용
        m_mRegenGroup = 'table',
        m_isRegenWave = 'bool',		-- regen Wave 가 있는지 여부

        -- 추가 레벨
        m_addLevel = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr:init(world, stage_name, stage_id, develop_mode)
    self.m_world = world

    self.m_stageName = stage_name
	
    -- 파일에서 웨이브 정보를 얻어옴
    self:getScriptData()

    self.m_currWave = 0
    self.m_maxWave = 0
    self.m_waveTimer = -1
    self.m_lDynamicWave = {}
	self.m_lSummonWave = {}

    self.m_bDevelopMode = develop_mode or (stage_name == 'stage_dev') or false
	
    if self.m_scriptData then
		-- 최대 웨이브 갯수 체크
        if (self.m_scriptData['wave']) then
            self.m_maxWave = #self.m_scriptData['wave']
        end
        
        -- 소환 몬스터 정보
	    self:setSummonData(self.m_scriptData)
    end

	-- regen 전용 멤버 변수
    self.m_mRegenGroup = nil
    self.m_isRegenWave = false

    -- 스테이지별 추가 레벨
    self.m_addLevel = TableStageData():getValue(stage_id, 'level') or 0
    
    -- 리스너 등록
    self:addListener('change_wave', self.m_world)
end

-------------------------------------
-- function getScriptData
-------------------------------------
function WaveMgr:getScriptData()

    -- 파일에서 웨이브 정보를 얻어옴
    if (not self.m_scriptData) then
        local script = TABLE:loadStageScript(self.m_stageName)
        self.m_scriptData = script
    end

    return self.m_scriptData
end

-------------------------------------
-- function getNextWaveScriptData
-- @brief 다음 웨이브 정보, 최종 웨이브인지 여부를 리턴
-------------------------------------
function WaveMgr:getNextWaveScriptData()
    if (self.m_bDevelopMode == true) then
        self.m_currWave = 0
    end

    local wave = (self.m_currWave + 1)

    local t_script_data = self:getScriptData()

    -- 다음 웨이브가 없다는 뜻(스테이지 클리어를 의미)
    if (not t_script_data['wave'][wave]) then
        return false
    end

    -- 한번 더 검증
    if (self.m_maxWave < wave) then
        return false
    end

    local is_final_wave = (wave == self.m_maxWave)

    return t_script_data['wave'][wave], is_final_wave
end

-------------------------------------
-- function getBaseCameraScriptData
-------------------------------------
function WaveMgr:getBaseCameraScriptData()
    return self.m_scriptData['camera']
end

-------------------------------------
-- function getMovementScriptData
-------------------------------------
function WaveMgr:getMovementScriptData()
    return self.m_scriptData['move']
end

-------------------------------------
-- function setSummonData
-- @brief skill_summon의 대상이 되는 스크립트 추출 
-------------------------------------
function WaveMgr:setSummonData(script)
	if (script['summon']) then
		for i, summonData in pairs(script['summon']) do
			self.m_lSummonWave[i] = {}
			for j, summonWave in pairs(summonData) do
				local dynamic_wave = DynamicWave(self, summonWave, 0)
				table.insert(self.m_lSummonWave[i], dynamic_wave)
			end
		end
	end
end

-------------------------------------
-- function summonEnemy
-------------------------------------
function WaveMgr:summonEnemy(dynamic_wave)
	local enemy = self:spawnEnemy_dynamic(
		dynamic_wave.m_enemyID, 
		dynamic_wave.m_enemyLevel, 
		dynamic_wave.m_appearType,
		dynamic_wave.m_luaValue1,
		dynamic_wave.m_luaValue2,
		dynamic_wave.m_luaValue3,
		dynamic_wave.m_movement
		)

    if enemy and enemy.m_hpNode then
        enemy.m_hpNode:setVisible(true)
    end
end

-------------------------------------
-- function summonWave
-- @brief 소환을 위해 외부에서 호출함
-------------------------------------
function WaveMgr:summonWave(idx)
	-- summon 스크립트가 없으면 false
	if (not self.m_lSummonWave[idx]) then
		return false
	end
	
	-- enemy list를 순회하면서 소환하려는 위치에 몬스터가 없는 곳에 소환
	
	for _, dynamic_wave in pairs(self.m_lSummonWave[idx]) do
		
		-- 소환
		if (self:checkSummonable(dynamic_wave.m_luaValue2)) then 
			self:summonEnemy(dynamic_wave)
		end
	end
end

-------------------------------------
-- function checkSummonable
-- @brief 소환 가능 여부
-------------------------------------
function WaveMgr:checkSummonable(pos_key)
	local enemy_pos_x, enemy_pos_y = nil, nil
	local dest_pos = getEnemyPos(pos_key)
	local is_summonable = true

	for _, enemy in pairs(self.m_world:getEnemyList()) do
		enemy_pos_x = enemy.pos.x
		enemy_pos_y = enemy.pos.y
		if (enemy_pos_x == dest_pos['x']) and (enemy_pos_y == dest_pos['y']) then
			is_summonable = false	
			break
		end
	end

	return is_summonable
end

-------------------------------------
-- function setRegenDead
-- @brief 
-------------------------------------
function WaveMgr:setRegenDead(regen_info)
    local group_key = regen_info['group_key']
    local obj_key = regen_info['obj_key']

    local struct_group = self.m_mRegenGroup[group_key]
    if (not struct_group) then return end

    struct_group:setObjInfo(obj_key, false)
end

-------------------------------------
-- function setDynamicWave
-- @brief script를 읽어 dynamic wave를 저장
-------------------------------------
function WaveMgr:setDynamicWave(l_wave, l_data, group_key)
	if not (l_data) then return end

    local obj_key = 1

	for time, v in pairs(l_data) do
		for _, data in pairs(v) do
			-- dynamic wave 생성 및 저장
			local dynamic_wave = DynamicWave(self, data, time)
			
			if (group_key) then
				-- regen wave라면 regen 정보를 저장
                local regen_info = { group_key = group_key, obj_key = obj_key }
				dynamic_wave:setRegenInfo(regen_info)

                local struct_group = self.m_mRegenGroup[group_key]
                struct_group:setObjInfo(obj_key, true)
			end
			
			table.insert(l_wave, dynamic_wave)
            
            -- 해당 웨이브에서 가장 높은 Rarity를 저장
            do
                local enemy_id = dynamic_wave.m_enemyID
                local enemy_lv = dynamic_wave.m_enemyLevel
        
                local rarity = self:getRarity(enemy_id, enemy_lv)
    
	            if (rarity > self.m_highestRarity) then
		            self.m_highestRarity = rarity
                    self.m_bossId = enemy_id
                    self.m_bossLv = enemy_lv
	            end
            end

            obj_key = obj_key + 1
		end
	end
end

-------------------------------------
-- function newScenario
-------------------------------------
function WaveMgr:newScenario()

    -- 개발모드일 경우
    if (self.m_bDevelopMode) then
        -- 파일에서 웨이브 정보를 얻어옴
        local script = TABLE:loadStageScript(self.m_stageName)
        self.m_scriptData = script

        -- 개발스테이지는 [idx = 1] 인것을 찾아 사용
        self.m_currWave = 0
		for i, wave_data in ipairs(script['wave']) do
			if (wave_data['idx'] == 1) then
				self.m_currWave = i - 1
				break;
			end
		end
    end

    self.m_currWave = self.m_currWave + 1
    local wave = self.m_currWave
    self.m_waveTimer = -1

	local world = self.m_world

    if (not self.m_scriptData['wave'][wave]) then
        -- 다음 웨이브가 없다는 뜻(스테이지 클리어를 의미)
        return false
    end

    local t_data = self.m_scriptData['wave'][wave]
	
	if (wave == 1) or (self.m_bDevelopMode == true) then 
		-- 카메라 옵션 설정
        world:changeCameraOption(t_data['camera'])
        world:changeHeroHomePosByCamera()
	end

    self:newScenario_dynamicWave(t_data)

    self:dispatch('change_wave', {}, self.m_currWave)
end

-------------------------------------
-- function newScenario_dynamicWave
-------------------------------------
function WaveMgr:newScenario_dynamicWave(t_data)
    if (not t_data['wave']) then return end

    self.m_lDynamicWave = {}
    self.m_highestRarity = -1
    self.m_bDeadHighestRarity = false
    self.m_bossId = nil
    self.m_lBoss = nil

    -- wave 정보를 읽어 dynamic wave 세팅
	self:setDynamicWave(self.m_lDynamicWave, t_data['wave'])

	-- 이전에 저장된 regen 데이터가 있으면 초기화 시킴
    if (self.m_mRegenGroup) then
        self.m_isRegenWave = false
        self.m_mRegenGroup = nil
    end

    -- regen에 정보가 있다면 해당 몹을 지속적으로 소환하도록 세팅.
	if (t_data['regen']) then
		self.m_isRegenWave = true
        self.m_mRegenGroup = {}

        for group_key, v in ipairs(t_data['regen']) do
            self.m_mRegenGroup[group_key] = StructWaveRegenGroup(group_key, v, g_constant:get('INGAME', 'REGEN_APPEAR'))
        end
	end
end

-------------------------------------
-- function getRarity
-------------------------------------
function WaveMgr:getRarity(enemy_id, enemy_lv)
    local rarity

    if (isMonster(enemy_id)) then
        local t_monster = TableMonster():get(enemy_id)
        if (not t_monster) then
            error('invalid enemy_id : ' ..enemy_id)
        end
        rarity = monsterRarityStrToNum(t_monster['rarity'])

    else
        -- 드래곤은 몬스터보다 무조건 높아야하고 레벨로 설정함
        rarity = 10 + enemy_lv
    end
    
    return rarity
end

-------------------------------------
-- function checkToHighestRarity
-- @brief 현재 웨이브에서 최고 Rariry의 적이 죽었는지 체크
-------------------------------------
function WaveMgr:checkToDieHighestRariry()
    if (self.m_bDeadHighestRarity) then return true end
    if (not self.m_lBoss) then return false end

    local is_dead = true

    for i, boss in ipairs(self.m_lBoss) do
        if (not boss:isDead()) then
            is_dead = false
            break
        end
    end

    self.m_bDeadHighestRarity = is_dead
    
    return is_dead
end

-------------------------------------
-- function clearDynamicWave
-------------------------------------
function WaveMgr:clearDynamicWave()
    self.m_lDynamicWave = {}
end

-------------------------------------
-- function spawnEnemy_dynamic
-------------------------------------
function WaveMgr:spawnEnemy_dynamic(enemy_id, level, appear_type, value1, value2, value3, movement)
    
    local enemy

    -- Enemy 생성
    if isDragon(enemy_id) then
        -- @TODO 드래곤일 경우 등급 및 진화, 친밀도의 데이터도 추가 정리 필요
        enemy = self.m_world:makeDragonNew(StructDragonObject({
            did = enemy_id,
            lv = level + self.m_addLevel,
            grade = 1,
            skill_0 = 1
        }), true)
    else
        enemy = self.m_world:makeMonsterNew(enemy_id, level + self.m_addLevel)
    end

    local rarity = self:getRarity(enemy_id, level)
    local isBoss = (rarity == self.m_highestRarity and self:isFinalWave())

    -- 스테이지별 boss_hp_ratio 적용.
    if (isBoss) then
        if (not self.m_lBoss) then
            self.m_lBoss = {}
        end
        table.insert(self.m_lBoss, enemy)

        local boss_hp_ratio = TableStageData():getValue(self.m_world.m_stageID, 'boss_hp_ratio') or 1
        enemy.m_statusCalc:appendHpRatio(boss_hp_ratio)
        enemy:setStatusCalc(enemy.m_statusCalc)

        self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.BOSS)
    else
        self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
    end
    
    self.m_world.m_physWorld:addObject(PHYS.ENEMY, enemy)
    self.m_world:addEnemy(enemy)

	self.m_world.m_rightFormationMgr:setChangePosCallback(enemy)

	-- 등장 움직임 설정
    if (EnemyAppear[appear_type]) then
        EnemyAppear[appear_type](enemy, value1, value2, value3)
    end

    -- 이동 패턴 설정
    do
        if (not movement) then
            movement = self.m_currWave
        end

        -- 로밍 임시 처리
        if (movement == 'roam') then
            enemy.m_bRoam = true
        elseif (self.m_world.m_enemyMovementMgr) then
            self.m_world.m_enemyMovementMgr:addEnemy(movement, enemy)
        end
    end
    
	return enemy
end

-------------------------------------
-- function update
-------------------------------------
function WaveMgr:update(dt, no_regen)
    if (self.m_waveTimer == -1) then
        self.m_waveTimer = 0
    else
        self.m_waveTimer = self.m_waveTimer + dt
    end

    -- 동적 웨이브들 업데이트
    local t_remove = {}
    for i,v in ipairs(self.m_lDynamicWave) do
        if (v:update(dt) == true) then
            table.insert(t_remove, 1, i)
        end
    end

    -- 완료된 동적 웨이브 삭제
    for i,v in ipairs(t_remove) do
        table.remove(self.m_lDynamicWave, v)
    end

    -- 리젠 웨이브
    if (not no_regen and self.m_isRegenWave) then
        for group_key, struct_group in pairs(self.m_mRegenGroup) do
            local regen_wave = struct_group:update(dt)
            if (regen_wave) then
                struct_group:setInterval(g_constant:get('INGAME', 'REGEN_INTERVAL'))

                self:setDynamicWave(self.m_lDynamicWave, regen_wave, group_key)
            end
        end
    end
end

-------------------------------------
-- function dispatch
-------------------------------------
function WaveMgr:dispatch(event_name, t_event, ...)
    if (event_name == 'change_wave') then
        -- garg[1] = 웨이브
    else
        error('event_name : ' .. event_name)
    end

    return IEventDispatcher.dispatch(self, event_name, t_event, ...)
end

-------------------------------------
-- function isFirstWave
-------------------------------------
function WaveMgr:isFirstWave()
    if (self.m_bDevelopMode) then 
        return true
    end

    return (self.m_currWave == 1)
end

-------------------------------------
-- function isFinalWave
-------------------------------------
function WaveMgr:isFinalWave()
	if (self.m_bDevelopMode) then 
		return false 
	end

    return (self.m_currWave == self.m_maxWave)
end

-------------------------------------
-- function hasRegenWave
-------------------------------------
function WaveMgr:hasRegenWave()
	return self.m_isRegenWave
end

-------------------------------------
-- function isEmptyDynamicWaveList
-------------------------------------
function WaveMgr:isEmptyDynamicWaveList()
    return (#self.m_lDynamicWave == 0)
end

-------------------------------------
-- function getHighestRariry
-------------------------------------
function WaveMgr:getHighestRariry()
    return self.m_highestRarity
end

-------------------------------------
-- function getBossId
-------------------------------------
function WaveMgr:getBossId()
    return self.m_bossId
end

-------------------------------------
-- function getFinalBossInfo
-------------------------------------
function WaveMgr:getFinalBossInfo()
    local t_data = self.m_scriptData['wave'][self.m_maxWave]
    self:newScenario_dynamicWave(t_data)

    return self.m_bossId, self.m_bossLv + self.m_addLevel
end