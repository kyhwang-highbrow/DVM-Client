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

function UIC_Node:setEnabled(enable)
    return self.m_node:setEnabled(enable)
end

function UIC_Node:setVisible(visible)
    return self.m_node:setVisible(visible)
end

function UIC_Node:getPosition()
    return self.m_node:getPosition()
end

function UIC_Node:setPosition(x, y)
    return self.m_node:setPosition(x, y)
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

function UIC_Node:removeAllChildren(cleanup)
    return self.m_node:removeAllChildren(cleanup)
end