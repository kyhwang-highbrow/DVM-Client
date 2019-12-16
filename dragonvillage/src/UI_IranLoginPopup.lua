local PARENT = UI

-------------------------------------
-- class UI_IranLoginPopup
-- @brief 이란 빌드에서만 사용하는 로그인 팝업
--        guest or email
-------------------------------------
UI_IranLoginPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_IranLoginPopup:init()
    local vars = self:load('iran_login_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 없음
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_IranLoginPopup')

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
function UI_IranLoginPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_IranLoginPopup:initButton()
    local vars = self.vars
    
    vars['guestBtn']:registerScriptTapHandler(function() self:click_guestBtn() end)
    vars['emailRegistrationBtn']:registerScriptTapHandler(function() self:click_emailRegistrationBtn() end)
    vars['emailLoginBtn']:registerScriptTapHandler(function() self:click_emailLoginBtn() end)
    
    -- 서버 변경 버튼
    vars['serverBtn']:registerScriptTapHandler(function() self:click_changeServer() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IranLoginPopup:refresh()    
    self:setServerName(ServerListData:getInstance():getSelectServer())
end

-------------------------------------
-- function setServerName
-------------------------------------
function UI_IranLoginPopup:setServerName(name)
    local vars = self.vars
    vars['serverLabel']:setString(string.upper(name))
end

-------------------------------------
-- function click_exitBtn
-- @brief 종료
-------------------------------------
function UI_IranLoginPopup:click_exitBtn()
    local function yes_cb()
        closeApplication()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('종료하시겠습니까?'), yes_cb)
end

-------------------------------------
-- function click_uidBtn
-------------------------------------
function UI_IranLoginPopup:click_uidBtn()
    local vars = self.vars
    local uid = vars['editBox']:getText()
    if (uid == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('Please enter your UID.'))
        return
    end

    local t_info = {}
    t_info['uid'] = uid
    self:loginSuccess(t_info)
    self:close()
end

-------------------------------------
-- function click_guestBtn
-------------------------------------
function UI_IranLoginPopup:click_guestBtn()

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

    local ui_network = UI_Network()
    ui_network:setFullUrl(GetPlatformApiUrl() .. '/user/guestuidgeneration')
    ui_network:setParam('game_id', 1003)
    ui_network:setParam('os', os)
    ui_network:setHmac(false)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function click_emailRegistrationBtn
-- @brief 회원 가입
-------------------------------------
function UI_IranLoginPopup:click_emailRegistrationBtn()
    require('UI_IranEmailRegistrationPopup')
    local ui = UI_IranEmailRegistrationPopup()
    
    local function close_cb()
        -- uid가 설정되었을 경우
        local uid = g_localData:get('local', 'uid')
        if (uid and uid ~= '') then
            self:close()
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_emailLoginBtn
-------------------------------------
function UI_IranLoginPopup:click_emailLoginBtn()
    require('UI_IranEmailLoginPopup')
    local ui = UI_IranEmailLoginPopup()
    
    local function close_cb()
        -- uid가 설정되었을 경우
        local uid = g_localData:get('local', 'uid')
        if (uid and uid ~= '') then
            self:close()
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_changeServer()
-- @brief 서버 변경
-------------------------------------
function UI_IranLoginPopup:click_changeServer()
    local selecte_server_popup
    local on_finish

    -- 1. 서버 선택 팝업 오픈
    selecte_server_popup = function()
        UI_SelectServerPopup(on_finish)
    end

    -- 1-1. 서버 선택 콜백에서 선택된 서버 저장
    on_finish = function(server_name)        
        ServerListData:getInstance():selectServer(server_name)
        self:setServerName(server_name)
    end

    selecte_server_popup()
end

-------------------------------------
-- function loginSuccess
-------------------------------------
function UI_IranLoginPopup:loginSuccess(info)
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

    cclog('# UI_IranLoginPopup:loginSuccess(info)')
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
UI:checkCompileError(UI_IranLoginPopup)
