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
	local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    local camera_scale = self.m_world.m_gameCamera:getScale()
	local scr_size = cc.Director:getInstance():getWinSize()

    self.m_indicatorEffect:setPosition(cameraHomePosX - pos_x - scr_size['width'] / 2, touch_y - pos_y)
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

		indicator:setScaleX(self.m_indicatorScale)
		indicator:setScaleY(1)
        indicator:setRotation(0)
		self:initIndicatorEffect(indicator)

        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillIndicator_AoESquare_Width:findCollision(x, y)
    local l_target = self:getProperTargetList()
    local x = x
	local y = y
	local width = self.m_skillWidth
	local height = (self.m_skillHeight / 2)

    local l_ret = SkillTargetFinder:findCollision_AoESquare(l_target, x, y, width, height, true)

    -- x값이 작은 순으로 정렬
    if (#l_ret > 1) then
        if (self.m_hero.m_bLeftFormation) then
            table.sort(l_ret, function(a, b)
                local x_a = a:getPosX()
                local x_b = b:getPosX()

                if (x_a == x_b) then
                    return a:getDistance() < b:getDistance()
                else
                    return x_a < x_b
                end
            end)
        else
            table.sort(l_ret, function(a, b)
                local x_a = a:getPosX()
                local x_b = b:getPosX()

                if (x_a == x_b) then
                    return a:getDistance() < b:getDistance()
                else
                    return x_a > x_b
                end
            end)
        end
    end

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function optimizeIndicatorData
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator_AoESquare_Width:optimizeIndicatorData(l_target, fixed_target)
    local max_count = -1
    local t_best = {}
        
    for _, v in ipairs(l_target) do
        for i, body in ipairs(v:getBodyList()) do
            local skill_half = self.m_skillHeight / 2

            local min_y = v.pos['y'] + body['y'] - body['size'] - skill_half + 1
            local max_y = v.pos['y'] + body['y'] + body['size'] + skill_half - 1

            for _, y in ipairs({ min_y, max_y }) do
                local count = self:getCollisionCountByVirtualTest(v.pos['x'], y, fixed_target)

                if (max_count < count) then
                    max_count = count

                    t_best = { 
                        target = self.m_targetChar,
                        x = self.m_targetPosX,
                        y = self.m_targetPosY
                    }
                end

                if (max_count >= self.m_targetLimit) then break end
            end
        end
    end

    if (max_count > 0) then
        self:setIndicatorData(t_best['x'], t_best['y'])
        return true
    end

    return false
end

-------------------------------------
-- function optimizeIndicatorDataByArena
-- @brief 가장 많이 타겟팅할 수 있도록 인디케이터 정보를 설정
-------------------------------------
function SkillIndicator_AoESquare_Width:optimizeIndicatorDataByArena(l_target)
    local t_best
        
    for _, v in ipairs(l_target) do
        for i, body in ipairs(v:getBodyList()) do
            local skill_half = self.m_skillHeight / 2

            local min_y = v.pos['y'] + body['y'] - body['size'] - skill_half + 1
            local max_y = v.pos['y'] + body['y'] + body['size'] + skill_half - 1

            for _, y in ipairs({ min_y, max_y }) do
                local value, count = self:getTotalSortValueByVirtualTest(v.pos['x'], y)
                local b = false

                if (count > 0) then
                    if (not t_best) then
                        b = true
                    elseif (t_best['value'] < value) then
                        b = true
                    elseif (t_best['value'] == value and t_best['count'] < count) then
                        b = true
                    end
                end

                if (b) then
                    t_best = { 
                        target = self.m_targetChar,
                        x = self.m_targetPosX,
                        y = self.m_targetPosY,
                        value = value,
                        count = count
                    }
                end
            end
        end
    end

    if (t_best) then
        self:setIndicatorData(t_best['x'], t_best['y'])
        return true
    end

    return false
end