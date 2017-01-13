local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_AoESquare_Height
-------------------------------------
SkillIndicator_AoESquare_Height = class(PARENT, {
        m_skillWidth = 'number',
		m_skillHeight = 'number',
		m_indicatorAddEffect = 'a2d',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoESquare_Height:init(hero, t_skill)
    self.m_skillWidth = t_skill['val_1']
	self.m_skillHeight = t_skill['val_2']
	self.m_indicatorScale = t_skill['res_scale']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_AoESquare_Height:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local t_collision_obj = self:findTarget(x, y)

    self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 조정
    self.m_indicatorEffect:setPosition(x - pos_x, -CRITERIA_RESOLUTION_Y/2)
    self.m_indicatorAddEffect:setPosition(x - pos_x, y - pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoESquare_Height:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator(RES_INDICATOR['HEALING_WIND'])
        indicator:setTimeScale(5)
        root_node:addChild(indicator.m_node)
		indicator.m_node:setColor(COLOR_CYAN)
        self.m_indicatorEffect = indicator

        local scale_x = self.m_skillWidth/360 --@TODO 리소스를 고치자 답이 없음
        indicator.m_node:setScaleX(scale_x)
    end

	do -- 커서 이펙트
		local indicator = MakeAnimator(RES_INDICATOR['HEALING_WIND'])
		indicator:setTimeScale(5)
		indicator:changeAni('cursor', true)
		root_node:addChild(indicator.m_node)
		self.m_indicatorAddEffect = indicator
	end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_AoESquare_Height:findTarget(x, y)
    local world = self.m_world

    local l_target = world:getTargetList(nil, x, y, 'all', 'x', 'distance_x')
    
    local l_ret = {}

    local std_width = (self.m_skillWidth / 2)
	local std_height = (self.m_skillHeight / 2)

    for i,v in ipairs(l_target) do
		if isCollision_Rect(x, y, v, std_width, std_height) then
            table.insert(l_ret, v)
		end
    end

    return l_ret
end
