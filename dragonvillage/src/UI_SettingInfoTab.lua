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
    vars['communityBtn']:registerScriptTapHandler(function() self:click_communityBtn() end) 
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
    -- 하이브로 쿠폰의 경우 하이브로 상점내에서 UI_CouponPopup('highbrow')로 호출해야 함
    UI_CouponPopup()
end

-------------------------------------
-- function click_serviceBtn
-- @brief 고객 센터 (브라우저)
-------------------------------------
function UI_Setting:click_serviceBtn()
    local url = URL['HIGHBROW_CS']
    SDKManager:goToWeb(url)
    --UI_WebView(url)
end

-------------------------------------
-- function click_communityBtn
-- @brief 커뮤니티 (브라우저)
-------------------------------------
function UI_Setting:click_communityBtn()

    -- 2017-09-13 sgkim 네이버 카페를 연동하면서 네이버 카페로 연결함
    if true then
        NaverCafeManager:naverCafeStart(0) -- @tapNumber : 0(Home) or 1(Notice) or 2(Event) or 3(Menu) or 4(Profile)
        return
    end

    local url = URL['DVM_COMMUNITY']
    SDKManager:goToWeb(url)
    --UI_WebView(url)
end