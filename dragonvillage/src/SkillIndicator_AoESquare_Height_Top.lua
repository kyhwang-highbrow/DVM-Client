local PARENT = SkillIndicator_AoESquare

-------------------------------------
-- class SkillIndicator_AoESquare_Height_Top
-------------------------------------
SkillIndicator_AoESquare_Height_Top = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoESquare_Height_Top:init(hero, t_skill)
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoESquare_Height_Top:init_indicator(t_skill)
	PARENT.init_indicator(self, t_skill)

	local skill_size = t_skill['skill_size']
	if (skill_size) and (not (skill_size == '')) then
		local t_data = SkillHelper:getSizeAndScale('square_height', skill_size)  

		self.m_indicatorScale = t_data['scale']
		self.m_skillWidth = t_data['size']
	end
end

-------------------------------------
-- function setIndicatorPosition
-------------------------------------
function SkillIndicator_AoESquare_Height_Top:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
	local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
	local camera_scale = self.m_world.m_gameCamera:getScale()
	local scr_size = cc.Director:getInstance():getWinSize()
    
    self.m_indicatorEffect:setPosition(touch_x - pos_x, (cameraHomePosY - pos_y + scr_size['height'] / 2) / camera_scale)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoESquare_Height_Top:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'square_height')
        local indicator = MakeAnimator(indicator_res)
        
		indicator:setScaleX(self.m_indicatorScale)
		indicator:setScaleY(1)
        indicator:setRotation(270)
		self:initIndicatorEffect(indicator)
        
		root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillIndicator_AoESquare_Height_Top:findCollision(x, y)
    local l_target = self:getProperTargetList()
    local x = x
	local y = y
	local width = (self.m_skillWidth / 2)
	local height = self.m_skillHeight

    local l_ret = SkillTargetFinder:findCollision_AoESquare(l_target, x, y, width, height, true)

    -- y값이 큰 순으로 정렬
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            local y_a = a:getPosY()
            local y_b = b:getPosY()

            if (y_a == y_b) then
                return a:getDistance() < b:getDistance()
            else
                return y_a > y_b
            end
        end)
    end

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function optimizeIndicatorData
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator_AoESquare_Height_Top:optimizeIndicatorData(l_target, fixed_target)
    return SkillIndicator_AoESquare_Height.optimizeIndicatorData(self, l_target, fixed_target)
end

-------------------------------------
-- function optimizeIndicatorDataByArena
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator_AoESquare_Height_Top:optimizeIndicatorDataByArena(l_target)
    return SkillIndicator_AoESquare_Height.optimizeIndicatorDataByArena(self, l_target)
end