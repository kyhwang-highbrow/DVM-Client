local PARENT = EnemyLua

-------------------------------------
-- class EnemyLua_Boss
-------------------------------------
EnemyLua_Boss = class(PARENT, {
        m_tCurrPattern = 'table',
        m_currPatternIdx = 'number',
        m_patternWaitTime = 'number',
        
        m_patternAtkIdx = 'number',

        m_patternScriptName = 'string',
        m_triggerHpPercent = 'TriggerHpPercent',

        m_coolTimeTimer = 'number',
        m_coolTimeTime = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function EnemyLua_Boss:init(file_name, body, ...)
end

-------------------------------------
-- function initScript
-------------------------------------
function EnemyLua_Boss:initScript(pattern_script_name)
    self.m_patternScriptName = pattern_script_name

    local script = TABLE:loadJsonTable(pattern_script_name)
    local pattern_list = script[pattern_script_name]

    self.m_tCurrPattern = pattern_list[math_random(1, #pattern_list)]
    self.m_currPatternIdx = 0

    -- HP 트리거 생성
    if script['hp_trriger'] then
        self.m_triggerHpPercent = TriggerHpPercent(self, script['hp_trriger'])
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
end

EnemyLua_Boss.st_attack = PARENT.st_attack

-------------------------------------
-- function initState
-------------------------------------
function EnemyLua_Boss:initState()
    PARENT.initState(self)

    self:addState('attackDelay', EnemyLua_Boss.st_pattern_idle, 'idle', true)
    self:addState('charge', EnemyLua_Boss.st_pattern_idle, 'idle', true)
    self:addState('casting', EnemyLua_Boss.st_casting, 'casting', true)

    self:addState('dying', EnemyLua_Boss.st_dying, 'idle', false, PRIORITY.DYING)
    
    self:addState('pattern_idle', EnemyLua_Boss.st_pattern_idle, 'idle', true)
    self:addState('pattern_wait', EnemyLua_Boss.st_pattern_wait, 'idle', true)
    self:addState('pattern_move', EnemyLua_Boss.st_pattern_move, 'idle', true)
end


-------------------------------------
-- function st_pattern_idle
-------------------------------------
function EnemyLua_Boss.st_pattern_idle(owner, dt)
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
function EnemyLua_Boss.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 효과음
        if owner.m_charTable['rarity'] == 'boss' then
            local difficulty, chapter, stage = parseAdventureID(g_gameScene.m_stageID)
        
            SoundMgr:playEffect('VOICE', string.format('vo_boss%d_die', chapter))
        end
    end

    PARENT.st_dying(owner, dt)
end

-------------------------------------
-- function st_casting
-------------------------------------
function EnemyLua_Boss.st_casting(owner, dt)
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
        if owner.m_charTable['rarity'] == 'boss' then
            local difficulty, chapter, stage = parseAdventureID(g_gameScene.m_stageID)
            local type = math_random(1, 2)

            SoundMgr:playEffect('VOICE', string.format('vo_boss%d_skill_%d', chapter, type))
        end
    end
end

-------------------------------------
-- function st_pattern_wait
-------------------------------------
function EnemyLua_Boss.st_pattern_wait(owner, dt)
    if (owner.m_stateTimer >= owner.m_patternWaitTime) then
        owner:changeState('pattern_idle')
    end

    -- 쿨타임 게이지 적용
    if owner.m_coolTimeTime and (owner.m_coolTimeTimer < owner.m_coolTimeTime) then
        owner.m_coolTimeTimer = (owner.m_coolTimeTimer + dt)

        if (owner.m_coolTimeTimer > owner.m_coolTimeTime) then
            owner.m_coolTimeTimer = owner.m_coolTimeTime
        end
    end
end

-------------------------------------
-- function st_pattern_move
-------------------------------------
function EnemyLua_Boss.st_pattern_move(owner, dt)
    if owner:isOverTargetPos() then
        owner:setPosition(owner.m_targetPosX, owner.m_targetPosY)
        owner:setSpeed(0)
        owner:changeState('pattern_idle')
    end
end

-------------------------------------
-- function getNextPattern
-------------------------------------
function EnemyLua_Boss:getNextPattern()
    local pattern_cnt = #self.m_tCurrPattern

    self.m_currPatternIdx = self.m_currPatternIdx + 1
    if (pattern_cnt < self.m_currPatternIdx) then
        self.m_currPatternIdx = 1

        if (not self.m_triggerHpPercent) or (not self.m_triggerHpPercent) then
            -- 다시 랜덤
            local pattern_script_name = self.m_patternScriptName
            local script = TABLE:loadJsonTable(pattern_script_name)
            local pattern_list = script[pattern_script_name]
            self.m_tCurrPattern = pattern_list[math_random(1, #pattern_list)]
        end
    end

    -- 쿨타이머 설정
    if (self.m_coolTimeTime == nil) then
        local cool_time = 0
        local idx = self.m_currPatternIdx
        while true do
            if (not self.m_tCurrPattern[idx]) then
                break
            end
            local l_str = seperate(self.m_tCurrPattern[idx], ';')

            local type = l_str[1]
            local value_1 = l_str[2]

            if (type == 'w') then
                local _cool = tonumber(value_1) or 1
                cool_time = (cool_time + _cool)
            elseif (type == 'a') then
                break
            end

            idx = (idx + 1)
        end
        self.m_coolTimeTime = cool_time
        self.m_coolTimeTimer = 0
    end

    return self.m_tCurrPattern[self.m_currPatternIdx]
end

-------------------------------------
-- function getAttackAnimationName
-- @param
-------------------------------------
function EnemyLua_Boss:getAttackAnimationName(idx_str)
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
function EnemyLua_Boss:doPattern(pattern)
    --cclog('EnemyLua_Boss:doPattern pattern = ' .. pattern)
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
end

-------------------------------------
-- function setHp
-------------------------------------
function EnemyLua_Boss:setHp(hp)
    PARENT.setHp(self, hp)

    if self.m_triggerHpPercent then
        local percent = (self.m_hp / self.m_maxHp * 100)
        self.m_triggerHpPercent:checkTrigger(percent)
    end
end

-------------------------------------
-- function cancelSkill
-------------------------------------
function EnemyLua_Boss:cancelSkill()
    local b = PARENT.cancelSkill(self)
    
    -- 보스별 음성
    if b and self.m_charTable['rarity'] == 'boss' then
        local difficulty, chapter, stage = parseAdventureID(g_gameScene.m_stageID)
        SoundMgr:stopEffect('VOICE', string.format('vo_boss%d_skill_1', chapter))
        SoundMgr:stopEffect('VOICE', string.format('vo_boss%d_skill_2', chapter))
        SoundMgr:playEffect('VOICE', string.format('vo_boss%d_skill_cancel', chapter))
    end
    
    return b
end