-------------------------------------
-- class UIC_Node
-------------------------------------
UIC_Node = class({
        m_node = 'cc.Node',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_Node:init(node)
    self.m_node = node
end

-------------------------------------
-- function create
-------------------------------------
function UIC_Node:create()
    local node = cc.Node:create()
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))
    return UIC_Node(node)
end

-------------------------------------
-- function initGLNode
-------------------------------------
function UIC_Node:initGLNode()
    -- glNode 생성
    local glNode = cc.GLNode:create()
    glNode:registerScriptDrawHandler(function(transform, transformUpdated) self:primitivesDraw(transform, transformUpdated) end)
    self.m_node:addChild(glNode)
end

-------------------------------------
-- function primitivesDraw
-------------------------------------
function UIC_Node:primitivesDraw(transform, transformUpdated)
    kmGLPushMatrix()
    kmGLLoadMatrix(transform)

    local width, height = self.m_node:getNormalSize()
    local origin = cc.p(0, 0)
    local destination = cc.p(width, height)
    local color = cc.c4f(0.2, 0.2, 0.2, 0.5)
    cc.DrawPrimitives.drawSolidRect(origin, destination, color)

    kmGLPopMatrix()
end

function UIC_Node:setEnabled(enable)
    return self.m_node:setEnabled(enable)
end

function UIC_Node:isEnabled()
    return self.m_node:isEnabled()
end

function UIC_Node:setVisible(visible)
    return self.m_node:setVisible(visible)
end

function UIC_Node:isVisible()
    return self.m_node:isVisible()
end

function UIC_Node:getPosition()
    return self.m_node:getPosition()
end

function UIC_Node:getPositionX()
    local pos_x, pos_y = self.m_node:getPosition()
    return pos_x
end

function UIC_Node:getPositionY()
    local pos_x, pos_y = self.m_node:getPosition()
    return pos_y
end

function UIC_Node:setPosition(x, y)
    if (x == nil) then
        return
    elseif (x ~= nil) and (y == nil) and (type(x) == 'table') then
        return self.m_node:setPosition(x.x, x.y)
    else
        return self.m_node:setPosition(x, y)
    end
end

function UIC_Node:setPositionX(x)
    return self.m_node:setPositionX(x)
end

function UIC_Node:setPositionY(y)
    return self.m_node:setPositionY(y)
end

function UIC_Node:addChild(child, z_order)
    return self.m_node:addChild(child, z_order or 0)
end

function UIC_Node:getParent()
    return self.m_node:getParent()
end

function UIC_Node:getBoundingBox()
    return self.m_node:getBoundingBox()
end

function UIC_Node:convertToWorldSpaceAR(pos)
    return self.m_node:convertToWorldSpaceAR(pos)
end

function UIC_Node:convertToNodeSpaceAR(pos)
    return self.m_node:convertToNodeSpaceAR(pos)
end

function UIC_Node:runAction(action)
    return self.m_node:runAction(action)
end

function UIC_Node:stopAllActions()
    return self.m_node:stopAllActions()
end

function UIC_Node:getNormalSize()
    return self.m_node:getNormalSize()
end

function UIC_Node:setNormalSize(width, height)
    local ret = self.m_node:setNormalSize(width, height)

    -- 자식 node들의 transform을 update(dockpoint의 영향이 있을수 있으므로)
    self.m_node:setUpdateChildrenTransform()

    return ret
end

function UIC_Node:setContentSize(size)
    return self.m_node:setContentSize(size)
end


function UIC_Node:getContentSize()
    return self.m_node:getContentSize()
end

function UIC_Node:setDockPoint(dock_point)
    return self.m_node:setDockPoint(dock_point)
end

function UIC_Node:getDockPoint()
    return self.m_node:getDockPoint()
end

function UIC_Node:setAnchorPoint(anchor_point)
    return self.m_node:setAnchorPoint(anchor_point)
end

function UIC_Node:getAnchorPoint()
    return self.m_node:getAnchorPoint()
end

function UIC_Node:getScale()
    return self.m_node:getScale()
end

function UIC_Node:getScaleX()
    return self.m_node:getScaleX()
end

function UIC_Node:getScaleY()
    return self.m_node:getScaleY()
end

function UIC_Node:removeAllChildren(cleanup)
    return self.m_node:removeAllChildren(cleanup)
end

function UIC_Node:setOpacity(opacity)
    return self.m_node:setOpacity(opacity)
end

function UIC_Node:getColor()
    return self.m_node:getColor()
end

function UIC_Node:setColor(color)
    return self.m_node:setColor(color)
end

function UIC_Node:setScale(scale)
    return self.m_node:setScale(scale)
end

function UIC_Node:setRotation(rotation)
    return self.m_node:setRotation(rotation)
end

function UIC_Node:getRotation()
    return self.m_node:getRotation()
end

function UIC_Node:isVisible()
    return self.m_node:isVisible()
end

function UIC_Node:isRunning()
    return self.m_node:isRunning()
end

function UIC_Node:registerScriptHandler(func)
    return self.m_node:registerScriptHandler(func)
end

function UIC_Node:setLocalZOrder(z_order)
    return self.m_node:setLocalZOrder(z_order)
end

function UIC_Node:getLocalZOrder()
    return self.m_node:getLocalZOrder()
end

function UIC_Node:retain()
    return self.m_node:retain()
end

function UIC_Node:release()
    return self.m_node:release()
end

function UIC_Node:removeFromParent()
    return self.m_node:removeFromParent()
end
