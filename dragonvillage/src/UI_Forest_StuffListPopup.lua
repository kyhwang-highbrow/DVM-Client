local PARENT = UI

-------------------------------------
-- class UI_Forest_StuffListPopup
-------------------------------------
UI_Forest_StuffListPopup = class(PARENT,{
        m_tableView = 'UIC_TableView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_StuffListPopup:init()
    local vars = self:load('dragon_forest_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Forest_StuffListPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_StuffListPopup:initUI()
    self:makeTableView()
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

	local l_stuff_list = {}
    for _, t_stuff in pairs(table_forest_stuff.m_orgTable) do
        local clone_stuff = clone(t_stuff)
        local server_info = t_server_info[stuff_type] or {}
        
        for i, v in pairs(server_info) do
            clone_stuff[i] = v
        end

        table.insert(l_stuff_list, clone_stuff)
    end

	-- item ui에 보상 수령 함수 등록하는 콜백 함수
	local create_cb_func = function(ui, data)

	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(800, 110 + 3)
    table_view:setCellUIClass(self.makeCellUI, create_cb_func)
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
function UI_Forest_StuffListPopup.makeCellUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('dragon_forest_popup_item.ui')

    local name = t_data['stuff_name']
    local lv = t_data['stuff_lv'] or 0
    vars['nameLabel']:setString(string.format('%s Lv.%d', name, lv))

    local desc = ''
    vars['dscLabel']:setString(desc)

    local icon = IconHelper:getIcon(t_data['res'])
    vars['iconNode']:addChild(icon)

    vars['levelupBtn']:registerScriptTapHandler(function()
        UI_Forest_StuffLevelupPopup(t_data)    
    end)

	return ui
end