local PARENT = UI

-------------------------------------
-- class UI_LoginPopup2
-- @brief 타이틀 화면 외에 로그인 권유 팝업 통하여 진입 시 사용
-------------------------------------
UI_LoginPopup2 = class(PARENT,{
        m_loadingUI = 'UI_TitleSceneLoading',                
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoginPopup2:init()
    local vars = self:load('login_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 없음
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_LoginPopup2')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_loadingUI = UI_TitleSceneLoading()
    self.m_loadingUI:hideLoading()

    LoginHelper:setup(self.m_loadingUI, function(info) self:loginSuccess(info) end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoginPopup2:initUI()
    local vars = self.vars

    vars['serverMenu']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LoginPopup2:initButton()
    local vars = self.vars
    
    vars['googleBtn']:registerScriptTapHandler(function() LoginHelper:linkWithGoogle() end)
	vars['facebookBtn']:registerScriptTapHandler(function() LoginHelper:linkWithFacebook() end)
	vars['twitterBtn']:registerScriptTapHandler(function() LoginHelper:linkWithTwitter() end)
    vars['gamecenterBtn']:registerScriptTapHandler(function() self:click_gameCenter() end)
    vars['appleBtn']:registerScriptTapHandler(function() LoginHelper:linkWithApple() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

	LoginHelper:alignLoginButtons(self.vars, false) -- use_guest
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoginPopup2:refresh()    
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_LoginPopup2:click_closeBtn()
    LoginHelper:release()
    self:close()
end

-------------------------------------
-- function loginSuccess
-------------------------------------
function UI_LoginPopup2:loginSuccess(info)
    local t_info = dkjson.decode(info)
    local fuid = t_info.fuid
    -- local push_token = t_info.pushToken
    local platform_id = t_info.providerId
    local account_info = t_info.name

    -- 고대의 탑 로컬 덱 리셋
    if (g_settingDeckData) then
        g_settingDeckData:resetAncientBestDeck()
    end

    if platform_id ~= 'gamecenter' then
        Network_platform_updateId(fuid, platform_id, account_info)
    end

    -- dirty -> lobby btn state
    GoogleHelper.setDirty(true)

    self:click_closeBtn() 
end


-------------------------------------
-- function click_gameCenter
-------------------------------------
function UI_LoginPopup2:click_gameCenter()
    local ok_btn_cb = function()
        LoginHelper:linkWithGameCenter()
    end

    -- 혹시 검수 반려 사항이 될 수도 있기 때문에 검수 모드일 때에는 경고 팝업 노출시키지 않음
    if (true == g_remoteConfig:hideCouponBtn()) or (true == LocalData.getInstance():isInAppReview()) then
        ok_btn_cb()
        return
    end

    local msg = 'Game Center'
    -- 현재 게임 센터 연동 시 다른 계정으로 전환을 막아놓음
    -- 기술적으로 불가능해 보이지 않지만 공수나 리스크를 고려해 아래와 같은 경고 문구 띄움
    -- 나중에는 전환이 가능하도록 지원을 고려해야 함(by kyhwang)
    local submsg = Str('게임센터 연동 시 다른 계정으로의 전환이 어렵습니다.\n그래도 연동을 진행하시겠습니까?')
    MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
end

--@CHECK
UI:checkCompileError(UI_LoginPopup2)
