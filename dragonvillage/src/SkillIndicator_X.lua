local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_X
-------------------------------------
SkillIndicator_X = class(PARENT, {
		m_indicatorAddEffect = '',
		m_physGroup = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_X:init(hero, t_skill)
	self.m_physGroup = nil
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_X:onTouchMoved(x, y)
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local t_collision_obj = self:findTarget(x, y)
    
    self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 위치
    self.m_indicatorEffect:setPosition(x - pos_x, y - pos_y)
	self.m_indicatorAddEffect:setPosition(x - pos_x, y - pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj)
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
        local indicator = MakeAnimator(RES_INDICATOR['X'])
        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end

    do -- Cursor
        local indicator = MakeAnimator(RES_INDICATOR['X'])
        indicator:changeAni('cursor', true)
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
	local t_collision_obj = nil
	local t_ret = {}
	
    local radius = 20
	local std_width = (1280 / 2)
	local std_height = (720 / 2)
	
	local target_x, target_y = pos_x, pos_y
	local start_x, start_y = nil, nil
	local end_x, end_y = nil, nil
    
	if (not self.m_physGroup) then
		self.m_physGroup = self.m_hero:getAttackPhysGroup()
	end

	-- 레이저에 충돌된 모든 객체 리턴
	for i = 1, 2 do 
		
		start_x = target_x - std_width
		start_y = target_y - (std_height * (math_pow(-1, i)))
		
		end_x = target_x + std_width
		end_y = target_y + (std_height * (math_pow(-1, i)))
		
		t_collision_obj = self.m_world.m_physWorld:getLaserCollision(
			start_x, start_y,
			end_x, end_y, radius, self.m_physGroup)
		
		for i, obj in pairs(t_collision_obj) do 
			table.insert(t_ret, obj['obj'])
		end
    end
	
	return t_ret
end