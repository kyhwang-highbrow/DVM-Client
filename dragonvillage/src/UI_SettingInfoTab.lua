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
    vars['privacyPolicyBtn']:registerScriptTapHandler(function() self:click_privacyPolicyBtn() end)

    vars['couponBtn']:registerScriptTapHandler(function() self:click_couponBtn() end)
    vars['serviceBtn']:registerScriptTapHandler(function() self:click_serviceBtn() end) 
    vars['communityBtn']:registerScriptTapHandler(function() self:click_communityBtn() end) 
    self:init_infoTab_buttons()

    -- 표준시간 표시
    local utc_desc = datetime.getTimeUTCDesc()
    vars['utcLabel']:setString(utc_desc)

    local timezone = Timer:getTimeZone()
    vars['timezoneLabel']:setString(Str('({1})', timezone))
end

-------------------------------------
-- function init_infoTab_buttons
-------------------------------------
function UI_Setting:init_infoTab_buttons()
    local vars = self.vars

    do -- 버튼들의 활성 여부를 visible로 설정한다. ui 파일에서는 기본값을 true로 간주한다.
        -- [쿠폰 입력] - ios 정책 강화로 ios에선 쿠폰 입력 버튼을 숨겨야 하는 경우가 있다.
        if (g_remoteConfig:hideCouponBtn() == true) then
            vars['couponBtn']:setVisible(false)
        else
            vars['couponBtn']:setVisible(true)
        end

        -- [개인정보 취급방침] - 한국 유저에게만 노출
        local is_korea_server = g_localData:isKoreaServer()
        local game_lang = Translate:getGameLang()
        if (is_korea_server == true) or (game_lang == 'ko') then
            vars['privacyPolicyBtn']:setVisible(true)
        else
            vars['privacyPolicyBtn']:setVisible(false)
        end
    end

    -- 버튼 이름들
    local l_btn_name_list = {}
    table.insert(l_btn_name_list, 'couponBtn')
    table.insert(l_btn_name_list, 'helpBtn')
    table.insert(l_btn_name_list, 'communityBtn')
    table.insert(l_btn_name_list, 'agreementBtn')
    table.insert(l_btn_name_list, 'privacyPolicyBtn')
    table.insert(l_btn_name_list, 'serviceBtn')

    -- 버튼들 리스트에 추가한다. 존재하지 없는 버튼일 경우 자동으로 nil로 들어가서 리스트에 포함되지 않는다.
    local l_btn_list = {}
    for _,btn_name in ipairs(l_btn_name_list) do
        if (vars[btn_name] and vars[btn_name]:isVisible()) then
            table.insert(l_btn_list, vars[btn_name])
        end
    end

    -- ui파일상의 y좌표값으로 순서 지정
    table.sort(l_btn_list, function(btn_a, btn_b)
        return btn_a:getPositionY() > btn_b:getPositionY()
    end)

    -- 간격에 맞추어 버툰 위치 조정
    local l_pos = getSortPosListReverse(65, #l_btn_list)
    for i,v in ipairs(l_btn_list) do
        v:setPositionY(l_pos[i])
    end
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
    GoToAgreeMentUrl()
end

-------------------------------------
-- function click_privacyPolicyBtn
-- @brief 개인정보 취급방침
-------------------------------------
function UI_Setting:click_privacyPolicyBtn()
    GoToPersonalInfoUrl()
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
    --한국서버와 나머지 서버
	local _url = GetCSUrl(server)
    local market = GetMarketAndOS()
    local ver = getAppVer() or 'undefined'
    local uid = g_userData:get('uid') or 'undefined'
    local lang = Translate:getGameLang()
    local server = g_localData:getServerName()

    local url;
    if server == SERVER_NAME.KOREA then
        url = formatMessage('{1}?market={2}&ver={3}&uid={4}', _url, market, ver, uid)
    else
        url = formatMessage('{1}?market={2}&ver={3}&uid={4}&lang={5}&server={6}', _url, market, ver, uid, lang, server)
    end

    cclog('url : ' .. url )
    SDKManager:goToWeb(url)
end

-------------------------------------
-- function click_communityBtn
-- @brief 카페 플러그
-------------------------------------
function UI_Setting:click_communityBtn()
    -- 2017-09-13 sgkim 네이버 카페를 연동하면서 네이버 카페로 연결함
    NaverCafeManager:naverCafeStart(0) -- @tapNumber : 0(Home) or 1(Notice) or 2(Event) or 3(Menu) or 4(Profile)
end