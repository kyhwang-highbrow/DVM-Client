local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ClanTabMember
-- @brief 클랜원 정보 탭
-------------------------------------
UI_ClanTabMember = class(PARENT,{
        owner = '',
        vars = '',
        m_sortManager = '',
        m_tableView = '',

        m_isGuest = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanTabMember:init(owner_ui, guest)
    self.owner = owner_ui
    self.m_isGuest = guest or false
    self.root = owner_ui.vars['memberMenu']
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ClanTabMember:onEnterTab(first)
    if first then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ClanTabMember:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanTabMember:initUI()
    local vars = self.vars
    if (self.m_isGuest) then
        self:init_TableViewGuest()
    else
        self:init_TableView()
    end 
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ClanTabMember:init_TableView()
    local node = self.vars['memberNode']
    node:removeAllChildren()

    local struct_clan = g_clanData:getClanStruct()
    local l_item_list = struct_clan.m_memberList or {}

    local function refresh_cb()
        self.owner:refresh_memberCnt()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui:setRefreshCB(refresh_cb)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1170, UIHelper:getProfileScrollItemHeight(85 + 6, 15))
    table_view:setCellUIClass(UI_ClanMemberListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_tableView = table_view

    -- 정렬
    self:init_memberSortMgr()
end

-------------------------------------
-- function init_TableViewGuest
-------------------------------------
function UI_ClanTabMember:init_TableViewGuest()
    local node = self.vars['memberNode']
    node:removeAllChildren()

    local struct_clan = self.owner.m_structClan
    local l_item_list = struct_clan.m_memberList

    -- 생성 콜백
    local function create_func(ui, data)
        -- 관리 버튼 visible off
        ui.vars['adminBtn']:setVisible(false)
        ui.vars['adminBtn'] = nil

        -- 친선전 버튼 visible off
        ui.vars['friendlyBattleBtn']:setVisible(false)
        ui.vars['friendlyBattleBtn'] = nil

        -- 출석 관련 노드 visible off
        ui.vars['attendanceNode']:setVisible(false)

        -- 던전 정보 관련 노드 visible off
        ui.vars['playInfoNode']:setVisible(false)

		-- 클랜 경험치 기여도
		ui.vars['expInfoNode']:setVisible(false)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1170, 85 + 6)
    table_view:setCellUIClass(UI_ClanMemberListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_tableView = table_view

    -- 정렬
    self:init_memberSortMgr()
end

-------------------------------------
-- function init_memberSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_ClanTabMember:init_memberSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManager = SortManager_ClanMember()

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_clanMember(vars['sortSelectBtn'], vars['sortSelectLabel'], UIC_SORT_LIST_BOT_TO_TOP)
    

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
    uic_sort_list:setSelectSortType('member_type')
end

-------------------------------------
-- function apply_memberSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_ClanTabMember:apply_memberSort()
    local list = self.m_tableView.m_itemList
    self.m_sortManager:sortExecution(list)
    self.m_tableView:setDirtyItemList()
end