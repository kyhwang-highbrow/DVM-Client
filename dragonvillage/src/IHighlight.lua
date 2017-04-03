-------------------------------------
-- interface IHighlight
-------------------------------------
IHighlight = {
    m_highlightNode = 'cc.Node',
    m_highlightLevel = 'number',
}

-------------------------------------
-- function init
-------------------------------------
function IHighlight:init()
    self.m_highlightNode = nil
    self.m_highlightLevel = 0
end

-------------------------------------
-- function init
-------------------------------------
function IHighlight:setHighlightNode(node)
    self.m_highlightNode = node
end

-------------------------------------
-- function updateHighlight
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
    if (self.m_highlightNode) then
        self.m_highlightNode:runAction( cc.TintTo:create(duration, level, level, level) )
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
