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

        -- 스킬 마나
        m_activeSkillManaCost = 'SecurityNumberClass',
        m_originActiveSkillManaCost = 'SecurityNumberClass',

        m_skillPrepareEffect = '',
		
        m_isUseMovingAfterImage = 'boolean',
		m_bWaitState = 'boolean',
     })




-------------------------------------
-------------------------------------
-------------------------------------
-- object lifecycles
-------------------------------------
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
-------------------------------------
-- Initializer
-------------------------------------
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

    self:addState('charge', Monster.st_charge, 'idle', true)
    self:addState('casting', Monster.st_casting, 'idle', true)

    self:addState('wait', Monster.st_wait, 'idle', true)
end


-------------------------------------
-------------------------------------
-------------------------------------
-- getter, setter
-------------------------------------
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