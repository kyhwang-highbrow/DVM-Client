local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_AoESquare
-------------------------------------
SkillIndicator_AoESquare = class(PARENT, {
        m_skillWidth = 'number',
		m_skillHeight = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoESquare:init(hero, t_skill)
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoESquare:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	self.m_skillWidth = g_constant:get('SKILL', 'LONG_LENGTH')
	self.m_skillHeight = g_constant:get('SKILL', 'LONG_LENGTH')
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoESquare:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local t_collision_obj, t_collision_bodys = self:findTarget(x, y)

    self.m_targetPosX = x
    self.m_targetPosY = y

	-- 이펙트 위치 조정
	self:setIndicatorPosition(x, y, pos_x, pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj, t_collision_bodys)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoESquare:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'sqaure')
        local indicator = MakeAnimator(indicator_res)
		
		indicator.m_node:setColor(COLOR_CYAN)
        
		root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_AoESquare:findTarget(x, y)
    local l_target = self.m_hero:getTargetListByType(self.m_targetType, self.m_targetFormation)
    local x = x
	local y = y
	local width = (self.m_skillWidth / 2)
	local height = (self.m_skillHeight / 2)

    return SkillTargetFinder:findTarget_AoESquare(l_target, x, y, width, height)
end
