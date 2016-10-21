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
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Hero:initAnimator(file_name)

end

-------------------------------------
-- function initAnimatorHero
-------------------------------------
function Hero:initAnimatorHero(file_name, evolution)
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimator(file_name, evolution)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end
end

Hero.st_idle = PARENT.st_idle
Hero.st_attack = PARENT.st_attack

Hero.st_dying = PARENT.st_dying
Hero.st_dead = PARENT.st_dead
Hero.st_delegate = PARENT.st_delegate

-------------------------------------
-- function initState
-------------------------------------
function Hero:initState()
    self:addState('idle', Hero.st_idle, 'idle', true)
    self:addState('attack', Hero.st_attack, 'attack', true)
    self:addState('attackDelay', Hero.st_attackDelay, 'idle', true)

    --
    self:addState('skillPrepare', Hero.st_skillPrepare, 'skill_appear', true)
    self:addState('skillIdle', Hero.st_skillIdle, 'skill_idle', true)
    self:addState('skillAttack', Hero.st_skillAttack, 'skill_idle', true)
    self:addState('skillDisappear', Hero.st_skillDisappear, 'skill_disappear', false)
    --

    self:addState('dying', Hero.st_dying, 'idle', false, PRIORITY.DYING)
    self:addState('dead', Hero.st_dead, nil, nil, PRIORITY.DEAD)

    self:addState('delegate', Hero.st_delegate, 'idle', true)
    self:addState('wait', Hero.st_wait, 'idle', true)

    -- success
    self:addState('success_pose', Hero.st_success_pose, 'pose_1', false)
    self:addState('success_move', Hero.st_success_move, 'idle', true)

	self:addState('stun', PARENT.st_stun, 'idle', true, PRIORITY.STUN)
	self:addState('stun_esc', PARENT.st_stun_esc, 'idle', true, PRIORITY.STUN_ESC)
    self:addState('comeback', PARENT.st_comeback, 'idle', true)
end

-------------------------------------
-- function st_attackDelay
-------------------------------------
function Hero.st_attackDelay(owner, dt)
    if owner.m_stateTimer == 0 then
        owner:calcAttackPeriod()
    end

    if (owner.m_attackPeriod <= owner.m_stateTimer) then
        owner:changeState('attack')
        owner.m_infoUI.vars['atkGauge']:setPercentage(0)
        return
    end

    local percentage = owner.m_stateTimer / owner.m_attackPeriod * 100
    owner.m_infoUI.vars['atkGauge']:setPercentage(percentage)
end

-------------------------------------
-- function st_skillPrepare
-------------------------------------
function Hero.st_skillPrepare(owner, dt)
    --[[
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
            owner:changeState('skillIdle')
        end)
    end
    --]]
end

-------------------------------------
-- function st_skillIdle
-------------------------------------
function Hero.st_skillIdle(owner, dt)

end

-------------------------------------
-- function st_skillAttack
-------------------------------------
function Hero.st_skillAttack(owner, dt)
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
            error('motion_type : ' .. motion_type)
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
            local name = owner.m_charTable['t_name']

            if (name == '고대 신룡') then
                SoundMgr:playEffect('EFFECT', 'skill_godae_shinryong')

            elseif (name == '파워 드래곤') then
                SoundMgr:playEffect('EFFECT', 'skill_power_dragon')

            elseif (name == '서펀트 드래곤') then
                SoundMgr:playEffect('EFFECT', 'skill_serpent_dragon')

            elseif (name == '크레센트 드래곤') then
                SoundMgr:playEffect('EFFECT', 'skill_crescent')

            elseif (name == '테일 드래곤') then
                SoundMgr:playEffect('EFFECT', 'skill_tail_dragon')

            elseif (name == '가루다') then
                SoundMgr:playEffect('EFFECT', 'skill_garuda')

            elseif (name == '핑크벨') then
                SoundMgr:playEffect('EFFECT', 'skill_pinkbell')
            end
        end

        -- 공격 타이밍이 있을 경우
        owner.m_animator:setEventHandler(attack_cb)
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
        self.m_world:removeHero(self)
    end

    PARENT.release(self)
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
function Hero:changeHomePos(x, y)
    self.m_homePosX = x
    self.m_homePosY = y

    self:setMove(x, y, 500)
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

    self.m_world.m_worldNode:addChild(self.m_hpNode, 5)

    self.m_infoUI = ui
end

-------------------------------------
-- function setHp
-------------------------------------
function Hero:setHp(hp)
    self.m_hp = hp

    if self.m_hpGauge then
        self.m_hpGauge:setPercentage(self.m_hp / self.m_maxHp * 100)
    end

    if self.m_hpEventListener then
        for i, v in pairs(self.m_hpEventListener) do
            v:changeHpCB(self, self.m_hp, self.m_maxHp)
        end
    end

    self:dispatch('change_hp', self, self.m_hp, self.m_maxHp)
end

-------------------------------------
-- function initStatus
-------------------------------------
function Hero:initStatus(t_char, level, grade, evolution)
    PARENT.initStatus(self, t_char, level, grade, evolution)
	
    local active_skill_id = self:getSkillID('active')
    if (active_skill_id == 0) then
        return
    end
	
    local t_skill = TABLE:get('dragon_skill')[active_skill_id]

	local type = t_skill['type']
	
    -- 직선형
    if isExistValue(type, 'skill_laser', 'skill_breath_1', 'skill_breath_2', 'skill_breath_3') then
        self.m_skillIndicator = SkillIndicator_laser(self, t_skill)

    -- 범위형
    elseif isExistValue(type, 'skill_bullet_hole') then
        self.m_skillIndicator = SkillIndicator_Range(self)
        self.m_skillIndicator.m_bUseHighlight = false

    -- 타겟형 (아군)
    elseif isExistValue(type, 'skill_protection', 'skill_protection_spread', 'skill_dispel_harm') then
        self.m_skillIndicator = SkillIndicator_Target(self)
	elseif string.find(type, 'skill_buff') then
        self.m_skillIndicator = SkillIndicator_Target(self)

	-- 타겟형 (적군)
    elseif isExistValue(type, 'skill_strike_finish_spread') then
        self.m_skillIndicator = SkillIndicator_OppositeTarget(self)

    -- 힐링윈드
    elseif isExistValue(type, 'skill_aod_square_heal_dmg') then
        self.m_skillIndicator = SkillIndicator_HealingWind(self, t_skill)

    -- 크래시
    elseif isExistValue(type, 'skill_crash') then
        self.m_skillIndicator = SkillIndicator_Crash(self, t_skill)

    -- 리프 블레이드
    elseif isExistValue(type, 'skill_curve_twin') then
        self.m_skillIndicator = SkillIndicator_LeafBlade(self, t_skill)

    -- 청룡 번개구름, 붐버 액티브, 램곤 수면, 서펀트 액티브
    elseif isExistValue(type, 'skill_aoe_round', 'skill_explosion_def') then
        local isFixedOnTarget = false
        self.m_skillIndicator = SkillIndicator_AoERound(self, t_skill, isFixedOnTarget)

    -- 허리케인
    elseif isExistValue(type, 'skill_aoe_cone_spread') then
        self.m_skillIndicator = SkillIndicator_ConicSpread(self, t_skill)

    else
        self.m_skillIndicator = SkillIndicator_Target(self)
		cclog('###############################################')
		cclog('## 인디케이터 정의 되지 않은 스킬 : ' .. type)
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
-- function initDragonSkillManager
-------------------------------------
function Hero:initDragonSkillManager(char_type, char_id, char_grade)
    PARENT.initDragonSkillManager(self, char_type, char_id, char_grade)

    -- 액티브 스킬 쿨타임 지정
    self:initActiveSkillCoolTime()
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
    self.m_activeSkillTimer = 0
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

    self.m_activeSkillTimer = (self.m_activeSkillTimer + dt)
    if (self.m_activeSkillCoolTime <= self.m_activeSkillTimer) then
        self.m_activeSkillTimer = self.m_activeSkillCoolTime
        self.m_infoUI.vars['skllFullVisual']:setVisible(true)
    end

    self.m_infoUI.vars['skillGauge']:setPercentage(self.m_activeSkillTimer / self.m_activeSkillCoolTime * 100)

    --cclog(' self.m_activeSkillTimer ' .. self.m_activeSkillTimer)
end

-------------------------------------
-- function resetActiveSkillCoolTime
-------------------------------------
function Hero:resetActiveSkillCoolTime()
    if (self.m_activeSkillTimer == self.m_activeSkillCoolTime) then
        self.m_activeSkillTimer = 0
        self.m_infoUI.vars['skllFullVisual']:setVisible(false)
        self.m_infoUI.vars['skillGauge']:setPercentage(0)
        return true
    else
        return false
    end
end

-------------------------------------
-- function checkTarget
-------------------------------------
function Hero:checkTarget(t_skill)

    -- 25%의 확률로 테이머 타겟을 공격
    if (math_random(1, 100) <= 25) then
        local target = self.m_world.m_tamer:getTamerTarget()
        if target then
            self.m_targetChar = target
            return
        end
    end

    -- 기본 룰로 타겟 지정
    PARENT.checkTarget(self, t_skill)
end