-------------------------------------
-- function init_infoTab
-------------------------------------
function UI_Setting:init_infoTab()
    local vars = self.vars

    -- 유저 ID
    local uid = g_userData:get('uid')
    vars['uidLabel']:setString(tostring(uid))

    -- 게임 버전
    local version_str = PatchData:getInstance():getAppVersionAndPatchIdxString()
    vars['versionLabel']:setString(version_str)

    vars['makeBtn']:registerScriptTapHandler(function() self:click_makeBtn() end)
    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
    vars['agreementBtn']:registerScriptTapHandler(function() self:click_agreementBtn() end)

    vars['couponBtn']:registerScriptTapHandler(function() self:click_couponBtn() end)
    vars['serviceBtn']:registerScriptTapHandler(function() self:click_serviceBtn() end) 
end

-------------------------------------
-- function click_makeBtn
-- @brief 만든 사람들
-------------------------------------
function UI_Setting:click_makeBtn()
    UIManager:toastNotificationRed(Str('"만든 사람들"은 준비 중입니다.'))
end

-------------------------------------
-- function click_helpBtn
-- @brief 도움말
-------------------------------------
function UI_Setting:click_helpBtn()
    UI_Help()
end

-------------------------------------
-- function click_agreementBtn
-- @brief 이용약관
-------------------------------------
function UI_Setting:click_agreementBtn()
    UIManager:toastNotificationRed(Str('"이용약관"은 준비 중입니다.'))
end

-------------------------------------
-- function click_couponBtn
-- @brief 쿠폰 입력
-------------------------------------
function UI_Setting:click_couponBtn()
    UI_CouponPopup()
end

-------------------------------------
-- function click_serviceBtn
-- @brief 고객 센터
-------------------------------------
function UI_Setting:click_serviceBtn()
    UIManager:toastNotificationRed(Str('"고객 센터"은 준비 중입니다.'))
end