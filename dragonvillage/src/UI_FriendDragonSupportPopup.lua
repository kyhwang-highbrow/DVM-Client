local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_FriendDragonSupportPopup
-------------------------------------
UI_FriendDragonSupportPopup = class(PARENT, {
        m_tFriendInfo = 'table', 
        m_dragonSortManager = 'SortManager_Dragon',
        m_tableView = 'UIC_TableViewTD',
        m_selectedDragonItem = '',
        m_bSupportDragon = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendDragonSupportPopup:init(t_friend_info)
    self.m_tFriendInfo = t_friend_info
	local vars = self:load('friend_support_popup.ui')
	UIManager:open(self, UIManager.POPUP)

    -- 정렬 매니저
    self.m_dragonSortManager = SortManager_Dragon()
    self.m_dragonSortManager:setAllAscending(true) -- 오름차순

    self.m_bSupportDragon = false

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_FriendDragonSupportPopup')

	-- @UI_ACTION
	--self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendDragonSupportPopup:initUI()
    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendDragonSupportPopup:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['supportRequestBtn']:registerScriptTapHandler(function() self:clcik_supportBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendDragonSupportPopup:refresh()
    local vars = self.vars
    self:refresh_sortUI()
end

-------------------------------------
-- function refresh_sortUI
-------------------------------------
function UI_FriendDragonSupportPopup:refresh_sortUI()
    local vars = self.vars

    local sort_manager = self.m_dragonSortManager

    -- 테이블 뷰 정렬
    local table_view = self.m_tableView
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_FriendDragonSupportPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function clcik_supportBtn
-------------------------------------
function UI_FriendDragonSupportPopup:clcik_supportBtn()
    -- 선택했는지 여부
    if (not self.m_selectedDragonItem) then
        UIManager:toastNotificationRed(Str('지원할 드래곤을 선택해주세요.'))
        return
    end

    -- 서버 통신
    local function finish_cb(ret)        
        local did = self.m_selectedDragonItem['data']['did']
        local name = TableDragon():getValue(did, 't_name')

        local friend_nick = self.m_tFriendInfo['nick']

        UIManager:toastNotificationGreen(Str('[{1}]님에게 [{2}]을(를) 지원하였습니다.', friend_nick, Str(name)))

        local sent_fp = ret['sent_fp']
        UIManager:toastNotificationGreen(Str('우편함으로 {1}우정포인트가 발송되었습니다.', comma_value(sent_fp)))

        self.m_bSupportDragon = true
        
        self:close()
    end

    local fuid = self.m_tFriendInfo['uid']
    local doid = self.m_selectedDragonItem['data']['id']
    g_friendData:request_sendNeedDragon(fuid, doid, finish_cb)
end

-------------------------------------
-- function clcik_sortSelectOrderBtn
-------------------------------------
function UI_FriendDragonSupportPopup:clcik_sortSelectOrderBtn()
    local sort_manager = self.m_dragonSortManager
    sort_manager:setAllAscending(not sort_manager.m_defaultSortAscending)
    self:refresh_sortUI()
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_FriendDragonSupportPopup:init_dragonTableView()

    local node = self.vars['listNode']
    --node:removeAllChildren()

    local t_friend_info = self.m_tFriendInfo
    local l_need_info = t_friend_info['need_did']
    local t_need_info = g_friendData:parseDragonSupportRequestInfo(l_need_info)
    local did = t_need_info['did']

    local l_item_list = g_dragonsData:getDragonsList_specificDid(did)

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.72)
        
        local function click_func()
            self:setSelectedDragon(ui, data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(108, 108)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(Str('지원가능한 드래곤이 없습니다.'))

    -- 정렬
    local sort_manager = self.m_dragonSortManager
    sort_manager:sortExecution(table_view_td.m_itemList)

    self.m_tableView = table_view_td
end

-------------------------------------
-- function setSelectedDragon
-------------------------------------
function UI_FriendDragonSupportPopup:setSelectedDragon(ui, data)
    if self.m_selectedDragonItem then
        self.m_selectedDragonItem['ui']:setShadowSpriteVisible(false)
    end

    if ui and data then
        local item = {}
        item['ui'] = ui
        item['data'] = data
        self.m_selectedDragonItem = item
        self.m_selectedDragonItem['ui']:setShadowSpriteVisible(true)
    end
end

--@CHECK
UI:checkCompileError(UI_FriendDragonSupportPopup)