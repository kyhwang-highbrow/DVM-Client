local PARENT = SkillIndicator_AoESquare

-------------------------------------
-- class SkillIndicator_AoESquare_Width_Right
-------------------------------------
SkillIndicator_AoESquare_Width_Right = class(PARENT, { 
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoESquare_Width_Right:init(hero, t_skill)
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoESquare_Width_Right:init_indicator(t_skill)
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
function SkillIndicator_AoESquare_Width_Right:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
	local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    local camera_scale = self.m_world.m_gameCamera:getScale()
	local scr_size = cc.Director:getInstance():getWinSize()
    
	self.m_indicatorEffect:setPosition(cameraHomePosX - pos_x + scr_size['width'], touch_y - pos_y)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoESquare_Width_Right:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'square_width')
        local indicator = MakeAnimator(indicator_res)

		indicator:setScaleX(self.m_indicatorScale)
		indicator:setScaleY(1)
        indicator:setRotation(180)
		self:initIndicatorEffect(indicator)

        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillIndicator_AoESquare_Width_Right:findCollision(x, y)
    local l_target = self:getProperTargetList()
    local x = x
	local y = y
	local width = (self.m_skillWidth / 2)
	local height = (self.m_skillHeight / 2)

    local l_ret = SkillTargetFinder:findCollision_AoESquare(l_target, x, y, width, height, true)

    -- x값이 큰 순으로 정렬
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            return a:getPosX() > b:getPosX()
        end)
    end

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end