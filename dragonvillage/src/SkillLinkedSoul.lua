local PARENT = class(Skill, IEventListener:getCloneTable())

-------------------------------------
-- class SkillLinkedSoul
-- @TODO 덩치가 매우 커서 나누어야 할 필요가 있다. 하지만 특수한 스킬이 될 경우 그럴 필요는 없다고 판단되어 우선 기능 동작하도록 하고
-- 추후에 비슷한 스킬이 늘어났을때 구조화 하여 사용, 
-- skillSpatter 처럼 status_effect_trigger 구조를 사용하는 것도 좋음, skillGuadian 도 묶어야함
-------------------------------------
SkillLinkedSoul = class(PARENT, {
        m_targetChar = 'Character',
		m_res = 'string',
        m_duration = 'num',
		m_healRate = 'number',
		m_healAbs = 'number',
		m_damageReduceRate = 'number',
		m_aoeHealRange = 'number',

		m_preSKillTime = 'number',
		m_skillInterval = 'number', 

        m_shieldEffect = 'Animator',
        m_barEffect = 'EffectLink',
        m_barrierEffect1 = 'Animator',
        m_barrierEffect2 = 'Animator',

		m_bDirtyPos = 'boolean', -- 위치가 변경되어 이펙트 수정이 필요한 경우
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillLinkedSoul:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLinkedSoul:init_skill(duration, res, damage_ruduce_rate, aoe_heal_range)
	PARENT.init_skill(self)

	-- 멤버 변수
	self.m_duration = duration
	self.m_res = res
	self.m_healRate = (self.m_powerRate/100)
	self.m_healAbs = self.m_powerAbs
	self.m_damageReduceRate = (1 - (damage_ruduce_rate/100))
	self.m_aoeHealRange = aoe_heal_range

	self.m_preSKillTime = self.m_duration
	self.m_skillInterval = SKILL_GLOBAL_COOLTIME
end


-------------------------------------
-- function initState
-------------------------------------
function SkillLinkedSoul:initState()
	self:setCommonState(self)
    self:addState('start', SkillLinkedSoul.st_start, 'buff_effect', true)
    self:addState('idle', SkillLinkedSoul.st_idle, 'idle', true)
    self:addState('end', SkillLinkedSoul.st_end, 'ready', false)
end

-------------------------------------
-- function st_start
-------------------------------------
function SkillLinkedSoul.st_start(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:makeEffectLink()
        owner:onStart()

        local function func()
            owner:changeState('idle')
        end

        owner:addAniHandler(func)
    end

	-- 리소스 생성후 애니메이션 끝날때까지 체크
    owner:checkDurability(dt)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillLinkedSoul.st_idle(owner, dt)
	owner:checkDurability(dt)
end

-------------------------------------
-- function st_end
-------------------------------------
function SkillLinkedSoul.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:onEnd()

        -- 방패 이팩트
        owner.m_shieldEffect:changeAni('shield_disappear', false)
        
        -- 연결 이팩트
        owner.m_barEffect.m_effectNode:changeAni('bar_disappear', false)

        -- 베리어 이팩트
        owner.m_barrierEffect1:changeAni('barrier_disappear', false)
        owner.m_barrierEffect2:changeAni('barrier_disappear', false)

    elseif (owner.m_stateTimer >= 2) then
		-- 적당히 diappear animation이 끝난 후 동작
        owner:changeState('dying')
    end
end

-------------------------------------
-- function checkDurablity
-------------------------------------
function SkillLinkedSoul:checkDurability(dt)
	if (self.m_owner.m_bDead) then
		self:changeState('end')
	end
    if (self.m_duration == -1) then
        return
    end

    self.m_duration = self.m_duration - dt
	
    if (self.m_duration <= 0) then
        self:changeState('end')
	else
		-- 위치 갱신이 필요한지 확인
		self:checkBuffPosDirty()

		-- 위치 변경 처리
		if self.m_bDirtyPos then
			self:updateBuffPos()
		end
    end
end

-------------------------------------
-- function makeEffectLink
-------------------------------------
function SkillLinkedSoul:makeEffectLink()
	local res = self.m_res

    -- 연결 이펙트 -- @TODO groundnode..? 여기서만 사용중
    self.m_barEffect = EffectLink(res, 'bar_appear', '', '', 512, 256)
    self.m_world.m_groundNode:addChild(self.m_barEffect.m_node)
    self.m_barEffect.m_startPointNode:setVisible(false)
    self.m_barEffect.m_endPointNode:setVisible(false)
    self.m_barEffect.m_effectNode:addAniHandler(function() self.m_barEffect.m_effectNode:changeAni('bar_idle', true) end)

    -- 베리어 이펙트
    self.m_barrierEffect1 = MakeAnimator(res)
    self.m_barrierEffect1:changeAni('barrier_appear', false)
    self.m_barrierEffect1:addAniHandler(function() self.m_barrierEffect1:changeAni('barrier_idle', true) end)
    self.m_rootNode:addChild(self.m_barrierEffect1.m_node)

    -- 베리어 이펙트
    self.m_barrierEffect2 = MakeAnimator(res)
    self.m_barrierEffect2:changeAni('barrier_appear', false)
    self.m_barrierEffect2:addAniHandler(function() self.m_barrierEffect2:changeAni('barrier_idle', true) end)
    self.m_rootNode:addChild(self.m_barrierEffect2.m_node)

    -- 방패 이펙트
    self.m_shieldEffect = MakeAnimator(res)
    self.m_shieldEffect:changeAni('shield_appear', false)
    self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
    self.m_rootNode:addChild(self.m_shieldEffect.m_node)
end

-------------------------------------
-- function onStart
-- @brief listener를 owner와 target한테 등록
-------------------------------------
function SkillLinkedSoul:onStart()
	self.m_owner:addListener('undergo_attack_linked_owner', self)
	self.m_targetChar:addListener('undergo_attack_linked_target', self)
end

-------------------------------------
-- function onHit
-------------------------------------
function SkillLinkedSoul:onHit()
    -- 방패 이팩트
    self.m_shieldEffect:changeAni('shield_hit', false)
    self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
        
    -- 연결 이팩트
    self.m_barEffect.m_effectNode:changeAni('bar_hit', false)
    self.m_barEffect.m_effectNode:addAniHandler(function() self.m_barEffect.m_effectNode:changeAni('bar_idle', true) end)

    -- 베리어 이팩트
    self.m_barrierEffect1:changeAni('barrier_hit', false)
    self.m_barrierEffect1:addAniHandler(function() self.m_barrierEffect1:changeAni('barrier_idle', true) end)

    self.m_barrierEffect2:changeAni('barrier_hit', false)
    self.m_barrierEffect2:addAniHandler(function() self.m_barrierEffect2:changeAni('barrier_idle', true) end)
end

-------------------------------------
-- function onEnd
-- @brief listener 전부 해제
-------------------------------------
function SkillLinkedSoul:onEnd()
	self.m_owner:removeListener('undergo_attack_linked_owner', self)
	self.m_targetChar:removeListener('undergo_attack_linked_target', self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function SkillLinkedSoul:onEvent(event_name, t_event, ...)
	-- 쿨타임 적용
	if (self.m_preSKillTime - self.m_duration > self.m_skillInterval) then
		self.m_preSKillTime = clone(self.m_duration)
	else
		return
	end

	if (event_name == 'undergo_attack_linked_owner') then
		local target = self.m_targetChar

		-- 타격 연출
		self:onHit()
		
		-- 감소된 데미지 만큼 링크 대상 힐
		local reduced_damage = t_event['reduced_damage']
		self:doHeal(target, reduced_damage)

		-- 피해 나눔
		t_event['damage'] = self:seperateDamage(t_event['damage'], target)

		-- 광역 힐 시전
		self:doAoeHeal(target, (reduced_damage/2))

	elseif (event_name == 'undergo_attack_linked_target') then
		-- 타격 연출
		self:onHit()

		-- 피해 나눔
		t_event['damage'] = self:seperateDamage(t_event['damage'], self.m_owner)
	end
end

-------------------------------------
-- function doHeal
-- @brief 타겟에 회복 수행, 이팩트 생성
-------------------------------------
function SkillLinkedSoul:doHeal(target, heal_org)
    if target and (not target.m_bDead) then
		-- 힐은 데미지 경감에 대한 상대치 + 절대치
		local heal = (heal_org * self.m_healRate) + self.m_healAbs
        target:healAbs(heal, true)

		-- 나에게로부터 상대에게 가는 힐 이펙트 생성 -> res가 없음
		--[[
        local effect_heal = EffectHeal('', {0,0,0})
        effect_heal:initState()
        effect_heal:changeState('move')
        effect_heal:init_EffectHeal(self.pos.x, self.pos.y, target)
		local world = self.m_world
        world.m_physWorld:addObject(PHYS.EFFECT, effect_heal)
        world.m_worldNode:addChild(effect_heal.m_rootNode, 0)
        world:addToUnitList(effect_heal)
		]]
    end
end

-------------------------------------
-- function seperateDamage
-- @brief 데미지를 감소 시킨 후 반으로 나누어 owner와 target에게 분배한다 
-------------------------------------
function SkillLinkedSoul:seperateDamage(damage, linked_char)
	-- 데미지 감소가 없다면 패시브가 활성되지 않은것으로 간주하여 탈출
	if (self.m_damageReduceRate == 1) then 
		return damage 
	end

	-- 감소된 데미지 계산
	local reduced_damage = (damage * self.m_damageReduceRate)
	local ret_damage = (reduced_damage / 2)

	-- 이벤트 발생 주체가 아닌 대상은 직접 데미지를 가한다
	linked_char:setDamage(nil, linked_char, linked_char.pos.x, linked_char.pos.y, ret_damage, nil)
	
	-- 자신한테는 undergo_attack 을 통하여 데미지 전달
	return ret_damage
end

-------------------------------------
-- function doAoeHeal
-- @brief 광역힐 시전
-------------------------------------
function SkillLinkedSoul:doAoeHeal(target, damage)
	-- range가 0 이라면 탈출
	if (self.m_aoeHealRange == 0) then return end

	-- 힐할 대상을 찾는다
    local l_remove = {target}
    local l_target = self.m_owner:getFormationMgr():findNearTarget(target.pos.x, target.pos.y, self.m_aoeHealRange, -1, l_remove)

	-- 힐 시전
	for i,v in pairs(l_target) do
		self:doHeal(v, damage)
    end
end

-------------------------------------
-- function checkBuffPosDirty
-------------------------------------
function SkillLinkedSoul:checkBuffPosDirty()
    -- 본체 변경 확인
    if (self.pos.x ~= self.m_owner.pos.x) or (self.pos.y ~= self.m_owner.pos.y) then
        self.m_bDirtyPos = true
        return
    end

    -- 베리어 대상자 변경 확인
    local x = self.m_targetChar.pos.x - self.pos.x
    local y = self.m_targetChar.pos.y - self.pos.y
    if (self.m_barrierEffect2.m_posX ~= x) or (self.m_barrierEffect2.m_posY ~= y) then
        self.m_bDirtyPos = true
        return
    end
end

-------------------------------------
-- function updateBuffPos
-------------------------------------
function SkillLinkedSoul:updateBuffPos()
    local x = self.m_targetChar.pos.x - self.pos.x
    local y = self.m_targetChar.pos.y - self.pos.y
    self.m_barrierEffect2:setPosition(x, y)
    self.m_shieldEffect:setPosition(x, y)
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
    EffectLink_refresh(self.m_barEffect, self.pos.x, self.pos.y, self.m_targetChar.pos.x, self.m_targetChar.pos.y)

    self.m_bDirtyPos = false
end

-------------------------------------
-- function release
-------------------------------------
function SkillLinkedSoul:release()
    PARENT.release(self)

    if self.m_barEffect then
        self.m_barEffect:release()
        self.m_barEffect = nil
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillLinkedSoul:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local duration = t_skill['val_1']
	local damage_ruduce_rate = t_skill['val_2']
	local aoe_heal_range = t_skill['val_3']
	local res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillLinkedSoul(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(duration, res, damage_ruduce_rate, aoe_heal_range)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end