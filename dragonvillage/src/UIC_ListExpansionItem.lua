local PARENT = UIC_Node

-------------------------------------
-- class UIC_ListExpansionItem
-- 참고 UI https://uimovement.com/design/list-expansion/
-------------------------------------
UIC_ListExpansionItem = class(PARENT, {
        m_node = 'cc.Node',

        m_itemName = 'string',

        m_uicClippingNode = '',

        m_collapsedSize = 'cc.Size',
        m_expandedSize = 'cc.Size',

        m_actionDuration = 'number',
        
        m_isExpanded = 'bool',
    })

local THIS = UIC_ListExpansionItem

-------------------------------------
-- function init
-------------------------------------
function UIC_ListExpansionItem:init(node)
    self.m_node = node
end

-------------------------------------
-- function configExpansionItem
-------------------------------------
function UIC_ListExpansionItem:configExpansionItem(item_name, expandedNode, collapsedNode, clippingNode, duration, expanded)
    self.m_itemName = item_name

    if expandedNode then
        self.m_expandedSize = cc.size(expandedNode:getNormalSize())
    end

    if collapsedNode then
        self.m_collapsedSize = cc.size(collapsedNode:getNormalSize())
    end

    if duration then
        self.m_actionDuration = duration
    end

    if clippingNode then
        self.m_uicClippingNode = clippingNode
    end

    if (expanded ~= nil) then
        self:setExpansion(expanded, true)
    end
end

-------------------------------------
-- function setExpansion
-------------------------------------
function UIC_ListExpansionItem:setExpansion(is_expanded, is_immediately)
    self.m_isExpanded = is_expanded

    local uic_clipping_node = self.m_uicClippingNode
    uic_clipping_node.m_node:stopAllActions()
    

    if is_immediately then
        if (is_expanded) then
            uic_clipping_node:setNormalSize(self.m_expandedSize['width'], self.m_expandedSize['height'])
        else
            uic_clipping_node:setNormalSize(self.m_collapsedSize['width'], self.m_collapsedSize['height'])
        end
        return
    end


    
    local duration = self.m_actionDuration
  

    if (is_expanded) then

        local func = function(value)
            uic_clipping_node:setNormalSize(self.m_expandedSize['width'], value)
        end

        local width, height = uic_clipping_node:getNormalSize()
        local tween = cc.ActionTweenForLua:create(duration, height, self.m_expandedSize['height'], func)
        local action = cc.EaseInOut:create(tween, 2)
        cca.runAction(uic_clipping_node.m_node, action, TAG_CELL_WIDTH_TO)

    else
        local func = function(value)
            uic_clipping_node:setNormalSize(self.m_collapsedSize['width'], value)
        end

        local width, height = uic_clipping_node:getNormalSize()
        local tween = cc.ActionTweenForLua:create(duration, height, self.m_collapsedSize['height'], func)
        local action = cc.EaseInOut:create(tween, 2)
        cca.runAction(uic_clipping_node.m_node, action, TAG_CELL_WIDTH_TO)
    end
end

-------------------------------------
-- function toggleExpantionState
-------------------------------------
function UIC_ListExpansionItem:toggleExpantionState()
    self:setExpansion(not self.m_isExpanded)
    return self.m_isExpanded
end

-------------------------------------
-- function getCurrHeight
-------------------------------------
function UIC_ListExpansionItem:getCurrHeight()
    if (self.m_isExpanded == true) then
        return self.m_expandedSize['height']
    else
        return self.m_collapsedSize['height']
    end
end