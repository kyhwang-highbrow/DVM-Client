local PARENT = UI

-------------------------------------
-- class UI_LoginPopup
-- @brief 타이틀 화면에서 계정 생성 or 로그인을 할 때 사용
-------------------------------------
UI_LoginPopup = class(PARENT,{
        m_loadingUI = 'UI_TitleSceneLoading',                
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoginPopup:init(owner_ui)
    local vars = self:load('login_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_LoginPopup'
    
    -- backkey 없음
    g_currScene:pushBackKeyListener(self, function() self:close(true) end, 'UI_LoginPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_loadingUI = owner_ui.m_loadingUI
    self.m_loadingUI:hideLoading()

    LoginHelper:setup(self.m_loadingUI, function(info) self:loginSuccess(info) end)

    --서버선택 팝업으로 최초에 보여주도록
    -- @sgkim 2019-05-28 타이틀 화면(UI_TitleScene:workCheckSelectedGameServer()) 에서 서버 선택을 하도록 변경 
    --self:click_changeServer()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoginPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LoginPopup:initButton()
    local vars = self.vars
    
    vars['googleBtn']:registerScriptTapHandler(function() LoginHelper:loginWithGoogle() end)
	vars['facebookBtn']:registerScriptTapHandler(function() LoginHelper:loginWithFacebook() end)
    vars['twitterBtn']:registerScriptTapHandler(function() LoginHelper:loginWithTwitter() end)
    vars['gamecenterBtn']:registerScriptTapHandler(function() LoginHelper:loginWithGameCenter() end)
    vars['appleBtn']:registerScriptTapHandler(function() LoginHelper:loginWithApple() end)
    vars['guestBtn']:registerScriptTapHandler(function() LoginHelper:loginAsGuest() end)
    vars['serverBtn']:registerScriptTapHandler(function() self:click_changeServer() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close(true) end)
    vars['testmodeBtn']:registerScriptTapHandler(function() self:click_testmodeBtn() end)
	
    LoginHelper:alignLoginButtons(self.vars, true) -- use_guest
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoginPopup:refresh()    
    local vars = self.vars
    local target_server = ServerListData:getInstance():getSelectServer()
    self:setServerName(target_server)
    
    local is_new_server = (target_server == SERVER_NAME.EUROPE)
    self.vars['serverRewardMenu']:setVisible(is_new_server)

    if IS_TEST_MODE() then
        if (target_server == 'DEV') or (target_server == 'QA') then
            vars['testmodeBtn']:setVisible(true)
        else
            vars['testmodeBtn']:setVisible(false)
        end        
    end
end

-------------------------------------
-- function setServerName
-------------------------------------
function UI_LoginPopup:setServerName(name)
    local vars = self.vars
    vars['serverLabel']:setString( string.upper( name ) )
end

-------------------------------------
-- function close
-------------------------------------
function UI_LoginPopup:close(is_back_key)
    if self.closed then
        cclog('attempted to close twice')
        cclog(debug.traceback())
        return
    end
    self.closed = true
    self:onClose()

    UIManager:close(self)
    
    if self.m_closeCB then
        self.m_closeCB(is_back_key)
    end

    LoginHelper:release()
    
    --[[
        -- 이전에는 뒤로가기 키 눌렀을 때, 이전 UI가 없어서 앱을 종료시켜줌
        -- @jhakim 190714 통합 로그인 창 생기면서 로그인하면 바로 다음 넘어가던가, 뒤로가기 키 누르면 UI창만 꺼주는 방향으로 수정
        local function yes_cb()
            closeApplication()
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('종료하시겠습니까?'), yes_cb)
    --]]
end

-------------------------------------
-- function click_changeServer
-------------------------------------
function UI_LoginPopup:click_changeServer()
    local function onFinish( name )        
        ServerListData:getInstance():selectServer( name )
        self:setServerName( name )
    end
    UI_SelectServerPopup( onFinish )
end

-------------------------------------
-- function click_testmodeBtn
-------------------------------------
function UI_LoginPopup:click_testmodeBtn()
    local ui = UI_LoginPopupWithoutFirebase()
    ui:setCloseCB(function()
        self:close()
    end)
end

-------------------------------------
-- function loginSuccess
-------------------------------------
function UI_LoginPopup:loginSuccess(info)
    local t_info = dkjson.decode(info)
    -- local fuid = t_info.fuid
    -- local push_token = t_info.pushToken
    local platform_id = t_info.providerId
    -- local account_info = t_info.name

    --선택 서버 저장
    g_localData:lockSaveData()
    g_localData:setServerName( ServerListData:getInstance():getSelectServer() )
    g_localData:unlockSaveData()

    -- 혹시 시스템 오류로 멀티연동이 된 경우 현재 로그인한 플랫폼 이외의 연결은 해제한다.
    UnlinkBrokenPlatform(t_info, platform_id)

    self:close()
end

--@CHECK
UI:checkCompileError(UI_LoginPopup)
