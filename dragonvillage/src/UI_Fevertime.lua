local PARENT = UI

-------------------------------------
-- class UI_Fevertime
-- @breif 핫타임(개발 코드는 fevertime)
-------------------------------------
UI_Fevertime = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Fevertime:init()
    local ui_name = 'event_fevertime.ui'
    self:load(ui_name)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Fevertime:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Fevertime:initButton()
    local vars = self.vars

    local l_item_list = g_fevertimeData:getAllStructFevertimeList()

    local function sort_func(a, b)
        local struct_a = a['data']
        local struct_b = b['data']
        return StructFevertime.sortFunc(struct_a, struct_b)
    end

    local node = vars['listNode']
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(900, 90 + 10)
    require('UI_FevertimeListItem')
    table_view:setCellUIClass(UI_FevertimeListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    table_view:insertSortInfo('sort', sort_func)
    table_view:sortImmediately('sort')
    --self.m_tableView = table_view
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_Fevertime:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Fevertime:refresh()
end

--@CHECK
UI:checkCompileError(UI_Fevertime)
