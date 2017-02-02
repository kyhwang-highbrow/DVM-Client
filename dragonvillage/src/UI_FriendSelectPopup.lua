local PARENT = UI

-------------------------------------
-- class UI_FriendSelectPopup
-- @brief 친구 드래곤 선택
-------------------------------------
UI_FriendSelectPopup = class(PARENT, {
        m_tableView = 'UIC_TableView',
        m_selectedFriendUid = '',
        m_selectedFriendInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendSelectPopup:init()
	local vars = self:load('friend_select_popup.ui')
	UIManager:open(self, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_FriendSelectPopup')

	-- @UI_ACTION
	--self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton()
	self:refresh()

    -- 선택되어 있는 친구
    self.m_selectedFriendInfo = g_friendData:getSelectedShareFriendData()
    if self.m_selectedFriendInfo then
        self.m_selectedFriendUid = self.m_selectedFriendInfo['uid']
    end

    local function finish_cb(ret)
        self:init_tableView()
    end
    local force = true
    g_friendData:request_friendList(finish_cb, force)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendSelectPopup:initUI()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_FriendSelectPopup:init_tableView()
    if self.m_tableView then
        return
    end

    local node = self.vars['listNode']
    --node:removeAllChildren()

    local l_item_list = g_friendData:getFriendList()

    -- 생성 콜백
    local function create_func(ui, data)
        local uid = data['uid']
        self:refresh_listItemSelectSprite(uid, ui)

        local function click_func()
            self:click_selectBtn(data)
        end

        ui.vars['selectBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(500, 100)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendSelectListItem, create_func)
    local skip_update = true --정렬 시 update되기 때문에 skip
    table_view:setItemList(l_item_list, skip_update)

    -- 정렬
    g_friendData:sortForFriendDragonSelectList(table_view.m_itemList)
    local animated = false
    table_view:expandTemp(0.5, animated)

    self.m_tableView = table_view
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendSelectPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendSelectPopup:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_FriendSelectPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_FriendSelectPopup:click_selectBtn(data)
    local prev_uid = self.m_selectedFriendUid
   
    local t_friend_info = data

    local uid = t_friend_info['uid']

    if (self.m_selectedFriendUid == uid) then
        uid = nil
        self.m_selectedFriendInfo = nil
    else
        self.m_selectedFriendInfo = t_friend_info
    end

    self.m_selectedFriendUid = uid
    self:refresh_listItemSelectSprite(prev_uid)
    self:refresh_listItemSelectSprite(self.m_selectedFriendUid)
end

-------------------------------------
-- function refresh_listItemSelectSprite
-------------------------------------
function UI_FriendSelectPopup:refresh_listItemSelectSprite(uid, ui)
    if (not uid) then
        return
    end

    local is_selected = (self.m_selectedFriendUid == uid)

    if (not ui) then
        local item = self.m_tableView:getItem(uid)
        ui = item and item['ui']
        if (not ui) then
            return
        end
    end

    ui.vars['selectSprite']:setVisible(is_selected)
    ui.vars['selectSprite2']:setVisible(is_selected)
end

-------------------------------------
-- function close
-------------------------------------
function UI_FriendSelectPopup:close()
    g_friendData:setSelectedShareFriendData(self.m_selectedFriendInfo)
    PARENT.close(self)
end

--@CHECK
UI:checkCompileError(UI_FriendSelectPopup)