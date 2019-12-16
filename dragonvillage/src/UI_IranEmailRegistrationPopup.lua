local PARENT = UI

-------------------------------------
-- class UI_IranEmailRegistrationPopup
-- @brief 이란 빌드에서만 사용하는 이메일 등록 팝업
--        guest or email
-------------------------------------
UI_IranEmailRegistrationPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_IranEmailRegistrationPopup:init()
    local vars = self:load('iran_email_registration_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 없음
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_IranEmailRegistrationPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IranEmailRegistrationPopup:initUI()
    local vars = self.vars

    -- emailEditBox
    -- pwEditBox
    -- pwEditConfirmBox

    vars['emailEditBox']:setPlaceHolder('')
    vars['pwEditBox']:setPlaceHolder('')
    vars['pwEditConfirmBox']:setPlaceHolder('')

    vars['pwEditBox']:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    vars['pwEditConfirmBox']:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD) 
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_IranEmailRegistrationPopup:initButton()
    local vars = self.vars
    
    vars['confirmBtn']:registerScriptTapHandler(function() self:click_confirmBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IranEmailRegistrationPopup:refresh()    
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_IranEmailRegistrationPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function validemail
-- @brief 이메일 검증 (우선 간단하게 처리)
-------------------------------------
function UI_IranEmailRegistrationPopup:validemail(str)
    if (str == '') then
        return false
    end

    if (not string.find(str, '@')) then
        return false
    end

    if (not string.find(str, '%.')) then
        return false
    end

    return true
end

-------------------------------------
-- function validpw
-- @brief 비밀번호 검증 (우선 간단하게 처리)
-------------------------------------
function UI_IranEmailRegistrationPopup:validpw(pw, pw2)
    if (pw ~= pw2) then
        return false
    end

    if (string.len(pw) < 6) then
        return false
    end
    
    return true
end

-------------------------------------
-- function click_emailLoginBtn
-- @brief 확인 버튼
-------------------------------------
function UI_IranEmailRegistrationPopup:click_confirmBtn()
    -- email 확인
    -- pw 확인 (6자 이상인지, 같은지)

    local vars = self.vars
    local email = vars['emailEditBox']:getText()
    
    if (not self:validemail(email)) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이메일을 확인해주세요.'))
        return
    end

    local pw = vars['pwEditBox']:getText()
    local pw2 = vars['pwEditConfirmBox']:getText()

    if (not self:validpw(pw, pw2)) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('비밀번호를 확인해주세요.'))
        return
    end

    -- 마지막 확인 팝업
    require('UI_IranEmailConfirmPopup')
    local ui = UI_IranEmailConfirmPopup(email, pw)
    local function close_cb()
        if (ui.m_bConfirm == true) then
            self:requestEmailRegistration(email, pw)
        end
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function requestEmailRegistration
-- @brief
-------------------------------------
function UI_IranEmailRegistrationPopup:requestEmailRegistration(email, pw)
    local os = 0 -- ( 0 : Android / 1 : iOS )
    if (isAndroid() == true) then
        os = 0
    elseif (isIos() == true) then
        os = 1
    end


    local function success_cb(ret)
        local uid = ret['uid']
        local t_info = {}
        t_info['uid'] = uid
        self:loginSuccess(t_info)
        self:close()
    end

    local function response_status_cb(ret)
        local t_status = ret['status'] or {}
        local status = t_status['retcode']

        if (status == -94) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('이미 가입된 이메일입니다.'))
            return true
        end

        -- 위쪽에서 true를 리턴했다면 이 통신에 대한 처리를 완료했다는 의미
        return false
    end

    local ui_network = UI_Network()
    ui_network:setFullUrl(GetPlatformApiUrl() .. '/user/signupbyemail')
    ui_network:setParam('game_id', 1003)
    ui_network:setParam('os', os)
    ui_network:setParam('email', email)
    ui_network:setParam('password', pw)
    ui_network:setHmac(false)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:request()
end

-------------------------------------
-- function loginSuccess
-------------------------------------
function UI_IranEmailRegistrationPopup:loginSuccess(info)
    local t_info = nil

    -- info가 문자열일 경우 json decode
    if (type(info) == 'string') then
        t_info = dkjson.decode(info)

    -- info의 type이 table이라고 간주
    else 
        t_info = info
    end

    local uid = t_info['fuid'] or t_info['uid']
    local push_token = t_info['pushToken'] or 'firebase' -- 'firebase'는 게스트 계정이라는 의미
    local platform_id = t_info['providerId'] or 'firebase'
    local account_info = t_info['name'] or 'Guest'

    cclog('# UI_IranEmailRegistrationPopup:loginSuccess(info)')
    cclog('  uid: ' .. tostring(uid))
    cclog('  push_token: ' .. tostring(push_token))
    cclog('  platform_id:' .. tostring(platform_id))
    cclog('  account_info:' .. tostring(account_info))

    g_localData:applyLocalData(uid, 'local', 'uid')
    g_localData:applyLocalData(push_token, 'local', 'push_token')
    g_localData:applyLocalData(platform_id, 'local', 'platform_id')
    g_localData:applyLocalData(account_info, 'local', 'account_info')

    if (platform_id == 'google.com') then
		if (t_info['google'] and t_info['google']['playServicesConnected']) then
			g_localData:setGooglePlayConnected(true)
		end
    else
        g_localData:setGooglePlayConnected(false)
    end

    --이쪽이면 os 로그인과 서버선택하며 들어가는것으로 naver channel을 추천으로 선택다시해준다.    
    NaverCafeManager:naverInitGlobalPlug(g_localData:getServerName(), g_localData:getLang())
    g_localData:setSavedNaverChannel(1)

    -- 혹시 시스템 오류로 멀티연동이 된 경우 현재 로그인한 플랫폼 이외의 연결은 해제한다.
    -- @sgkim 2019-05-29 firebase에서 사용하는 기능이므로 호출하지 않는다
    -- UnlinkBrokenPlatform(t_info, platform_id)
end


--@CHECK
UI:checkCompileError(UI_IranEmailRegistrationPopup)
