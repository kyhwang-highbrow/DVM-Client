-------------------------------------
-- class UI_AdventureStageInfo
-------------------------------------
UI_FevertimeUIHelper = {
}

-------------------------------------
-- function initStaminaFevertimeUI
-- @brief 날개 피버타임 UI 설정
-------------------------------------
function UI_FevertimeUIHelper:initStaminaFevertimeUI(vars, stage_id, type)
    local vars = vars
    local stage_id = stage_id
    local active, value = g_fevertimeData:isActiveFevertimeByType(type)
    if active then
        local table_drop = TABLE:get('drop')
        local t_drop = table_drop[stage_id]
        local cost_value = math_floor(t_drop['cost_value'] * (1 - value))
        local str = string.format('-%d%%', value * 100)
        vars['actingPowerLabel']:setString(cost_value)
        vars['actingPowerLabel']:setTextColor(cc.c4b(0, 255, 255, 255))
        vars['hotTimeSprite']:setVisible(true)
        vars['hotTimeStLabel']:setString(str)
        vars['staminaNode']:setVisible(false)
    else
        vars['actingPowerLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
        vars['hotTimeSprite']:setVisible(false)
        vars['staminaNode']:setVisible(true)
    end
end

-------------------------------------
-- function initFevertimeUI
-- @brief 피버타임 UI 설정 +xx% 또는 -xx%표시
-------------------------------------
function UI_FevertimeUIHelper:initFevertimeUI(vars, type, name, sign, l_active_hot)
    local vars = self.vars
    local label_name = 'hotTime' .. name .. 'Label'
    local btn_name = 'hotTime' .. name .. 'Btn'
    local active, value = g_fevertimeData:isActiveFevertimeByType(type)
    if active then
        value = value * 100 -- fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
        table.insert(l_active_hot, btn_name)
        local str = string.format(sign .. '%d%%', value)
        vars[label_name]:setString(str)
        vars[btn_name]:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip(type, vars[btn_name]) end)
    end
    ---- 악몽 던전 날개 할인 // 원본
    --local active, value = g_fevertimeData:isActiveFevertimeByType('dg_nm_st_dc')
    --if active then
        --value = value * 100 -- fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
        --table.insert(l_active_hot, 'hotTimeDgNmStBtn')
        --local str = string.format('-%d%%', value)
        --vars['hotTimeDgNmStLabel']:setString(str)
        --vars['hotTimeDgNmStBtn']:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip('dg_nm_st_dc', vars['hotTimeDgNmStBtn']) end)
    --end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FevertimeUIHelper:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FevertimeUIHelper:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FevertimeUIHelper:refresh()
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function UI_FevertimeUIHelper:getCloneTable()
	return clone(UI_FevertimeUIHelper)
end

UI:checkCompileError(UI_FevertimeUIHelper)