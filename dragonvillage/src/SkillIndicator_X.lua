local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_X
-------------------------------------
SkillIndicator_X = class(PARENT, {
		m_indicatorAddEffect = '',
		m_lineSize = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_X:init(hero, t_skill)
	self.m_lineSize = g_constant:get('SKILL', 'VOLTES_LINE_SIZE')
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_X:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local t_collision_obj, l_collision_bodys = self:findTarget(x, y)
    
    self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 위치
    self.m_indicatorEffect:setPosition(x - pos_x, y - pos_y)
	self.m_indicatorAddEffect:setPosition(x - pos_x, y - pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj, l_collision_bodys)
end



-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_X:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- X
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'voltes_x')
        local indicator = MakeAnimator(indicator_res)
        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end

    do -- Cursor
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'round')
        local indicator = MakeAnimator(indicator_res)
        indicator:changeAni('skill_range_normal', true)
		indicator:setScale(0.2)
        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end
end


-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_X:onChangeTargetCount(old_target_count, cur_target_count)
    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorEffect.m_node:setColor(COLOR_RED)
        self.m_indicatorAddEffect.m_node:setColor(COLOR_RED)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorEffect.m_node:setColor(COLOR_CYAN)
		self.m_indicatorAddEffect.m_node:setColor(COLOR_CYAN)
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_X:findTarget(pos_x, pos_y)
	local l_target = self:getProperTargetList()
	local t_ret = {}
    local t_ret_bodys = {}
	
    local radius = 20
	local std_width = (CRITERIA_RESOLUTION_X / 2)
	local std_height = (CRITERIA_RESOLUTION_Y / 2)
	
	local target_x, target_y = pos_x, pos_y
    
	-- 레이저에 충돌된 모든 객체 리턴
	for i = 1, 2 do 
		local t_collision_obj, l_collision_bodys = self:findTargetEachLine(l_target, target_x, target_y, std_width, std_height, i)
		
		for i, obj in pairs(t_collision_obj) do
			table.insert(t_ret, obj)
		end
        for i, body in pairs(l_collision_bodys) do
			table.insert(t_ret_bodys, body)
		end
    end
	
	return t_ret, t_ret_bodys
end

-------------------------------------
-- function findTargetEachLine
-------------------------------------
function SkillIndicator_X:findTargetEachLine(l_target, target_x, target_y, std_width, std_height, idx)
	local start_x = target_x - std_width
	local start_y = target_y - (std_height * (math_pow(-1, idx)))
		
	local end_x = target_x + std_width
	local end_y = target_y + (std_height * (math_pow(-1, idx)))

	return SkillTargetFinder:findTarget_Bar(l_target, start_x, start_y, end_x, end_y, self.m_lineSize/2)
end