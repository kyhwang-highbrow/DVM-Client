local PARENT = UI

-------------------------------------
-- class UI_Forest_StuffListPopup
-------------------------------------
UI_Forest_StuffListPopup = class(PARENT,{
        m_tStuffObjectTable = 'Table<ForestStuff>',
        m_tableView = 'UIC_TableView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_StuffListPopup:init(t_stuff_object)
    local vars = self:load('dragon_forest_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Forest_StuffListPopup')

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

    -- 드래곤의 숲 확장 레벨 UI
    local ui = UI_Forest_ExtensionBoard()
    local vars = self.vars
    vars['forestLvNode']:addChild(ui.root)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest_StuffListPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
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

    local table_forest_stuff = TableForestStuffType()
    local t_server_info = ServerData_Forest:getInstance():getStuffInfo()

	local l_stuff_list = self.m_tStuffObjectTable

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(800, 110 + 3)
    table_view:setCellUIClass(self.makeCellUI, nil)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_stuff_list)

    self.m_tableView = table_view
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Forest_StuffListPopup:click_closeBtn()
    self:close()
end








-------------------------------------
-- function makeCellUI
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_Forest_StuffListPopup.makeCellUI(stuff_object)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('dragon_forest_popup_item.ui')

    local t_data = stuff_object.m_tStuffInfo

    -- 이름 레벨
    local name = t_data['stuff_name']
    local lv = t_data['stuff_lv'] or 0
    vars['nameLabel']:setString(string.format('%s Lv.%d', name, lv))

    -- 설명
    local stuff_type = t_data['stuff_type']
    local desc = TableForestStuffLevelInfo:getStuffOptionDesc(stuff_type, lv)
    vars['dscLabel']:setString(desc)
    
    -- 아이콘
    local icon = IconHelper:getIcon(t_data['res'])
    vars['iconNode']:addChild(icon)

    -- 레벨업 버튼
    vars['levelupBtn']:registerScriptTapHandler(function()
        UI_Forest_StuffLevelupPopup(stuff_object):setCloseCB(function()
            UI_Forest_StuffListPopup.refreshCell(ui, t_data)
        end)    
    end)

    -- 레벨업 버튼 막기
    if (nil == TableForestStuffLevelInfo:getStuffOptionDesc(stuff_type, lv + 1)) then
        vars['levelupBtn']:setEnabled(false)
    end
	return ui
end

-------------------------------------
-- function refreshCell
-- @static
-- @brief 테이블 셀 갱신
-------------------------------------
function UI_Forest_StuffListPopup.refreshCell(ui, t_data)
    local vars = ui.vars

    local name = t_data['stuff_name']
    local lv = t_data['stuff_lv'] or 0
    vars['nameLabel']:setString(string.format('%s Lv.%d', name, lv))

    local stuff_type = t_data['stuff_type']
    local desc = TableForestStuffLevelInfo:getStuffOptionDesc(stuff_type, lv)
    vars['dscLabel']:setString(desc)
end
