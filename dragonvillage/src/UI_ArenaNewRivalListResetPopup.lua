local PARENT = UI

-------------------------------------
-- class UI_ArenaNewRivalListResetPopup
-------------------------------------
UI_ArenaNewRivalListResetPopup = class(PARENT,{
    m_ok_cb = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewRivalListResetPopup:init(ok_cb)
    self.m_uiName = 'UI_ArenaNewRivalListResetPopup'
    local vars = self:load('arena_new_popup_refresh.ui')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    self.m_ok_cb = ok_cb

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewRivalListResetPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewRivalListResetPopup:initUI(ok_cb)
    local vars = self.vars

    -- 대전 상대를 갱신하시겠습니까?
    -- 1일 남은 횟수: {1}/10
    if (vars['countLabel']) then
        -- cost_info 조회
        local cost = g_arenaNewData:getCostInfo('refresh_gold_cost')
        local is_free_refresh = g_arenaNewData:getCostInfo('refresh_free_enable') == 1
        local refillGuideText

        if (cost > 0) and (cost <= 0 or is_free_refresh) then 
            refillGuideText = Str('무료 갱신은 일일 갱신 횟수가 감소하지 않습니다.')
            vars['priceLabel']:setString(Str('무료'))
        else
            local maxRefreshCount = g_arenaNewData:getCostInfo('refresh_gold_max_count')
            local curRefreshCount = g_arenaNewData:getCostInfo('refresh_gold_cur_count')

            if (curRefreshCount >= maxRefreshCount) then
                refillGuideText = Str('사용 가능한 횟수를 초과했습니다.')
                if (vars['priceLabel']) then vars['priceLabel']:setString(Str('구매 불가')) end
                vars['okBtn']:setEnabled(false)
            else
                refillGuideText = Str('1일 남은 횟수: {1}/{2}', math.max(maxRefreshCount - curRefreshCount, 0), maxRefreshCount)
                if (vars['priceLabel']) then vars['priceLabel']:setString(comma_value(cost)) end
            end
        end

        vars['countLabel']:setString(refillGuideText)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewRivalListResetPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewRivalListResetPopup:refresh()
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewRivalListResetPopup:click_okBtn()
    local function success_cb()
        if (self.m_ok_cb) then self.m_ok_cb() end
    end

	g_arenaNewData:request_rivalRefresh(success_cb)
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ArenaNewRivalListResetPopup)
