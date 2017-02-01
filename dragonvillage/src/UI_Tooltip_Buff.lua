local PARENT = UI

local FONT_SIZE = 20
local MIN_WIDTH = 60
local MAX_WIDTH = 600
local MIN_HEIGHT = 70
local MAX_HEIGHT = 1000

local ICON_SIZE = 12
local ICON_INTERVAL = 30

-------------------------------------
-- class UI_Tooltip_Buff
-------------------------------------
UI_Tooltip_Buff = class(PARENT, {
        m_bubbleImage = 'cc.Scale9Sprite',
        m_richLabel = 'RichLabel',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Tooltip_Buff:init(x, y, text, skip_touch_layer)
    self.root = cc.Node:create()
    self.root:setDockPoint(cc.p(0.5, 0.5))
    self.root:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_bubbleImage = cc.Scale9Sprite:create('res/ui/frame/base_frame_08.png')
    self.m_bubbleImage:setDockPoint(cc.p(0.5, 0.5))
    self.m_bubbleImage:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_bubbleImage:setContentSize(600, 100)
    self.m_bubbleImage:setPosition(x, y)
    self.m_bubbleImage:setColor(cc.c3b(0, 0, 0))
    self.root:addChild(self.m_bubbleImage)

    local rich_label = self:makeRichLabel(text)
    self.m_richLabel = rich_label
    self.m_bubbleImage:addChild(rich_label.m_root)

    -- 문자열 시작 표시 아이콘
    do
        local height = self.m_richLabel:getStringHeight()
        local count = self.m_richLabel:getLineCount()
        local posX = (self.m_richLabel:getStringWidth()) / 2 + ICON_SIZE
        local posY = (self.m_richLabel:getStringHeight()) / 2 - ICON_SIZE

        for i = 1, count do
            local icon = cc.Sprite:create('res/ui/icon/buff_dsc_icon.png')
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            icon:setPosition(-posX, posY + (-ICON_INTERVAL * (i - 1)))
            rich_label.m_root:addChild(icon)
        end
    end

    self.vars = {}

    UIManager:open(self, UIManager.TOOLTIP)

    if (not skip_touch_layer) then
        self:makeTouchLayer(self.root)
    end

    self:doActionReset()
    self:doAction()
end

-------------------------------------
-- function doActionReset
-------------------------------------
function UI_Tooltip_Buff:doActionReset()
    PARENT.doActionReset(self)

    self.m_bubbleImage:setScale(0)
end

-------------------------------------
-- function doAction
-------------------------------------
function UI_Tooltip_Buff:doAction(complete_func, no_action)
    PARENT.doAction(self, complete_func, no_action)


    local scale_action = cc.ScaleTo:create(0.2, 1)
    local secuence = cc.Sequence:create(cc.EaseBackInOut:create(scale_action))
        --cc.DelayTime:create(3),
        --cc.EaseBackInOut:create(cc.ScaleTo:create(0.2, 0)),
        --cc.CallFunc:create(function() self:close() end))

    self.m_bubbleImage:stopAllActions()
    self.m_bubbleImage:runAction(secuence)
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function UI_Tooltip_Buff:makeTouchLayer(target_node)
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
function UI_Tooltip_Buff.onTouch(self, touch, event)
    self:close()
    return true
end

-------------------------------------
-- function makeRichLabel
-------------------------------------
function UI_Tooltip_Buff:makeRichLabel(text)
    local font_size = FONT_SIZE
    local dimensions_width = MAX_WIDTH - FONT_SIZE
    local dimensions_height = MAX_HEIGHT
    local align_h = TEXT_H_ALIGN_LEFT
    local align_v = TEXT_V_ALIGN_CENTER
    local dock_point = cc.p(0.5, 0.5)
    local is_limit_message = false

    -- RichLabel상에서의 width, height를 얻어온다.
    local rich_label = RichLabel(text, font_size, dimensions_width, dimensions_height, align_h, align_v, dock_point, is_limit_message)
    local width = rich_label:getStringWidth()
    local height = rich_label:getStringHeight()

    -- 적절한 ToolTip의 크기를 얻어온다.
    width = math_clamp(width, MIN_WIDTH, MAX_WIDTH)
    height = math_clamp(height + FONT_SIZE, MIN_HEIGHT, MAX_HEIGHT)

    -- 배경 이미지의 ContentSize를 갱신한다.
    self.m_bubbleImage:setContentSize(width + FONT_SIZE + ICON_SIZE * 2, height)

    -- 조절된 사이즈로 RichLabel을 생성한다.
    rich_label = RichLabel(text, font_size, width, height, align_h, align_v, dock_point, is_limit_message)

    return rich_label
end

-------------------------------------
-- function autoPositioning
-------------------------------------
function UI_Tooltip_Buff:autoPositioning(node)
    -- UI클래스의 root상 위치를 얻어옴
    local local_pos = convertToAnoterParentSpace(node, self.root)
    local pos_x = local_pos['x']
    local pos_y = local_pos['y']

    do -- X축 위치 지정
        local width = self.m_richLabel:getStringWidth() + 100
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
        self.m_bubbleImage:setAnchorPoint(cc.p(0.5, anchor_y))
    end

    -- 위치 설정
    self.m_bubbleImage:setPosition(pos_x, pos_y)
end

-------------------------------------
-- function autoRelease
-------------------------------------
function UI_Tooltip_Buff:autoRelease(duration)
    local duration = duration or 3
    local action = cc.Sequence:create(cc.DelayTime:create(duration), cc.FadeOut:create(1), cc.CallFunc:create(function() self:close() end))
    self.root:runAction(action)
end