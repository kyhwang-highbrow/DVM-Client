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