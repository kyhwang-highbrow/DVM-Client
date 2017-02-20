local PARENT = SkillAoERound

-------------------------------------
-- class SkillAoERound_Sura
-------------------------------------
SkillAoERound_Sura = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound_Sura:init(file_name, body, ...)    
end
 
-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoERound_Sura:init_skill(attack_count, range, aoe_res)
    PARENT.init_skill(self, attack_count, range, aoe_res, nil)
end

-------------------------------------
-- function setAttackInterval
-- @Overridding
-------------------------------------
function SkillAoERound:setAttackInterval()
	-- 공격 애니 재생시간을 hit수로 나눔
	self.m_hitInterval = (self.m_animator:getDuration() / self.m_maxAttackCnt)
	cclog(self.m_hitInterval)
end

-------------------------------------
-- function doSpecailEffect
-- @Overridding
-------------------------------------
function SkillAoERound_Sura:doSpecailEffect(t_target)

end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound_Sura:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
    local range = t_skill['val_1']		  -- 공격 반경
	
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 개별 타겟 이펙트 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound_Sura(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, range, aoe_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
