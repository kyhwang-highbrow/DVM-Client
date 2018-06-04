local PARENT = Skill

-------------------------------------
-- class SkillResurrect
-------------------------------------
SkillResurrect = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillResurrect:init(file_name, body, ...)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillResurrect:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillResurrect:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    if (self.m_targetChar) then
        self.m_targetChar.m_resurrect = self
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillResurrect:initState()
	self:setCommonState(self)
    self:addState('start', SkillResurrect.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillResurrect.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 부활
        owner:runResurrect()

		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function runResurrect
-------------------------------------
function SkillResurrect:runResurrect()
    local l_target = self:findTarget()

    for _, target in ipairs(l_target) do
        local atk_dmg = self.m_activityCarrier:getAtkDmg(target)
        local heal = HealCalc_M(atk_dmg) * self.m_activityCarrier:getPowerRate() / 100

        target:doRevive(heal, self.m_owner, true)

        self:onHeal(target)
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillResurrect:findTarget()
    local l_target = {}

    if (self.m_targetChar) then
        table.insert(l_target, self.m_targetChar)
    else
        
    end

    return l_target
end

-------------------------------------
-- function doStatusEffect
-- @brief l_start_con 조건에 해당하는 statusEffect를 적용
-------------------------------------
function SkillResurrect:doStatusEffect(start_con, l_target)
    local lStatusEffect = self:getStatusEffectList(start_con)
    
    if (#lStatusEffect > 0) then
        local l_target = l_target
		local add_param = self.m_activityCarrier.m_tParam

        -- 드래그 스킬의 경우엔 충돌 정보를 파라미터에 추가시킴
        if (self.m_chanceType == 'active') then
            if (start_con == CON_SKILL_START) then
                l_target = self.m_lTargetChar
                add_param['skill_collision_list'] = self.m_lTargetCollision
            else
                l_target = l_target or self:findTarget()
                add_param['skill_collision_list'] = convertToListFrom2DArray(self.m_hitCollisionList)
            end
        else
            l_target = l_target or self:findTarget()
        end
        
        cclog('SkillResurrect:doStatusEffect count : ' .. #l_target)

        StatusEffectHelper:doStatusEffectByStruct(self.m_owner, l_target, lStatusEffect, nil, self.m_skillId, add_param)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillResurrect:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillResurrect(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill()
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end