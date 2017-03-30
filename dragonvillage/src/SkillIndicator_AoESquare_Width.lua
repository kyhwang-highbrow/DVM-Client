local PARENT = SkillIndicator_AoESquare

-------------------------------------
-- class SkillIndicator_AoESquare_Width
-------------------------------------
SkillIndicator_AoESquare_Width = class(PARENT, { 
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoESquare_Width:init(hero, t_skill)
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoESquare_Width:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('square_width', skill_size)  

		self.m_indicatorScale = t_data['scale']
		self.m_skillHeight = t_data['size']
	end
end

-------------------------------------
-- function setIndicatorPosition
-------------------------------------
function SkillIndicator_AoESquare_Width:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
	local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
    self.m_indicatorEffect:setPosition(cameraHomePosX - pos_x, touch_y - pos_y)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoESquare_Width:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'square_width')
        local indicator = MakeAnimator(indicator_res)
        indicator:setRotation(0)
        root_node:addChild(indicator.m_node)
		indicator.m_node:setColor(COLOR_CYAN)
        self.m_indicatorEffect = indicator
        indicator.m_node:setScaleY(self.m_indicatorScale)
    end
end