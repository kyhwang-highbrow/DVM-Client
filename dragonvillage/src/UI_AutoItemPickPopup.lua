local PARENT = UI

-------------------------------------
-- class UI_AutoItemPickPopup
-------------------------------------
UI_AutoItemPickPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AutoItemPickPopup:init()
    local vars = self:load('package_daily_dia_2.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_AutoItemPickPopup')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AutoItemPickPopup:initUI()
    local vars = self.vars

    local auto_pick_item = g_userData:get('auto_root')
    if (auto_pick_item) then
        local cnt = math_floor(auto_pick_item/24)
        vars['itemLabel']:setString(Str('x{1}', cnt))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AutoItemPickPopup:initButton()
	local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_AutoItemPickPopup:click_okBtn()
    
    local auto_pick_item = g_userData:get('auto_root')
    local cnt = 0
    if (auto_pick_item) then
        cnt = math_floor(auto_pick_item/24)
    end

    local function cb_func(ret)
        local toast_msg = Str('24시간 자동줍기 x{1}를 사용하였습니다.', cnt)
        -- 바로 팝업이 뜨면서 가려짐
        -- UI_ToastPopup(toast_msg)
        UIManager:toastNotificationGreen(toast_msg)

        local function func()
            self:close()
        end
        self:doActionReverse(func, 0.5, false)
	end
	
    g_subscriptionData:request_useAutoPickItem(cb_func)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_AutoItemPickPopup:click_closeBtn()
    self:close()
end