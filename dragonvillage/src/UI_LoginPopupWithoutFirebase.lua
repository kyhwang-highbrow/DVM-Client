local PARENT = UI

-------------------------------------
-- class UI_LoginPopupWithoutFirebase
-- @brief 파이어베이스를 통한 로그인이 불가능한 환경에서 지원하는 로그인 팝업
--        Google, Apple, Facebook, Twitter 로그인 사용 불가
-------------------------------------
UI_LoginPopupWithoutFirebase = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoginPopupWithoutFirebase:init()
    local vars = self:load('login_popup_without_firebase.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 없음
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LoginPopupWithoutFirebase')

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
function UI_LoginPopupWithoutFirebase:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LoginPopupWithoutFirebase:initButton()
    local vars = self.vars
    
    vars['uidBtn']:registerScriptTapHandler(function() self:click_uidBtn() end)
    vars['guestBtn']:registerScriptTapHandler(function() self:click_guestBtn() end)
    vars['serverBtn']:registerScriptTapHandler(function() self:click_changeServer() end)

	self:alignButton()
end

-------------------------------------
-- function alignButton
-- @brief 상황별 지원하는 버튼의 수가 다를 경우 사용
-------------------------------------
function UI_LoginPopupWithoutFirebase:alignButton()
	local vars = self.vars
	
    vars['closeBtn']:setVisible(false)

    -- @sgkim 2019-05-29 파이어베이스 없는 로그인 UI에서는 필요없는 기능이라 코드 삭제
    --                   UI_LoginPopup의 alignButton 함수를 참고할 것
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoginPopupWithoutFirebase:refresh()    
    self:setServerName(ServerListData:getInstance():getSelectServer())
end

-------------------------------------
-- function setServerName
-------------------------------------
function UI_LoginPopupWithoutFirebase:setServerName(name)
    local vars = self.vars
    vars['serverLabel']:setString(string.upper(name))
end

-------------------------------------
-- function click_exitBtn
-- @brief 종료
-------------------------------------
function UI_LoginPopupWithoutFirebase:click_exitBtn()
    local function yes_cb()
        closeApplication()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('종료하시겠습니까?'), yes_cb)
end

-------------------------------------
-- function click_uidBtn
-------------------------------------
function UI_LoginPopupWithoutFirebase:click_uidBtn()
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
function UI_LoginPopupWithoutFirebase:click_guestBtn()

    local confirm_popup
    local guest_loin

    -- 1. 게스트 계정에 대한 안내
    confirm_popup = function()
        local msg = Str('게스트 계정으로 접속을 하면 게임 삭제,\n기기변동, 휴대폰 초기화시 계정 데이터도\n삭제됩니다.\n\n게스트 계정으로 로그인하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, guest_loin, nil)
    end

    -- 2. 게스트 계정으로 로그인 시도
    guest_loin = function()
        local uid = self:makeRandomUid()
        local t_info = {}
        t_info['uid'] = uid
        self:loginSuccess(t_info)
        self:close()
    end

    confirm_popup()
end

-------------------------------------
-- function click_changeServer
-- @brief 서버 변경
-------------------------------------
function UI_LoginPopupWithoutFirebase:click_changeServer()
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
function UI_LoginPopupWithoutFirebase:loginSuccess(info)
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

    cclog('# UI_LoginPopupWithoutFirebase:loginSuccess(info)')
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

-------------------------------------
-- function loginCancel
-------------------------------------
function UI_LoginPopupWithoutFirebase:loginCancel()
    local msg = Str('로그인을 취소했습니다.')
    MakeSimplePopup(POPUP_TYPE.OK, msg)
end

-------------------------------------
-- function makeRandomUid
-- @brief 난수를 통해 UID 생성
-------------------------------------
function UI_LoginPopupWithoutFirebase:makeRandomUid()
    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local uuid = string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end) 

    return uuid
end

--@CHECK
UI:checkCompileError(UI_LoginPopupWithoutFirebase)
