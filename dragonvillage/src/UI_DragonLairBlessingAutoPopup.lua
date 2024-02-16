-------------------------------------
-- class UI_DragonLairBlessingAutoPopup
-------------------------------------
UI_DragonLairBlessingAutoPopup = class(UI, {
    m_lairIdList = 'List<number>',
    m_lairType = 'number',
    m_tableview = 'UIC_TableView',

    m_ticketNum = 'number',
    m_autoCount = 'number',
    m_maxAutoCount = 'number',

    m_ticketnumPerBlessing = 'number',
    m_okCallback = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingAutoPopup:init(type, target_id_list)
    self.m_lairIdList = target_id_list
    self.m_lairType = type
    self.m_ticketnumPerBlessing = #target_id_list

    self:load('dragon_lair_blessing_setting_popup.ui')
    self.m_uiName = 'UI_DragonLairBlessingAutoPopup'
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairBlessingAutoPopup')
    
    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    local item_num = g_userData:get('blessing_ticket')
    local auto_num = math_floor(item_num/self.m_ticketnumPerBlessing)
    
    self.m_autoCount = self.m_ticketnumPerBlessing
    self.m_maxAutoCount = auto_num * self.m_ticketnumPerBlessing

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLairBlessingAutoPopup:initUI()
    local vars = self.vars
    self:initTableView()

    local price_icon = IconHelper:getPriceIcon('blessing_ticket')
    vars['priceNode']:removeAllChildren()
    vars['priceNode']:addChild(price_icon)

    vars['quantityLabel']:setString(self.m_autoCount)
    vars['priceLabel']:setString(self.m_autoCount)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonLairBlessingAutoPopup:initTableView()
    local vars = self.vars
    local node = vars['optionNode']
    local type_id = self.m_lairType
    local item_list = TableLairBuffStatus:getInstance():getLairRepresentOptionKeyListByType(type_id)

    local table_view = UIC_TableView(node)
    table_view:setCellUIClass(UI_DragonLairBlessingAutoPopupItem)
    table_view.m_gapBtwCellsSize = 5
    table_view:setCellSizeToNodeSize()
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(item_list, true)
    self.m_tableview = table_view
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonLairBlessingAutoPopup:initButton()
    local vars = self.vars

    vars['blessAutoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['plusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(1) end)
    vars['plusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(1, true) end)
    vars['minusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(-1) end)
    vars['minusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(-1, true) end)    
    vars['100Btn']:registerScriptTapHandler(function() self:click_adjustBtn(5) end)
    vars['100Btn']:registerScriptPressHandler(function() self:click_adjustBtn(5, true) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLairBlessingAutoPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function setOkCallback
-------------------------------------
function UI_DragonLairBlessingAutoPopup:setOkCallback(callback)
    self.m_okCallback = callback
end

-------------------------------------
-- function getTargetOptionList
-------------------------------------
function UI_DragonLairBlessingAutoPopup:getTargetOptionList()
    local item_list = self.m_tableview.m_itemList
    local result = {}

    --체크된 리스트 항목 뽑기
    for _, item in pairs(item_list) do
        local ui = item['ui']
        if(ui == nil) then
             break
        end

        if (ui.m_isChecked == true) then
            local option_type = ui.m_optionKey

            local cur_id = ui.m_optionIdList[ui.m_currValue]
            local option_value = TableLairBuffStatus:getInstance():getLairStatOptionValue(cur_id)

            result[option_type] = option_value
        end
    end

    return result
end

-------------------------------------
-- function saveAutoSetting
-------------------------------------
function UI_DragonLairBlessingAutoPopup:saveAutoSetting(option_list)
    if (option_list ~= nil) and (type(option_list) == 'table') then
        for option_type, option_value in pairs(option_list) do
            g_settingData:setLairBlessingAutoSetting(option_type, option_value)
        end
    end
end

-------------------------------------
-- function click_autoBtn
-------------------------------------
function UI_DragonLairBlessingAutoPopup:click_autoBtn()
    local target_option_list = self:getTargetOptionList()

    if (table.count(target_option_list) == 0) then
        UIManager:toastNotificationRed(Str('원하는 축복 옵션을 선택해 주세요'))
        return
    end

    local function ok_callback()
        local auto_grind_num = self.m_autoCount

        self:click_closeBtn()

        if self.m_okCallback then
            self.m_okCallback(auto_grind_num, target_option_list)
        end
    end

    local main_msg = Str('선택한 옵션으로 자동 축복을 시작합니다.\n진행하시겠습니까?')
    local sub_msg = Str('자동 축복 횟수: {1}', self.m_autoCount)

    MakeSimplePopup2(POPUP_TYPE.YES_NO, main_msg, sub_msg, ok_callback)
end


-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonLairBlessingAutoPopup:click_closeBtn()
    local item_list = self.m_tableview.m_itemList
    local target_option_list = {}

    --체크된 리스트 항목 뽑기
    for _, item in pairs(item_list) do
        local ui = item['ui']
        if(ui == nil) then
             break
        end

        if (ui.m_isChecked == true) then
            local option_type = ui.m_optionKey
            target_option_list[option_type] = ui.m_currValue
        end
    end

    self:saveAutoSetting(target_option_list)
    self:close()
end

-------------------------------------
-- function click_adjustBtn
-------------------------------------
function UI_DragonLairBlessingAutoPopup:click_adjustBtn(value, is_pressed)
    local vars = self.vars
    local function adjust_function()
        local curr_num = self.m_autoCount + (value * self.m_ticketnumPerBlessing)
        local before_Value = self.m_autoCount

        if (curr_num > 0) and (curr_num <= self.m_maxAutoCount) then
            self.m_autoCount = curr_num
        elseif (curr_num > self.m_maxAutoCount) then
            self.m_autoCount = self.m_maxAutoCount
        end

        --값이 변경되지 않았으면 팝업과 함께 리턴
        if (before_Value == self.m_autoCount) then
            return false
        end

        vars['quantityLabel']:setString(self.m_autoCount)
        vars['priceLabel']:setString(self.m_autoCount)
        return true
    end

    if (not is_pressed) then
        adjust_function()
    else -- (is_pressed == true)
        local button
        if (value < 0) then
            button = vars['minusBtn']
        elseif (value >= 5) then
            button = vars['100Btn']
        else
            button = vars['plusBtn']
        end

        local function update_callback(dt)
            local result = adjust_function()
            if (result == false) or (button:isSelected() == false) or (button:isEnabled() == false) then
                self.root:unscheduleUpdate()
                return
            end
        end

        self.root:scheduleUpdateWithPriorityLua(function(dt) return update_callback(dt) end, 1)
    end
end
















PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_DragonLairBlessingAutoPopupItem
-------------------------------------
UI_DragonLairBlessingAutoPopupItem = class(PARENT, {
    m_lairStatId = 'table',
    m_optionIdList = '',
    m_optionKey = 'string',
    m_targetRune = 'StructRuneObject',
    m_tableOption = '',

    m_isPercent = 'boolean',
    m_isChecked = 'boolean',

    m_minValue = 'number',
    m_maxValue = 'number',
    m_currValue = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingAutoPopupItem:init(data)
    self.m_isChecked = false
    self.m_optionKey = data
    self.m_optionIdList = TableLairBuffStatus:getInstance():getLairStatOptionIdList(self.m_optionKey)

    self:load('dragon_lair_blessing_setting_popup_item.ui')

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0.2, 0.3)
    self:doActionReset()
    self:doAction(nil, false)

    self.m_tableOption = TableOption()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingAutoPopupItem:initUI()
    local vars = self.vars
    local min_value = 1
    local max_value = #self.m_optionIdList
    self.m_minValue = min_value
    self.m_maxValue = max_value
    self.m_currValue = min_value

    local save_val = g_settingData:getLairBlessingAutoSetting(self.m_optionKey)
    if save_val ~= nil and save_val <= max_value then
        --self.m_isChecked = true
        self.m_currValue = save_val
    end

    local season_option = g_lairData:getLairSeasonOption()
    local season_color = g_lairData:getLairSeasonColor()

    do
        if table.find(season_option, self.m_optionKey) ~= nil then
            vars['effectLayer']:setColor(COLOR[season_color])
            vars['effectLayer']:setVisible(true)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonLairBlessingAutoPopupItem:initButton()
    local vars = self.vars
    
    vars['plusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(1) end)
    vars['plusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(1, true) end)
    vars['minusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(-1) end)
    vars['minusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(-1, true) end)
    vars['checkBoxBtn']:registerScriptTapHandler(function() self:click_checkBoxBtn() end)
end



-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingAutoPopupItem:refresh()
    local vars = self.vars
    local option_type = self.m_optionKey

    vars['checkSprite']:setVisible(self.m_isChecked)
    vars['quantityMenu']:setVisible(self.m_isChecked)
    vars['skipLabel']:setVisible(self.m_isChecked == false)

    do
        local min_id = self.m_optionIdList[self.m_minValue]
        local max_id = self.m_optionIdList[self.m_maxValue]

        local min_num = TableLairBuffStatus:getInstance():getLairStatOptionValue(min_id)
        local max_num = TableLairBuffStatus:getInstance():getLairStatOptionValue(max_id)

        local min_max_str = string.format('%d~%d', min_num, max_num)
        local option_str = self.m_tableOption:getValue(option_type, 't_desc')

        vars['optionLabel']:setString(Str(option_str, min_max_str))
        self.m_isPercent = (string.find(option_str, '%%') ~= nil)
    end


    if (self.m_isChecked == true) then
        local cur_id = self.m_optionIdList[self.m_currValue]
        local cur_num = TableLairBuffStatus:getInstance():getLairStatOptionValue(cur_id)
        local percent_str = self.m_isPercent and '%' or ''
        vars['quantityLabel']:setString(cur_num .. percent_str)
    end
end

-------------------------------------
-- function click_checkBoxBtn
-------------------------------------
function UI_DragonLairBlessingAutoPopupItem:click_checkBoxBtn()
    local vars = self.vars
    self.m_isChecked = (not self.m_isChecked)

    self:refresh()
end

-------------------------------------
-- function click_adjustBtn
-------------------------------------
function UI_DragonLairBlessingAutoPopupItem:click_adjustBtn(value, is_pressed)
    local vars = self.vars
    local function adjust_function()
        local curr_value = self.m_currValue + value
        local before_value = self.m_currValue;

        if (curr_value < self.m_minValue) then
            curr_value = self.m_minValue
        elseif (curr_value > self.m_maxValue) then
            curr_value = self.m_maxValue
        end

        self.m_currValue = curr_value

        --값이 변경되지 않았다면
        if (before_value == self.m_currValue) then
            return false
        end

        local cur_id = self.m_optionIdList[self.m_currValue]
        local cur_num = TableLairBuffStatus:getInstance():getLairStatOptionValue(cur_id)
        local percent_str = self.m_isPercent and '%' or ''
        vars['quantityLabel']:setString(cur_num .. percent_str)        
        return true
    end

    if (not is_pressed) then
        adjust_function()
    else -- (is_pressed == true)
        local button = (value >= 0) and vars['plusBtn'] or vars['minusBtn']

        local function update_callback(dt)
            local result = adjust_function()
            if (result == false) or (button:isSelected() == false) or (button:isEnabled() == false) then
                self.root:unscheduleUpdate()
                return
            end
        end

        self.root:scheduleUpdateWithPriorityLua(function(dt) return update_callback(dt) end, 1)
    end
end