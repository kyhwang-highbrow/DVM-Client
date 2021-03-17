local PARENT = Character

-------------------------------------
-- class SummonedCreature
-------------------------------------
SummonedCreature = class(PARENT, {
        -- 기본 정보
        m_creatureID = '',			-- 소환체 obj ID
        m_tSummonedCreatureInfo = 'table',	

        m_skillOffsetX = 'number',
        m_skillOffsetY = 'number',

        m_reservedSkillPos = 'cc.p',    -- 예약된 스킬이 가지는 특정 위치값(해당 위치로 이동해서 스킬 사용)

        -- 스킬 마나
        m_activeSkillManaCost = 'SecurityNumberClass',
        m_originActiveSkillManaCost = 'SecurityNumberClass',

        m_skillPrepareEffect = '',
		
        m_isUseMovingAfterImage = 'boolean',
		m_bWaitState = 'boolean',
		m_regenInfo = 'boolean',

        m_lBodyToUseBone = 'table',     -- bone(spine)의 위치를 기준값으로 사용하는 body 리스트
        -- 몬스터 드래곤 관련
        m_mBoneEffect = 'table',        -- 본 위치에 표시되는 추가 이펙트(m_mBoneEffect[effect] = bone_name 형태로 사용)

     })




-------------------------------------
-------------------------------------
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- object lifecycles
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-------------------------------------
-------------------------------------

-------------------------------------
-- function update
-------------------------------------
function SummonedCreature:update(dt)
    -- 잔상
    if (self.m_isUseMovingAfterImage) then
        self:updateMovingAfterImage(dt)
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function updateMovingAfterImage
-- @brief updateAfterImage와는 생성한 잔상이 직접 움직인다는 차이점이 있다.
-------------------------------------
function SummonedCreature:updateMovingAfterImage(dt)
    local speed = self.m_world.m_mapManager.m_speed

    -- 에프터이미지
    self.m_afterimageTimer = self.m_afterimageTimer + (speed * dt)

    local interval = -60
    if (self.m_afterimageTimer <= interval) then
        self.m_afterimageTimer = self.m_afterimageTimer - interval

        local duration = (interval / speed) * 1.5 -- 3개의 잔상이 보일 정도
        duration = math_clamp(duration, 0.3, 0.7)

        local res = self.m_animator.m_resName
        local scale = self.m_animator:getScale()

        -- GL calls를 줄이기 위해 월드를 통해 sprite를 얻어옴
        local sprite = self.m_world:getSummonedCreatureBatchNodeSprite(res, scale)
        sprite:setFlippedX(self.m_animator.m_bFlip)
        sprite:setOpacity(255 * 0.2)
        sprite:setPosition(self.pos.x, self.pos.y)
        
        sprite:runAction(cc.MoveBy:create(duration, cc.p(speed / 2, 0)))
        sprite:runAction(cc.Sequence:create(cc.FadeTo:create(duration, 0), cc.RemoveSelf:create()))
    end
end


-------------------------------------
-------------------------------------
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- Initializer
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-------------------------------------
-------------------------------------

-------------------------------------
-- function init_creature
-- 생성 후 기본정보 초기화
-------------------------------------
function SummonedCreature:init_creature(t_creature, creature_id, level)
    -- 각종 init 함수 실행
	do
		self:initDragonSkillManager('summon_object', creature_id, 6, true) -- monster는 skill_1~skill_6을 모두 사용
		self:initStatus(t_creature, level, 0, 0, 0)

		self:initAnimatorCreature(t_creature['res'], t_creature['attr'], t_creature['scale'], t_creature['size_type'])
		self:makeCastingNode()
		self:initTriggerListener()
		self:initLogRecorder(creature_id)
	end

    -- 피격 처리
    self:addDefCallback(function(attacker, defender, i_x, i_y, k, b)
        self:undergoAttack(attacker, defender, i_x, i_y, k or 0, b)
    end)
end

-------------------------------------
-- function initAnimatorCreature
-------------------------------------
function SummonedCreature:initAnimatorCreature(file_name, attr, scale, size_type)
    if (self.m_animator) then
        return false
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeSummonCreatureAnimator(file_name, attr)
    if (not self.m_animator.m_node) then return false end

    self.m_rootNode:addChild(self.m_animator.m_node)
	if (scale) then
		self.m_animator:setScale(scale)
	end

    -- 각종 쉐이더 효과 시 예외 처리할 슬롯 설정(Spine)
    self:blockMatchingSlotShader('effect_')

    -- 하이라이트 노드 설정
    self:addHighlightNode(self.m_animator.m_node)

    -- 차지 이펙트 생성
    if (size_type ~= 'xl') then
        local res = 'res/effect/effect_attack_ready/effect_attack_ready.vrp'
        local animator = MakeAnimator(res)
        animator:changeAni('idle', false)
        animator:setVisible(false)
        self.m_rootNode:addChild(animator.m_node)
        
        if (size_type == 's') then
            animator:setPosition(0, -25)
        elseif (size_type == 'm') then
            animator:setPosition(0, -50)
        elseif (size_type == 'l') then
            animator:setPosition(0, -75)
        end

        self.m_chargeDuration = animator:getDuration()
        self.m_chargeEffect = animator

        -- 하이라이트 노드 설정
        self:addHighlightNode(self.m_chargeEffect.m_node)
    end

    return true
end


-------------------------------------
-- function initFormation
-------------------------------------
function SummonedCreature:initFormation(body_size)
    self:makeHPGauge({0, -(body_size[3] * 1.5)})

    if (self.m_animator) then
        self.m_animator:setFlip(true)
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SummonedCreature:initState()
    PARENT.initState(self)

    self:addState('charge', SummonedCreature.st_charge, 'idle', true)
    self:addState('casting', SummonedCreature.st_casting, 'idle', true)

    -- 공격을 어떻게 할지 결정한다.
    -- 물건이면 일정 시간 후 스킬 발동 후 사라짐
    if (self.m_charTable and self.m_charTable['type'] and self.m_charTable['type'] == 'object') then 
        self:addState('attackDelay', SummonedCreature.st_attackDelay, 'idle', false)
    end


    self:addState('wait', SummonedCreature.st_wait, 'idle', true)
end



-------------------------------------
-------------------------------------
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- Animating States
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-------------------------------------
-------------------------------------

-------------------------------------
-- function st_charge
-------------------------------------
function SummonedCreature.st_charge(owner, dt)
    if (owner.m_stateTimer == 0) then
        if (owner.m_chargeEffect) then
            local attr = owner:getAttribute()

            owner.m_chargeEffect:setVisible(true)
            owner.m_chargeEffect:setFrame(0)
        else
            owner:changeState('attack')
        end

    elseif (owner.m_stateTimer >= owner.m_chargeDuration) then
        owner:changeState('attack')

    end
end

-------------------------------------
-- function st_casting
-------------------------------------
function SummonedCreature.st_casting(owner, dt)
    if (owner.m_stateTimer == 0) then
		if (owner:isBoss()) then
			SoundMgr:playEffect('EFFECT', 'monster_skill_cast') -- @ memo 출처 불분명하나 일단 남겨두기로함 (170928)
		end

        -- 스킬 사용 위치 정보가 있다면 해당 위치까지 이동시킴
        if (owner.m_reservedSkillPos) then
            owner:changeHomePosByTime(owner.m_reservedSkillPos.x, owner.m_reservedSkillPos.y, owner.m_reservedSkillCastTime)
        end
    end

    PARENT.st_casting(owner, dt)
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

		-- 스킬 캐스팅 불가 처리
		if (owner.m_isSilence) then
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
-------------------------------------
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- getter, setter
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-------------------------------------
-------------------------------------

-------------------------------------
-- function getBodySize
-------------------------------------
function SummonedCreature:getBodySize(size_type)
	local size = g_constant:get('INGAME', 'MONSTER_BODY_SIZE')[size_type] or 50
	local body = {0, 0, size}

	return body
end

-------------------------------------
-- function setWaitState
-------------------------------------
function SummonedCreature:setWaitState(is_wait_state)
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
-- function setDamage
-------------------------------------
function SummonedCreature:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    if (not self.m_charTable or not self.m_charTable['attacked_type']) then return end

    local attacked_type = self.m_charTable['attacked_type']
    local is_active_skill = t_info and t_info['attack_type'] and t_info['attack_type'] == 'active'

    if (attacked_type == 'active_only' and is_active_skill) then
        PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)

    elseif (attacked_type == 'both') then
        PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)

    end
end