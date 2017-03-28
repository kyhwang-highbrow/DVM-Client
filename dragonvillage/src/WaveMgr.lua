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
        
        m_highestRarity = 'number',     -- 하나의 웨이브 안에서 가장 높은 rarity

		-- regen 전용
		m_regenWaveData = 'table',	-- 리젠 테이블 저장
		m_regenCoolTime = 'num',	-- 리젠 주기 (constant.json에서 제어)
        m_regenTimer = 'number',	-- 리젠 체크용 시간 체크
		m_lRegenWave = 'list',		-- 리젠 DynamicWave 저장
		m_isRegenWave = 'bool',		-- regen Wave 가 있는지 여부
		m_mRegenObjMap = 'Map<obj>' -- regen 으로 생성된 몬스터의 phys_idx 맵
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr:init(world, stage_name, develop_mode)
    self.m_world = world

    self.m_stageName = stage_name
	
    -- 파일에서 웨이브 정보를 얻어옴
    local script = TABLE:loadJsonTable(stage_name)
    if (not script) then
        error('script is nil : ' .. stage_name)
    end

	-- 멤버 변수
    self.m_scriptData = script

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
	self.m_isRegenWave = false
	self.m_regenWaveData = nil
	self.m_lRegenWave = {}
	self.m_mRegenObjMap = {}

	self.m_regenCoolTime = g_constant:get('INGAME', 'REGEN_INTERVAL')
	self.m_regenTimer = 0

    -- 리스너 등록
    self:addListener('change_wave', self.m_world)
end

-------------------------------------
-- function getScriptData
-------------------------------------
function WaveMgr:getScriptData()

    -- 파일에서 웨이브 정보를 얻어옴
    if (not self.m_scriptData) then
        local script = TABLE:loadJsonTable(self.m_stageName)
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
-- function checkRegenable
-- @brief 리젠 가능 여부
-------------------------------------
function WaveMgr:checkRegenable(idx_key)
	return not self.m_mRegenObjMap[idx_key]
end

-------------------------------------
-- function setRegenDead
-- @brief 
-------------------------------------
function WaveMgr:setRegenDead(idx_key)
	self.m_mRegenObjMap[idx_key] = false
end

-------------------------------------
-- function setDynamicWave
-- @brief script를 읽어 dynamic wave를 저장
-------------------------------------
function WaveMgr:setDynamicWave(l_wave, l_data, is_regen_wave)
	if not (l_data) then
		return 
	end

	for time, v in pairs(l_data) do
		for idx, data in pairs(v) do
			-- dynamic wave 생성 및 저장
			local dynamic_wave = nil
			
			if (is_regen_wave) then
				-- regen wave라면 무조건 0초로 등록하고 regen 정보를 저장한다.
				dynamic_wave = DynamicWave(self, data, 0)
				dynamic_wave:setRegenWaveInfo({idx = idx, time = time})
			else
				dynamic_wave = DynamicWave(self, data, time)
			end
			
			table.insert(l_wave, dynamic_wave)
		end
	end

end

-------------------------------------
-- function newScenario
-------------------------------------
function WaveMgr:newScenario()

    -- 개발모드일 경우
    if (self.m_bDevelopMode == true) then
        -- 파일에서 웨이브 정보를 얻어옴
        local script = TABLE:loadJsonTable(self.m_stageName)
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

    -- TODO 160504
    do -- 웨이브 진행 정도
        local percent = ((wave / self.m_maxWave) * 100)
        g_gameScene.m_inGameUI.vars['stageGauge']:runAction(cc.ProgressTo:create(0.1, percent))
    end
    
    if (not self.m_scriptData['wave'][wave]) then
        -- 다음 웨이브가 없다는 뜻(스테이지 클리어를 의미)
        return false
    end

    local t_data = self.m_scriptData['wave'][wave]
	
	if (wave == 1) or (self.m_bDevelopMode == true) then 
		-- 카메라 옵션 설정
        self.m_world:changeCameraOption(t_data['camera'])
        self.m_world:changeHeroHomePosByCamera()
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
    self.m_highestRarity = 'common'

    -- wave 정보를 읽어 dynamic wave 세팅
	self:setDynamicWave(self.m_lDynamicWave, t_data['wave'], false)

	-- 이전에 저장된 regen 데이터가 있으면 초기화 시킴
	if (self.m_regenWaveData) then
		self.m_isRegenWave = false
		self.m_regenWaveData = nil
		self.m_lRegenWave = {}
		self.m_mRegenObjMap = {}
	end

	-- regen에 정보가 있다면 해당 몹을 지속적으로 소환하도록 세팅.
	if (t_data['regen']) then
		self.m_isRegenWave = true
		self.m_regenWaveData = t_data['regen']
		self:setDynamicWave(self.m_lRegenWave, self.m_regenWaveData, true)
	end
end

-------------------------------------
-- function findHighestRarity
-- @brief 최대 등급을 갱신한다.
-------------------------------------
function WaveMgr:checkHighestRarity(monster)
	local rarity = monster:getRarity()
	if monsterRarityStrToNum(rarity) > monsterRarityStrToNum(self.m_highestRarity) then
		self.m_highestRarity = rarity
	end
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
    if isMonster(enemy_id) then
        enemy = self.m_world:makeMonsterNew(enemy_id, level)

    elseif isDragon(enemy_id) then
        -- @TODO 드래곤일 경우 등급 및 진화, 친밀도의 데이터도 추가 정리 필요
        enemy = self.m_world:makeDragonNew({
            did = enemy_id,
            lv = level,
            skill_0 = 1
        }, true)
    end
	                        
    self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
    self.m_world.m_physWorld:addObject(PHYS.ENEMY, enemy)
    self.m_world:addEnemy(enemy)

	enemy:setAddPhysObject()

    self.m_world.m_rightFormationMgr:setChangePosCallback(enemy)

	-- 등장 움직임 설정
    if (EnemyAppear[appear_type]) then
        EnemyAppear[appear_type](enemy, value1, value2, value3)
    end

    -- 이동 패턴 설정
    if (self.m_world.m_enemyMovementMgr) then
        if (not movement) then
            movement = self.m_currWave
        end

        -- 로밍 임시 처리
        if (movement == 'roam') then
            enemy.m_bRoam = true
        else
            self.m_world.m_enemyMovementMgr:addEnemy(movement, enemy)
        end
    end

	if enemy and enemy.m_hpNode then
        enemy.m_hpNode:setVisible(true)
    end

	-- 마지막 웨이브인 경우 최대 등급 찾음
	if (self:isFinalWave()) then
		self:checkHighestRarity(enemy)
	end

	return enemy
end

-------------------------------------
-- function update
-------------------------------------
function WaveMgr:update(dt)
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
end

-------------------------------------
-- function update_regen
-------------------------------------
function WaveMgr:update_regen(dt)
	self.m_regenTimer = self.m_regenTimer + dt
	
	if (self.m_regenTimer > self.m_regenCoolTime) then
		-- 리젠 웨이브 업데이트
		for i, dynamic_wave in ipairs(self.m_lRegenWave) do
			-- 소환 (일반 웨이브와 다르게 위치 기반한 소환여부 체크)
			if (self:checkRegenable(i)) then
				dynamic_wave:update(dt)
				self.m_mRegenObjMap[i] = true
			end
		end

		-- 리젠 웨이브 삭제 (전부 삭제한다)
		self.m_lRegenWave = {}

		-- 리젠 웨이브 다시 생성
		self.m_regenTimer = self.m_regenTimer - self.m_regenCoolTime
		if (self.m_regenWaveData) then
			self:setDynamicWave(self.m_lRegenWave, self.m_regenWaveData, true)
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