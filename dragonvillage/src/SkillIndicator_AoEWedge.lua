local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_AoEWedge
-------------------------------------
SkillIndicator_AoEWedge = class(PARENT, {
		m_skillRange = 'num',
		m_skillAngle = 'num',
    })
	 
-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoEWedge:init(hero, t_skill)
	self.m_skillRange = g_constant:get('SKILL', 'LONG_LENGTH')
	self.m_indicatorAngleLimit = g_constant:get('SKILL', 'ANGLE_LIMIT')
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoEWedge:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('wedge', skill_size)  

		self.m_indicatorScale = 1
		self.m_skillAngle = t_data['size']
	end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoEWedge:onTouchMoved(x, y)
    local pos_x, pos_y = self:getAttackPosition()
	local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
	
	-- 1. 각도 제한
	local t_ret = self:checkIndicatorLimit(dir, nil)
    dir = t_ret['angle']

	if (t_ret['is_change']) then 
		self.m_targetPosX = x
		self.m_targetPosY = y
	end
	
	-- 이펙트 조정
	self.m_indicatorEffect:setRotation(dir)

	-- 하이라이트 갱신
	local t_collision_obj = self:findTarget(dir)
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoEWedge:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'wedge'..self.m_skillAngle)
        local indicator = MakeAnimator(indicator_res)
		
		indicator.m_node:setColor(COLOR_CYAN)
		indicator:setPosition(self:getAttackPosition())
		indicator:setScale(self.m_indicatorScale)

        root_node:addChild(indicator.m_node)
		self.m_indicatorEffect = indicator
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_AoEWedge:findTarget(dir)
	local char = self.m_hero
	local l_target = char:getTargetListByType(self.m_targetType, self.m_targetFormation)
	local dir = dir
	return SkillTargetFinder:findTarget_AoEWedge(l_target, char.pos.x, char.pos.y, dir, self.m_skillRange, self.m_skillAngle)
end