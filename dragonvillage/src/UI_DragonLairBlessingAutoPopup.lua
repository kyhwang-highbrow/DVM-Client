-------------------------------------
-- class UI_DragonLairBlessingAutoPopup
-------------------------------------
UI_DragonLairBlessingAutoPopup = class(UI, {
    m_targetRune = 'StructRuneObject',
    m_selectedOption = 'string',
    m_itemType = 'string',

    m_tableview = 'UIC_TableView',

    m_grindNum = 'number',
    m_maxItemNum = 'number',

    m_okCallback = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingAutoPopup:init(selected_option, rune_obj, item_type)
    local vars = self:load('dragon_lair_blessing_setting_popup.ui')
    self.m_uiName = 'UI_DragonLairBlessingAutoPopup'
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairBlessingAutoPopup')

    
    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    if (item_type == 'none_select') then
        item_type = 'grindstone'
    end

    self.m_targetRune = rune_obj
    self.m_selectedOption = selected_option
    self.m_itemType = item_type
    self.m_grindNum = 1

    local item_num = g_userData:get(item_type)
    local gold_num = math.floor(g_userData:get('gold') / rune_obj:getRuneGrindReqGold())
    
    self.m_maxItemNum = math.min(item_num, gold_num)

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

    vars['quantityLabel']:setString(self.m_grindNum)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonLairBlessingAutoPopup:initTableView()
    local vars = self.vars
    local node = vars['optionNode']

    local item_list = self:getExpectedOptionList()

    local function ctor_func(data)
        local ui = UI_DragonLairBlessingAutoPopupItem(data, self.m_targetRune)
        return ui
    end

    local table_view = UIC_TableView(node)
    table_view:setCellUIClass(ctor_func)
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

    vars['grindAutoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)

    vars['cancelBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    
    vars['plusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(1) end)
    
    vars['plusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(1, true) end)

    vars['minusBtn']:registerScriptTapHandler(function() self:click_adjustBtn(-1) end)
    
    vars['minusBtn']:registerScriptPressHandler(function() self:click_adjustBtn(-1, true) end)
    
    vars['100Btn']:registerScriptTapHandler(function() self:click_adjustBtn(100) end)

    vars['100Btn']:registerScriptPressHandler(function() self:click_adjustBtn(100, true) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLairBlessingAutoPopup:refresh()
    local vars = self.vars
end


-------------------------------------
-- function getExpectedOptionStr
-- @brief 연마로 다시 나올 수 있는 옵션 나열한 String 반환 
-------------------------------------
function UI_DragonLairBlessingAutoPopup:getExpectedOptionList()
    local rune_obj = self.m_targetRune
    local selected_option = plSplit(rune_obj[self.m_selectedOption], ';')[1]
    local table_opt = TableOption()
    
    -- 연마로 나올 수 있는 옵션
    -- 1. 주옵션 or 부 옵션 or 선택하지 않은 추가 옵션과 중복되지 않는 옵션
    -- 2. table_rune_opt_status의 none과 aspd_multi 제외
    -- 3. 현재 선택한 옵션은 연마로 다시 나올 수 있음
    -- 4. 치명회피와, 속도 %는 제외
    local t_rune_opt = TABLE:get('table_rune_opt_status')

    local result = {}

    for id, v in pairs(t_rune_opt) do
        if (pl.stringx.endswith(id, '_1')) then
            local opt_type = v['key']
            local is_expected = true
            for _, opt_str in ipairs(StructRuneObject.OPTION_LIST) do
                local l_str = plSplit(rune_obj[opt_str], ';')
                -- 1, 3번 조건 처리
                if (l_str[1] == opt_type) and (opt_type ~= selected_option) then
                    is_expected = false
                end
            end

            -- 2, 4번 조건 처리
            if (is_expected) and (opt_type ~= 'none') and (opt_type ~= 'aspd_multi') and (opt_type ~= 'cri_avoid_add') then
                table.insert(result, v)
            end    
        end
    end

    return result
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
            local option_type = ui.m_data['key']
            local option_value = ui.m_currValue

            result[option_type] = option_value
        end
    end

    return result
end

-------------------------------------
-- function setGrindAutoSetting
-------------------------------------
function UI_DragonLairBlessingAutoPopup:setGrindAutoSetting(option_list)
    if (option_list ~= nil) and (type(option_list) == 'table') then
        for option_type, option_value in pairs(option_list) do
            g_settingData:setGrindAutoSetting(option_type, option_value)
        end
    end
end

-------------------------------------
-- function click_autoBtn
-------------------------------------
function UI_DragonLairBlessingAutoPopup:click_autoBtn()
    local target_option_list = self:getTargetOptionList()

    if (table.count(target_option_list) == 0) then
        UIManager:toastNotificationRed(Str('원하는 연마 옵션을 선택해 주세요'))
        return
    end

    local function ok_callback()
        self:setGrindAutoSetting(target_option_list)

        local auto_grind_num = self.m_grindNum

        self:close()

        if self.m_okCallback then
            self.m_okCallback(auto_grind_num, target_option_list)
        end
    end

    local main_msg = Str('선택한 옵션으로 자동 연마를 시작합니다.\n진행하시겠습니까?')
    local sub_msg = Str('자동 연마 횟수: {1}', self.m_grindNum)

    MakeSimplePopup2(POPUP_TYPE.YES_NO, main_msg, sub_msg, ok_callback)
end


-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonLairBlessingAutoPopup:click_closeBtn()
    local target_option_list = self:getTargetOptionList()
    
    self:setGrindAutoSetting(target_option_list)

    self:close()
end

-------------------------------------
-- function click_adjustBtn
-------------------------------------
function UI_DragonLairBlessingAutoPopup:click_adjustBtn(value, is_pressed)
    local vars = self.vars
    local function adjust_function()
        local curr_num = self.m_grindNum + value
        local before_Value = self.m_grindNum

        if (curr_num > 0) and (curr_num <= self.m_maxItemNum) then
            self.m_grindNum = curr_num
        elseif (curr_num > self.m_maxItemNum) then
            self.m_grindNum = self.m_maxItemNum
        end

        --값이 변경되지 않았으면 팝업과 함께 리턴
        if (before_Value == self.m_grindNum) then
            self:checkGrindCondition(curr_num)
            return false
        end

        vars['quantityLabel']:setString(self.m_grindNum)
        return true
    end

    if (not is_pressed) then
        adjust_function()
    else -- (is_pressed == true)
        local button
        if (value < 0) then
            button = vars['minusBtn']
        elseif (value >= 100) then
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

-------------------------------------
-- function checkGrindCondition
-------------------------------------
function UI_DragonLairBlessingAutoPopup:checkGrindCondition(target_num)
    local rune_obj = self.m_targetRune

    -- 재료 확인
    local required_grind_stone = rune_obj:getRuneGrindReqGrindstone()
    local owned_grind_stone = g_userData:get(self.m_itemType) -- grind_stone

    local required_gold = rune_obj:getRuneGrindReqGold()
    local owned_gold = g_userData:get('gold')

    if ((required_gold * target_num) > owned_gold) then
        local item_name = TableItem:getItemNameFromItemType('gold')
        UIManager:toastNotificationRed(Str('{1}이(가) 부족합니다.', item_name))
    elseif ((required_grind_stone * target_num) > owned_grind_stone) then
        local item_name = TableItem:getItemNameFromItemType(self.m_itemType)
        UIManager:toastNotificationRed(Str('{1}이(가) 부족합니다.', item_name))
    end
end















PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_DragonLairBlessingAutoPopupItem
-------------------------------------
UI_DragonLairBlessingAutoPopupItem = class(PARENT, {
    m_data = 'table',
    m_targetRune = 'StructRuneObject',

    m_isPercent = 'boolean',
    m_isChecked = 'boolean',

    m_minValue = 'number',
    m_maxValue = 'number',
    m_currValue = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingAutoPopupItem:init(data, rune_obj)
    local vars = self:load('dragon_lair_blessing_setting_popup_item.ui')

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0.2, 0.3)
    self:doActionReset()
    self:doAction(nil, false)

    self.m_targetRune = rune_obj
    self.m_data = data
    self.m_isChecked = false

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingAutoPopupItem:initUI()
    local vars = self.vars
    local table_opt = TableOption()

    local option_type = self.m_data['key']
    local option_str = table_opt:getValue(option_type, 't_desc')
    self.m_isPercent = (string.find(option_str, '%%') ~= nil)

    local min_value = self.m_targetRune:getOptionMinValue(option_type)
    local max_value = self.m_targetRune:getOptionMaxValue(option_type)
    self.m_minValue = min_value
    self.m_maxValue = max_value
    local min_max_str = string.format('%d~%d', min_value, max_value)

    self.m_currValue = min_value

    vars['optionLabel']:setString(Str(option_str, min_max_str))
end

-------------------------------------
-- function init
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

    vars['checkSprite']:setVisible(self.m_isChecked)
    vars['quantityMenu']:setVisible(self.m_isChecked)

    vars['skipLabel']:setVisible(self.m_isChecked == false)

    if (self.m_isChecked == true) then
        local option_type = self.m_data['key']

        local option_value = g_settingData:getGrindAutoSetting(option_type)

        if (option_value ~= nil) and (option_value >= self.m_minValue) and (option_value <= self.m_maxValue) then
            self.m_currValue = option_value
        end

        local percent_str = self.m_isPercent and '%' or ''
        vars['quantityLabel']:setString(self.m_currValue .. percent_str)
    end
end

function UI_DragonLairBlessingAutoPopupItem:click_checkBoxBtn()
    local vars = self.vars
    self.m_isChecked = (not self.m_isChecked)

    self:refresh()
end


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

        local percent_str = self.m_isPercent and '%' or ''
        vars['quantityLabel']:setString(curr_value .. percent_str)
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