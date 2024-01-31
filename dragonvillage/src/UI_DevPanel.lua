local PARENT = UI

-------------------------------------
---@class UI_DevPanel:UI
-------------------------------------
UI_DevPanel = class(PARENT, {
        m_bShow = 'boolean', -- 보여지고 있는 상태(기본은 화면 왼쪽에 숨겨있음)
        m_width = 'number', -- UI 넓이
        m_height = 'number', -- UI 높이
        m_tebleView = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DevPanel:init()
    --self:load('empty.ui')
    --UIManager:open(self, UIManager.SCENE)

    -- scene상단에 붙인다.
    -- 세로 길이는 relative vertical로 한다.
    -- 가로는 설정한 값 or 최소값으로 한다.
    -- 버튼 - 라벨이 기본 값이다.
    -- 라벨을 넣는다.

    -- 변수 초기화
    self.vars = {}

    self:initUI()
    self:initButton()
    self:refresh()
    self:makeTableView()

    -- UI를 숨김 상태로 변경
    self.m_bShow = false
    self.root:setPositionX(-self.m_width)
    self:showDebugUI(false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DevPanel:initUI()
    -- UI의 크기 지정(높이는 화면의 높이)
    local scr_size = cc.Director:getInstance():getWinSize()
    self.m_width = 400
    self.m_height = scr_size.height

    -- root 메뉴 생성
    local node = cc.Node:create() --cc.Menu:create()
    node:setAnchorPoint(cc.p(0, 0.5))
    node:setDockPoint(cc.p(0, 0.5))
    node:setPosition(0, 0)
    node:setNormalSize(self.m_width, self.m_height)
    self.root = node
    


    do -- UI아래쪽은 터치되지 않도록 임의 버튼 생성
        --local EMPTY_PNG = 'res/template/empty.png'
        --local node = cc.MenuItemImage:create(EMPTY_PNG, nil, nil, 1)
        --local node = ccui.Button:create(EMPTY_PNG, EMPTY_PNG)
        --node:setContentSize(self.m_width, self.m_height)
        --node:setDockPoint(cc.p(0.5, 0.5))
        --node:setAnchorPoint(cc.p(0.5, 0.5))

        local EMPTY_PNG = 'res/template/empty.png'
        local node = ccui.Button:create(EMPTY_PNG)
        node:setScale9Enabled(true)
        node:setNormalSize(cc.size(self.m_width, self.m_height))
        node:setPosition(cc.p(0, 0))
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setDockPoint(cc.p(0.5, 0.5))

        self.root:addChild(node)
    end


    do -- 배경
        local rect = cc.rect(0, 0, 0, 0)
        local res = 'res/template/frame_popup_0101.png'
        local node = cc.Scale9Sprite:create(rect, res)
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setDockPoint(cc.p(0.5, 0.5))
        node:setRelativeSizeAndType(cc.size(0, 0), 3, false)
        node:setOpacity(210)
        self.root:addChild(node)
        self.vars['bgNode'] = node
    end

    do -- 테이블 뷰 노드
        local node = cc.Node:create()
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setDockPoint(cc.p(0.5, 0.5))
        node:setRelativeSizeAndType(cc.size(-50, -30), 3, false)
        self.vars['bgNode']:addChild(node)
        self.vars['tableViewNode'] = node
    end

    do -- 열고 닫는 버튼
        --local node = cc.MenuItemImage:create('res/template/button_base70_0101.png', 'res/template/button_base70_0101.png', 1)


        local function touchEvent(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:showDebugUI(not self.m_bShow)
            end
        end

        local button = ccui.Button:create()
        button:loadTextures('res/template/btn_debug_01.png', 'res/template/btn_debug_02.png')
        button:setTouchEnabled(true)    
        button:setPosition(ZERO_POINT)        
        button:setDockPoint(cc.p(1, 0.5))
        button:setAnchorPoint(cc.p(0.5, 0.5))
        button:setPosition(10, 0)
        button:addTouchEventListener(touchEvent)

        --local node = cc.MenuItemImage:create('res/template/btn_debug_01.png', 'res/template/btn_debug_02.png')
        -- node:setDockPoint(cc.p(1, 0.5))
        -- node:setAnchorPoint(cc.p(0.5, 0.5))
        -- node:setPosition(100, 0)

        -- -- local uic_button = UIC_Button(node)        
        -- -- ---uic_button:setEnabled(true)
        -- -- uic_button:registerScriptTapHandler(function() self:showDebugUI(not self.m_bShow) end)
        -- -- self.root:addChild(node)
        -- -- self.vars['openButton'] = node

        -- local uic_button = UIC_Button(button)
        -- uic_button:registerScriptTapHandler(function()
        --     data['cb1'](self, data, 1)
        -- end)

        self.vars['openButton'] = button
        self.root:addChild(button, 1)
        do
            local sprite = cc.Sprite:create('res/template/btn_debug_03.png')
            sprite:setDockPoint(cc.p(0.5, 0.5))
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
            button:addChild(sprite)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DevPanel:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DevPanel:refresh()
end

-------------------------------------
-- function showDebugUI
-------------------------------------
function UI_DevPanel:showDebugUI(show)
    self.m_bShow = show
    self.vars['openButton']:stopAllActions()
    self.root:stopAllActions()
    local duration = 0.2

    if show then
        self.vars['bgNode']:setVisible(true)
        local action = cc.MoveTo:create(duration, cc.p(0, 0))
        local ease_action = cc.EaseInOut:create(action, 2)
        self.root:runAction(ease_action)
        self.vars['openButton']:runAction(cc.RotateTo:create(duration, 0))
    else
        local action = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(-self.m_width, 0)), cc.CallFunc:create(function() self.vars['bgNode']:setVisible(false) end))
        local ease_action = cc.EaseInOut:create(action, 2)
        self.root:runAction(ease_action)
        self.vars['openButton']:runAction(cc.RotateTo:create(duration, 180))
    end
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_DevPanel:makeTableView()
    local node = self.vars['tableViewNode']
    local size_width, size_height = (node:getContentSize()['width']), 64

    local function create_func(data)
        local ui = UIC_ChatTableViewCell(data)

        local cell_menu = ui.root
        cell_menu:setDockPoint(cc.p(0.5, 0.5))
        cell_menu:setAnchorPoint(cc.p(0.5, 0.5))
        cell_menu:setNormalSize(size_width, size_height)
        cell_menu:setPosition(0, 0)
        cell_menu:setSwallowTouch(true)

        local cell_root = cc.Node:create()
        cell_menu:addChild(cell_root)

        if data['cb1'] then
            --local node = cc.MenuItemImage:create('res/buttons/64_base_btn_0101.png', 'res/buttons/64_base_btn_0102.png', 1)
            local node = cc.MenuItemImage:create('res/template/button_base70_0101.png', 'res/template/button_base70_0101.png', 1)
            --node:setScale9Enabled(true)
            node:setNormalSize(cc.size(60, 60))
            node:setDockPoint(cc.p(1, 0.5))
            node:setPositionX(-40)
            node:setAnchorPoint(cc.p(0.5, 0.5))
            local uic_button = UIC_Button(node)
            uic_button:registerScriptTapHandler(function()
                data['cb1'](self, data, 1)
            end)
            cell_menu:addChild(node)
        end

        if data['cb2'] then
            --local node = cc.MenuItemImage:create('res/buttons/64_base_btn_0101.png', 'res/buttons/64_base_btn_0102.png', 1)
            local node = cc.MenuItemImage:create('res/template/button_base70_0101.png', 'res/template/button_base70_0101.png', 1)
            --node:setScale9Enabled(true)
            node:setNormalSize(cc.size(60, 60))
            node:setDockPoint(cc.p(0, 0.5))
            node:setPositionX(40)
            node:setAnchorPoint(cc.p(0.5, 0.5))
            local uic_button = UIC_Button(node)
            uic_button:registerScriptTapHandler(function()
                data['cb2'](self, data, 2)
            end)
            cell_menu:addChild(node)
        end

        -- 입력으로 처리하는 콜백
        if data['edit_cb'] then
            -- editbox 생성
            -- local layer = cc.LayerColor:create()
            -- layer:setColor(cc.c3b(0, 0, 0))
            -- cell_menu:addChild(layer)

            local normalBG = cc.Scale9Sprite:create('res/template/frame_popup_0101.png')
            normalBG:setVisible(false)
            normalBG:setScale(0.5)

            local editbox = cc.EditBox:create(cc.size(80, 60), normalBG)
            editbox:setDockPoint(cc.p(0, 0.5))
            editbox:setAnchorPoint(cc.p(0, 0.5))
            editbox:setPositionX(0)
            editbox:setFontSize(26)            

            cell_menu:addChild(editbox)
            data['editbox'] = editbox

            local node = cc.MenuItemImage:create('res/template/button_base70_0101.png', 'res/template/button_base70_0101.png', 1)
            --node:setScale9Enabled(true)
            node:setNormalSize(cc.size(60, 60))
            node:setDockPoint(cc.p(1, 0.5))
            node:setPositionX(-40)
            node:setAnchorPoint(cc.p(0.5, 0.5))
            local uic_button = UIC_Button(node)
            uic_button:registerScriptTapHandler(function()
                local text = editbox:getText()
                data['edit_cb'](text)
            end)
            cell_menu:addChild(node)
        end

        do -- label 생성
            -- left 0, center 1, right 2
            -- local font_res = 'res/font/common_font_01.ttf'
            --local label = cc.Label:createWithTTF(data['str'] or 'label', Translate:getFontPath(), 20, 2, cc.size(size_width, size_height), 1, 1)
            --local label = cc.Label:createWithTTF(data['str'] or 'label', font_res, 20, 2, cc.size(size_width, size_height), 1, 1)
            --local label = cc.Label:createWithTTF(data['str'] or 'label', font_res, 20, cc.size(size_width, size_height), 1, 1)
            local label = cc.Label:createWithTTF(data['str'] , Translate:getFontPath(), 20, 0, cc.size(size_width, size_height), 1, 1)

            label:setTextColor(cc.c4b(40, 40, 40, 255))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            cell_menu:addChild(label)
            data['label'] = label
        end

        return ui
    end

    local table_view = UIC_TableView(node)
    self.m_tebleView = table_view
    table_view.m_defaultCellSize = cc.size(size_width, size_height)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(create_func, nil)

    local item_info = {}

    do -- 테스트 항목
        --[[
        local item = {}
        item['cb1'] = function() cclog('cb1 클릭!') end
        item['cb2'] = function() cclog('cb2 클릭!') end
        item['str'] = '테스트 라벨'

        table.insert(item_info, item)
        --]]
    end

    table_view:setItemList(item_info)
end

-------------------------------------
-- function addDevComponent
-- @param StructDevPanelComponent
-------------------------------------
function UI_DevPanel:addDevComponent(struct_dev_panel_component)
    -- 1. 단순 버튼 (라벨)
    -- 2. 라벨
    -- 3. 2button, 1label

    local unique_id = struct_dev_panel_component['unique_id']
    self.m_tebleView:addItem(unique_id, struct_dev_panel_component) -- params: unique_id, t_data
end

-------------------------------------
-- Class StructDevPanelComponent
-------------------------------------
StructDevPanelComponent = class({
    unique_id = 'string',
    str = 'string',
    cb1 = 'function',
    cb2 = 'function',
    edit_cb = 'function',

    label = 'label',
    editbox = 'cc.EditBox',
})

-------------------------------------
-- function init
-------------------------------------
function StructDevPanelComponent:init()

end

-------------------------------------
-- function create
-------------------------------------
function StructDevPanelComponent:create(unique_id, cb1, cb2, str)
    local struct_dev_panel_component = StructDevPanelComponent()
    struct_dev_panel_component['unique_id'] = unique_id
    struct_dev_panel_component['cb1'] = cb1
    struct_dev_panel_component['cb2'] = cb2
    struct_dev_panel_component['str'] = str

    return struct_dev_panel_component
end
