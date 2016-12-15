local PARENT = Monster

-------------------------------------
-- class MonsterLua_Boss
-------------------------------------
MonsterLua_Boss = class(PARENT, {
        m_tOrgPattern = 'table',    -- 반복되어서 수행될 패턴 리스트
        m_tCurrPattern = 'table',
        m_currPatternIdx = 'number',
        m_patternWaitTime = 'number',
        
        m_patternAtkIdx = 'number',

        m_patternScriptName = 'string',
        m_triggerHpPercent = 'TriggerHpPercent',
        m_triggerTime = 'TriggerTime',

        m_patternTime = 'number',

        m_tEffectSound = 'table',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MonsterLua_Boss:init(file_name, body, ...)
    self.m_patternTime = 0
    self.m_tEffectSound = {}
end

-------------------------------------
-- function initScript
-------------------------------------
function MonsterLua_Boss:initScript(pattern_script_name, is_boss)
    self.m_patternScriptName = pattern_script_name

    local script = TABLE:loadJsonTable(pattern_script_name)
    
    self.m_tOrgPattern = self:getBasePatternList()
    self.m_tCurrPattern = self.m_tOrgPattern
    self.m_currPatternIdx = 0

    -- HP 트리거 생성
    if script['hp_trriger'] then
        self.m_triggerHpPercent = TriggerHpPercent(self, clone(script['hp_trriger']))
    end

    -- 타임 트리거 생성
    if script['time_trriger'] then
        self.m_triggerTime = TriggerTime(self, clone(script['time_trriger']))
    end

    -- 애니메이션 믹스 설정
    if script['ani_mix'] then
        for _, string_value in pairs(script['ani_mix']) do
            local l_str = seperate(string_value, ';')
            local aniName1 = l_str[1]
            local aniName2 = l_str[2]
            local time = l_str[3]
            
            self.m_animator.m_node:setMix(aniName1, aniName2, time)
        end
    end

    -- 이펙트 사운드 설정
    if script['sound'] then
        self.m_tEffectSound = script['sound']

    -- 모험모드일 경우 보스 사운드 자동 설정
    elseif is_boss and g_gameScene:isAdventureMode() then
        local difficulty, chapter, stage = parseAdventureID(g_gameScene.m_stageID)
        
        self.m_tEffectSound['skill_1'] = string.format('vo_boss%d_skill_1', chapter)
        self.m_tEffectSound['skill_2'] = string.format('vo_boss%d_skill_2', chapter)
        self.m_tEffectSound['skill_cancel'] = string.format('vo_boss%d_skill_cancel', chapter)
        self.m_tEffectSound['die'] = string.format('vo_boss%d_die', chapter)
    end
end

-------------------------------------
-- function initSound
-------------------------------------
function MonsterLua_Boss:initSound()
    
end


MonsterLua_Boss.st_attack = PARENT.st_attack

-------------------------------------
-- function initState
-------------------------------------
function MonsterLua_Boss:initState()
    PARENT.initState(self)

    self:addState('attackDelay', MonsterLua_Boss.st_pattern_idle, 'idle', true)
    self:addState('charge', MonsterLua_Boss.st_pattern_idle, 'idle', true)
    self:addState('casting', MonsterLua_Boss.st_casting, 'casting', true)

    self:addState('dying', MonsterLua_Boss.st_dying, 'idle', false, PRIORITY.DYING)
    
    self:addState('pattern_idle', MonsterLua_Boss.st_pattern_idle, 'idle', true)
    self:addState('pattern_wait', MonsterLua_Boss.st_pattern_wait, 'idle', true)
    self:addState('pattern_move', MonsterLua_Boss.st_pattern_move, 'idle', true)
end

-------------------------------------
-- function update
-------------------------------------
function MonsterLua_Boss:update(dt)
    if (self.m_state == 'pattern_idle' or self.m_state == 'pattern_wait' or self.m_state == 'pattern_move') then
        self.m_patternTime = self.m_patternTime + dt
        --cclog('self.m_patternTime = ' .. self.m_patternTime)
    
        if self.m_triggerTime then
            self.m_triggerTime:checkTrigger(self.m_patternTime)
        end
    end
    
    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_pattern_idle
-------------------------------------
function MonsterLua_Boss.st_pattern_idle(owner, dt)
    if owner.m_stateTimer == 0 then
        
        -- 캐스팅 게이지
        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end

        local pattern = owner:getNextPattern()
        owner:doPattern(pattern)
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function MonsterLua_Boss.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 효과음
        if owner.m_tEffectSound['die'] then
            SoundMgr:playEffect('VOICE', owner.m_tEffectSound['die'])
        end
    end

    PARENT.st_dying(owner, dt)
end

-------------------------------------
-- function st_casting
-------------------------------------
function MonsterLua_Boss.st_casting(owner, dt)
    PARENT.st_casting(owner, dt)

    if owner.m_state == 'casting' and owner.m_stateTimer == 0 then
        local eventList = owner.m_animator:getEventList('casting', 'casting')
        local eventData = eventList[1]
        if eventData then
            local string_value = eventData['stringValue']           
            if string_value and (string_value ~= '') then
                local l_str = seperate(string_value, ',')
                if l_str then
                    local scale = owner.m_animator:getScale()
					local flip = owner.m_animator.m_bFlip
                        
					local x = l_str[1] * scale
					local y = l_str[2] * scale

					if flip then
						x = -x
					end

                    if owner.m_castingEffect then
                        owner.m_castingEffect:setPosition(x, y)
                    end
                end
            end
        end

        -- 효과음
        local type = math_random(1, 2)

        if owner.m_tEffectSound['skill_' .. type] then
            SoundMgr:playEffect('VOICE', owner.m_tEffectSound['skill_' .. type])
        end
    end
end

-------------------------------------
-- function st_pattern_wait
-------------------------------------
function MonsterLua_Boss.st_pattern_wait(owner, dt)
    if (owner.m_stateTimer >= owner.m_patternWaitTime) then
        owner:changeState('pattern_idle')
    end
end

-------------------------------------
-- function st_pattern_move
-------------------------------------
function MonsterLua_Boss.st_pattern_move(owner, dt)
    if owner:isOverTargetPos() then
        owner:setPosition(owner.m_targetPosX, owner.m_targetPosY)
        owner:setSpeed(0)
        owner:changeState('pattern_idle')
    end
end

-------------------------------------
-- function getNextPattern
-------------------------------------
function MonsterLua_Boss:getNextPattern()
    local pattern_cnt = #self.m_tCurrPattern

    self.m_currPatternIdx = self.m_currPatternIdx + 1
    if (pattern_cnt < self.m_currPatternIdx) then
        self.m_currPatternIdx = 1

        if (not self.m_triggerHpPercent) then
            -- 다시 랜덤
            self.m_tOrgPattern = self:getBasePatternList()
        end

        self.m_tCurrPattern = self.m_tOrgPattern
    end

    local pattern_info = self.m_tCurrPattern[self.m_currPatternIdx]
    return pattern_info['pattern']
end

-------------------------------------
-- function getAttackAnimationName
-- @param
-------------------------------------
function MonsterLua_Boss:getAttackAnimationName(idx_str)
    local default_ani = 'attack'
    local skill_id = self.m_charTable['skill_' .. idx_str]

    -- 테이블 정보 가져옴
    local table_name = self.m_charType .. '_skill'
    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    local animation_name = t_skill['animation']
    if (not animation_name) then
        return default_ani
    end

    if (animation_name == 'x') then
        return default_ani
    end

    return animation_name
end

-------------------------------------
-- function doPattern
-- @param idx
-------------------------------------
function MonsterLua_Boss:doPattern(pattern)
    local l_str = seperate(pattern, ';')

    local type = l_str[1]
    local value_1 = l_str[2]
    local value_2 = l_str[3]

    -- 공격 명령
    if (type == 'a') then
        self.m_patternAtkIdx = value_1

        -- 에니메이션 변경
        self.m_tStateAni['attack'] = self:getAttackAnimationName(self.m_patternAtkIdx)

        -- 스킬 예약
        local skill_id = self.m_charTable['skill_' .. self.m_patternAtkIdx]
        self:reserveSkill(skill_id)

        if self.m_reservedSkillCastTime > 0 then
            self:changeState('casting')
        else
            self:changeState('attack')
        end

    -- 이동 명령
    elseif (type == 'm') then
        local speed = 300
        if value_2 then
            speed = tonumber(value_2)
        end
        local pos = getEnemyPos(value_1)
        
        self:setTargetPos(pos['x'], pos['y'])
		self:setHomePos(pos['x'], pos['y'])
        self:setSpeed(speed)
        self:changeState('pattern_move')

    -- 대기 명령
    elseif (type == 'w') then
        local wait_time = nil
        if value_1 then
            wait_time = tonumber(value_1)
        else
            wait_time = (math_random(100, 200) / 100)
        end
        self.m_patternWaitTime = wait_time
        self:changeState('pattern_wait')

    else
        error()
    end

	if PRINT_BOSS_PATTERN then 
		self:printBossPattern(pattern, type, value_1)
	end
end

-------------------------------------
-- function setHp
-------------------------------------
function MonsterLua_Boss:setHp(hp)
    PARENT.setHp(self, hp)

    if self.m_triggerHpPercent then
        local percent = (self.m_hp / self.m_maxHp * 100)
        self.m_triggerHpPercent:checkTrigger(percent)
    end
end

-------------------------------------
-- function cancelSkill
-------------------------------------
function MonsterLua_Boss:cancelSkill()
    local b = PARENT.cancelSkill(self)
    
    -- 보스별 음성
    if b then
        if self.m_tEffectSound['skill_cancel'] then
            if self.m_tEffectSound['skill_1'] then
                SoundMgr:stopEffect('VOICE', self.m_tEffectSound['skill_1'])
            end
            if self.m_tEffectSound['skill_2'] then
                SoundMgr:stopEffect('VOICE', self.m_tEffectSound['skill_2'])
            end
            
            SoundMgr:playEffect('VOICE', self.m_tEffectSound['skill_cancel'])
        end
    end
    
    return b
end

-------------------------------------
-- function getBasePatternList
-- @brief 기본 패턴 리스트를 얻음(기본 패턴 리스트가 다수일 경우 랜덤하게 하나만 가져옴)
-------------------------------------
function MonsterLua_Boss:getBasePatternList()
    local pattern_script_name = self.m_patternScriptName
    local script = TABLE:loadJsonTable(pattern_script_name)
    local pattern_list_set = script[pattern_script_name]
    local pattern_list = pattern_list_set[math_random(1, #pattern_list_set)]
    local ret = {}

    for i, pattern in ipairs(pattern_list) do
        local pattern_info = {
            priority = 0,
            pattern = pattern
        }

        table.insert(ret, pattern_info)
    end
    
    return ret
end

-------------------------------------
-- function printBossPattern
-------------------------------------
function MonsterLua_Boss:printBossPattern(pattern, type, value_1)
	local boss_name = self.m_charTable['t_name']
	local add_str = ''
	if (type == 'a') then
		local skill_id = self.m_charTable['skill_' .. value_1]
		local table_name = self.m_charType .. '_skill'
		local table_skill = TABLE:get(table_name)
		local t_skill = table_skill[skill_id]
		add_str = t_skill['t_name']
	end
	cclog(boss_name .. ' pattern = ' .. pattern .. ' ' .. add_str)
end