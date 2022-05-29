local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Forest_StuffListPopup
-------------------------------------
UI_Forest_StuffListPopup = class(PARENT,{
        m_tStuffObjectTable = 'Table<ForestStuff>',
        m_tableView = 'UIC_TableView',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Forest_StuffListPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Forest_StuffListPopup'
    self.m_bVisible = true or false
    self.m_titleStr = Str('숲 관리')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_StuffListPopup:init(t_stuff_object)
    local vars = self:load('dragon_forest_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Forest_StuffListPopup')

    self.m_tStuffObjectTable = t_stuff_object

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_StuffListPopup:initUI()
    self:makeTableView()

    do -- 드래곤의 숲 확장 레벨 UI
        local ui = UI_Forest_ExtensionBoard()
        local vars = self.vars
        vars['forestLvNode']:addChild(ui.root)

        local function cb_forest_lv_change()
            self:refreshForestDragonCnt()
        end
        ui:setForestLvChange(cb_forest_lv_change)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest_StuffListPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest_StuffListPopup:refresh()
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_Forest_StuffListPopup:makeTableView()
    local node = self.vars['listNode']
    node:removeAllChildren()

	local item_list = ServerData_Forest:getInstance():getStuffInfoList()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(800, 110 + 3)
    table_view:setCellUIClass(UI_Forest_StuffListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(item_list)

    self.m_tableView = table_view

    
    local function sort_func(a, b)
        local a_stuff_type = a['data']['stuff_type']
        local b_stuff_type = b['data']['stuff_type']

        local a_extension_lv = TableForestStuffLevelInfo:getStuffTable(a_stuff_type)[1]['extension_lv']
        local b_extension_lv = TableForestStuffLevelInfo:getStuffTable(b_stuff_type)[1]['extension_lv']

        return a_extension_lv < b_extension_lv
    end

    table.sort(table_view.m_itemList, sort_func)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Forest_StuffListPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function refreshForestDragonCnt
-- @brief 드래곤의 숲 레벨이 변경됨에 따라 UI 갱신
-------------------------------------
function UI_Forest_StuffListPopup:refreshForestDragonCnt()
    for i,v in pairs(self.m_tableView.m_itemList) do
        local ui = v['ui']
        if ui then
            ui:refresh()
        end
    end
end