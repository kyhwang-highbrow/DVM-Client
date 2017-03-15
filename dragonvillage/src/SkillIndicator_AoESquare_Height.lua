local PARENT = SkillIndicator_AoESquare

-------------------------------------
-- class SkillIndicator_AoESquare_Height
-------------------------------------
SkillIndicator_AoESquare_Height = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoESquare_Height:init(hero, t_skill, target_type)
end

-------------------------------------
-- function setIndicatorPosition
-------------------------------------
function SkillIndicator_AoESquare_Height:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
	local _, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
    self.m_indicatorEffect:setPosition(touch_x - pos_x, cameraHomePosY - pos_y)
    self.m_indicatorAddEffect:setPosition(touch_x - pos_x, touch_y - pos_y)
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
        root_node:addChild(indicator.m_node)
		indicator.m_node:setColor(COLOR_CYAN)
        self.m_indicatorEffect = indicator

        local scale_x = self.m_skillWidth/360 --@TODO 리소스를 고치자 답이 없음
        indicator.m_node:setScaleX(scale_x)
    end

	do -- 커서 이펙트
		local indicator = MakeAnimator(RES_INDICATOR['HEALING_WIND'])
		indicator:changeAni('cursor', true)
		root_node:addChild(indicator.m_node)
		self.m_indicatorAddEffect = indicator
	end
end
