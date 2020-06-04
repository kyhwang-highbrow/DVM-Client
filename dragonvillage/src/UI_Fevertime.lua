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

    vars['hotTimeExpLabel']:setString('')
    vars['hotTimeGoldLabel']:setString('')

    -- 서버 시간 표시
    local time_zone_str, t = datetime.getTimeUTCHourStr()
    local hour = string.format('%.2d', t.hour)
    local min = string.format('%.2d', t.min)
    local sec = string.format('%.2d', t.sec)
    local str = Str('서버 시간 : {1}시 {2}분 {3}초 ({4})', hour, min, sec, time_zone_str)
    vars['serverTimeLabel']:setString(str)
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

    do -- 포커싱
        local idx = 0
        local l_struct_fevertime = table_view.m_itemList
        for i, v in ipairs(l_struct_fevertime) do
            local struct = v['data']
            if (struct:isAfterStartDate() == true) and (struct:isFevertimeExpired() == false) then
                idx = i
                break
            end
        end
        idx = math_min(idx + 1, #l_struct_fevertime)

        table_view:relocateContainerFromIndex(idx, false)
    end

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
