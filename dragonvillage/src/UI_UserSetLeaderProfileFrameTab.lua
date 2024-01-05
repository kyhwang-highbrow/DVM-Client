local PARENT = UI_IndivisualTab
-------------------------------------
-- class UI_UserSetLeaderProfileFrameTab
-------------------------------------
UI_UserSetLeaderProfileFrameTab = class(PARENT, {
	m_tUserInfo = 'table',
    m_selectProfileFrameId = 'number',
    m_tableView = 'UIC_TableViewTD',
})

-------------------------------------
-- function init
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:init(t_user_info)
    self.m_uiName = 'UI_UserSetLeaderProfileFrameTab'
    self.m_selectProfileFrameId = g_profileFrameData:getSelectedProfileFrame()
    self:load('user_info_dragon_setting_profile_frame.ui')
	self.m_tUserInfo = t_user_info
    self.m_tableView = nil
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:initTableView()
    local vars = self.vars

    local create_cb = function(ui, data)
        ui.root:setScale(0.5)
        ui.root:setSwallowTouch(true)        
        ui.vars['clickBtn']:registerScriptTapHandler(function() 
            self:click_selectBtn(data)
        end)
        ui:setSelect(self.m_selectProfileFrameId == data)
	end

    local l_item_list = TableProfileFrame:getInstance():getAllProfileIdList()
    local table_view_td = UIC_TableViewTD(vars['listNode'])
    table_view_td.m_cellSize = cc.size(120, 120)
    table_view_td.m_nItemPerCell = 4
    table_view_td:setCellUIClass(UI_ProfileFrameItem, create_cb)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_item_list)
    self.m_tableView = table_view_td
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:refreshTableView()
    local refresh_func = function(t_data, data)
        if t_data['ui'] ~= nil then
            t_data['ui']:setSelect(self.m_selectProfileFrameId == data)
        end
    end

    local l_item_list = TableProfileFrame:getInstance():getAllProfileIdList()
    self.m_tableView:mergeItemList(l_item_list, refresh_func)
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:initButton()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:onEnterTab(first)
    if first == true then
        self:initTableView()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:onExitTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:click_selectBtn(profile_frame_id)
    self.m_selectProfileFrameId = profile_frame_id
    self:refreshTableView()
end

-------------------------------------
-- function click_equipBtn
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:click_equipBtn(profile_frame_id)

end



--@CHECK
UI:checkCompileError(UI_UserSetLeaderProfileFrameTab)
