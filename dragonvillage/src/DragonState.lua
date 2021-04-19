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

    self:addState('wait', Dragon.st_wait, 'idle', true)

    -- success
    self:addState('success_pose', Dragon.st_success_pose, 'pose_1', false, PRIORITY.SUCCESS_POSE)
    self:addState('success_move', Dragon.st_success_move, 'idle', true, PRIORITY.SUCCESS_POSE)
end

-------------------------------------
-- function st_attack
-------------------------------------
function Dragon.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 타겟이 미리 검사하여 없다면 스킬을 취소시킴(쿨타임은 이미 돈 상태)
        do
            local skill_id = owner.m_reservedSkillId
            local t_skill = owner:getSkillTable(skill_id)

            if (not owner:checkTarget(t_skill)) then
                -- 타겟이 없다면 스킬을 취소시킴
                owner:reserveSkill(nil)
                owner:changeState('attackDelay')

                return
            end
        end

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

        end
    end

    PARENT.st_attack(owner, dt)
end

-------------------------------------
-- function st_charge
-------------------------------------
function Dragon.st_charge(owner, dt)
    if (owner.m_stateTimer == 0) then
        if (owner.m_chargeEffect) then
            local attr = owner:getAttribute()

            owner.m_chargeEffect:setVisible(true)
            owner.m_chargeEffect:changeAni('idle_' .. attr, false)
        else
            owner:changeState('attack')
        end

    --[[
    elseif (owner.m_chargeDuration >= owner.m_attackPeriod) then
        -- 공속이 준비보다 빠르다면?
        owner:changeState('attack')]]

    elseif (owner.m_stateTimer >= owner.m_chargeDuration) then
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
    local world = owner.m_world

    if (owner:getStep() == 0) then
        -- 경직 불가능 상태 설정
        owner.m_bEnableSpasticity = false

		-- @LOG : 전체 스킬 사용 횟수
		if (owner.m_bLeftFormation) then
			owner.m_world.m_logRecorder:recordLog('use_skill', 1)
		else
			-- 적 드래곤 (pvp, 인연던전) 체크해야할 경우 추가
		end

        -- 액티브 스킬 사용 이벤트 발생
        do
            owner:dispatch('dragon_active_skill', {}, owner)

            if (owner.m_bLeftFormation) then
                owner:dispatch('hero_active_skill', {}, owner)
            else
                owner:dispatch('enemy_active_skill', {}, owner)
            end
        end

        --
        if (PLAYER_VERSUS_MODE[owner.m_world.m_gameMode] == 'pvp') then
            if (g_settingData:get('colosseum_test_mode')) then
                owner:changeState('skillIdle')
            end
        end
        
        owner:nextStep()
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

            local indicatorData = owner:getSkillIndicator():getIndicatorData()
                        
            owner:doSkill(active_skill_id, x, y, indicatorData)

            owner.m_animator:setEventHandler(nil)
            owner.m_bFinishAttack = true
        end

        -- 모션 타입 처리
        if (motion_type == 'instant') then
            owner.m_aiParamNum = nil
            owner:addAniHandler(function()
                owner.m_bFinishAnimation = true
                owner.m_aiParamNum = 0
            end)
        elseif (motion_type == 'maintain') then
            owner.m_aiParamNum = (owner.m_statusCalc.m_attackTick / 2)
            owner:addAniHandler(function()
                owner.m_bFinishAnimation = true
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

        owner.m_animator:setRotation(90)
    
    elseif (owner.m_aiParamNum and (owner.m_stateTimer >= owner.m_aiParamNum)) then
        if (owner.m_bFinishAttack) then
            if (owner.m_state ~= 'delegate') then
                -- GameDragonSkill에서 연출 종료후 attackDelay로 변경됨
                owner:changeState('wait')
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
        owner:setMove(owner.pos.x + 2500, owner.pos.y, 1500 + add_speed)
        owner:setAfterImage(true)
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
    if (self.m_bWaitState) then
        if (not isExistValue(state, 'dying', 'dead')) then
            return PARENT.changeState(self, 'wait', true)
        end
    end

    if (not forced) then
        if (state == 'attackDelay' and self.m_state == 'skillPrepare') then
            return false
        end
    end

    return PARENT.changeState(self, state, forced)
end