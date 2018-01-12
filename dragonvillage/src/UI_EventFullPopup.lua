local PARENT = UI

-------------------------------------
-- class UI_EventFullPopup
-------------------------------------
UI_EventFullPopup = class(PARENT,{
        m_popupKey = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventFullPopup:init(popup_key)
    self.m_popupKey = popup_key
end

-------------------------------------
-- function openEventFullPopup
-------------------------------------
function UI_EventFullPopup:openEventFullPopup()
    local vars = self:load('event_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventFullPopup')

    self:initUI()
    self:initButton()
    self:refresh()

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventFullPopup:initUI()
    local vars = self.vars
    local popup_key = self.m_popupKey

    -- 이벤트 배너
    if (string.find(popup_key, 'banner')) then
        local l_str = plSplit(popup_key, ';')
        local event_data = { banner = l_str[2], url = l_str[3] or ''}
        local struct_data = StructEventPopupTab(event_data)
        local ui = UI_EventPopupTab_Banner(self, struct_data)
        vars['eventNode']:addChild(ui.root)

	-- Daily Mission
	elseif string.find(popup_key, 'daily_mission') then
		local l_str = plSplit(popup_key, ';')
		local key = l_str[2]
		local ui
		if (key == 'clan') then
			ui = UI_DailyMisson_Clan()
		end

        vars['eventNode']:addChild(ui.root)

	-- 출석
	elseif string.find(popup_key, 'attendance') then
		local l_str = plSplit(popup_key, ';')
		local key = l_str[2]
		local ui
		if (key == 'basic') then
			ui = UI_EventPopupTab_Attendance()
		elseif (key == 'event') then
			ui = UI_EventPopupTab_EventAttendance()
		elseif (key == 'newbie') then
			ui = UI_EventPopupTab_EventAttendance()

		end

        vars['eventNode']:addChild(ui.root)

    -- 패키지 상품 
    elseif string.find(popup_key, 'package') then
        
        local package_name = popup_key
        local is_popup = false
        local ui = PackageManager:getTargetUI(package_name, is_popup)

        if (ui) then
            local node = vars['eventNode']
            node:addChild(ui.root)
        else
            -- 이벤트 프로덕트 정보 없을 경우 비활성화라고 생각하고 닫아줌 (주말 패키지)
            self:close()
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventFullPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventFullPopup:refresh()
end

-------------------------------------
-- function setBtnBlock
-------------------------------------
function UI_EventFullPopup:setBtnBlock()
	self.vars['clickBtn']:setEnabled(false)
end

-------------------------------------
-- function click_checkBtn
-------------------------------------
function UI_EventFullPopup:click_checkBtn()
    local vars = self.vars
    vars['checkSprite']:setVisible(true)

    -- 다시보지않기
    local product_id = self.m_popupKey
    local save_key = tostring(product_id)
    g_settingData:applySettingData(true, 'event_full_popup', save_key)

    self:close()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventFullPopup:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_EventFullPopup)
