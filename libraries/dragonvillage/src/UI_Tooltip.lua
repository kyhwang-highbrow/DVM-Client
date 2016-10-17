local PARENT = UI

-------------------------------------
-- class UI_Tooltip
-------------------------------------
UI_Tooltip = class(PARENT,{
        m_rootNode = 'cc.Node',
        m_frameNode = 'cc.Node',
        m_rootMenu = 'cc.Menu',

        m_bubbleImage = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Tooltip:init(x, y, text)
    self.root = cc.Node:create()
    self.root:setDockPoint(cc.p(0.5, 0.5))
    self.root:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:setPosition(x, y)

    self.m_rootNode = cc.Node:create()
    self.m_rootNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_rootNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_rootNode:setPositionY(15)
    self.root:addChild(self.m_rootNode)

    self.m_frameNode = cc.Node:create()
    self.m_frameNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_frameNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_rootNode:addChild(self.m_frameNode)

    self.m_rootMenu = cc.Menu:create()
    self.m_frameNode:addChild(self.m_rootMenu)

    self.m_bubbleImage = cc.Scale9Sprite:create('ui/frame/a_dialogue_0102.png')
    self.m_bubbleImage:setDockPoint(cc.p(0.5, 0))
    self.m_bubbleImage:setAnchorPoint(cc.p(0.5, 0))
    self.m_bubbleImage:setContentSize(200, 100)
    self.m_bubbleImage:setPositionY(8)
    --self.m_bubbleImage:setScaleY(0)
    --self.m_bubbleImage:setColor(cc.c3b(0,0,0))
    --self.m_bubbleImage:setOpacity(216)
    self.m_frameNode:addChild(self.m_bubbleImage)


    local sprite = cc.Sprite:create('ui/frame/a_dialogue_0102_2.png')
    sprite:setDockPoint(cc.p(0.5, 0))
    sprite:setAnchorPoint(cc.p(0.5, 0))
    self.m_frameNode:addChild(sprite)


    local rich_label = RichLabel(text, 20, 200, 100, TEXT_H_ALIGN_CENTER, TEXT_V_ALIGN_CENTER, cc.p(0.5, 0.5), false)
    self.m_bubbleImage:addChild(rich_label.m_root)

    

    self.vars = {}

    UIManager:open(self, UIManager.TOOLTIP)

    self:doActionReset()
    self:doAction()
end

-------------------------------------
-- function doAction
-------------------------------------
function UI_Tooltip:doAction(complete_func, no_action)
    PARENT.doAction(self, complete_func, no_action)


    local scale_action = cc.ScaleTo:create(0.4, 1)
    local secuence = cc.Sequence:create(cc.EaseBackInOut:create(scale_action),
        cc.DelayTime:create(3),
        cc.EaseBackInOut:create(cc.ScaleTo:create(0.2, 0)),
        cc.CallFunc:create(function() self:close() end))

    self.m_frameNode:stopAllActions()
    self.m_frameNode:runAction(secuence)
end

-------------------------------------
-- function doActionReset
-------------------------------------
function UI_Tooltip:doActionReset()
    PARENT.doActionReset(self)

    self.m_frameNode:setScale(0)
end