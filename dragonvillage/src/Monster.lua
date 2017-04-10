local PARENT = Character

-------------------------------------
-- class Monster
-------------------------------------
Monster = class(PARENT, {
        m_bWaitState = 'boolean',
		m_regenInfo = 'boolean',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster:init(file_name, body, ...)
    self.m_charType = 'monster'
    self.m_bWaitState = false
	self.m_regenInfo = nil
end

-------------------------------------
-- function init_monster
-------------------------------------
function Monster:init_monster(t_monster, monster_id, level, stage_id)
    local t_drop = TABLE:get('drop')[stage_id]
    local level = level + t_drop['level']

    -- 각종 init 함수 실행
	self:initDragonSkillManager('monster', monster_id, 6) -- monster는 skill_1~skill_6을 모두 사용
    self:initStatus(t_monster, level, 0, 0, 0)
    self:initAnimatorMonster(t_monster['res'], t_monster['attr'], t_monster['scale'])
    self:makeCastingNode()
	self:initTriggerListener()		

    -- 피격 처리
    self:addDefCallback(function(attacker, defender, i_x, i_y)
        self:undergoAttack(attacker, defender, i_x, i_y, 0)
    end)

	-- @TODO character 수준으로 들어가야한다. + monster_id 는 고유하지 않다 
    self.m_charLogRecorder = self.m_world.m_logRecorder:getLogRecorderChar(monster_id)
end

-------------------------------------
-- function initFormation
-------------------------------------
function Monster:initFormation(body_size)
    local hp_ui_offset = {0, -(body_size[3] * 1.5)}

	-- 진영에 따른 처리
	if (self.m_bLeftFormation) then
        self:changeState('idle')
        self:makeHPGauge(hp_ui_offset)
    else
        self:changeState('move')
	    self:makeHPGauge(hp_ui_offset)
        self.m_animator:setFlip(true)
    end
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Monster:initAnimator(file_name)
end

-------------------------------------
-- function initAnimatorMonster
-------------------------------------
function Monster:initAnimatorMonster(file_name, attr, scale)
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeMonsterAnimator(file_name, attr)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
		if (scale) then
			self.m_animator:setScale(scale)
		end
    end

    -- 각종 쉐이더 효과 시 예외 처리할 슬롯 설정(Spine)
    self:blockMatchingSlotShader('effect_')

    -- 하이라이트 노드 설정
    self:addHighlightNode(self.m_animator.m_node)
end

-------------------------------------
-- function initState
-------------------------------------
function Monster:initState()
    PARENT.initState(self)

    self:addState('charge', Monster.st_charge, 'idle', true)
    self:addState('casting', Monster.st_casting, 'idle', true)

    self:addState('wait', Monster.st_wait, 'idle', true)
end

-------------------------------------
-- function setRegenInfo
-- @brief 리젠 정보를 저장한다.
-------------------------------------
function Monster:setRegenInfo(t_info)
    self.m_regenInfo = t_info
end

-------------------------------------
-- function setDead
-- @overriding
-------------------------------------
function Monster:setDead()
    PARENT.setDead(self)

	-- regen된 몹이라면 waveMgr에 알려준다.
	if (self.m_regenInfo) then
		local idx = self.m_regenInfo['idx']
		self.m_world.m_waveMgr:setRegenDead(idx)
	end
end

-------------------------------------
-- function st_charge
-------------------------------------
function Monster.st_charge(owner, dt)
    if (owner.m_stateTimer == 0) then

        -- 차지 이팩트 재생
        local res = 'res/effect/effect_attack_ready/effect_attack_ready.vrp'
        local animator = MakeAnimator(res)
        animator:changeAni('idle', false)
        owner.m_rootNode:addChild(animator.m_node)
        local duration = animator:getDuration()
        animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

        local size_type = owner.m_charTable['size_type']
        if (size_type == 's') then
            animator:setPosition(0, -25)
        elseif (size_type == 'm') then
            animator:setPosition(0, -50)
        elseif (size_type == 'l') then
            animator:setPosition(0, -75)
        end

    elseif (owner.m_stateTimer >= 0.5) then
        owner.m_chargeDuration = owner.m_stateTimer
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_casting
-------------------------------------
function Monster.st_casting(owner, dt)
    PARENT.st_casting(owner, dt)

    if owner.m_state == 'casting' and owner.m_stateTimer == 0 then
        SoundMgr:playEffect('EFFECT', 'monster_skill_cast')
    end
end

-------------------------------------
-- function setWaitState
-------------------------------------
function Monster:setWaitState(is_wait_state)
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
-- function release
-------------------------------------
function Monster:release()
    PARENT.release(self)

    if self.m_world then
        self.m_world:removeEnemy(self)
    end
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function Monster:changeState(state, forced)
    if self.m_bWaitState then
        if (not isExistValue(state, 'dying', 'dead')) then
            return PARENT.changeState(self, 'wait', false)
        end
    end

    return PARENT.changeState(self, state, forced)
end

-------------------------------------
-- function getBodySize
-------------------------------------
function Monster:getBodySize(size_type)
	local size = g_constant:get('INGAME', 'BODY_SIZE')[size_type] or 50
	local body = {0, 0, size}

	return body
end