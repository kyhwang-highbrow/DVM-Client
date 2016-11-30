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
    self.m_maxWave = #self.m_scriptData['wave']
    self.m_waveTimer = -1
    self.m_lDynamicWave = {}
	self.m_lSummonWave = {}

    self.m_bDevelopMode = develop_mode or (stage_name == 'stage_dev') or false

    -- 소환 몬스터 정보
	self:setSummonData(script)
end

-------------------------------------
-- function getScriptData
-------------------------------------
function WaveMgr:getScriptData()

    -- 파일에서 웨이브 정보를 얻어옴
    --if (not self.m_scriptData) then
        local script = TABLE:loadJsonTable(self.m_stageName)
        self.m_scriptData = script
    --end

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
	for _, dynamic_wave in pairs(self.m_lSummonWave[idx]) do
		self:spawnEnemy_dynamic(
			dynamic_wave.m_enemyID, 
			dynamic_wave.m_enemyLevel, 
			dynamic_wave.m_movement,
			dynamic_wave.m_luaValue1,
			dynamic_wave.m_luaValue2,
			dynamic_wave.m_luaValue3,
			dynamic_wave.m_luaValue4,
			dynamic_wave.m_luaValue5
			)
	end
end

-------------------------------------
-- function checkSummonable
-------------------------------------
function WaveMgr:checkSummonable(idx)
	-- summon 스크립트가 없으면 false
	if (not self.m_lSummonWave[idx]) then
		return false
	end

	-- enemy list를 순회하면서 소환하려는 위치에 몬스터가 있는지 체크
	for _, enemy in pairs(self.m_world:getEnemyList()) do
		local enemy_pos = enemy['pos']
		for _, dynamic_wave in pairs(self.m_lSummonWave[idx]) do
			local dest_pos = getEnemyPos(dynamic_wave.m_luaValue2)
			if (enemy_pos['x'] == dest_pos['x']) and (enemy_pos['y'] == dest_pos['y']) then
				return false
			end
		end
	end

	return true
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
	end

    self:newScenario_dynamicWave(t_data)

    self:dispatch('change_wave', self.m_currWave)
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
    
    for i, v in pairs(t_data['wave']) do
        for _, data in pairs(v) do
            local dynamic_wave = DynamicWave(self, data, i)
            table.insert(self.m_lDynamicWave, dynamic_wave)

            -- 마지막 웨이브에서는 최대 등급을 가진 적을 찾음
            local t_enemy = TABLE:get('enemy')[dynamic_wave.m_enemyID]
            local rarity = t_enemy['rarity']
                
            if monsterRarityStrToNum(rarity) > monsterRarityStrToNum(self.m_highestRarity) then
                self.m_highestRarity = rarity
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
function WaveMgr:spawnEnemy_dynamic(enemy_id, level, movement, value1, value2, value3, value4, value5)

    local table_enemy = TABLE:get('enemy')
    local t_enemy = table_enemy[enemy_id]

    if (not t_enemy) then
        error(tostring('다음 ID는 존재하지 않습니다 : ' .. enemy_id))
    end

    local body = {0, 0, 50}

    -- 사이즈 타입별 피격박스 반지름 변경
    local size_type = t_enemy['size_type']
    if (size_type == 's') then
        body[3] = 30
    elseif (size_type == 'm') then
        body[3] = 40
    elseif (size_type == 'l') then
        body[3] = 60
    elseif (size_type == 'xl') then
        body[3] = 100
	elseif (size_type == 'xxl') then
        body[3] = 200
    end

    -- 난이도별 레벨 설정
    local t_drop = TABLE:get('drop')[self.m_world.m_stageID]
    local level = level + t_drop['level']
    
    local scale = 1
    local offset_y = (body[3] * 1.5)
    local hp_ui_offset = {0, -offset_y}
    local animator_scale = t_enemy['scale'] or 1

    -- Enemy 생성
    local enemy = self:tryPatternEnemy(t_enemy, body)
    if (not enemy) then
        enemy = EnemyLua(t_enemy['res'], body)
        enemy:initAnimatorMonster(t_enemy['res'], t_enemy['attr'])
    end

    self.m_world:initEnemyClass(enemy)
    enemy:initLuaValue(value1, value2, value3, value4, value5)
    enemy:initDragonSkillManager('enemy', enemy_id, 6) -- monster는 skill_1~skill_6을 모두 사용
    enemy:initState()
    enemy:initStatus(t_enemy, level)
    enemy:changeState('move')

    -- 죽음 콜백 등록
    enemy:addListener('character_dead', self.m_world)

    -- 등장 완료 콜백 등록
    enemy:addListener('enemy_appear_done', self.m_world.m_gameState)

    -- 스킬 캐스팅 중 취소시 콜백 등록
    enemy:addListener('character_casting_cancel', self.m_world.m_tamerSpeechSystem)
    enemy:addListener('character_casting_cancel', self.m_world.m_gameFever)

    enemy.m_animator.m_node:setScale(animator_scale)
    enemy.m_animator:setFlip(true)

    self.m_world.m_worldNode:addChild(enemy.m_rootNode, 1)
    self.m_world:addToUnitList(enemy)
    enemy:makeHPGauge(hp_ui_offset)

    enemy:setPosition(1000, 0)
    self.m_world.m_physWorld:addObject('enemy', enemy)

    enemy:addDefCallback(function(attacker, defender, i_x, i_y)
        enemy:undergoAttack(attacker, defender, i_x, i_y, 0)
    end)

	-- 패시브 실행
	local l_passive = enemy.m_lSkillIndivisualInfo['passive']
    for i,skill_info in pairs(l_passive) do
        local skill_id = skill_info.m_skillID
        enemy:doSkill(skill_id, nil, 0, 0)
    end

    if EnemyLua[movement] then
        EnemyLua[movement](enemy)
    end
end

-------------------------------------
-- function tryPatternEnemy
-- @brief 패턴을 가진 적군
-- ex) 'pattern_' + rarity + type
--     'pattern_boss_queenssnake'
-------------------------------------
function WaveMgr:tryPatternEnemy(t_enemy, body)
    local rarity = t_enemy['rarity']
    local type = t_enemy['type']
    local script_name = 'pattern_' .. rarity .. '_' .. type    

    -- 임시 구현
    if (type == 'giantdragon') then
        local enemy = Monster_GiantDragon(t_enemy['res'], body)
        enemy:initAnimatorMonster(t_enemy['res'], t_enemy['attr'])
        enemy:initScript(script_name)

        return enemy
    end

    -- 테이블이 없을 경우 return
    local script = TABLE:loadJsonTable(script_name)
	local is_pattern_ignore = (t_enemy['pattern'] == 'ignore')
	
    if (not script) or is_pattern_ignore then
        return nil
    end

    local enemy = EnemyLua_Boss(t_enemy['res'], body)
    enemy:initAnimatorMonster(t_enemy['res'], t_enemy['attr'])
    enemy:initScript(script_name)

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
function WaveMgr:dispatch(event_name, ...)
    if (event_name == 'change_wave') then
        -- garg[1] = 웨이브
    else
        error('event_name : ' .. event_name)
    end

    return IEventDispatcher.dispatch(self, event_name, ...)
end

-------------------------------------
-- function isFirstWave
-------------------------------------
function WaveMgr:isFirstWave()
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