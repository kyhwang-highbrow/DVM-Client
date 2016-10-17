
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
        owner:calcAttackPeriod()
    end

    if (owner.m_attackPeriod <= owner.m_stateTimer) then
        owner:changeState('attack')
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