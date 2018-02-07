local PARENT = UI

-------------------------------------
-- class UI_AutoItemPickResultPopup
-------------------------------------
UI_AutoItemPickResultPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AutoItemPickResultPopup:init(hours, drop_info)
    local vars = self:load('package_daily_dia_result.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_AutoItemPickResultPopup')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(hours, drop_info)
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AutoItemPickResultPopup:initUI(hours, drop_info)
    local vars = self.vars

    local play_cnt = drop_info['play_cnt']
    local cash_cnt = drop_info['cash']
    local gold_cnt = drop_info['gold']
    local amethyst_cnt = drop_info['amethyst']
    
    -- 자동줍기 적용된 시간
    if (hours) then
        vars['dayLabel']:setString(Str('{1}일', math_floor(hours/24)))
    end

    -- 플레이 횟수
    if (play_cnt) then
        vars['playLabel']:setString(Str('{1}회', comma_value(play_cnt)))
    end

    -- 캐시
    if (cash_cnt) then
        vars['itemLabel1']:setString(Str('{1}개', comma_value(cash_cnt)))
    end

    -- 골드
    if (gold_cnt) then
        vars['itemLabel2']:setString(Str('{1}개', comma_value(gold_cnt)))
    end

    -- 자수정
    if (amethyst_cnt) then
        vars['itemLabel3']:setString(Str('{1}개', comma_value(amethyst_cnt)))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AutoItemPickResultPopup:initButton()
	local vars = self.vars
	vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_AutoItemPickResultPopup:click_okBtn()
    self:close()
end