local PARENT = SkillIndicator_AoECone

-------------------------------------
-- class SkillIndicator_AoECone_Vertical
-------------------------------------
SkillIndicator_AoECone_Vertical = class(PARENT, {
		
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoECone_Vertical:init(hero, t_skill)
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoECone_Vertical:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    self.m_targetPosX = x
    self.m_targetPosY = y

	local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
	self.m_indicatorEffect:setPosition(x - pos_x, y - pos_y)

	-- 하이라이트 갱신
	local t_collision_obj = self:findTargetList(x, y)
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoECone_Vertical:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do
        local indicator = MakeAnimator(RES_INDICATOR['CONE'..self.m_skillAngle])
        indicator:changeAni('idle', true)
        indicator:setRotation(90)
		indicator.m_node:setScaleY(self.m_skillRadius/504) --self.m_indicatorScale)
        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end

	return true
end

-------------------------------------
-- function findTargetList
-------------------------------------
function SkillIndicator_AoECone_Vertical:findTargetList(x, y)
    local l_target = self.m_owner:getTargetListByType(self.m_targetType, self.m_targetFormation)
    return SkillTargetFinder:findTarget_AoECone(l_target, x, y, 90, self.m_skillRadius, self.m_skillAngle)
    --[[
    local world = self:getWorld()

    local t_data = {}
    t_data['x'] = x
    t_data['y'] = y
    t_data['dir'] = 90
    t_data['angle_range'] = self.m_skillAngle
    t_data['radius'] = self.m_skillRadius

    return world:getTargetList(self.m_hero, x, y, 'enemy', nil, 'fan_shape', t_data)
    ]]--
end