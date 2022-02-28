local PARENT = UI

-------------------------------------
-- class UI_DragonRunesGrindFirstPopup
-------------------------------------
UI_DragonRunesGrindFirstPopup = class(PARENT,{
        m_selectedopt = 'string',
        m_okCb = 'function',
        m_structRune = 'StructRuneeObject',
        m_isInfo = 'boolean',
        m_item_type = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesGrindFirstPopup:init(selected_opt, rune_obj, ok_cb, is_info, item_type)

    local vars = self:load('rune_grind_popup.ui')
    self.m_uiName = 'UI_DragonRunesGrindFirstPopup'

    UIManager:open(self, UIManager.POPUP)

    self.m_okCb = ok_cb
    self.m_structRune = rune_obj
    self.m_selectedopt = selected_opt
    self.m_isInfo = is_info
    self.m_item_type = item_type

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonRunesGrindFirstPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesGrindFirstPopup:initUI()
    local vars = self.vars
    local rune_obj = self.m_structRune

    local rune_desc_str = rune_obj:makeEachRuneDescRichText(self.m_selectedopt, nil)
    --  Max 표시
    local is_max = rune_obj:isMaxOption(self.m_selectedopt, rune_desc_str)
    if (is_max) then
        rune_desc_str = rune_desc_str .. '{@yellow} [MAX]'  
    end

    vars['sopt_label']:setString(rune_desc_str)
    
    local expected_option_str = ''
    if (self.m_item_type == 'max_fixed_ticket') then
        expected_option_str = self:getExpectedOptionStr_MaxOptItem()
    elseif(self.m_item_type == 'opt_keep_ticket') then
        expected_option_str = self:getExpectedOptionStr_KeepOptItem()
    else
        expected_option_str = self:getExpectedOptionStr()
    end
    vars['sopt_changeLabel']:setString(expected_option_str)

    vars['grindMenu']:setVisible(not self.m_isInfo)
    vars['backBtn']:setVisible(self.m_isInfo)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesGrindFirstPopup:initButton()
    local vars = self.vars
    
    vars['okBtn']:registerScriptTapHandler(function() self:click_okay() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['backBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesGrindFirstPopup:refresh()
end

-------------------------------------
-- function click_okay
-------------------------------------
function UI_DragonRunesGrindFirstPopup:click_okay()
    self:close()
    if (self.m_okCb) then
        self.m_okCb()
    end
end

-------------------------------------
-- function getExpectedOptionStr
-- @brief 연마로 다시 나올 수 있는 옵션 나열한 String 반환 
-------------------------------------
function UI_DragonRunesGrindFirstPopup:getExpectedOptionStr()
    local rune_obj = self.m_structRune
    local expected_option_str = ''
    local selected_option = plSplit(rune_obj[self.m_selectedopt], ';')[1]
    local table_opt = TableOption()
    
    -- 연마로 나올 수 있는 옵션
    -- 1. 주옵션 or 부 옵션 or 선택하지 않은 추가 옵션과 중복되지 않는 옵션
    -- 2. table_rune_opt_status의 none과 aspd_multi 제외
    -- 3. 현재 선택한 옵션은 연마로 다시 나올 수 있음
    -- 4. 치명회피와, 속도 %는 제외
    local t_rune_opt = TABLE:get('table_rune_opt_status')

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

            local min_value = rune_obj:getOptionMinValue(opt_type)
            local max_value = rune_obj:getOptionMaxValue(opt_type)

            local min_max_str = string.format('%d~%d', min_value, max_value)
            -- 2, 4번 조건 처리
            if (is_expected) and (opt_type ~= 'none') and (opt_type ~= 'aspd_multi') and (opt_type ~= 'cri_avoid_add') then
                expected_option_str = expected_option_str ..Str(table_opt:getValue(opt_type, 't_desc'), min_max_str) .. '\n'
            end    
        end
    end

    return expected_option_str
end

-------------------------------------
-- function getExpectedOptionStr_MaxOptItem
-- @brief max확정권 사용 했을 때 나올 수 있는 옵션
-------------------------------------
function UI_DragonRunesGrindFirstPopup:getExpectedOptionStr_MaxOptItem()
    local rune_obj = self.m_structRune
    local expected_option_str = ''
    local selected_option = plSplit(rune_obj[self.m_selectedopt], ';')[1]
    local table_opt = TableOption()
    
    -- 연마로 나올 수 있는 옵션
    -- 1. 주옵션 or 부 옵션 or 선택하지 않은 추가 옵션과 중복되지 않는 옵션
    -- 2. table_rune_opt_status의 none과 aspd_multi 제외
    -- 3. 현재 선택한 옵션은 연마로 다시 나올 수 있음
    -- 4. 치명회피와, 속도 %는 제외
    local t_rune_opt = TABLE:get('table_rune_opt_status')

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

            local max_value = rune_obj:getOptionMaxValue(opt_type)
            -- 2, 4번 조건 처리
            if (is_expected) and (opt_type ~= 'none') and (opt_type ~= 'aspd_multi') and (opt_type ~= 'cri_avoid_add') then
                expected_option_str = expected_option_str ..Str(table_opt:getValue(opt_type, 't_desc'), max_value) .. '\n'
            end
        end
    end

    return expected_option_str
end

-------------------------------------
-- function getExpectedOptionStr_KeepOptItem
-- @brief 옵션 유지권 사용 했을 때 나올 수 있는 옵션 
-------------------------------------
function UI_DragonRunesGrindFirstPopup:getExpectedOptionStr_KeepOptItem()
    local rune_obj = self.m_structRune
    local expected_option_str = ''
    local selected_option = plSplit(rune_obj[self.m_selectedopt], ';')[1]
    local table_opt = TableOption()

    local min_value = rune_obj:getOptionMinValue(selected_option)
    local max_value = rune_obj:getOptionMaxValue(selected_option)
    local min_max_str = string.format('%d~%d', min_value, max_value)
    
    expected_option_str = Str(table_opt:getValue(selected_option, 't_desc'), min_max_str)        
    
    return expected_option_str
end

--@CHECK
UI:checkCompileError(UI_DragonRunesGrindFirstPopup)
