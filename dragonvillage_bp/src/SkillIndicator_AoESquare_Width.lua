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
        table.sort(l_ret, function(a, b)
            return a:getPosX() < b:getPosX()
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
function SkillIndicator_AoESquare_Width:optimizeIndicatorData(l_target, fixed_target)
    local max_count = -1
    local t_best = {}
    
    local setIndicator = function(target, x, y)
        self.m_targetChar = target
        self.m_targetPosX = x
        self.m_targetPosY = y
        self.m_critical = nil
        self.m_bDirty = true

        self:getTargetForHighlight() -- 타겟 리스트를 사용하지 않고 충돌리스트 수로 체크

        local list = self.m_collisionList or {}
        local count = #list

        -- 반드시 포함되어야하는 타겟이 존재하는지 확인
        if (fixed_target) then
            if (not table.find(self.m_highlightList, fixed_target)) then
                count = -1
            end
        end
        
        return count
    end

    
    for _, v in ipairs(l_target) do
        for i, body in ipairs(v:getBodyList()) do
            local skill_half = self.m_skillHeight / 2

            local min_y = v.pos['y'] + body['y'] - body['size'] - skill_half + 1
            local max_y = v.pos['y'] + body['y'] + body['size'] + skill_half - 1

            for _, y in ipairs({ min_y, max_y }) do
                local count = setIndicator(v, v.pos['x'], y)

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
        setIndicator(t_best['target'], t_best['x'], t_best['y'])
        return true
    end

    return false
end