local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_Laser
-- @breif 이름이 bar여야 하는데...
-------------------------------------
SkillIndicator_Laser = class(PARENT, {
        m_thickness = 'number', -- 레이저의 굵기
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Laser:init(hero, t_skill)
	self.m_indicatorAngleLimit = g_constant:get('SKILL', 'ANGLE_LIMIT')
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_Laser:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('bar', skill_size)  

		self.m_indicatorScale = t_data['scale']
		self.m_thickness = t_data['size']
	end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Laser:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local pos_x, pos_y = self:getAttackPosition()

	-- 각도 제한
    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
	local t_ret = self:checkIndicatorLimit(dir, nil)
    dir = t_ret['angle']

    self.m_targetPosX = x
    self.m_targetPosY = y

	-- 이펙트 조정
	self.m_targetDir = dir
    self.m_indicatorEffect:setRotation(dir)

    if (not t_ret['is_change']) then
        local adjust_pos = getPointFromAngleAndDistance(dir, 500)
        local ap1 = {x=pos_x, y=pos_y}
        local ap2 = {x=pos_x+adjust_pos['x'], y=pos_y+adjust_pos['y']}
        local bp1 = {x=0, y=y}
        local bp2 = {x=3000, y=y}
        local ip_x, ip_y = getIntersectPoint(ap1, ap2, bp1, bp2)

        self.m_targetPosX = (ip_x + self.m_attackPosOffsetX)
        self.m_targetPosY = (ip_y + self.m_attackPosOffsetY)
    end

	-- 하이라이트 갱신
	local l_collision = self:findCollision(pos_x, pos_y, dir)
	self:setHighlightEffect(l_collision)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Laser:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'bar')
        local indicator = MakeAnimator(indicator_res)
        
		indicator:setPosition(self.m_attackPosOffsetX, self.m_attackPosOffsetY)
        indicator:setScaleX(self.m_indicatorScale)
		indicator:setScaleY(1)
		self:initIndicatorEffect(indicator)

        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillIndicator_Laser:findCollision(pos_x, pos_y, dir)
	local l_target = self:getProperTargetList()
    local end_pos = getPointFromAngleAndDistance(dir, 2560)    
    local end_x = pos_x + end_pos['x']
    local end_y = pos_y + end_pos['y']

	local l_ret = SkillTargetFinder:findCollision_Bar(l_target, pos_x, pos_y, end_x, end_y, self.m_thickness/2)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end