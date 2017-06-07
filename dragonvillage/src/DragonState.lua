local PARENT = Character

-------------------------------------
-- function initState
-------------------------------------
function Dragon:initState()
    PARENT.initState(self)

    self:addState('attack', Dragon.st_attack, 'attack', true)
    self:addState('charge', Dragon.st_charge, 'idle', true)
    self:addState('casting', PARENT.st_casting, 'skill_appear', true)

    self:addState('skillPrepare', Dragon.st_skillPrepare, 'skill_appear', true)
    self:addState('skillAppear', Dragon.st_skillAppear, 'skill_idle', false)
    self:addState('skillIdle', Dragon.st_skillIdle, 'skill_disappear', false)

    self:addState('dead', Dragon.st_dead, nil, nil, PRIORITY.DEAD)
    self:addState('revive', Dragon.st_revive, 'pose_1', false)
    
    self:addState('wait', Dragon.st_wait, 'idle', true)

    -- success
    self:addState('success_pose', Dragon.st_success_pose, 'pose_1', false)
    self:addState('success_move', Dragon.st_success_move, 'idle', true)
end

-------------------------------------
-- function st_attack
-------------------------------------
function Dragon.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        local role_type = owner:getRole()

        -- 패시브 스킬에만 이펙트를 추가
        if (owner.m_charTable['skill_basic'] ~= owner.m_reservedSkillId) then
            local attr = owner:getAttribute()
            local res = 'res/effect/effect_missile_charge/effect_missile_charge.vrp'
            local t_skill = owner:getSkillTable(owner.m_reservedSkillId)
                
            local animator = MakeAnimator(res)
            animator:changeAni('idle_' .. attr, false)
            owner.m_rootNode:addChild(animator.m_node)
            local duration = animator:getDuration()
            animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

            -- 텍스트
            SkillHelper:makePassiveSkillSpeech(owner, t_skill['t_name'])

            -- indie_time 공격시 이벤트
            if (t_skill['chance_type'] == 'indie_time') then
                owner:dispatch('dragon_time_skill', {}, owner)
            end
            
            -- 스킬 게이지 증가
            if (role_type == 'supporter') then
                local t_temp = g_constant:get('INGAME', 'DRAGON_SKILL_ACTIVE_POINT_INCREMENT_VALUE')

                if (t_skill['chance_type'] == 'indie_time') then
                    owner:increaseActiveSkillCool(t_temp['time_skill'])
                else
                    owner:increaseActiveSkillCool(t_temp['passive_skill'])
                end
            end
        else
            -- 스킬 게이지 증가
            if (role_type == 'dealer') then
                local t_temp = g_constant:get('INGAME', 'DRAGON_SKILL_ACTIVE_POINT_INCREMENT_VALUE')
                owner:increaseActiveSkillCool(t_temp['basic_skill'])
            end
        end
    end

    PARENT.st_attack(owner, dt)
end

-------------------------------------
-- function st_charge
-------------------------------------
function Dragon.st_charge(owner, dt)
    if (owner.m_stateTimer == 0) then
        local attr = owner:getAttribute()

        -- 차지 이팩트 재생
        local res = 'res/effect/effect_melee_charge/effect_melee_charge.vrp'
        local animator = MakeAnimator(res)
        animator:changeAni('idle_' .. attr, false)
        animator:setPosition(0, -50)
        owner.m_rootNode:addChild(animator.m_node)
        local duration = animator:getDuration()
        animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

    elseif (owner.m_stateTimer >= 0.5) then
        owner.m_chargeDuration = owner.m_stateTimer
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_skillPrepare
-------------------------------------
function Dragon.st_skillPrepare(owner, dt)
end

-------------------------------------
-- function st_skillAppear
-------------------------------------
function Dragon.st_skillAppear(owner, dt)
    if (owner.m_stateTimer == 0) then	
        owner.m_bEnableSpasticity = false

		-- @LOG : 전체 스킬 사용 횟수
		if (owner.m_bLeftFormation) then
			owner.m_world.m_logRecorder:recordLog('use_skill', 1)
		else
			-- 적 드래곤 (pvp, 인연던전) 체크해야할 경우 추가
		end

        owner:dispatch('dragon_active_skill', {}, owner)
    end
end

-------------------------------------
-- function st_skillIdle
-------------------------------------
function Dragon.st_skillIdle(owner, dt)
    if (owner.m_stateTimer == 0) then
        local active_skill_id = owner:getSkillID('active')
        local t_dragon_skill = TableDragonSkill():get(active_skill_id)
        local motion_type = t_dragon_skill['motion_type']

        -- 변수 초기화
        owner.m_bLuanchMissile = false
        owner.m_bFinishAttack = false
        owner.m_bFinishAnimation = false

        local function attack_cb()
            owner.m_bLuanchMissile = true

            local scale = owner.m_animator:getScale()
            local flip = owner.m_animator.m_bFlip
            local x = owner.m_skillOffsetX * scale
            local y = owner.m_skillOffsetY * scale

            if flip then
                x = -x
            end

            local active_skill_id = owner:getSkillID('active')
            local indicatorData = owner.m_skillIndicator:getIndicatorData()
            indicatorData['highlight'] = true
            
            owner:doSkill(active_skill_id, x, y, indicatorData)
            owner.m_animator:setEventHandler(nil)
            owner.m_bFinishAttack = true

            -- 액티브 스킬 사용 이벤트 발생
            if (owner.m_bLeftFormation) then
                owner:dispatch('hero_active_skill', {}, owner)
            else
                owner:dispatch('enemy_active_skill', {}, owner)
            end
            owner:dispatch('set_global_cool_time_active')

            -- 사운드
            local sound_name = owner:getSoundNameForSkill(owner.m_charTable['type'])
            if sound_name then
                SoundMgr:playEffect('EFFECT', sound_name)
            end
        end

        -- 모션 타입 처리
        if (motion_type == 'instant') then
            owner.m_aiParamNum = nil
            owner:addAniHandler(function()
                owner.m_bFinishAnimation = true

                if (not owner.m_bFinishAttack) then
                    attack_cb()
                end

                owner.m_aiParamNum = 0
            end)
        elseif (motion_type == 'maintain') then
            owner.m_aiParamNum = (owner.m_statusCalc.m_attackTick / 2)
            owner:addAniHandler(function()
                owner.m_bFinishAnimation = true

                if (not owner.m_bFinishAttack) then
                    attack_cb()
                end
            end)
        else
            error('스킬 테이블 motion_type이 ['.. motion_type .. '] 라고 잘못들어갔네요...')
        end

        attack_cb()
        
        -- 캐스팅 게이지
        if owner.m_castingUI then
            owner.m_castingUI:stopAllActions()
        end

        if owner.m_castingSpeechVisual then
            owner.m_castingSpeechVisual:changeAni('success', false)
            owner.m_castingSpeechVisual:registerScriptLoopHandler(function() owner.m_castingNode:setVisible(false) end)
        elseif owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end
    
    elseif (owner.m_aiParamNum and (owner.m_stateTimer >= owner.m_aiParamNum)) then
        if (owner.m_bFinishAttack) then
            if (owner.m_state ~= 'delegate') then
                owner:changeState('attackDelay')
            end
        end
    end
end

-------------------------------------
-- function st_wait
-------------------------------------
function Dragon.st_wait(owner, dt)
    if (owner.m_stateTimer == 0) then
        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end
    end
end

-------------------------------------
-- function st_success_pose
-- @brief success 세레머니
-------------------------------------
function Dragon.st_success_pose(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
            owner.m_animator:changeAni('idle', true)
        end)
    elseif (owner.m_stateTimer >= 2.5) then
        owner:changeState('success_move')
    end
end

-------------------------------------
-- function st_success_move
-- @brief success 세레머니 후 오른쪽으로 퇴장
-------------------------------------
function Dragon.st_success_move(owner, dt)
    if (owner.m_stateTimer == 0) then
        local add_speed = math_random(-2, 2) * 100
        owner:setMove(owner.pos.x + 2000, owner.pos.y, 1500 + add_speed)
        owner:setAfterImage(true)
    end
end

-------------------------------------
-- function st_dead
-------------------------------------
function Dragon.st_dead(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_world:standbyHero(owner)
    end
end

-------------------------------------
-- function st_revive
-- @brief 부활 중인 상태
-------------------------------------
function Dragon.st_revive(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 홈 위치로 즉시 이동시킴
        owner:setPosition(owner.m_homePosX, owner.m_homePosY)

        owner.m_animator:setRotation(90)
        owner.m_animator:runAction(cc.FadeTo:create(0.5, 255))
        
        owner:addAniHandler(function()
            owner:changeState('attackDelay')
        end)
    end
end

-------------------------------------
-- function setWaitState
-------------------------------------
function Dragon:setWaitState(is_wait_state)
    self.m_bWaitState = is_wait_state

    if is_wait_state then
        if isExistValue(self.m_state, 'idle', 'attackDelay') then
            self:changeState('wait')
        end
    else
        if (self.m_state == 'wait') then
            self:changeState('attackDelay')
        end
    end
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function Dragon:changeState(state, forced)
    if self.m_bWaitState then
        if (not isExistValue(state, 'dying', 'dead')) then
            return PARENT.changeState(self, 'wait', true)
        end
    end

    return PARENT.changeState(self, state, forced)
end