local PARENT = UI

-------------------------------------
-- class UI_FriendSelectPopup
-- @brief 친구 드래곤 선택
-------------------------------------
UI_FriendSelectPopup = class(PARENT, {
        m_tableView = 'UIC_TableView',
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
    local skip_update = false --정렬 시 update되기 때문에 skip
    table_view:setItemList(l_item_list, skip_update)

    --[[
    -- 정렬
    local sort_manager = SortManager_Fruit()
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:expandTemp(0.5)
    --]]

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
    local t_friend_info = data
    g_friendData:setSelectedShareFriendData(t_friend_info)
    self:close()
end

--@CHECK
UI:checkCompileError(UI_FriendSelectPopup)