local PARENT = UI

-------------------------------------
-- class UI_LobbyNoticePopup
-- @brief 마을 알림 (운영진 메세지, 푸시 접속 보상 등을 알리는 팝업)
-------------------------------------
UI_LobbyNoticePopup = class(PARENT,{
        m_structLobbyNotice = 'StructLobbyNotice',
    })

-------------------------------------
-- function init
-- @param struct_lobby_notice StructLobbyNotice
-------------------------------------
function UI_LobbyNoticePopup:init(struct_lobby_notice)
    self.m_structLobbyNotice = struct_lobby_notice
    
    local ui_res = self:getUIRes()
    local vars = self:load(ui_res)
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_LobbyNoticePopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function getUIRes
-- @virtual
-------------------------------------
function UI_LobbyNoticePopup:getUIRes()
    local type = self.m_structLobbyNotice:getType()
    local ui_res = 'lobby_notice_' .. type .. '.ui'

    -- 타입별로 처리가 필요한 경우 사용
    if (self.m_structLobbyNotice ~= nil) then
        --ui_res = self.m_structLobbyNotice:getUIRes()
    end

    return ui_res
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyNoticePopup:initUI()
    local vars = self.vars

    local struct_lobby_notice = self.m_structLobbyNotice
    local l_item_list = struct_lobby_notice:getRewardList()
    
    if (#l_item_list == 1) then
        local item = l_item_list[1]
        local item_id = item['item_id']
        local count = item['count']

        local ui = UI_ItemCard(item_id, count)
        ui.root:setSwallowTouch(false)
        vars['itemNode']:addChild(ui.root)

        if vars['itemLabel'] then
            local item_name = TableItem:getItemName(item_id)

            vars['itemLabel']:setString(Str('{1} {2}개', item_name, tostring(count)))
        end
    
    else
        vars['itemNode']:setVisible(false)
        vars['itemListNode']:setVisible(true)
        self:initTableView()
        if vars['itemLabel'] then
            vars['itemLabel']:setVisible(false)
        end
    end
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_LobbyNoticePopup:initTableView()
    local vars = self.vars

    local struct_lobby_notice = self.m_structLobbyNotice
    local l_item_list = struct_lobby_notice:getRewardList()

    local node = vars['itemListNode']

    if (node == nil) then
        return
    end

	-- 리스트 아이템 생성 콜백
    local function make_func(object)
        local ui = UI_ItemCard(object['item_id'], object['count'])
        return ui
    end

    local function create_func(ui, data)
        ui.root:setScale(0.95)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(150, 150)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	table_view.m_bAlignCenterInInsufficient = true

    table_view:setItemList(l_item_list)
end

-------------------------------------
-- function showRewardCheckSprite
-- @brief 보상 수령 후 보상 아이콘에 체크표시
-------------------------------------
function UI_LobbyNoticePopup:showRewardCheckSprite(_checked)
    local checked = true
    if (_checked ~= nil) then
        checked = _checked
    end

    local vars = self.vars

    local struct_lobby_notice = self.m_structLobbyNotice
    local l_item_list = struct_lobby_notice:getRewardList()

    -- 보상 리스트 아이콘 생성
    for i,v in ipairs(l_item_list) do
        local lua_name = string.format('itemCheckSprite%.2d', i)

        -- rewardNode01과 같이 숫자가 붙어있는 형태가 아닌 ui 예외처리
        if (i == 1) and (not vars[lua_name]) then
            lua_name = 'itemCheckSprite'
        end

        if vars[lua_name] then
            vars[lua_name]:setVisible(checked)
        end
    end
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_LobbyNoticePopup:initButton()
    local vars = self.vars
    local struct_lobby_notice = self.m_structLobbyNotice

    local has_reward = struct_lobby_notice:hasReward()

    -- 보상 수령 버튼
    local receive_btn = vars['receiveBtn']
    if receive_btn then
        receive_btn:setVisible(has_reward)
        receive_btn:registerScriptTapHandler(function() self:click_receiveBtn() end)
    end

    -- 닫기 버튼 (보상이 있을 경우 숨긴 상태로 시작)
    local close_btn = vars['closeBtn']
    if close_btn then
        close_btn:setVisible(not has_reward)
        close_btn:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LobbyNoticePopup:refresh()
    
end

-------------------------------------
-- function click_receiveBtn
-------------------------------------
function UI_LobbyNoticePopup:click_receiveBtn()
    local struct_lobby_notice = self.m_structLobbyNotice
    
    local lobby_notice_id = struct_lobby_notice:getLobbyNoticeID()

    local function finish_cb(ret)
        local vars = self.vars

        if (ret['status'] == 0) then
            local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
            UI_ToastPopup(toast_msg)
            g_highlightData:setHighlightMail()
            self:showRewardCheckSprite(true) -- param : _checked
        end

        -- 보상 수령 버튼
        local receive_btn = vars['receiveBtn']
        if receive_btn then
            receive_btn:setVisible(false)
        end

        -- 닫기 버튼 (보상이 있을 경우 숨긴 상태로 시작)
        local close_btn = vars['closeBtn']
        if close_btn then
            close_btn:setVisible(true)
        end
    end

    --finish_cb()
    g_lobbyNoticeData:request_getLobbyNoticeReward(lobby_notice_id, finish_cb)
end

--@CHECK
UI:checkCompileError(UI_LobbyNoticePopup)
