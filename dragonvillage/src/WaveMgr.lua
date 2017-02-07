-------------------------------------
-- class WaveMgr
-------------------------------------
WaveMgr = class(IEventDispatcher:getCloneClass(), {
        m_world = 'GameWorld',
        m_currWave = 'number',
        m_maxWave = 'number',
        m_scriptData = 'table',

        m_waveTimer = 'number', -- 현재 웨이브의 흘러간 시간
        m_lDynamicWave = '',
		m_lSummonWave = '',

        m_stageName = '',
        m_bDevelopMode = '',
        
        m_highestRarity = 'number',     -- 하나의 웨이브 안에서 가장 높은 rarity
    })

-------------------------------------
-- function init
-------------------------------------
function WaveMgr:init(world, stage_name, develop_mode)
    self.m_world = world

    self.m_stageName = stage_name
	
    -- 파일에서 웨이브 정보를 얻어옴
    local script = TABLE:loadJsonTable(stage_name)
    self.m_scriptData = script

    self.m_currWave = 0
    self.m_maxWave = 0
    self.m_waveTimer = -1
    self.m_lDynamicWave = {}
	self.m_lSummonWave = {}

    self.m_bDevelopMode = develop_mode or (stage_name == 'stage_dev') or false

    if self.m_scriptData then
        if (self.m_scriptData['wave']) then
            self.m_maxWave = #self.m_scriptData['wave']
        end
        
        -- 소환 몬스터 정보
	    self:setSummonData(self.m_scriptData)
    end

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
-- function summonWave
-------------------------------------
function WaveMgr:summonWave(idx)
	-- summon 스크립트가 없으면 false
	if (not self.m_lSummonWave[idx]) then
		return false
	end
	
	-- enemy list를 순회하면서 소환하려는 위치에 몬스터가 없는 곳에 소환
	local enemy_pos, dest_pos = nil, nil
	local isSummonable = true
	for _, dynamic_wave in pairs(self.m_lSummonWave[idx]) do
		dest_pos = getEnemyPos(dynamic_wave.m_luaValue2)
		isSummonable = true
		
		-- 소환 가능한지 체크한다.
		for _, enemy in pairs(self.m_world:getEnemyList()) do
			enemy_pos = enemy['pos']
			if (enemy_pos['x'] == dest_pos['x']) and (enemy_pos['y'] == dest_pos['y']) then
				isSummonable = false	
				break
			end
		end

		-- 소환
		if isSummonable then 
			self:summonEnemy(dynamic_wave)
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

        -- 웨이브 변경 시 골드 제거
        self.m_world:clearGold()
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
    if (not t_data['wave']) then
        return
    end

    self.m_lDynamicWave = {}
    self.m_highestRarity = 'common'

    local table_enemy = TableMonster()
    
    for i, v in pairs(t_data['wave']) do
        for _, data in pairs(v) do
            local dynamic_wave = DynamicWave(self, data, i)
            table.insert(self.m_lDynamicWave, dynamic_wave)

            -- 마지막 웨이브에서는 최대 등급을 가진 적을 찾음
            if isMonster(dynamic_wave.m_enemyID) then
                local t_enemy = table_enemy:get(dynamic_wave.m_enemyID)
                local rarity = t_enemy['rarity']
                
                if monsterRarityStrToNum(rarity) > monsterRarityStrToNum(self.m_highestRarity) then
                    self.m_highestRarity = rarity
                end
            end
        end
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
	                        
    self.m_world.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.UNIT)
    self.m_world.m_physWorld:addObject(PHYS.ENEMY, enemy)
    self.m_world:addEnemy(enemy)

	enemy:setAddPhysObject()

    self.m_world.m_rightFormationMgr:setChangePosCallback(enemy)

	-- 패시브 실행
	local l_passive = enemy.m_lSkillIndivisualInfo['passive']
    for i,skill_info in pairs(l_passive) do
        local skill_id = skill_info.m_skillID
        enemy:doSkill(skill_id, 0, 0)
    end

    -- 등장 움직임 설정
    if (EnemyAppear[appear_type]) then
        EnemyAppear[appear_type](enemy, value1, value2, value3)
    end

    -- 이동 패턴 설정
    if (self.m_world.m_enemyMovementMgr) then
        if (not movement) then
            movement = self.m_currWave
        end

        self.m_world.m_enemyMovementMgr:addEnemy(movement, enemy)
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