-------------------------------------
-- class UI_CollectionTabUnit
-------------------------------------
UI_CollectionTabUnit = class({
        vars = 'table',
        m_ownerUI = 'UI',

        m_tableView = 'UIC_TableView',

        -- refresh 체크 용도
        m_collectionLastChangeTime = 'timestamp',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionTabUnit:init(owner_ui)
    self.m_ownerUI = owner_ui
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_CollectionTabUnit:onEnterTab(first)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_CollectionTabUnit:onEnterTab(first)
    if first then
        self.m_collectionLastChangeTime = g_dragonUnitData:getLastChangeTimeStamp()
        self:initUI()
    else
        self:checkRefresh()
    end
end

-------------------------------------
-- function initUI
-- @brief
-------------------------------------
function UI_CollectionTabUnit:initUI()
    local vars = self.vars

    -- 테이블 뷰 생성
    self:init_TableView()
end

-------------------------------------
-- function init_TableView
-- @brief
-------------------------------------
function UI_CollectionTabUnit:init_TableView()
    local node = self.vars['unitListNode']
    --node:removeAllChildren()

    local l_item_list = g_dragonUnitData:getDragonUnitIDList()

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_rewardBtn()
            local unit_id = data
            self:click_rewardBtn(unit_id)
        end
        ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)

        local function click_selectBtn()
            local unit_id = data
            self:click_selectBtn(unit_id)
        end
        ui.vars['buffBtn']:registerScriptTapHandler(click_selectBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1140, 180 + 5)
    table_view:setCellUIClass(UI_CollectionUnitListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    --table_view_td:makeDefaultEmptyDescLabel(Str(''))

    -- 정렬
    self.m_tableView = table_view
end

-------------------------------------
-- function checkRefresh
-- @brief 도감 데이터가 변경되었는지 확인 후 변경되었으면 갱신
-------------------------------------
function UI_CollectionTabUnit:checkRefresh()
    local is_changed = g_dragonUnitData:checkChange(self.m_collectionLastChangeTime)

    if is_changed then
        self.m_collectionLastChangeTime = g_dragonUnitData:getLastChangeTimeStamp()

        -- 리스트 refresh
        self.m_tableView:refreshAllItemUI()
    end
end

-------------------------------------
-- function click_rewardBtn
-- @brief
-------------------------------------
function UI_CollectionTabUnit:click_rewardBtn(unit_id)
    local function finish_cb(ret)
        self:checkRefresh()
    end

    g_dragonUnitData:request_unitReward(unit_id, finish_cb)
end

-------------------------------------
-- function click_selectBtn
-- @brief
-------------------------------------
function UI_CollectionTabUnit:click_selectBtn(unit_id)
    local function finish_cb(ret)
        self:checkRefresh()
    end

    g_dragonUnitData:request_unitSelect(unit_id, finish_cb)
end