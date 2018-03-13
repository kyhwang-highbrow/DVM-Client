local PARENT = UI

-------------------------------------
-- class UI_ClanAcceptPopup
-------------------------------------
UI_ClanAcceptPopup = class(PARENT, {
        m_sortManager = '',
        m_tableView = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanAcceptPopup:init()
    local vars = self:load('clan_request.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_ClanAcceptPopup'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanAcceptPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanAcceptPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanAcceptPopup:initUI()
    local vars = self.vars
    self:init_TableView()
    self:init_memberSortMgr()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanAcceptPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanAcceptPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ClanAcceptPopup:init_TableView()
    local node = self.vars['listNode']
    node:removeAllChildren()

    local l_item_list = g_clanData.m_lJoinRequestUserList or {}

    -- 생성 콜백
    local function create_func(ui, data)

    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1170, 120 + 5)
    table_view:setCellUIClass(UI_ClanAcceptListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('가입 요청이 없습니다.'))

    self.m_tableView = table_view
end

-------------------------------------
-- function init_memberSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_ClanAcceptPopup:init_memberSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManager = SortManager_ClanRequest()

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_clanRequest(vars['sortSelectBtn'], vars['sortSelectLabel'], UIC_SORT_LIST_BOT_TO_TOP)
    

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManager:pushSortOrder(sort_type)
        self:apply_memberSort()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function()
            local ascending = (not self.m_sortManager.m_defaultSortAscending)
            self.m_sortManager:setAllAscending(ascending)
            self:apply_memberSort()

            vars['sortSelectOrderSprite']:stopAllActions()
            if ascending then
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
            else
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
            end
        end)

    -- 첫 정렬 타입 지정
    uic_sort_list:setSelectSortType('active_time')
end

-------------------------------------
-- function apply_memberSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_ClanAcceptPopup:apply_memberSort()
    local list = self.m_tableView.m_itemList
    self.m_sortManager:sortExecution(list)
    self.m_tableView:setDirtyItemList()
end