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



-------------------------------------
-- class UI_TooltipTest
-------------------------------------
UI_TooltipTest = class(PARENT,{
    m_bubbleImage = 'cc.Scale9Sprite',

})


-------------------------------------
-- function init
-------------------------------------
function UI_TooltipTest:init()
    local vars = self:load('marble_bonus_popup.ui')
    UIManager:open(self, UIManager.TOOLTIP)

    -- UI 클래스명 지정
    self.m_uiName = 'UI_TooltipTest'

    self:initUI()

    --self:makeTouchLayer(self.root)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TooltipTest:initUI()
    local vars = self.vars 
    local str = '{1}/{2}'
    vars['diaLabel']:setString(Str(str, g_userData:getDropInfoDia(), g_userData:getDropInfoMaxDia()))
    vars['goldLabel']:setString(Str(str, g_userData:getDropInfoGold(), g_userData:getDropInfoMaxGold()))
    vars['amethystLabel']:setString(Str(str, g_userData:getDropInfoAmethyst(), g_userData:getDropInfoMaxAmethyst()))
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function UI_TooltipTest:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self.onTouch(self, touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self.onTouch(self, touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self.onTouch(self, touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self.onTouch(self, touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouch
-------------------------------------
function UI_TooltipTest.onTouch(self, touch, event)
    self:close()
    return true
end


-------------------------------------
-- function autoPositioning
-------------------------------------
function UI_TooltipTest:autoPositioning(node)
    -- UI클래스의 root상 위치를 얻어옴
    local local_pos = convertToAnoterParentSpace(node, self.root)
    local pos_x = local_pos['x']
    local pos_y = local_pos['y']

    do -- X축 위치 지정
        local width =  100
        local scr_size = cc.Director:getInstance():getWinSize()
        if (pos_x < 0) then
            local min_x = -(scr_size['width'] / 2)
            local left_pos = pos_x - (width/2)
            if (left_pos < min_x) then
                pos_x = min_x + (width/2)
            end
        else
            local max_x = (scr_size['width'] / 2)
            local right_pos = pos_x + (width/2)
            if (max_x < right_pos) then
                pos_x = max_x - (width/2)
            end
        end
    end

    do -- Y축 위치 지정
        -- 화면상에 보이는 Y스케일을 얻어옴
        local transform = node.m_node:getNodeToWorldTransform()
        local scale_y = transform[5 + 1]

        -- tooltip의 위치를 위쪽으로 표시할지 아래쪽으로 표시할지 결정
        local bounding_box = node:getBoundingBox()
        local anchor_y = 0.5
        if (pos_y < 0) then
            pos_y = pos_y + (bounding_box['height'] * scale_y / 2) + 10
            anchor_y = 0
        else
            pos_y = pos_y - (bounding_box['height'] * scale_y / 2) - 10
            anchor_y = 1
        end

        -- 위, 아래의 위치에 따라 anchorPoint 설정
        self.root:setAnchorPoint(cc.p(0.5, anchor_y))
    end

    -- 위치 설정
    self.root:setPosition(pos_x, pos_y)
end