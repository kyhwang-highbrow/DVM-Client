local PARENT = class(UI, ITabUI:getCloneTable())

UI_DragonLairBlessingPopup = class(PARENT, {
    m_listView = 'UIC_TableView',
    m_blessTargetIdList = 'List<id>',
    m_mGoodsInfo = 'UI',
})

--------------------------------------------------------------------------
-- @function init  
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:init()
    local vars = self:load('dragon_lair_blessing.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairBlessingPopup') -- backkey 지정

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.3)

    --self:doActionReset()
    --self:doAction(nil, false)
    
    self:initUI()
    self:initButton()
    self:initTab()
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

    local goods_icon = IconHelper:getPriceIcon('blessing_ticket')
    vars['goodsNode']:removeAllChildren()
    vars['goodsNode']:addChild(goods_icon)


    do -- 상단 재화
        local ui = UI_GoodsInfo('blessing_ticket')
        vars['goodsNode']:removeAllChildren()
        vars['goodsNode']:addChild(ui.root)
        self.m_mGoodsInfo = ui
    end
    
    do -- 이름
        --local season_name = g_lairData:getLairSeasonName()
        local season_desc = g_lairData:getLairSeasonDesc()
        vars['titleLabel']:setString(season_desc)
    end

    local function update(dt)
        self.m_mGoodsInfo:refresh()
    end

    self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
end

--------------------------------------------------------------------------
-- @function initButton
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:initButton()
    local vars = self.vars
    vars['blessBtn']:registerScriptTapHandler(function() self:click_blessBtn() end)
    vars['blessAutoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
    --vars['blockBtn']:registerScriptTapHandler(function() end)

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
    local type = self.m_currTab

    do -- 타입별 모든 능력치 
        local table_option = TableOption()        
        local option_key_list = g_lairData:getLairRepresentOptionKeyListByType(type)

        for idx, option_key in ipairs(option_key_list) do
            local label_str = string.format('TypeLabel%d', idx)
            vars[label_str]:setVisible(false)

            local option_value_sum, option_bonus_sum = g_lairData:getLairStatOptionValueSum(type ,option_key)
            local option_value_total = option_value_sum + option_bonus_sum
            local progress_label_str = string.format('TypeProgressLabel%d', idx)
            local desc = table_option:getOptionDesc(option_key, option_value_total)
            
            if option_value_sum == 0 then
                vars[progress_label_str]:setString(desc)
            else
                vars[progress_label_str]:setString(string.format('{@ORANGE}%s(%d + {@green}%d{@}{@ORANGE}){@}',desc, option_value_sum, option_bonus_sum))
            end

            -- 보너스
            local bonus_label_str =  string.format('BonusLabel%d', idx)
            vars[bonus_label_str]:setVisible(false)
        end
    end

    do -- 프로그레스
        local curr_progress, max_progress = g_lairData:getLairStatProgressInfo(type)
        local percentage = curr_progress*100/max_progress
        --vars['TypeProgress']:setPercentage(curr_progress*100/max_progress)
        local progress_to = cc.EaseIn:create(cc.ProgressTo:create(0.3, percentage), 1)
        vars['TypeProgress']:setPercentage(0)
		vars['TypeProgress']:runAction(progress_to)
    end

    do -- 가격
        local _, need_count = g_lairData:getLairStatBlessTargetIdList(self.m_currTab)
        vars['priceLabel']:setString(need_count)
    end

    do -- 보유 재화
        local goods_count = g_userData:get('blessing_ticket')
        if vars['goodsLabel'] ~= nil then
            vars['goodsLabel']:setString(comma_value(goods_count))
        end
    end
end

--------------------------------------------------------------------------
-- @function refreshTableView
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:refreshTableView(lair_id_list)
    local func_find = function(val)
        for i,v in ipairs(lair_id_list) do
            if v == val then
                return true
            end
        end

        return false
    end

    for i,v in pairs(self.m_listView.m_itemList) do
        local ui = v['ui']
        ui:refresh()
        if func_find(v['data']) == true then
            ui:showLabelEffect()
        end
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

    local animator = MakeAnimator(string.format('res/ui/icons/bless/bless_%d.png', tonumber(tab)))
    vars['iconNode1']:removeAllChildren()
    vars['iconNode1']:addChild(animator.m_node)

    cca.dropping(animator.m_node, 100)

    local special_type, ani_type = g_lairData:getLairSeasonSpecialType()
    vars['effectVisual1']:setVisible(tab == special_type)
    vars['effectVisual1']:changeAni(ani_type, true)

    cca.dropping(vars['effectVisual1'], 100)

    self:refresh()
end

--------------------------------------------------------------------------
-- @function makeTableView
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:makeTableView(curr_tab)
    local vars = self.vars
    local node = vars['optionNode']
    node:removeAllChildren()
    local item_list = TableLairBuff:getInstance():getLairIdListByType(curr_tab)

    local function create_func(ui, data)
        local lair_id = data

        local click_refresh = function()
            self:click_refreshBtn(lair_id)
        end

        ui.vars['refreshBtn']:registerScriptTapHandler(click_refresh)
    
        local click_lock = function()
            local struct_lair_stat = g_lairData:getLairStatInfo(lair_id)
            local is_lock = ui.vars['lockBtn']:isChecked()        
            local req_count = TableLairBuff:getInstance():getLairRequireCount(lair_id)
            local is_available = g_lairData:getLairSlotCompleteCount() >= req_count

            local success_cb = function ()
                self:refresh()
                ui:refresh()
            end
        
            if is_available == false then
                UIManager:toastNotificationRed(Str('아직 이용할 수 없습니다.'))
                ui.vars['lockBtn']:setChecked(not is_lock)
                return
            end

            if is_lock == false and struct_lair_stat:isStatOptionMaxLevel() == true then
                MakeSimplePopup(POPUP_TYPE.YES_NO, Str('최대 옵션 수치를 달성한 상태입니다.\n그래도 잠금을 해제하시겠습니까?'),
                    function()
                        g_lairData:request_lairStatLock(tostring(lair_id), is_lock, success_cb)
                    end)
                ui.vars['lockBtn']:setChecked(not is_lock)
                return
            end
            
            g_lairData:request_lairStatLock(tostring(lair_id), is_lock, success_cb)
        end
        
        ui.vars['lockBtn']:registerScriptTapHandler(click_lock)
        return ui
    end

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(990, 25)
    table_view:setCellUIClass(UI_DragonLairBlessingPopupItem, create_func)
    --table_view:setCellCreateInterval(0.1)
    table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['ui_action'])
    table_view:setCellSizeToNodeSize()
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(item_list, true)
    table_view.m_scrollView:setTouchEnabled(false)
    self.m_listView = table_view
end

--------------------------------------------------------------------------
-- @function begin_autoBlessingSeq
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:begin_autoBlessingSeq(_auto_count, _target_option_list)
    local vars = self.vars
    local target_option_list = _target_option_list
    local auto_count = _auto_count
    local curr_count = 0
    local is_auto_stop = false
    local lock_id_list = {} -- 자동 중 최대 옵션이 나온 경우 잠근다
    
    -- 컨트롤 함수    
    local func_control_auto = function(on)
        vars['ingMenu']:setVisible(on)
        vars['blessAutoBtn']:setVisible(not on)
        vars['blessAutoStopBtn']:setVisible(on)
        vars['blockMenu']:setVisible(on)
        UIManager:blockBackKey(on)
        is_auto_stop = not on
    end
    
    -- 매 루프마다 만족하는 옵션이 나왔는지 체크
    local refresh_target_list = function() 
        local result_list = {}
        local target_id_list, need_count = g_lairData:getLairStatBlessTargetIdList(self.m_currTab)
        local available_count = math_min(g_userData:get('blessing_ticket'), need_count)

        for _, lair_id in ipairs(target_id_list) do
            local struct_lair_stat = g_lairData:getLairStatInfo(lair_id)
            local option_key = struct_lair_stat:getStatOptionKey()
            local option_value = struct_lair_stat:getStatOptionValue()
             local is_satify = false
            for key, val in pairs(target_option_list) do
                if option_key == key and option_value >= val then
                    table.insert(lock_id_list, lair_id)
                    is_satify = true
                    struct_lair_stat:setStatReserveLock()
                    break
                end
            end

            if is_satify == false and #result_list < available_count then
                table.insert(result_list, lair_id)
            end
        end

        return result_list, #result_list
    end

    vars['blessAutoStopBtn']:registerScriptTapHandler(func_control_auto)

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        func_control_auto(true)

        while true do
            local target_id_list, target_id_count  = refresh_target_list()
            local blessing_ticket = g_userData:get('blessing_ticket')

            -- 시즌 종료
            if g_lairData:checkSeasonEnd() == true then
                UIManager:toastNotificationGreen(Str('시즌이 종료되었습니다.'))
                break
            end

            -- 티켓이 모자란 경우
            if blessing_ticket < target_id_count == true then
                UIManager:toastNotificationGreen(Str('자동 축복이 종료되었습니다.'))
                break
            end

            -- 대상이 없을 경우
            if #target_id_list == 0 then
                UIManager:toastNotificationGreen(Str('자동 축복이 종료되었습니다.'))
                break
            end

            -- 횟수를 채운 경우
            if curr_count >= auto_count then
                UIManager:toastNotificationGreen(Str('자동 축복이 종료되었습니다.'))
                break
            end

            -- 자동 축복을 종료한 경우
            if is_auto_stop == true then
                UIManager:toastNotificationGreen(Str('자동 축복이 종료되었습니다.'))
                break
            end

            -- 서버 요청
            co:work()
            local str_ids = table.concat(target_id_list, ',')
            g_lairData:request_lairStatPick(str_ids, function(ret)
                self:refreshTableView(target_id_list)
                self:refresh()
                curr_count = curr_count + (#target_id_list)
                co.NEXT()
            end, co.ESCAPE)
            if co:waitWork() then return end

            vars['ingLabel']:setString(Str('{1}/{2}회 진행 중', curr_count, auto_count))

            -- 0.5초 기다림
            co:waitTime(0.5)
        end

        -- 만족하는 옵션이 나왔을 경우 잠금 처리
        if #lock_id_list > 0 then
            co:work()
            UIManager:toastNotificationGreen(Str('원하시는 옵션을 획득하여 잠금처리합니다.'))
            self:request_lair_lock(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        func_control_auto(false)
        co:close()
    end

    Coroutine(coroutine_function, 'begin_autoBlessingSeq')
end

--------------------------------------------------------------------------
-- @function request_lair_lock
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:request_lair_lock(success_cb, fail_cb)
    local lock_id_list = {}
    local target_id_list, need_count = g_lairData:getLairStatBlessTargetIdList(self.m_currTab)
    
    for _, lair_id in ipairs(target_id_list) do
        local struct_lair_stat = g_lairData:getLairStatInfo(lair_id)
        if struct_lair_stat:isStatReserveLock() == true then
            table.insert(lock_id_list, lair_id)
        end
    end

    if #lock_id_list == 0 then
        return
    end

    local str_ids = table.concat(lock_id_list, ',')
    g_lairData:request_lairStatLock(str_ids, true, function(ret) 
        self:refreshTableView(lock_id_list)
        self:refresh()
        if success_cb ~= nil then
            success_cb()
        end
    end, fail_cb)
end

--------------------------------------------------------------------------
-- @function check_maxLevel
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:check_maxLevel(target_id_list)
    for _, lair_id in ipairs(target_id_list) do
        local info = g_lairData:getLairStatInfo(lair_id)
        if info:isStatOptionMaxLevel() == true then
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------
-- @function click_autoBtn
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:click_autoBtn()
    -- 축복 티켓이 없을 경우 예외 처리
    local target_id_list, need_count = g_lairData:getLairStatBlessTargetIdList(self.m_currTab)
    if ConfirmPrice('blessing_ticket', need_count) == false then
        return
    end

    if need_count == 0 then
        UIManager:toastNotificationRed(Str('하나 이상의 축복 효과가 잠금이 해제되어야 합니다.'))
        return
    end

    local function ok_callback(auto_count, target_option_list)
        self:begin_autoBlessingSeq(auto_count, target_option_list)
    end

    local function confirm_cb()
        local ui = UI_DragonLairBlessingAutoPopup(self.m_currTab, target_id_list)
        ui:setOkCallback(ok_callback)
    end

    if self:check_maxLevel(target_id_list) == true then
        local msg = Str('최대 수치의 옵션이 포함되어 있습니다.\n그래도 진행하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, confirm_cb)
        return
    end

    confirm_cb()
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

    local success_cb = function(ret)
        for _, lair_id in ipairs(target_id_list) do
            local struct_lair_stat = g_lairData:getLairStatInfo(lair_id)
            if struct_lair_stat:isStatOptionMaxLevel() == true then
                struct_lair_stat:setStatReserveLock()
            end
        end

        self:refreshTableView(target_id_list)
        self:refresh()
        self:request_lair_lock()
    end

    local ok_btn_cb = function()    
        local str_ids = table.concat(target_id_list, ',')
        g_lairData:request_lairStatPick(str_ids, success_cb)
    end

    local confirm_cb = function()
        local msg = Str('축복 효과를 받으시겠습니까?')
        local submsg = Str('{1}개의 축복 티켓이 사용됩니다.', need_count)
        local ui = MakeSimplePricePopup(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
        ui:setPrice('blessing_ticket', need_count)
    end

    if self:check_maxLevel(target_id_list) == true then
        local msg = Str('최대 수치의 옵션이 포함되어 있습니다.\n그래도 진행하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, confirm_cb)
        return
    end

    confirm_cb()
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

    local msg = Str('{1}개의 다이아를 사용하여 축복 효과를 초기화하시겠습니까?', 3000)
    local submsg = Str('초기화를 할 경우 {1}개의 축복 티켓을 돌려받습니다.', struct_lair_stat:getStatPickCount())
    local ui = MakeSimplePricePopup(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
    ui:setPrice('cash', 3000)
end

--------------------------------------------------------------------------
-- @function click_helpBtn
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:click_helpBtn()
    UI_Help('blessing')
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