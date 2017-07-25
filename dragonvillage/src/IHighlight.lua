-------------------------------------
-- interface IHighlight
-------------------------------------
IHighlight = {
    m_lHighlightNodes = 'table',
    m_highlightLevel = 'number',
}

-------------------------------------
-- function init
-------------------------------------
function IHighlight:init()
    self.m_lHighlightNodes = {}
    self.m_highlightLevel = 0
end

-------------------------------------
-- function addHighlightNode
-------------------------------------
function IHighlight:addHighlightNode(node)
    table.insert(self.m_lHighlightNodes, node)
end

-------------------------------------
-- function removeHighlightNode
-------------------------------------
function IHighlight:removeHighlightNode(node)
    local idx = table.find(self.m_lHighlightNodes, node)
    if (idx) then
        table.remove(self.m_lHighlightNodes, idx)
    end
end

-------------------------------------
-- function setHighlight
-------------------------------------
function IHighlight:setHighlight(highlightLevel)
    if (self.m_highlightLevel == highlightLevel) then return end

    self.m_highlightLevel = highlightLevel

    self:runAction_Highlight(0.2, self.m_highlightLevel)
end

-------------------------------------
-- function runAction_Highlight
-------------------------------------
function IHighlight:runAction_Highlight(duration, level)
    local function f_tint(node)
        node:runAction( cc.TintTo:create(duration, level, level, level) )
    end

    for i, node in ipairs(self.m_lHighlightNodes) do
        if (level == 0) then
            node:setVisible(false)
        else
            node:setVisible(true)
            doAllChildren(node, f_tint)
        end
    end
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function IHighlight:getCloneTable()
	return clone(IHighlight)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function IHighlight:getCloneClass()
	return class(clone(IHighlight))
end
