local PARENT = SkillScript

local CON_SKILL_IDLE = 'skill_idle'

-------------------------------------
-- class SkillScript_ClanRaidBoss
-------------------------------------
SkillScript_ClanRaidBoss = class(PARENT, {})

-------------------------------------
-- function initEventListener
-- @breif 이벤트 처리..
-------------------------------------
function SkillScript_ClanRaidBoss:initEventListener()
    PARENT.initEventListener(self)

    self:addListener(CON_SKILL_IDLE, self)
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillScript_ClanRaidBoss:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    self.m_lTargetChar = self.m_world:getDragonList()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillScript_ClanRaidBoss:init_skill(script_name, duration)
    PARENT.init_skill(self, script_name, duration)

    -- 받는 피해 증가 상태효과 설정
    local struct_status_effect = StructStatusEffect({
        type = 'cldg_dmg_add',
		target_type = 'self',
		target_count = 1,
		trigger = CON_SKILL_IDLE,
		duration = self.m_duration + 0.5,
		rate = 100,
		value = 250,
        source = '',
    })
    table.insert(self.m_lStatusEffect, struct_status_effect)

    -- 다중 광폭화 상태효과 설정
    local struct_status_effect = StructStatusEffect({
        type = 'passive_fury',
		target_type = 'ally_all',
		target_count = '',
		trigger = CON_SKILL_END,
		duration = -1,
		rate = 100,
		value = 100,
        source = '',
    })
    table.insert(self.m_lStatusEffect, struct_status_effect)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillScript_ClanRaidBoss:initState()
    self:setCommonState(self)
	
    self:addState('start', SkillScript_ClanRaidBoss.st_appear, nil, false)
    self:addState('attack', SkillScript_ClanRaidBoss.st_attack, nil, false)
    self:addState('end', SkillScript_ClanRaidBoss.st_disappear, nil, false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillScript_ClanRaidBoss.st_appear(owner, dt)
	if (owner.m_stateTimer == 0) then
        local unit = owner.m_owner

        -- 주체 유닛 애니 설정
        unit.m_animator:changeAni('skill_appear', false)
        unit.m_animator:addAniHandler(function()
            owner:changeState('attack')
        end)
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillScript_ClanRaidBoss.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
        local unit = owner.m_owner

        -- 주체 유닛 애니 설정
        unit.m_animator:changeAni('skill_idle', true)

        -- 미사일 발사
        owner:runAttack()
                
        -- idle 애니메이션 시작시 발동되는 status effect를 적용
		owner:dispatch(CON_SKILL_IDLE, {l_target = {owner.m_targetChar}})
	end

    if (owner.m_stateTimer >= owner.m_duration) then
        owner:changeState('end')
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillScript_ClanRaidBoss.st_disappear(owner, dt)
	if (owner.m_stateTimer == 0) then
        local unit = owner.m_owner

        -- 주체 유닛 애니 설정
        unit.m_animator:changeAni('skill_disappear', false)
        unit.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)
    end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillScript_ClanRaidBoss:runAttack()
    -- attack pos 가져옴
    local pos = self:getOwnerAttackPos('skill_idle')
    if (not pos) then
        pos = { x = 0, y = 0 }
    end

    self:do_script_shot(pos['x'], pos['y'], PHYS.MISSILE.ENEMY)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillScript_ClanRaidBoss:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = t_skill['res_1']
    local script_name = t_skill['val_1']
    local duration = t_skill['val_2']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillScript_ClanRaidBoss(res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(script_name, duration)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode('bottom')
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end