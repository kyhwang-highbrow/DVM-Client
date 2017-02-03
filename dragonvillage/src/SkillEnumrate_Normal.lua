local PARENT = SkillEnumrate

-------------------------------------
-- class   
-------------------------------------
SkillEnumrate_Normal = class(PARENT, {
		m_missileRes = 'string',
        m_motionStreakRes = 'string',

		m_skillLineNum = 'num',		-- 공격 하는 직선 갯수
		m_skillLineSize = 'num',	-- 직선의 두께

		m_skillTimer = 'time',
		m_skillTotalTime = 'time',	-- 적절하게 계산된 총 등장 시간
		m_skillInterval = 'time',
		m_skillCount = 'num',

		m_skillAttackPosList = 'pos list',
		m_skillDirList = 'dir list',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillEnumrate_Normal:init(file_name, body, ...)
end

-------------------------------------
-- function init_SkillEnumrate_Normal
-------------------------------------
function SkillEnumrate_Normal:init_skill(missile_res, motionstreak_res, line_num, line_size)
	PARENT.init_skill(self, missile_res, motionstreak_res, line_num, line_size)

	-- 1. 멤버 변수
	self.m_skillInterval = P_RANDOM_INTERVAL
	self.m_lRandomTargetList = self:getRandomTargetList()
	self.m_enumTargetType = 'target'
	self.m_enumPosType = 'linear'
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillEnumrate_Normal:fireMissile(idx)

end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillEnumrate_Normal:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])
	local motionstreak_res = (t_skill['res_2'] == 'x') and nil or string.gsub(t_skill['res_2'], '@', owner.m_charTable['attr'])

	local line_num = t_skill['hit']
	local line_size = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillEnumrate_Normal(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, line_num, line_size)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end