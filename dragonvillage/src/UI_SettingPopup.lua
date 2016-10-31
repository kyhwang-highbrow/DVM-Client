local PARENT = UI

-------------------------------------
-- class UI_SettingPopup
-------------------------------------
UI_SettingPopup = class(PARENT, {
        m_currTap = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SettingPopup:init()
    local vars = self:load('setting_popup.ui')
    UIManager:open(self, UIManager.POPUP, false, Z_ORDER_POPUP_TOP_USER_INFO + 1)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SettingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

--[[
-------------------------------------
-- function close
-------------------------------------
function UI_SettingPopup:close()
    if (not self.enable) then
        return
    end

    local function finish_cb()
        UI.close(self)
    end

    -- @ui_actions
    self:doActionReverse(finish_cb, 0.5, false)
end
--]]

-------------------------------------
-- function initUI
-------------------------------------
function UI_SettingPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SettingPopup:initButton()
    local vars = self.vars

    -- 탭 버튼
    vars['infoTab']:registerScriptTapHandler(function() self:click_tap('info') end)
    vars['setTab']:registerScriptTapHandler(function() self:click_tap('set') end)
    vars['devTab']:registerScriptTapHandler(function() self:click_tap('dev') end)

    -- 정보(info)
    do
        vars['clearBtn']:registerScriptTapHandler(function() self:click_clearBtn() end)
        
    end

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SettingPopup:refresh()
    local vars = self.vars
    if (not self.m_currTap) then
         self.m_currTap = 'info'
    end

    vars['infoNode']:setVisible(false)
    vars['setNode']:setVisible(false)
    vars['devNode']:setVisible(false)
    vars[self.m_currTap .. 'Node']:setVisible(true)

    if (self.m_currTap == 'info') then
        self:refresh_infoTap()
    elseif (self.m_currTap == 'set') then

    elseif (self.m_currTap == 'dev') then

    end
end

-------------------------------------
-- function refresh_infoTap
-------------------------------------
function UI_SettingPopup:refresh_infoTap()
    local vars = self.vars

    local uid = g_userData:get('uid')
    local nickname = g_userData:get('nickname') or g_serverData:get('local', 'idfa')
    local version_str = PatchData:getInstance():getAppVersionAndPatchIdxString()

    vars['userIdLabel']:setString(Str('유저 ID : ') .. uid)
    vars['userNameLabel']:setString(Str('닉네임 : ') .. nickname)
    vars['versionLabel']:setString(version_str)
end


-------------------------------------
-- function click_tap
-------------------------------------
function UI_SettingPopup:click_tap(tap_type)
    self.m_currTap = tap_type
    self:refresh()
end

-------------------------------------
-- function click_clearBtn
-------------------------------------
function UI_SettingPopup:click_clearBtn()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SettingPopup:click_closeBtn()
    self:close()
end

--@CHECK