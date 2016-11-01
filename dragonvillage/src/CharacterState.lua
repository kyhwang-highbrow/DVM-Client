
-------------------------------------
-- function st_idle
-------------------------------------
function Character.st_idle(owner, dt)
end

-------------------------------------
-- function st_dying
-------------------------------------
function Character.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then

        owner:setSpeed(0)
        if (owner.m_bDead == false) then
            owner:setDead()
        end

        local action = cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.CallFunc:create(function()
            owner:changeState('dead')
        end))
        owner.m_animator:runAction(action)

        owner.m_animator:runAction(cc.RotateTo:create(0.5, -45))

        if owner.m_hpNode then
            owner.m_hpNode:setVisible(false)
        end

        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end
    end
end

-------------------------------------
-- function st_dead
-------------------------------------
function Character.st_dead(owner, dt)
    return true
end

-------------------------------------
-- function st_attack
-------------------------------------
function Character.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then

        owner:dispatch('basic_skill')

        -- 변수 초기화
        owner.m_bLuanchMissile = false
        owner.m_bFinishAttack = false
        owner.m_bFinishAnimation = false

        local function attack_cb(event)
            owner.m_bLuanchMissile = true

            local x, y = 0, 0

            if event then
                local string_value = event['eventData']['stringValue']           
                if string_value and (string_value ~= '') then
                    local l_str = seperate(string_value, ',')
                    if l_str then
                        local scale = owner.m_animator:getScale()
                        local flip = owner.m_animator.m_bFlip
                        
                        x = l_str[1] * scale
                        y = l_str[2] * scale

                        if flip then
                            x = -x
                        end
                    end
                end
            end

            owner.m_attackOffsetX = x
            owner.m_attackOffsetY = y

            owner:doAttack(x, y)
            owner.m_bFinishAttack = true
        end

        -- 에니메이션 종료 시
        owner:addAniHandler(function()
            owner.m_animator:changeAni('idle', true)
            owner.m_bFinishAnimation = true

            if (not owner.m_bLuanchMissile) then
                attack_cb()
            end
        end)

        -- 공격 타이밍이 있을 경우
        owner.m_animator:setEventHandler(attack_cb)

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
        
    elseif (owner.m_bFinishAnimation and owner.m_bFinishAttack) then    
        owner.m_attackAnimaDuration = owner.m_stateTimer
        owner:changeState('attackDelay')
    end
end

-------------------------------------
-- function st_attackDelay
-------------------------------------
function Character.st_attackDelay(owner, dt)
    if owner.m_stateTimer == 0 then
        -- 어떤 스킬을 사용할 것인지 결정
        local skill_id = owner:getBasicAttackSkillID()

        owner:reserveSkill(skill_id)
        owner:calcAttackPeriod()
        
        -- 캐스팅 게이지
        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end
    end

    if (owner.m_attackPeriod <= owner.m_stateTimer) then
        
        if owner.m_reservedSkillCastTime > 0 then
            owner:changeState('casting')
        else
            owner:changeState('charge')
        end
    end
end

-------------------------------------
-- function st_casting
-------------------------------------
function Character.st_casting(owner, dt)
    if owner.m_stateTimer == 0 then
        
        local cast_time = owner.m_reservedSkillCastTime

        -- 캐스팅 게이지
        if owner.m_castingNode then
            owner.m_castingNode:setVisible(true)

            if owner.m_castingUI then
                owner.m_castingUI:stopAllActions()
                owner.m_castingUI:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.DelayTime:create(1),
                    cc.JumpBy:create(0.2, cc.p(0, 0), 20, 1)
                )))
            end

            if owner.m_castingSpeechVisual then
                owner.m_castingSpeechVisual:changeAni('base_appear', false)
                owner.m_castingSpeechVisual:registerScriptLoopHandler(function()
                    owner.m_castingSpeechVisual:changeAni('base_keep', true)
                end)
            end
        end

        -- 캐스팅 이펙트
        do
            if owner.m_castingEffect then
                owner.m_castingEffect:release()
            end

            local offsetX = 60
            if owner.m_animator.m_bFlip then
                offsetX = -offsetX
            end

            local scale = 1
            local rarity = owner.m_charTable['rarity']
            if rarity ~= 'boss' and rarity ~= 'subboss' and rarity ~= 'elite' then
            else
                scale = 2
            end
            
            owner.m_castingEffect = MakeAnimator('res/effect/effect_skillcasting/effect_skillcasting.vrp')
            owner.m_castingEffect:changeAni('idle', false)
            owner.m_castingEffect:setPosition(offsetX, 0)
            owner.m_castingEffect:setScale(scale)
            owner.m_rootNode:addChild(owner.m_castingEffect.m_node)

            local duration = owner.m_castingEffect:getDuration()
            owner.m_castingEffect:setTimeScale(duration / cast_time)

            owner.m_castingEffect:runAction(cc.Sequence:create(
                cc.DelayTime:create(cast_time),
                cc.CallFunc:create(function() owner.m_castingEffect = nil end),
                cc.RemoveSelf:create()
            ))
        end
    end

    if (owner.m_reservedSkillCastTime <= owner.m_stateTimer) then
        if owner.m_tStateFunc['skillAttack'] then
            owner:changeState('skillAttack')
        else
            owner:changeState('attack')
        end
    end

    local percentage = owner.m_stateTimer / owner.m_reservedSkillCastTime * 100

    if owner.m_castingGauge then
        owner.m_castingGauge:setPercentage(percentage)
    end

    if owner.m_castingMarkGauge then
        owner.m_castingMarkGauge:setPercentage(percentage)
    end
end

-------------------------------------
-- function st_delegate
-------------------------------------
function Character.st_delegate(owner, dt)

end

-------------------------------------
-- function st_comeback
-------------------------------------
function Character.st_comeback(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:setMove(owner.m_homePosX, owner.m_homePosY, 800)
    
    elseif (not owner.m_isOnTheMove) then
        owner:changeState(owner.m_comebackNextState)
        owner.m_comebackNextState = nil
    end
end

-------------------------------------
-- function st_stun
-------------------------------------
function Character.st_stun(owner, dt)
	if owner.m_stateTimer == 0 then
		owner:setSpeed(0)

        -- 캐스팅 게이지
        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end
	end
end

-------------------------------------
-- function st_stun_esc
-------------------------------------
function Character.st_stun_esc(owner, dt)
	if owner.m_stateTimer == 0 then
        owner:changeStateWithCheckHomePos('attackDelay', true)
	end
end