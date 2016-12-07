local PARENT = Character

-------------------------------------
-- class Hero
-------------------------------------
Hero = class(PARENT, {
        -- 기본 정보
        m_dragonID = '',    -- 드래곤의 고유 ID
        m_tDragonInfo = 'table', -- 유저가 보유한 드래곤 정보

        m_bActive = '',

        m_skillIndicator = '',

        m_infoUI = 'UI_IngameDragonInfo',
        m_bWaitState = 'boolean',

        m_activeSkillTimer = 'number',
        m_activeSkillCoolTime = 'number',

        m_afterimageMove = 'number',

        m_bUseSelfAfterImage = 'boolean',

        m_skillPrepareEffect = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Hero:init(file_name, body, ...)
    self.m_charType = 'dragon'

    self.m_bActive = false
    self.m_bWaitState = false

    self.m_bUseSelfAfterImage = false
    self.m_skillPrepareEffect = nil
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Hero:initAnimator(file_name)

end

-------------------------------------
-- function initAnimatorHero
-------------------------------------
function Hero:initAnimatorHero(file_name, evolution, attr)
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimator(file_name, evolution, attr)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end
end

-------------------------------------
-- function update
-------------------------------------
function Hero:update(dt)
    if self.m_bUseSelfAfterImage then
        self:updateAfterImage(dt)
    end

    return Character.update(self, dt)
end

-------------------------------------
-- function doAttack
-------------------------------------
function Hero:doAttack(x, y)
    local basic_skill_id = self.m_reservedSkillId

    PARENT.doAttack(self, x, y)

    -- 원거리 기본 공격에만 이펙트를 추가
    local attr = self.m_charTable['attr']
    local table_skill = TABLE:get('dragon_skill')
    local t_skill = table_skill[basic_skill_id] or {}
    local type = t_skill['type']

    if type ~= 'skill_melee_atk' then
        local res = 'res/effect/effect_missile_charge/effect_missile_charge.vrp'
        local animator = MakeAnimator(res)
        animator:changeAni('shot_' .. attr, false)
        self.m_rootNode:addChild(animator.m_node)
        local duration = animator:getDuration()
        animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
    end
end

-------------------------------------
-- function initState
-------------------------------------
function Hero:initState()
    PARENT.initState(self)

    self:addState('attack', Hero.st_attack, 'attack', true)
    self:addState('charge', Hero.st_charge, 'idle', true)
    self:addState('casting', PARENT.st_casting, 'skill_appear', true)

    --
    self:addState('skillPrepare', Hero.st_skillPrepare, 'skill_appear', true)
    self:addState('skillAttack', Hero.st_skillAttack, 'skill_appear', true)
    self:addState('skillAttack2', Hero.st_skillAttack2, 'skill_idle', false)
    self:addState('skillDisappear', Hero.st_skillDisappear, 'skill_disappear', false)
    --

    self:addState('wait', Hero.st_wait, 'idle', true)

    -- success
    self:addState('success_pose', Hero.st_success_pose, 'pose_1', false)
    self:addState('success_move', Hero.st_success_move, 'idle', true)
end

-------------------------------------
-- function st_attack
-------------------------------------
function Hero.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 원거리 기본 공격에만 이펙트를 추가
        if owner.m_charTable['skill_basic'] == owner.m_reservedSkillId then
            local attr = owner.m_charTable['attr']
            local table_skill = TABLE:get('dragon_skill')
            local t_skill = table_skill[owner.m_reservedSkillId] or {}
            local type = t_skill['type']

            if type ~= 'skill_melee_atk' then
                local res = 'res/effect/effect_missile_charge/effect_missile_charge.vrp'
                if res then
                    local animator = MakeAnimator(res)
                    animator:changeAni('idle_' .. attr, false)
                    owner.m_rootNode:addChild(animator.m_node)
                    local duration = animator:getDuration()
                    animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
                end
            end
        end
    end

    PARENT.st_attack(owner, dt)
end

-------------------------------------
-- function st_charge
-------------------------------------
function Hero.st_charge(owner, dt)
    if (owner.m_stateTimer == 0) then
        local attr = owner.m_charTable['attr']

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
function Hero.st_skillPrepare(owner, dt)
end

-------------------------------------
-- function st_skillAttack
-------------------------------------
function Hero.st_skillAttack(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_bEnableSpasticity = false

        -- 이벤트
        owner:dispatch('dragon_skill', owner)
    end
end

-------------------------------------
-- function st_skillAttack2
-------------------------------------
function Hero.st_skillAttack2(owner, dt)
    if (owner.m_stateTimer == 0) then
        local active_skill_id = owner:getSkillID('active')
        local table_dragon_skill = TABLE:get('dragon_skill')
        local t_dragon_skill = table_dragon_skill[active_skill_id]
        local motion_type = t_dragon_skill['motion_type']

        -- 모션 타입 처리
        if (motion_type == 'instant') then
            owner.m_aiParamNum = nil
            owner:addAniHandler(function()
                owner:changeState('skillDisappear')
            end)
        elseif (motion_type == 'maintain') then
            owner.m_aiParamNum = (owner.m_statusCalc.m_attackTick / 2)
        else
            error('스킬 테이블 motion_type이 ['.. motion_type .. '] 라고 잘못들어갔네요...')
        end

        local function attack_cb(event)
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

            -- 액티브 스킬 사용 이벤트 발생
            owner:dispatch('active_skill')
            local active_skill_id = owner:getSkillID('active')
            owner:doSkill(active_skill_id, nil, x, y, owner.m_skillIndicator:getIndicatorData())
            owner.m_animator:setEventHandler(nil)

            -- 사운드
            local type = owner.m_charTable['type']

            if (type == 'powerdragon') then
                SoundMgr:playEffect('EFFECT', 'skill_powerdragon')

            elseif (type == 'lambgon') then
                SoundMgr:playEffect('EFFECT', 'skill_lambgon')

            elseif (type == 'applecheek') then
                SoundMgr:playEffect('EFFECT', 'skill_applecheek')

            elseif (type == 'spine') then
                SoundMgr:playEffect('EFFECT', 'skill_spine')

            elseif (type == 'leafdragon') then
                SoundMgr:playEffect('EFFECT', 'skill_leafdragon')

            elseif (type == 'taildragon') then
                SoundMgr:playEffect('EFFECT', 'skill_taildragon')

            elseif (type == 'purplelipsdragon') then
                SoundMgr:playEffect('EFFECT', 'skill_purplelipsdragon')

            elseif (type == 'pinkbell') then
                SoundMgr:playEffect('EFFECT', 'skill_pinkbell')

            elseif (type == 'bluedragon') then
                SoundMgr:playEffect('EFFECT', 'skill_bluedragon')

            elseif (type == 'littio') then
                SoundMgr:playEffect('EFFECT', 'skill_littio')

            elseif (type == 'hurricane') then
                SoundMgr:playEffect('EFFECT', 'skill_hurricane')

            elseif (type == 'garuda') then
                SoundMgr:playEffect('EFFECT', 'skill_garuda')

            elseif (type == 'boomba') then
                SoundMgr:playEffect('EFFECT', 'skill_boomba')

            elseif (type == 'godaeshinryong') then
                SoundMgr:playEffect('EFFECT', 'skill_godaeshinryong')

            elseif (type == 'crescentdragon') then
                SoundMgr:playEffect('EFFECT', 'skill_crescentdragon')

            elseif (type == 'serpentdragon') then
                SoundMgr:playEffect('EFFECT', 'skill_serpentdragon')

            end
        end

        -- 공격 타이밍이 있을 경우
        owner.m_animator:setEventHandler(attack_cb)

        -- 효과음
        if (owner.m_charType == 'dragon') then
            --SoundMgr:playEffect('EFFECT', 'd_skill')
        end
    end

    if (owner.m_aiParamNum and (owner.m_stateTimer >= owner.m_aiParamNum)) then
        owner:changeState('skillDisappear')
    end
end

-------------------------------------
-- function st_skillDisappear
-------------------------------------
function Hero.st_skillDisappear(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_bEnableSpasticity = true

        owner:addAniHandler(function()
            owner:changeState('attackDelay')
        end)
    end
end

-------------------------------------
-- function st_wait
-------------------------------------
function Hero.st_wait(owner, dt)

end

-------------------------------------
-- function st_success_pose
-- @brief success 세레머니
-------------------------------------
function Hero.st_success_pose(owner, dt)
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
function Hero.st_success_move(owner, dt)
    if (owner.m_stateTimer == 0) then
        local add_speed = (owner.pos['y'] / -100) * 100
        owner:setMove(owner.pos.x + 2000, owner.pos.y, 1500 + add_speed)

        owner.m_afterimageMove = 0
    end

    do -- 에프터이미지
        local self = owner
        self.m_afterimageMove = self.m_afterimageMove + (self.speed * dt)

        --local interval = self.body.size * 0.5 -- 반지름이기 때문에 2배
        local interval = 50

        if (self.m_afterimageMove >= interval) then
            self.m_afterimageMove = self.m_afterimageMove - interval
            -- cclog('출력 출력 출력')

            local duration = (interval / self.speed) * 1.5 -- 3개의 잔상이 보일 정도
            duration = math_clamp(duration, 0.3, 0.7)

            local res = self.m_animator.m_resName
            local rotation = self.m_animator:getRotation()
            local accidental = MakeAnimator(res)
            --accidental.m_node:setRotation(rotation)
            accidental:changeAni(self.m_animator.m_currAnimation)
            local parent = self.m_rootNode:getParent()
            --parent:addChild(accidental.m_node)
            self.m_world.m_worldNode:addChild(accidental.m_node, 2)
            accidental:setScale(self.m_animator:getScale())
            accidental:setFlip(self.m_animator.m_bFlip)
            accidental.m_node:setOpacity(255 * 0.3)
            accidental.m_node:setPosition(self.pos.x, self.pos.y)
            accidental.m_node:runAction(cc.Sequence:create(cc.FadeTo:create(duration, 0), cc.RemoveSelf:create()))

        end
    end
end

-------------------------------------
-- function release
-------------------------------------
function Hero:release()
    if self.m_world then
        if self.m_bLeftFormation then
            self.m_world:removeHero(self)
        else
            self.m_world:removeEnemy(self)
        end
    end

    if self.m_hpNode then
        self.m_hpNode:removeFromParent(true)
    end
    
    self.m_hpNode = nil
    self.m_hpGauge = nil

    Entity.release(self)
end

-------------------------------------
-- function makeSilhouette
-------------------------------------
function Hero:makeSilhouette()
    local res = self.m_animator.m_resName
    local entity = Entity(res)
    entity.m_animator:setSkin('White')
    entity.m_animator:changeAni('idle', true)
    entity.m_rootNode:setScale(self.m_animator:getScale())

    return entity
end

-------------------------------------
-- function setActive
-------------------------------------
function Hero:setActive(active)
    self.m_bActive = active

    if self.m_bActive then
        self.enable_body = true
        self.apply_movement = true
        if self.m_rootNode then
            self.m_rootNode:setVisible(true)
        end
    else
        self.enable_body = false
        self.apply_movement = false
        if self.m_rootNode then
            self.m_rootNode:setVisible(false)
        end

        -- 이동 중지
        self:resetMove()
    end

    if self.m_hpNode then
        self.m_hpNode:setVisible(active)
    end
end

-------------------------------------
-- function changeHomePos
-------------------------------------
function Hero:changeHomePos(x, y, speed)
    self:setHomePos(x, y)

    local speed = speed or 500
    self:setMove(x, y, speed)
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Hero:makeHPGauge(hp_ui_offset)
    self.m_hpUIOffset = hp_ui_offset
    self.m_hpUIOffset[1] = self.m_hpUIOffset[1] - 80

    local ui = UI_IngameDragonInfo(self)
    self.m_hpNode = ui.root
    self.m_hpNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_hpNode:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_hpGauge = ui.vars['hpGauge']
    self.m_hpGauge2 = ui.vars['hpGauge2']

    self.m_castingNode = ui.vars['atkGauge']
    --self.m_castingGauge = ui.vars['atkGauge']

    --self.m_castingGauge:setPercentage(0)

    self.m_world.m_worldNode:addChild(self.m_hpNode, 5)

    self.m_infoUI = ui
end

-------------------------------------
-- function setPosition
-------------------------------------
function Hero:setPosition(x, y)
    Entity.setPosition(self, x, y)

    if self.m_hpNode then
        self.m_hpNode:setPosition(x + self.m_hpUIOffset[1], y + self.m_hpUIOffset[2])
    end
    
    if self.m_cbChangePos then
        self.m_cbChangePos(self)
    end
end

-------------------------------------
-- function setHp
-------------------------------------
function Hero:setHp(hp)
    Character.setHp(self, hp)

    self:dispatch('change_hp', self, self.m_hp, self.m_maxHp)
end

-------------------------------------
-- function initStatus
-------------------------------------
function Hero:initStatus(t_char, level, grade, evolution, doid)
    PARENT.initStatus(self, t_char, level, grade, evolution, doid)
	
    local t_skill = self:getLevelingSkillByType('active').m_tSkill

	local type = t_skill['indicator']
		
	-- 타겟형(아군)
	if (type == 'target_ally') then
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, false)

	-- 타겟형(적군)
	elseif (type == 'target') then
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, true)

	-- 원형 범위
	elseif (type == 'round') then
		self.m_skillIndicator = SkillIndicator_AoERound(self, t_skill, false)

	-- 시전 범위 제한 있는 타겟
	elseif (type == 'range') then
		self.m_skillIndicator = SkillIndicator_Range(self)

	-- 원뿔형
	elseif (type == 'cone') then
		self.m_skillIndicator = SkillIndicator_Conic(self, t_skill)

	-- 레이저
	elseif (type == 'bar') then
		self.m_skillIndicator = SkillIndicator_Laser(self, t_skill)

	------------------ 특수한 인디케이터들 ------------------
	
	-- 크래쉬(가루다)
	elseif (type == 'target_cone') then
		self.m_skillIndicator = SkillIndicator_Crash(self, t_skill)
	
	-- 힐링윈드 (핑크벨)
	elseif (type == 'square') then
		self.m_skillIndicator = SkillIndicator_HealingWind(self, t_skill)
	
	-- 리프블레이드 (리프드래곤)
	elseif (type == 'curve_twin') then
		self.m_skillIndicator = SkillIndicator_LeafBlade(self, t_skill)
	
	-- 원뿔형 확산 (허리케인)
	elseif (type == 'cone_spread') then
		self.m_skillIndicator = SkillIndicator_ConicSpread(self, t_skill)

	-- 미정의 인디케이터
	else
		self.m_skillIndicator = SkillIndicator_Target(self, t_skill, false)
		cclog('###############################################')
		cclog('## 인디케이터 정의 되지 않은 스킬 : ' .. t_skill['type'])
		cclog('###############################################')
	end

end

-------------------------------------
-- function setWaitState
-------------------------------------
function Hero:setWaitState(is_wait_state)
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
function Hero:changeState(state, forced)
    if self.m_bWaitState then
        if (not isExistValue(state, 'dying', 'dead')) then
            return PARENT.changeState(self, 'wait', false)
        end
    end

    return PARENT.changeState(self, state, forced)
end

-------------------------------------
-- function initActiveSkillCoolTime
-------------------------------------
function Hero:initActiveSkillCoolTime()
    -- 액티브 스킬 쿨타임 지정
    local active_skil_id = self:getSkillID('active')

    if (active_skil_id == 0) then
        return
    end
    
    local table_skill = TABLE:get(self.m_charType .. '_skill')
    local t_skill = table_skill[active_skil_id]

    self.m_activeSkillCoolTime = tonumber(t_skill['cooldown'])
    
    self.m_activeSkillTimer = 100
end

-------------------------------------
-- function updateActiveSkillCoolTime
-------------------------------------
function Hero:updateActiveSkillCoolTime(dt)
    if (not self.m_activeSkillCoolTime) or (self.m_activeSkillCoolTime == 0) then
        return
    end

    if (self.m_activeSkillCoolTime == self.m_activeSkillTimer) then
        return
    end

    if (self.m_state ~= 'casting') and (self.m_state ~= 'skillPrepare') then
        self.m_activeSkillTimer = (self.m_activeSkillTimer + dt)
    end

    if (self.m_activeSkillCoolTime <= self.m_activeSkillTimer) then
        self.m_activeSkillTimer = self.m_activeSkillCoolTime

        self.m_infoUI.vars['skllFullVisual']:setVisible(true)
        self.m_infoUI.vars['skllFullVisual']:setRepeat(false)
        self.m_infoUI.vars['skllFullVisual']:setVisual('skill_gauge', 'charging')
        self.m_infoUI.vars['skllFullVisual']:registerScriptLoopHandler(function()
            local attr = self.m_charTable['attr']

            self.m_infoUI.vars['skllFullVisual']:setVisual('skill_gauge', 'idle_' .. attr)
            self.m_infoUI.vars['skllFullVisual']:setRepeat(true)

            self.m_infoUI.vars['skllFullVisual2']:setVisual('skill_gauge', 'idle_s_' .. attr)
            self.m_infoUI.vars['skllFullVisual2']:setVisible(true)
        end)
    end

    self.m_infoUI.vars['skillGauge']:setPercentage(self.m_activeSkillTimer / self.m_activeSkillCoolTime * 100)

    --cclog(' self.m_activeSkillTimer ' .. self.m_activeSkillTimer)
end

-------------------------------------
-- function resetActiveSkillCoolTime
-------------------------------------
function Hero:resetActiveSkillCoolTime()
    if self:isEndActiveSkillCoolTime() then
        self.m_activeSkillTimer = 0
        self.m_infoUI.vars['skllFullVisual']:setVisible(false)
        self.m_infoUI.vars['skllFullVisual2']:setVisible(false)
        self.m_infoUI.vars['skillGauge']:setPercentage(0)
        return true
    else
        return false
    end
end

-------------------------------------
-- function isEndActiveSkillCoolTime
-------------------------------------
function Hero:isEndActiveSkillCoolTime()
    return (self.m_activeSkillTimer == self.m_activeSkillCoolTime)
end

-------------------------------------
-- function checkTarget
-------------------------------------
function Hero:checkTarget(t_skill)
	-- @TODO 임시 처리
	--[[
    -- 25%의 확률로 테이머 타겟을 공격
    if (math_random(1, 100) <= 25) then
        local target = self.m_world.m_tamer:getTamerTarget()
        if target then
            self.m_targetChar = target
            return
        end
    end
	]]
    -- 기본 룰로 타겟 지정
    PARENT.checkTarget(self, t_skill)
end

-------------------------------------
-- function setAfterImage
-------------------------------------
function Hero:setAfterImage(b)
    self.m_afterimageMove = 0
    self.m_bUseSelfAfterImage = b
end

-------------------------------------
-- function updateAfterImage
-- @TODO hero class에 추가 됨에 따라 각각 따로 구현되었던 updateAfterImage 통합 필요
-------------------------------------
function Hero:updateAfterImage(dt)
    local speed = self.m_world.m_mapManager.m_speed

    -- 에프터이미지
    self.m_afterimageMove = self.m_afterimageMove + (speed * dt)

    local interval = -30

    if (self.m_afterimageMove <= interval) then
        self.m_afterimageMove = self.m_afterimageMove - interval

        local duration = (interval / speed) * 1.5 -- 3개의 잔상이 보일 정도
        duration = math_clamp(duration, 0.3, 0.7)

        local res = self.m_animator.m_resName
        local accidental = MakeAnimator(res)
        accidental:changeAni(self.m_animator.m_currAnimation)
        
		local parent = self.m_rootNode:getParent()
        self.m_world.m_worldNode:addChild(accidental.m_node, 1)
        accidental:setScale(self.m_animator:getScale())
        accidental:setFlip(self.m_animator.m_bFlip)
        accidental.m_node:setOpacity(255 * 0.2)
        accidental.m_node:setPosition(self.pos.x, self.pos.y)
        
        accidental.m_node:runAction(cc.MoveBy:create(duration, cc.p(speed / 2, 0)))
        accidental.m_node:runAction(cc.Sequence:create(cc.FadeTo:create(duration, 0), cc.RemoveSelf:create()))
    end
end

-------------------------------------
-- function makeSkillPrepareEffect
-------------------------------------
function Hero:makeSkillPrepareEffect()
    if self.m_skillPrepareEffect then return end

    local attr = self.m_charTable['attr']
    local res = 'res/effect/effect_skillcasting_dragon/effect_skillcasting_dragon.vrp'

    self.m_skillPrepareEffect = MakeAnimator(res)
    self.m_skillPrepareEffect:changeAni('start_' .. attr, true)
    self.m_rootNode:addChild(self.m_skillPrepareEffect.m_node)

    self.m_skillPrepareEffect.m_node:setTimeScale(10)
end

-------------------------------------
-- function removeSkillPrepareEffect
-------------------------------------
function Hero:removeSkillPrepareEffect()
    if not self.m_skillPrepareEffect then return end

    self.m_skillPrepareEffect:release()
    self.m_skillPrepareEffect = nil
end