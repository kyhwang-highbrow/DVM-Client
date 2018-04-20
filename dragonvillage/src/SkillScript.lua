local PARENT = class(Skill, IStateDelegate:getCloneTable())

-- TODO: 스킬과 맞추고 add_option_trigger를 사용하기 위해 발사되는 미사일에 콜백 등록이 필요

-------------------------------------
-- class SkillScript
-------------------------------------
SkillScript = class(PARENT, {
        m_scriptName = 'string',
        m_duration = 'number',
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillScript:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillScript:init_skill(script_name, duration)
    PARENT.init_skill(self)

    self.m_scriptName = script_name
    self.m_duration = duration
end

-------------------------------------
-- function do_script_shot
-------------------------------------
function SkillScript:do_script_shot(x, y, phys_group)
    local t_skill = self.m_owner:getSkillTable(self.m_skillId)
    local attr = self.m_owner:getAttribute()
    
    local b, missile_launcher = self.m_owner:do_script_shot(t_skill, attr, phys_group, x, y, {script = self.m_scriptName})
    if (b and missile_launcher) then
        missile_launcher.m_activityCarrier = self.m_activityCarrier
        missile_launcher.m_cbFunction = function(attacker, defender, x, y)
		    self:onAttack(defender)
	    end
    end
end

-------------------------------------
-- function getOwnerAttackPos
-- @breif 스킬 소유자의 해당 애니메이션에 있는 attack 이벤트 좌표값을 얻어옴(차후 글로벌 함수로 빼는게 나을듯)
-------------------------------------
function SkillScript:getOwnerAttackPos(ani_name)
    local unit = self.m_owner

    -- attack event 가져옴
    local l_event_data = unit.m_animator:getEventList(ani_name, 'attack')
    if (not l_event_data[1]) then return end

    local string_value = l_event_data[1]['stringValue']
    if (not string_value) or (string_value == '') then return end

    local x, y = 0, 0

    local l_str = seperate(string_value, ',')
    if (l_str) then
        local scale = unit.m_animator:getScale()
        local flip = unit.m_animator.m_bFlip
                        
        x = l_str[1] * scale
        y = l_str[2] * scale

        if flip then
            x = -x
        end
    end

    return { x = x, y = y }
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillScript:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = t_skill['res_1']
    local script_name = t_skill['val_1']
    local duration = t_skill['val_2']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillScript(res)

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