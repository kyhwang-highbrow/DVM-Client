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

    vars['listNode']:removeAllChildren()
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

    vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtn() end)
    vars['unequipBtn']:registerScriptTapHandler(function() self:click_unequipBtn() end)
    vars['unequipBtn']:setEnabled(false)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:onEnterTab(first)
    local vars = self.vars
    if first == true then
        self.root:scheduleUpdateWithPriorityLua(function () self:update() end, 1)
    end

    do -- 드래곤
        local dragon_obj = g_dragonsData:getLeaderDragon()
        vars['dragonNode']:removeAllChildren()
        if dragon_obj ~= nil then
            local card = UI_DragonCard(dragon_obj, nil, nil, nil,true)
            card.vars['clickBtn']:setEnabled(false)
            vars['dragonNode']:addChild(card.root)
        end
    end

    self:initTableView()
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

    do -- 이름
        if self.m_selectProfileFrameId == 0 then
            vars['nameLabel']:setString('')
        else
            local name = TableItem:getItemName(self.m_selectProfileFrameId)
            vars['nameLabel']:setString(name)
        end
    end

    do -- 프레임
        local profile_frame_animator = IconHelper:getProfileFrameAnimator(self.m_selectProfileFrameId)
        vars['frameNode']:removeAllChildren()
        if profile_frame_animator ~= nil then
            vars['frameNode']:addChild(profile_frame_animator.m_node)
        end
    end

    do -- 버튼
        local profile_frame = g_profileFrameData:getSelectedProfileFrame()
        local is_equpped = profile_frame == self.m_selectProfileFrameId
        local is_select = self.m_selectProfileFrameId ~= 0
        --local is_owned = g_profileFrameData:isOwnedProfileFrame(self.m_selectProfileFrameId)

        vars['equipBtn']:setVisible(not is_equpped and is_select)
        vars['unequipBtn']:setVisible(is_equpped and is_select)
        vars['stateLabel']:setVisible(is_select)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:update()
    local vars = self.vars
    do -- 버튼
        local profile_frame = self.m_selectProfileFrameId
        if profile_frame == 0 then
            vars['stateLabel']:setString('')
            return
        end

        local is_owned = g_profileFrameData:isOwnedProfileFrame(self.m_selectProfileFrameId)
        if is_owned == true then
            local msg = g_profileFrameData:getRemainTimeStr(profile_frame)
            vars['stateLabel']:setString(string.format('%s%s', '{@green}' ,msg))
        else
            vars['stateLabel']:setString(string.format('%s%s', '{@RED}' ,Str('미보유')))
        end
    end
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:click_selectBtn(profile_frame_id)
    self.m_selectProfileFrameId = profile_frame_id
    self:update()
    self:refresh()
    self:refreshTableView()
end

-------------------------------------
-- function click_equipBtn
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:click_equipBtn()
    -- 소유 중인 프로필 테두리냐?
    if g_profileFrameData:isOwnedProfileFrame(self.m_selectProfileFrameId) == false then
        UIManager:toastNotificationRed(Str('현재 보유 중인 테두리가 아닙니다.'))
        return
    end

    local success_cb = function(ret)
        UIManager:toastNotificationGreen(Str('테두리를 착용하였습니다.'))
    end

    g_profileFrameData:request_equip(self.m_selectProfileFrameId, success_cb)
end

-------------------------------------
-- function click_equipBtn
-------------------------------------
function UI_UserSetLeaderProfileFrameTab:click_unequipBtn()
    local success_cb = function(ret)
        UIManager:toastNotificationGreen(Str('착용이 해제되었습니다.'))
    end

    g_profileFrameData:request_equip(0, success_cb)
end

--@CHECK
UI:checkCompileError(UI_UserSetLeaderProfileFrameTab)
