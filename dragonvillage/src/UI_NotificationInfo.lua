-------------------------------------
-- class UI_NotificationInfo
-------------------------------------
UI_NotificationInfo = class({
        root = '',
        m_lElements = 'list',
        m_lElementsPositions = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_NotificationInfo:init()
    self.root = cc.Node:create()
    self.root:setDockPoint(cc.p(0.5, 0.5))
    self.root:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_lElements = {}
end

-------------------------------------
-- function addElement
-------------------------------------
function UI_NotificationInfo:addElement(element)
    self.root:addChild(element.root)
    table.insert(self.m_lElements, element)

    doAllChildren(element.root, function(node) node:setCascadeOpacityEnabled(true) end)
    element.root:setOpacity(0)

    self:updateElementPositions()
end

-------------------------------------
-- function updateElementPositions
-- @brief 정보 요소들의 위치를 업데이트
-------------------------------------
function UI_NotificationInfo:updateElementPositions()
    local pos_x = 0
    local pos_y = 0
    local margin = 5
    local max_width = 0

    self.m_lElementsPositions = {}

    for i,v in ipairs(self.m_lElements) do
        pos_y = pos_y - (v.m_height / 2)
        self.m_lElementsPositions[i] = pos_y
        pos_y = pos_y - (v.m_height / 2) - margin
        max_width = math_max(max_width, v.m_contentWidth)
    end

    pos_x = - max_width / 2

    for i,v in ipairs(self.m_lElements) do
        v:setElementSize(max_width, v.m_height)
        v.root:setPosition(pos_x, self.m_lElementsPositions[i])
    end
end

-------------------------------------
-- function show
-- @brief
-------------------------------------
function UI_NotificationInfo:show()
    for i,v in ipairs(self.m_lElements) do
        local delay = (i-1) * 0.05
        local action = cc.Sequence:create(cc.DelayTime:create(delay), cc.FadeIn:create(0.3))
        v.root:stopAllActions()
        v.root:runAction(action)
    end

    self.root:stopAllActions()
    local action = cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function() self:hide() end))
    self.root:runAction(action)
end

-------------------------------------
-- function hide
-- @brief
-------------------------------------
function UI_NotificationInfo:hide()
    for i,v in ipairs(self.m_lElements) do
        local idx = (#self.m_lElements - i)
        local delay = idx * 0.05
        local action = cc.Sequence:create(cc.DelayTime:create(delay), cc.FadeOut:create(0.3))
        v.root:stopAllActions()
        v.root:runAction(action)
    end
end