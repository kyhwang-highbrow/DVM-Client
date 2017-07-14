local PARENT = UI

-------------------------------------
-- class UI_LoginPopup
-------------------------------------
UI_LoginPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoginPopup:init()
    local vars = self:load('login_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_LoginPopup')

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
function UI_LoginPopup:initUI()
    local vars = self.vars
	--vars['facebookLabel'] -- LabelTTF
	--vars['gamecenterLabel'] -- LabelTTF
	--vars['highbrowLabel'] -- LabelTTF
	--vars['googleLabel'] -- LabelTTF
	--vars['geustLabel'] -- LabelTTF
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LoginPopup:initButton()
    local vars = self.vars
    self.vars['facebookBtn']:registerScriptTapHandler(function() self:click_facebookBtn() end)
    self.vars['gamecenterBtn']:registerScriptTapHandler(function() self:click_gamecenterBtn() end)
    self.vars['googleBtn']:registerScriptTapHandler(function() self:click_googleBtn() end)
    self.vars['guestBtn']:registerScriptTapHandler(function() self:click_guestBtn() end)

    self.vars['closeBtn']:setVisible(false)

    if isIos() then
        -- iOS
        self.vars['gamecenterBtn']:setVisible(true)
        self.vars['googleBtn']:setVisible(false)
    else
        -- Android, Win32
        self.vars['gamecenterBtn']:setVisible(false)
        self.vars['googleBtn']:setVisible(true)
    end

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoginPopup:refresh()
end

-------------------------------------
-- function click_facebookBtn
-------------------------------------
function UI_LoginPopup:click_facebookBtn()
    cclog('TODO click_facebookBtn event occurred!')

    PerpleSDK:loginWithFacebook(function(ret, info)
        if ret == 'success' then

            cclog('Firebase facebook login was successful.')

            local t_info = json_decode(info)
            local fuid = t_info.fuid
            local push_token = t_info.pushToken
            local platform_id = 'firebase'
            if t_info.providerData[2] ~= nil then
                platform_id = t_info.providerData[2].providerId
            end

            cclog('fuid: ' .. fuid)
            cclog('push_token: ' .. push_token)
            cclog('platform_id:' .. platform_id)

            g_serverData:applyServerData(fuid, 'local', 'uid')
            g_serverData:applyServerData(push_token, 'local', 'push_token')
            g_serverData:applyServerData(platform_id, 'local', 'platform_id')

            self:close()

        elseif ret == 'fail' then
            local code = info.code
            local subcode = info.subcode
            local msg = info.msg
            MakeSimplePopup(POPUP_TYPE.OK, msg)
        elseif ret == 'cancel' then
        end
    end)

end

-------------------------------------
-- function click_gamecenterBtn
-------------------------------------
function UI_LoginPopup:click_gamecenterBtn()
    cclog('TODO click_gamecenterBtn event occurred!')

    PerpleSDK:loginWithGameCenter(function(ret, info)
        if ret == 'success' then
        elseif ret == 'fail' then
        elseif ret == 'cancel' then
        end
    end)

end

-------------------------------------
-- function click_googleBtn
-------------------------------------
function UI_LoginPopup:click_googleBtn()
    cclog('TODO click_googleBtn event occurred!')

    PerpleSDK:loginWithGoogle(function(ret, info)
        if ret == 'success' then

            cclog('Firebase google login was successful.')

            local t_info = json_decode(info)
            local fuid = t_info.fuid
            local push_token = t_info.pushToken
            local platform_id = 'firebase'
            if t_info.providerData[2] ~= nil then
                platform_id = t_info.providerData[2].providerId
            end

            cclog('fuid: ' .. fuid)
            cclog('push_token: ' .. push_token)
            cclog('platform_id:' .. platform_id)

            g_serverData:applyServerData(fuid, 'local', 'uid')
            g_serverData:applyServerData(push_token, 'local', 'push_token')
            g_serverData:applyServerData(platform_id, 'local', 'platform_id')

            self:close()

        elseif ret == 'fail' then
            local code = info.code
            local subcode = info.subcode
            local msg = info.msg
            MakeSimplePopup(POPUP_TYPE.OK, msg)
        elseif ret == 'cancel' then
        end
    end)

end

-------------------------------------
-- function click_guestBtn
-------------------------------------
function UI_LoginPopup:click_guestBtn()
    cclog('TODO click_guestBtn event occurred!')

    PerpleSDK:loginAnonymously(function(ret, info)
        if ret == 'success' then

            cclog('Firebase guest login was successful.')

            local t_info = json_decode(info)
            local fuid = t_info.fuid
            local push_token = t_info.pushToken
            local platform_id = 'firebase'
            if t_info.providerData[2] ~= nil then
                platform_id = t_info.providerData[2].providerId
            end

            cclog('fuid: ' .. fuid)
            cclog('push_token: ' .. push_token)
            cclog('platform_id:' .. platform_id)

            g_serverData:applyServerData(fuid, 'local', 'uid')
            g_serverData:applyServerData(push_token, 'local', 'push_token')
            g_serverData:applyServerData(platform_id, 'local', 'platform_id')

            self:close()

        elseif ret == 'fail' then
            local code = info.code
            local subcode = info.subcode
            local msg = info.msg
            MakeSimplePopup(POPUP_TYPE.OK, msg)
        end
    end)

end

--@CHECK
UI:checkCompileError(UI_LoginPopup)
