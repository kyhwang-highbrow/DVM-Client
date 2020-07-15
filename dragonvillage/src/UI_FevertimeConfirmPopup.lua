local PARENT = UI

-------------------------------------
-- class UI_ConfirmPopup
-------------------------------------
UI_FevertimeConfirmPopup = class(PARENT,{
        m_structFevertime = 'StructFevertime',
		m_fevertimeName = 'string',
		m_fevertimePeriod = 'string',
        m_fevertimeInfo = 'string',
        m_fevertimeValue = 'number',
        m_fevertimeType = 'string',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FevertimeConfirmPopup:init(struct_fevertime, ok_btn_cb, cancel_btn_cb)

    self.m_structFevertime = struct_fevertime
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb
    self.m_fevertimeName = struct_fevertime:getFevertimeName()
    self.m_fevertimeInfo = struct_fevertime:getFevertimeDesc()
    self.m_fevertimePeriod = struct_fevertime:getPeriodStr()
    self.m_fevertimeValue = struct_fevertime:getFevertimeValue()
    self.m_fevertimeType = struct_fevertime:getFevertimeType()

    if (self.m_fevertimePeriod == '') or (struct_fevertime:isDailyHottime() == true) then
        self.m_fevertimePeriod = struct_fevertime:getTimeLabelStr()
    end

    local vars = self:load('event_fevertime_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_FevertimeConfirmPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FevertimeConfirmPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FevertimeConfirmPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FevertimeConfirmPopup:refresh()
	local vars = self.vars

    vars['timeLabel']:setString(self.m_fevertimePeriod)

    vars['hotTimeInfoLabel']:setString(self.m_fevertimeInfo)
    
    vars['hotTimeNameLabel']:setString(self.m_fevertimeName)

    local value = tostring(self.m_fevertimeValue * 100) .. '%'
    vars['hotTimePerLabel']:setString(value)

    local sprite = self:makeFevertimeIcon(self.m_structFevertime)
    vars['hotTimeIconNode']:addChild(sprite, -1)
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_FevertimeConfirmPopup:click_backKey()
    self:click_cancelBtn()
end

-------------------------------------
-- function setFevertimeIcon
-------------------------------------
function UI_FevertimeConfirmPopup:makeFevertimeIcon(struct_fevertime)
    local vars = self.vars
    local path = struct_fevertime:getFevertimeIcon()

    local sprite = cc.Sprite:create(path)
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    
    return sprite
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_FevertimeConfirmPopup:click_okBtn()
    if self.m_cbOKBtn then
        if self.m_cbOKBtn() then
            return
        end
    end

    self:close()
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_FevertimeConfirmPopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    self:close()
end

-------------------------------------
-- function click_linkBtn
-------------------------------------
function UI_FevertimeConfirmPopup:click_linkBtn()
    UI_LoginPopup2()
end

--@CHECK
UI:checkCompileError(UI_FevertimeConfirmPopup)
