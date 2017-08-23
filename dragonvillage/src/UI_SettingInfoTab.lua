-------------------------------------
-- function init_infoTab
-------------------------------------
function UI_Setting:init_infoTab()
    local vars = self.vars

    -- 게임 버전
    local version_str = PatchData:getInstance():getAppVersionAndPatchIdxString()
    vars['versionLabel']:setString(version_str)

    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
    vars['agreementBtn']:registerScriptTapHandler(function() self:click_agreementBtn() end)

    vars['couponBtn']:registerScriptTapHandler(function() self:click_couponBtn() end)
    vars['serviceBtn']:registerScriptTapHandler(function() self:click_serviceBtn() end) 
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
    local url = URL['PERPLELAB_AGREEMENT']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function click_couponBtn
-- @brief 쿠폰 입력
-------------------------------------
function UI_Setting:click_couponBtn()
    -- UI_CouponPopup() 은 하이브로 상점내로 옮기고 여기선 자체 쿠폰 처리만 한다.
end

-------------------------------------
-- function click_serviceBtn
-- @brief 고객 센터
-------------------------------------
function UI_Setting:click_serviceBtn()
    local url = URL['HIGHBROW_CS']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end