-------------------------------------
-- class LinkEffect
-------------------------------------
LinkEffect = class({
        m_node = 'CCNode',
        m_clippingNode = 'CCClippingNode',
        m_stencil = 'DrawNode',
        m_startPointNode = 'CCNode',
        m_endPointNode = 'CCNode',
        m_effectNode = 'CCNode',
        m_width = 'number',
        m_bRotateEndEffect = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function LinkEffect:init(res, bar_visual, start_visual, end_visual, width, height)
    local bar_visual = (bar_visual or 'bar_appear')
    local start_visual = (start_visual or 'start_appear')
    local end_visual = (end_visual or 'end_appear')

    local width = (width or 320)
    local height = (height or 300)

    self.m_width = width

    -- node 생성
    self.m_node = cc.Node:create()
	self.m_node:setPositionX(-100)

    -- clipping node 생성
    self.m_clippingNode = cc.ClippingNode:create()
    self.m_node:addChild(self.m_clippingNode)

    -- stencil 생성
    self.m_stencil = cc.DrawNode:create()
    self.m_stencil:clear()
    local rectangle = {}
    local white = cc.c4b(1,1,1,1)
    table.insert(rectangle, cc.p(-(width/2), 0))
    table.insert(rectangle, cc.p((width/2), 0))
    table.insert(rectangle, cc.p((width/2), height))
    table.insert(rectangle, cc.p(-(width/2), height))
    self.m_stencil:drawPolygon(rectangle, 4, white, 1, white)
    self.m_clippingNode:setStencil(self.m_stencil)

    -- effect
    self.m_effectNode = self:createWithParent(self.m_clippingNode, 0, 0, 0, res, bar_visual, true)
    self.m_effectNode.m_node:setAnchorPoint(cc.p(0.5, 0))

    -- start
    self.m_startPointNode = self:createWithParent(self.m_node, 0, 0, 0, res, start_visual, true)
    self.m_startPointNode.m_node:setAnchorPoint(cc.p(0.5, 0.5))

    -- end
    self.m_endPointNode = self:createWithParent(self.m_node, 0, 0, 0, res, end_visual, true)
    self.m_endPointNode.m_node:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_endPointNode.m_node:setPositionY(height)

    self.m_bRotateEndEffect = true
end

-------------------------------------
-- function setVisible
-------------------------------------
function LinkEffect:setVisible(visible)
    self.m_node:setVisible(visible)
end

-------------------------------------
-- function rotate
-------------------------------------
function LinkEffect_setRotation(self, degree)
    local rotation = (-(degree - 90))
    self.m_node:setRotation(rotation)

    local degree, gap, real_gap = getRotationDegree(degree, 90, 360)
    real_gap = -real_gap
    real_gap = (-(real_gap - 90))

    if self.m_bRotateEndEffect then
        self.m_startPointNode:setRotation(real_gap + 90)
        self.m_endPointNode.m_node:setRotation(real_gap + 90)
    end
end

-------------------------------------
-- function ignoreLowEndMode
-------------------------------------
function LinkEffect:setIgnoreLowEndMode(ignore)
    self.m_startPointNode:setIgnoreLowEndMode(ignore)
    self.m_effectNode:setIgnoreLowEndMode(ignore)
    self.m_endPointNode:setIgnoreLowEndMode(ignore)
end

-------------------------------------
-- function setPosition
-------------------------------------
function LinkEffect_setPosition(self, x, y)
    self.m_node:setPosition(x, y)
end

-------------------------------------
-- function setHeight
-------------------------------------
function LinkEffect_setHeight(self, height)
    local width = self.m_width
    local height = height

    self.m_stencil:clear()
    local rectangle = {}
    local white = cc.c4b(1,1,1,1)
    table.insert(rectangle, cc.p(-(width/2), 0))
    table.insert(rectangle, cc.p((width/2), 0))
    table.insert(rectangle, cc.p((width/2), height))
    table.insert(rectangle, cc.p(-(width/2), height))
    self.m_stencil:drawPolygon(rectangle, 4, white, 1, white)

    self.m_endPointNode.m_node:setPositionY(height)
end

-------------------------------------
-- function refresh
-------------------------------------
function LinkEffect_refresh(self, start_x, start_y, end_x, end_y)
    local degree = getDegree(start_x, start_y, end_x, end_y)
    local distance = math_distance(start_x, start_y, end_x, end_y)
    
    LinkEffect_setPosition(self, start_x, start_y)
    LinkEffect_setRotation(self, degree)
    LinkEffect_setHeight(self, distance)
end

-------------------------------------
-- function createWithParent
-------------------------------------
function LinkEffect:createWithParent(parent, x, y, z_order, res_name, visual_name, is_repeat)

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
function LinkEffect:registCommonAppearAniHandler()
    local function start_ani_handler() self.m_startPointNode:changeAni('start_idle', true) end
    self.m_startPointNode:addAniHandler(start_ani_handler)

    local function bar_ani_handler() self.m_effectNode:changeAni('bar_idle', true) end
    self.m_effectNode:addAniHandler(bar_ani_handler)

    local function end_ani_handler() self.m_endPointNode:changeAni('end_idle', true) end
    self.m_endPointNode:addAniHandler(end_ani_handler)
end

-------------------------------------
-- function changeCommonAni
-- @brief 공통 에니메이션 변경
-------------------------------------
function LinkEffect:changeCommonAni(ani_name, loop, anihandler)
    loop = (loop or false)

    self.m_startPointNode:changeAni('start_' .. ani_name, loop)
    self.m_effectNode:changeAni('bar_' .. ani_name, loop)
    self.m_endPointNode:changeAni('end_' .. ani_name, loop)

    if (not anihandler) then
        return
    end

    self.m_startPointNode:addAniHandler(nil)
    self.m_effectNode:addAniHandler(anihandler)
    self.m_endPointNode:addAniHandler(nil)
end

-------------------------------------
-- function doNotUseHead
-- @TODO start - effect - end node 전부 사용함을 가정하고 있기 때문에 하나만 덜어내는 것이 어려워 임시 처리
-------------------------------------
function LinkEffect:doNotUseHead()
	self.m_startPointNode:setVisible(false)
end

-------------------------------------
-- function release
-------------------------------------
function LinkEffect:release()
    if self.m_node then
        self.m_node:removeFromParent(true)
        self.m_node = nil
    end
end