local PARENT = SkillScript

-------------------------------------
-- class SkillScript_ClanRaidBossFinish
-------------------------------------
SkillScript_ClanRaidBossFinish = class(PARENT, {})

-------------------------------------
-- function initActvityCarrier
-------------------------------------
function SkillScript_ClanRaidBossFinish:initActvityCarrier()
    PARENT.initActvityCarrier(self)

    self.m_activityCarrier:setIgnoreAll(true)
    self.m_activityCarrier:setDefiniteDeath(true)
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillScript_ClanRaidBossFinish:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    self.m_lTargetChar = self.m_world:getDragonList()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillScript_ClanRaidBossFinish:initState()
    self:setCommonState(self)
	
    self:addState('start', SkillScript_ClanRaidBossFinish.st_appear, nil, false)
    self:addState('attack', SkillScript_ClanRaidBossFinish.st_attack, nil, false)
    self:addState('end', SkillScript_ClanRaidBossFinish.st_disappear, nil, false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillScript_ClanRaidBossFinish.st_appear(owner, dt)
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
function SkillScript_ClanRaidBossFinish.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
        local unit = owner.m_owner

        -- 주체 유닛 애니 설정
        unit.m_animator:changeAni('skill_idle', true)

        -- 미사일 발사
        owner:runAttack()
	end

    if (owner.m_stateTimer >= owner.m_duration) then
        owner:changeState('end')
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillScript_ClanRaidBossFinish.st_disappear(owner, dt)
	if (owner.m_stateTimer == 0) then
        local unit = owner.m_owner

        -- 주체 유닛 애니 설정
        unit.m_animator:changeAni('skill_disappear', false)
        unit.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)

        -- 플레이어 모두 죽임(혹시 안죽는 경우를 방지하기 위함)
        owner.m_world:removeAllHero()
    end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillScript_ClanRaidBossFinish:runAttack()
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
function SkillScript_ClanRaidBossFinish:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = t_skill['res_1']
    local script_name = t_skill['val_1']
    local duration = t_skill['val_2']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillScript_ClanRaidBossFinish(res)

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