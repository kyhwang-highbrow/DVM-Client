-------------------------------------
-- function initState
-------------------------------------
function Character:initState()
    self:addState('idle', Character.st_idle, 'idle', true)
    self:addState('attack', Character.st_attack, 'attack', false)
    self:addState('attackDelay', Character.st_attackDelay, 'idle', true)
    self:addState('charge', Character.st_charge, 'idle', true)
    self:addState('casting', Character.st_casting, 'idle', true)
    
    self:addState('dying', Character.st_dying, 'idle', false, PRIORITY.DYING)
    self:addState('dead', Character.st_dead, nil, nil, PRIORITY.DEAD)

    self:addState('delegate', Character.st_delegate, 'idle', true)
    self:addState('wait', Character.st_wait, 'idle', true)
    self:addState('move', Character.st_move, 'idle', true)

	self:addState('stun', Character.st_stun, 'idle', true, PRIORITY.STUN)
    self:addState('comeback', Character.st_comeback, 'idle', true)
end

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

        -- 사망 처리 시 StateDelegate Kill!
        owner:killStateDelegate()

        owner:dispatch('character_dying', {}, owner)
        
	    -- 사망 사운드
	    if (owner.m_charType == 'dragon') then
		    if (owner.m_charTable['c_appearance'] == 2) then
			    SoundMgr:playEffect('EFX', 'efx_dragon_die_cute')
		    else
			    SoundMgr:playEffect('EFX', 'efx_dragon_die_normal')
		    end
	    elseif (owner.m_charType == 'monster') then
		    if (owner:isBoss()) then
			    SoundMgr:playEffect('EFX', 'efx_midboss_die')
		    else
			    SoundMgr:playEffect('EFX', 'efx_monster_die')
		    end
	    end

        if (owner.m_animator and owner.m_animator.m_node) then
            -- 먼저 죽음 애니메이션 있는지 체크하고
            local has_die_animation = owner.m_animator:hasAni('die')

            if (has_die_animation) then
                -- 플레이 한다면
                local is_play_die_animation = owner.m_reactingInfo and owner.m_reactingInfo["is_play_die_animation"] or false

                -- 애니 바꿔주고
                if (is_play_die_animation) then
                    owner.m_animator:changeAni('die', false)

                    -- 후속 액션을 등록해준다
                    owner.m_animator:addAniHandler(function()
                        owner.m_animator:setAlpha(0)
                    end)
                else
                    -- 아니면 바로 하이드
                    owner.m_animator:setAlpha(0)
                end 

            else
                local action1 = cc.FadeTo:create(0.5, 0)
                local action2 = cc.RotateTo:create(0.5, -45)
                local action = cc.Spawn:create(action1, action2)
                cca.runAction(owner.m_animator.m_node, action, CHARACTER_ACTION_TAG__DYING)

            end
        end

        if (owner.m_hpNode) then
            owner.m_hpNode:setVisible(false)
        end

        if (owner.m_castingNode) then
            owner.m_castingNode:setVisible(false)
        end

    elseif (owner.m_stateTimer > 0.5) then
        owner:changeState('dead')

    end
end

-------------------------------------
-- function st_dead
-------------------------------------
function Character.st_dead(owner, dt)
    if (owner.m_stateTimer == 0) then
        if (owner.m_bLeftFormation) then
            owner.m_world:removeHero(owner)
        else
            owner.m_world:removeEnemy(owner)
        end

        owner:setDead()
    end

    if (not owner.m_bPossibleRevive) then
        return true
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function Character.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_bEnableSpasticity = false

        -- 변수 초기화
        owner.m_bLuanchMissile = false
        owner.m_bFinishAttack = false
        owner.m_bFinishAnimation = false

        local skill_id = owner.m_reservedSkillId

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

            if (skill_id == owner.m_reservedSkillId) then
                owner:doAttack(skill_id, x, y)
            end

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
        owner.m_animator:setEventHandler(function(event)
            if (not owner.m_bLuanchMissile) then
                attack_cb(event)
            end
        end)

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

        if (owner.m_state ~= 'delegate') then
            owner:changeState('attackDelay')
        end
    end
end

-------------------------------------
-- function st_attackDelay
-------------------------------------
function Character.st_attackDelay(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_bEnableSpasticity = true

        -- 어떤 스킬을 사용할 것인지 결정
        local skill_id, is_add_skill

        -- indie_time등의 우선순위가 높은 스킬로 인해 이전에 사용되지 못한 스킬이 있으면 사용하도록 함
        if (owner.m_prevReservedSkillId) then
            skill_id, is_add_skill = owner.m_prevReservedSkillId, owner.m_prevIsAddSkill
            owner.m_stateTimer = owner.m_prevAttackDelayTimer

            owner.m_prevReservedSkillId = nil
            owner.m_prevIsAddSkill = nil
            owner.m_prevAttackDelayTimer = 0
        else
            skill_id, is_add_skill = owner:getBasicAttackSkillID()
        end

        local t_skill = owner:getSkillTable(skill_id)

		-- 스킬 캐스팅 불가 처리
		if (owner.m_isSilence) then
			is_add_skill = false
			skill_id = owner:getSkillID('basic')
        -- 스킬 대상이 없는 경우 처리 (특히 아군 대상인 경우)
        elseif (t_skill['chance_type'] == 'basic_turn') and (not owner:checkTarget(t_skill)) then
			is_add_skill = false
			skill_id = owner:getSkillID('basic')
		end

        owner:reserveSkill(skill_id)
        owner:calcAttackPeriod()
		owner.m_isAddSkill = is_add_skill

        -- 캐스팅 게이지
        if (owner.m_castingNode) then
            owner.m_castingNode:setVisible(false)
        end

        -- 부유중 연출
        owner:runAction_Floating()

    elseif (owner.m_stateTimer >= owner.m_attackPeriod) then
        if (not owner.m_reservedSkillId) then
            owner:changeState('attackDelay')
        elseif (owner.m_reservedSkillCastTime > 0) then
            owner:changeState('casting')
        else
            owner:changeState('charge')
        end
    end

    if (not owner:hasStatusEffectToDisableSkill()) then
        local tParam = {
            time_out = owner.m_world.m_gameState:isTimeOut(),
            hp_rate = owner.m_hpRatio
        }

        -- 일반 공격 관련 스킬보다 우선순위가 높은 스킬
        local skill_id = owner:getInterceptableSkillID(tParam)
        if (skill_id) then
            local t_skill = owner:getSkillTable(skill_id)

            if (owner:checkTarget(t_skill)) then
                owner.m_prevReservedSkillId = owner.m_reservedSkillId
                owner.m_prevIsAddSkill = owner.m_isAddSkill
                owner.m_prevAttackDelayTimer = owner.m_stateTimer

                owner:reserveSkill(skill_id)
                owner.m_isAddSkill = false
                
                if (owner.m_reservedSkillCastTime > 0) then
                    owner:changeState('casting')
                else
                    owner:changeState('attack')
                end
            else
                -- 대상이 없을 경우
                local skill_indivisual_info = owner:findSkillInfoByID(skill_id)
                if (skill_indivisual_info) then
                    skill_indivisual_info:startCoolTime()
                end
            end
        end
    end
end

-------------------------------------
-- function st_casting
-------------------------------------
function Character.st_casting(owner, dt)
    if (owner.m_stateTimer == 0) then
        local skill_id = owner.m_reservedSkillId
        local cast_time = owner.m_reservedSkillCastTime

        -- chance_type관련 누적 정보를 초기화(cool_down은 제외)
        local skill_indivisual_info = owner:findSkillInfoByID(skill_id)
        if (skill_indivisual_info) then
            skill_indivisual_info:startCoolTimeByCasting()
        end

        -- 캐스팅 게이지
        if owner.m_castingNode then
            owner.m_castingNode:setVisible(true)

            if owner.m_castingUI then
                owner.m_castingUI:stopAllActions()
                owner.m_castingUI:setPosition(0, 0)
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
        if (owner.m_bUseCastingEffect) then
            if owner.m_castingEffect then
                owner.m_castingEffect:release()
            end

			-- 캐스팅 애니메이션 실행시 캐스팅 이벤트 문자열을 가져온다.
			local function casting_cb(event)
				owner.m_bLuanchMissile = true
				if event then
					local x, y = 0, 0
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
					-- 이벤트가 존재할 시에만 setPosition 된다.
					if owner.m_castingEffect then 
						owner.m_castingEffect:setPosition(x, y)
					end
				end
			end
			owner.m_animator:setEventHandler(casting_cb)

			-- 기본으로 찍히게 될 캐스팅 이펙트 좌표 (60, 0)
            local offsetX = 60
            if owner.m_animator.m_bFlip then
                offsetX = -offsetX
            end

            local scale = 1
            local aniName = 'idle'

            local rarity = owner.m_charTable['rarity']
            if rarity == 'boss' or rarity == 'subboss' or rarity == 'elite' then
                scale = 2
				offsetX = offsetX * 2
            end

            if rarity == 'boss' or rarity == 'subboss' then
                aniName = 'idle_boss'
            end
            
            owner.m_castingEffect = MakeAnimator('res/effect/effect_skillcasting/effect_skillcasting.vrp')
            owner.m_castingEffect:changeAni(aniName, false)
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

    if (owner.m_isSilence) then
        owner:changeState('attackDelay')
        
    elseif (owner.m_reservedSkillCastTime <= owner.m_stateTimer) then
        owner:changeState('attack')
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
    if (owner.m_stateTimer == 0) then
        owner.m_bEnableSpasticity = false

        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end
    end
end

-------------------------------------
-- function st_comeback
-------------------------------------
function Character.st_comeback(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:setMove(owner.m_homePosX, owner.m_homePosY, 800)

        owner:dispatch('character_comeback', {}, owner)
    
    elseif (not owner.m_isOnTheMove) then
        owner:changeState(owner.m_comebackNextState)
        owner.m_comebackNextState = nil
    end
end

-------------------------------------
-- function st_stun
-------------------------------------
function Character.st_stun(owner, dt)
	if (owner.m_stateTimer == 0) then
		-- 로밍 액션 해제
        if (owner.m_bRoam) then
            owner:stopRoaming()
        end

        -- 캐스팅 게이지
        if (owner.m_castingNode) then
            owner.m_castingNode:setVisible(false)
        end

	elseif (not owner.m_isGroggy) then
        owner:changeStateWithCheckHomePos('attackDelay', true)

    end
end

-------------------------------------
-- function st_move
-------------------------------------
function Character.st_move(owner, dt)
    local x, y = owner.m_rootNode:getPosition()
    if (owner.pos.x ~= x) or (owner.pos.y ~= y) then
        owner:setHomePos(x, y)
        owner:setPosition(x, y)
    end
end

-------------------------------------
-- function st_wait
-------------------------------------
function Character.st_wait(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.speed = 0

        if (owner.m_animator) then
            owner.m_animator:setRotation(90)
        end

        if (owner.m_castingNode) then
            owner.m_castingNode:setVisible(false)
        end
    end
end