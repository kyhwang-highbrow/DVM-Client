-------------------------------------
-- class EffectLink
-------------------------------------
EffectLink = class({
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
function EffectLink:init(res, bar_visual, start_visual, end_visual, width, height, is_repeat, attr, fire_distance)
    local bar_visual = (bar_visual or 'bar_appear')
    local start_visual = (start_visual or 'start_appear')
    local end_visual = (end_visual or 'end_appear')
    local fire_distance = fire_distance or 0

    local width = (width or 600)
    local height = (height or 600)
    local is_repeat = (is_repeat ~= nil) and is_repeat or true

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
    self.m_effectNode = self:createWithParent(self.m_clippingNode, 0, fire_distance, 0, res, bar_visual, is_repeat, attr)
    self.m_effectNode.m_node:setAnchorPoint(cc.p(0.5, 0))

    -- start
    self.m_startPointNode = self:createWithParent(self.m_node, 0, fire_distance, 0, res, start_visual, is_repeat, attr)
    self.m_startPointNode.m_node:setAnchorPoint(cc.p(0.5, 0.5))

    -- end
    self.m_endPointNode = self:createWithParent(self.m_node, 0, fire_distance, 0, res, end_visual, is_repeat, attr)
    self.m_endPointNode.m_node:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_endPointNode.m_node:setPositionY(height)

    self.m_bRotateEndEffect = true
end

-------------------------------------
-- function setVisible
-------------------------------------
function EffectLink:setVisible(visible)
    self.m_node:setVisible(visible)
end

-------------------------------------
-- function setScale
-------------------------------------
function EffectLink:setScale(scale)
    self.m_node:setScale(scale)
end

-------------------------------------
-- function EffectLink_setRotation
-------------------------------------
function EffectLink_setRotation(self, degree)
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
-- function setIgnoreLowEndMode
-------------------------------------
function EffectLink:setIgnoreLowEndMode(ignore)
    self.m_startPointNode:setIgnoreLowEndMode(ignore)
    self.m_effectNode:setIgnoreLowEndMode(ignore)
    self.m_endPointNode:setIgnoreLowEndMode(ignore)
end

-------------------------------------
-- function EffectLink_setPosition
-------------------------------------
function EffectLink_setPosition(self, x, y)
    self.m_node:setPosition(x, y)
end

-------------------------------------
-- function EffectLink_setHeight
-------------------------------------
function EffectLink_setHeight(self, height)
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
-- function refreshAction
-------------------------------------
function EffectLink:refreshAction()
	self.m_effectNode:setAlpha(0)
    self.m_effectNode:runAction(cc.FadeIn:create(0.05))
end

-------------------------------------
-- function EffectLink_refresh
-------------------------------------
function EffectLink_refresh(self, start_x, start_y, end_x, end_y)
    local degree = getDegree(start_x, start_y, end_x, end_y)
    local distance = math_distance(start_x, start_y, end_x, end_y)
    
    EffectLink_setPosition(self, start_x, start_y)
    EffectLink_setRotation(self, degree)
    EffectLink_setHeight(self, distance)
end

-------------------------------------
-- function createWithParent
-------------------------------------
function EffectLink:createWithParent(parent, x, y, z_order, res_name, visual_name, is_repeat, attr)
    local animator = MakeAnimator(res_name)
	animator:setAniAttr(attr)
    animator:changeAni(visual_name, is_repeat)
    animator.m_node:setPosition(x, y)
    parent:addChild(animator.m_node, z_order)

    return animator
end

-------------------------------------
-- function registCommonAppearAniHandler
-- @brief 공통 등장 에니메이션 핸들러 등록
-------------------------------------
function EffectLink:registCommonAppearAniHandler()
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
function EffectLink:changeCommonAni(ani_name, loop, anihandler)
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
-- function changeAni
-- @brief 구조상 필요
-------------------------------------
function EffectLink:changeAni(ani_name, loop)
	-- @TODO 인디케이터에서 idle_2를 사용하는데  g_constant:get('INDICATOR', 'RES', 'target') 에는 없다.. 추후에 문제가 될수도...
	if (ani_name == 'idle_2') then
		ani_name = 'idle'
	end

    local loop = (loop or false)
    self.m_startPointNode:changeAni('start_' .. ani_name, loop)
    self.m_effectNode:changeAni('bar_' .. ani_name, loop)
    self.m_endPointNode:changeAni('end_' .. ani_name, loop)
end

-------------------------------------
-- function setColor
-------------------------------------
function EffectLink:setColor(color)
    self.m_startPointNode:setColor(color)
    self.m_effectNode:setColor(color)
    self.m_endPointNode:setColor(color)
end

-------------------------------------
-- function setOpacity
-------------------------------------
function EffectLink:setOpacity(opacity)
    self.m_startPointNode:setOpacity(opacity)
    self.m_effectNode:setOpacity(opacity)
    self.m_endPointNode:setOpacity(opacity)
end

-------------------------------------
-- function addAniHandler
-- @brief 구조상 필요
-------------------------------------
function EffectLink:addAniHandler(anihandler)
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
function EffectLink:doNotUseHead()
	self.m_startPointNode:setVisible(false)
	self.m_endPointNode:setVisible(false)
end

-------------------------------------
-- function release
-------------------------------------
function EffectLink:release()
    if self.m_node then
        self.m_node:removeFromParent(true)
        self.m_node = nil
    end
end