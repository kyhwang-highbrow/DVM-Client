local PARENT = UI

-------------------------------------
-- class UI_ChatPopup
-------------------------------------
UI_ChatPopup = class(PARENT, {
        m_chatList = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatPopup:init()
    local vars = self:load('chat.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ChatPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    g_chatManager.m_tempCB = function(msg) self:msgQueueCB(msg) end
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_ChatPopup:initUI()
    local vars = self.vars
    
    local list_table_node = vars['listNode']

    --[[
    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(list_table_node)
    table_view._vordering = VerticalFillOrder['BOTTOM_UP']

    table_view.m_defaultCellSize = cc.size(1200, 50)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_ChatListItem, create_func)
    table_view:setItemList({})

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('메세지가 없습니다.'))

    self.m_chatListView = table_view
    --]]

    self.m_chatList = UI_ChatList(list_table_node, 1200, 540, 50)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChatPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChatPopup:refresh()
    local vars = self.vars
end


-------------------------------------
-- function closeBtn
-------------------------------------
function UI_ChatPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_ChatPopup:click_enterBtn()
    local vars = self.vars

    local msg = vars['editBox']:getText()
    if (string.len(msg) <= 0) then
        return
    end

    if g_chatManager:sendNormalMsg(msg) then
        vars['editBox']:setText('')
    end
end


-------------------------------------
-- function msgQueueCB
-------------------------------------
function UI_ChatPopup:msgQueueCB(msg)
    local unique_id = Timer:getServerTime()
    --self.m_chatListView:addItem(unique_id, msg)

    local content = UI_ChatListItem(msg)
    content.root:setAnchorPoint(0.5, 0)
    self.m_chatList:addContent(content.root, 50, 'type')
end

-------------------------------------
-- function close
-------------------------------------
function UI_ChatPopup:close()
    PARENT.close(self)
    g_chatManager.m_tempCB = nil
end