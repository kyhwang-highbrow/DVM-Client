-------------------------------------
-- class EffectLinearDot
-------------------------------------
EffectLinearDot = class({
        m_node = 'CCNode',
        m_resName = '',
        m_bar_visual = '',
        m_lEffectNode = 'CCNode'
    })

-------------------------------------
-- function init
-------------------------------------
function EffectLinearDot:init(res_name, bar_visual)
    self.m_lEffectNode = {}
    self.m_resName = res_name
    self.m_bar_visual = bar_visual

    -- node 생성
    self.m_node = cc.Node:create()
end

-------------------------------------
-- function setVisible
-------------------------------------
function EffectLinearDot:setVisible(visible)
    self.m_node:setVisible(visible)
end

-------------------------------------
-- function refresh
-------------------------------------
function EffectLinearDot_refresh(self, tar_x, tar_y, pos_x, pos_y, degree)
    local t_line_pos = {}
	
	local degree = degree

	local std_dist = 60
    local rad = math_rad(degree)

    local factor_y = math.tan(rad)
	local dist_x = tar_x - pos_x
	local dist_y = tar_y - pos_y
    
	-- 임의의 숫자 20개까지 만듬
	for i = 1, 20 do
        local x = dist_x + (std_dist * i)
        local y = dist_y + (std_dist * i * factor_y)
        table.insert(t_line_pos, {x = x, y = y})
    end

	local effectNode = nil
	for i, line_pos in pairs(t_line_pos) do
		if (nil == self.m_lEffectNode[i]) then
			-- 없을 경우 생성 
			effectNode = self:createWithParent(self.m_node, line_pos['x'], line_pos['y'], 0, self.m_resName, self.m_bar_visual, true)
			effectNode.m_node:setAnchorPoint(cc.p(0.5, 0))
			table.insert(self.m_lEffectNode, effectNode)
		else
			-- 있을 경우 위치 지정
			effectNode = self.m_lEffectNode[i]
            effectNode:setPosition(line_pos['x'], line_pos['y'])
		end
		
        effectNode:setRotation(degree)
    end

end

-------------------------------------
-- function createWithParent
-------------------------------------
function EffectLinearDot:createWithParent(parent, x, y, z_order, res_name, visual_name, is_repeat)
    local animator = MakeAnimator(res_name)
    animator:changeAni(visual_name, is_repeat)
    animator.m_node:setPosition(x, y)
    parent:addChild(animator.m_node, z_order)

    return animator
end

-------------------------------------
-- function registCommonAppearAniHandler
-- @brief 공통 등장 에니메이션 핸들러 등록
-------------------------------------
function EffectLinearDot:registCommonAppearAniHandler()
	-- local function bar_ani_handler() self.m_effectNode:changeAni('bar_idle', true) end
    -- self.m_effectNode:addAniHandler(bar_ani_handler)

    -- local function start_ani_handler() self.m_startPointNode:changeAni('start_idle', true) end
    -- self.m_startPointNode:addAniHandler(start_ani_handler)

    -- local function end_ani_handler() self.m_endPointNode:changeAni('end_idle', true) end
    -- self.m_endPointNode:addAniHandler(end_ani_handler)
end

-------------------------------------
-- function changeAni
-------------------------------------
function EffectLinearDot:changeAni(ani_name, loop)
    local loop = (loop or false)

    for i, v in pairs(self.m_lEffectNode) do
		v:changeAni(ani_name, loop)
	end
end

-------------------------------------
-- function release
-------------------------------------
function EffectLinearDot:release()
    for i, node in pairs(self.m_lEffectNode) do
        node:removeFromParent(true)
    end
    self.m_lEffectNode = nil
    
    if self.m_node then
        self.m_node:removeFromParent(true)
        self.m_node = nil
    end
end