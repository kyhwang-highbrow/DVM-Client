local PARENT = class(UI, ITabUI:getCloneTable())

UI_DragonLairBlessingPopup = class(PARENT, {
    m_listView = 'UIC_TableView',
    m_blessTargetIdList = 'List<id>',
})

--------------------------------------------------------------------------
-- @function init  
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:init()
    local vars = self:load('dragon_lair_blessing.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairBlessingPopup') -- backkey 지정
    
    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.3)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:makeTableView()
    self:refresh()
end

--------------------------------------------------------------------------
-- @function initUI
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:initUI()
    local vars = self.vars

    local price_icon = IconHelper:getPriceIcon('blessing_ticket')
    vars['priceNode']:removeAllChildren()
    vars['priceNode']:addChild(price_icon)

    self:initTab()
end

--------------------------------------------------------------------------
-- @function initButton
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:initButton()
    local vars = self.vars

    vars['blessBtn']:registerScriptTapHandler(function() self:click_blessBtn() end)
    vars['blessAutoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)


    	-- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            local text = vars['addTicketEdit']:getText()

            local success_cb = function()
                self:refresh()
            end

            g_lairData:request_lairAddBlessingTicketManage(tonumber(text), success_cb)
        end
    end

    if IS_TEST_MODE() == true then
        vars['addTicketEdit']:registerScriptEditBoxHandler(editBoxTextEventHandle)
        vars['addTicketEdit']:setMaxLength(5)
        vars['addTicketEdit']:setVisible(true)
        vars['addTicketBtn']:registerScriptTapHandler(function() self:click_addTicketBtn() end)
    end

end

--------------------------------------------------------------------------
-- @function refresh 
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:refresh()
    local vars = self.vars

    do -- 타입별 모든 능력치 
        local stat_id_list, stat_count = g_lairData:getLairStatIdList(self.m_currTab)

        if stat_count == 0 then
            vars['infoLabel']:setString(Str('축복 효과 없음'))
        else
            local attr_str = TableLairStatus:getInstance():getLairOverlapStatStrByIds(stat_id_list)
            vars['infoLabel']:setString(attr_str)
        end
    end

    do -- 가격
        local price_value = g_userData:get('blessing_ticket') or 0
        vars['priceLabel']:setString(comma_value(price_value))
    end
end

--------------------------------------------------------------------------
-- @function initTab
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:initTab()
    local vars = self.vars

    local func_cb = function (tab, first)
        self:onEnterTab(tab, first)
    end

    self:setChangeTabCB(func_cb)

    for i = 1, 5 do
        self:addTabAuto(i, vars)
    end

    self:setTab(1)
end

--------------------------------------------------------------------------
-- @function onEnterTab
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:onEnterTab(tab, first)
    local vars = self.vars
    self:makeTableView(self.m_currTab)
    self.m_blessTargetIdList = g_lairData:getLairStatBlessTargetIdList(self.m_currTab)

    self:refresh()
end

--------------------------------------------------------------------------
-- @function makeTableView
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:makeTableView(curr_tab)
    local vars = self.vars
    local node = vars['optionNode']
    node:removeAllChildren()

    local item_list = TableLair:getInstance():getLairIdListByType(curr_tab)

    local function create_func(data)
        local ui = UI_DragonLairBlessingPopupItem(data)
        local lair_id = data

        local click_refresh = function()
            self:click_refreshBtn(lair_id)
        end

        ui.vars['refreshBtn']:registerScriptTapHandler(click_refresh)
    
        local click_lock = function()
            local struct_lair_stat = g_lairData:getLairStatInfo(lair_id)
            local is_lock = ui.vars['lockBtn']:isChecked()        
            local req_count = TableLair:getInstance():getLairRequireCount(lair_id)
            local is_available = g_lairData:getLairSlotCompleteCount() >= req_count
        
            if is_available == false then
                UIManager:toastNotificationRed(Str('아직 이용할 수 없습니다.'))
                ui.vars['lockBtn']:setChecked(not is_lock)
                return
            end

            if struct_lair_stat:getStatId() == 0 then
                UIManager:toastNotificationRed(Str('축복 효과가 없는 상태에서 잠금이 불가합니다.'))
                ui.vars['lockBtn']:setChecked(not is_lock)
                return
            end
        
            local success_cb = function ()
                self:refresh()
                ui:refresh()
            end
            
            g_lairData:request_lairStatLock(lair_id, is_lock, success_cb)
        end
        
        ui.vars['lockBtn']:registerScriptTapHandler(click_lock)
        return ui
    end

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(990, 25)
    table_view:setCellUIClass(create_func)
    --table_view.m_gapBtwCellsSize = 5
    table_view:setCellSizeToNodeSize()
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(item_list, true)
    
    self.m_listView = table_view
end

--------------------------------------------------------------------------
-- @function click_autoBtn
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:click_autoBtn()
    UIManager:toastNotificationRed('작업 중입니다.')
end

--------------------------------------------------------------------------
-- @function click_blessBtn
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:click_blessBtn()
    -- 축복 티켓이 없을 경우 예외 처리
    local target_id_list, need_count = g_lairData:getLairStatBlessTargetIdList(self.m_currTab)
    if ConfirmPrice('blessing_ticket', need_count) == false then
        return
    end

    if need_count == 0 then
        UIManager:toastNotificationRed(Str('하나 이상의 축복 효과가 잠금이 해제되어야 합니다.'))
        return
    end

    local ok_btn_cb = function()
        local success_cb = function(ret)
            self:makeTableView(self.m_currTab)
            self:refresh()
        end
    
        local str_ids = table.concat(target_id_list, ',')
        g_lairData:request_lairStatPick(str_ids, success_cb)
    end
    
    local msg = Str('축복 효과를 받으시겠습니까?')
    local submsg = Str('{1}개의 축복 티켓이 사용됩니다.', need_count)
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

--------------------------------------------------------------------------
-- @function click_refreshBtn
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:click_refreshBtn(stat_id)
    local struct_lair_stat = g_lairData:getLairStatInfo(stat_id)
    if struct_lair_stat == nil then
        return
    end

    -- 옵션이 없을 경우 예외 처리
    if struct_lair_stat:getStatPickCount() == 0 then
        UIManager:toastNotificationRed(Str('버프 효과가 없습니다.'))
        return
    end

    -- 잠겼을 경우 예외 처리
    if struct_lair_stat:isStatLock() == true then
        UIManager:toastNotificationRed(Str('잠긴 상태에서는 초기화가 불가능합니다.'))
        return
    end


    local ok_btn_cb = function()
        local success_cb = function(ret)
            self:makeTableView(self.m_currTab)
            self:refresh()
        end
    
        g_lairData:request_lairStatReset(stat_id, success_cb)
    end

    local msg = Str('축복 효과를 초기화하시겠습니까?')
    local submsg = Str('초기화를 할 경우 {1}개의 축복 티켓을 돌려받습니다.', struct_lair_stat:getStatPickCount())
    local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

--------------------------------------------------------------------------
-- @function click_closeBtn
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:click_closeBtn()
    self:close()
end

--------------------------------------------------------------------------
-- @function click_addTicketBtn
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:click_addTicketBtn()
    local vars = self.vars
    vars['memoEditBox']:openKeyboard()
end



--------------------------------------------------------------------------
-- @function open
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup.open()
    local ui = UI_DragonLairBlessingPopup()
    return ui
end