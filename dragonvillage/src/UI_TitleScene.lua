local PARENT = UI

-------------------------------------
-- class UI_TitleScene
-------------------------------------
UI_TitleScene = class(PARENT,{
        m_lWorkList = 'list',
        m_workIdx = 'number',
        m_loadingUI = 'UI_TitleSceneLoading',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TitleScene:init()
    local vars = self:load('title.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_TitleScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh() 

    -- @brief work초기화 용도로 사용함
    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TitleScene:initUI()
    local vars = self.vars

    vars['messageLabel']:setVisible(false)
    vars['downloadLabel']:setVisible(false)

    do -- 앱버전과 패치 정보를 출력
        local patch_idx_str = PatchData:getInstance():getAppVersionAndPatchIdxString()
        if (TARGET_SERVER == nil) then
            patch_idx_str = patch_idx_str
        elseif (TARGET_SERVER == 'FGT') then
            patch_idx_str = patch_idx_str .. ' (FGT server)'
		elseif (TARGET_SERVER == 'PUBLIC') then
            patch_idx_str = patch_idx_str .. ' (PUBLIC server)'
        else
            error('TARGET_SERVER : ' .. TARGET_SERVER)
        end

        vars['patchIdxLabel']:setString(patch_idx_str)
    end    

    self.m_loadingUI = UI_TitleSceneLoading()
    self.m_loadingUI:hideLoading()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TitleScene:initButton()
    self.vars['okButton']:registerScriptTapHandler(function() self:click_screenBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TitleScene:refresh()
end

-------------------------------------
-- function setTouchScreen
-- @brief '화면을 터치하세요' 문구 출력
-------------------------------------
function UI_TitleScene:setTouchScreen()
    local node = self.vars['messageLabel']

    node:setOpacity(255)

    local sequence = cc.Sequence:create(cc.FadeOut:create(1), cc.FadeIn:create(0.2))
    node:stopAllActions()
    node:runAction(cc.RepeatForever:create(sequence))

    node:setVisible(true)
    node:setString(Str('화면을 터치하세요.'))
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_TitleScene:click_screenBtn()
    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        self[func_name](self)
    end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_TitleScene:setWorkList()
    self.m_workIdx = 0

    self.m_lWorkList = {}
    table.insert(self.m_lWorkList, 'workTitleAni')
    table.insert(self.m_lWorkList, 'workCheckUserID')
    table.insert(self.m_lWorkList, 'workPlatformLogin')
    table.insert(self.m_lWorkList, 'workGameLogin')
    table.insert(self.m_lWorkList, 'workGetDeck')
    table.insert(self.m_lWorkList, 'workGetServerInfo')
    table.insert(self.m_lWorkList, 'workCollection')
    table.insert(self.m_lWorkList, 'workLobbyUserList')
    table.insert(self.m_lWorkList, 'workFinish')
    
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_TitleScene:doNextWork()
    self.m_workIdx = (self.m_workIdx + 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        cclog('\n')
        cclog('############################################################')
        cclog('# idx : ' .. self.m_workIdx .. ', func_name : ' .. func_name)
        cclog('############################################################')
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function retryCurrWork
-------------------------------------
function UI_TitleScene:retryCurrWork()
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        cclog('\n')
        cclog('############################################################')
        cclog('retry')
        cclog('# idx : ' .. self.m_workIdx .. ', func_name : ' .. func_name)
        cclog('############################################################')
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function workTitleAni
-- @brief 타이틀 연출 화면 (패치 종료 후 로그인 직전)
-------------------------------------
function UI_TitleScene:workTitleAni()
    local vars = self.vars

    SoundMgr:playBGM('bgm_intro')

    local function ani_handler()
        vars['animator']:changeAni('04_title_idle', true)
        self:doNextWork()
    end

    vars['animator']:changeAni('03_title', false)
    vars['animator']:addAniHandler(ani_handler)
end

-------------------------------------
-- function workTitleAni_click
-- @brief 타이틀 연출 화면 클릭 (패치 종료 후 로그인 직전)
-------------------------------------
function UI_TitleScene:workTitleAni_click()
    local vars = self.vars
    vars['animator']:changeAni('04_title_idle', true)
    self:doNextWork()
end

-------------------------------------
-- function workCheckUserID
-- @breif uid가 있는지 체크, UID가 없을 경우 유저 닉네임을 받아서
--        idfa로 저장하고 이를 통해서 UID를 발급
-------------------------------------
function UI_TitleScene:workCheckUserID()
    self.m_loadingUI:showLoading(Str('유저 계정 확인 중...'))

    local uid = g_serverData:get('local', 'uid')
    local idfa = g_serverData:get('local', 'idfa')

    if (uid or idfa) then
        self:doNextWork()
    else
        self.m_loadingUI:hideLoading()
        local edit_box = UI_EditBoxPopup()
        edit_box:setPopupTitle(Str('닉네임 입력'))
        edit_box:setPopupDsc(Str('사용하실 닉네임을 입력하세요.'))
        edit_box:setPlaceHolder(Str('2~8글자'))

        local function confirm_cb(str)
            local len = uc_len(str)
            if (len < 2) then
                UIManager:toastNotificationRed('2자~8자 이내로 입력해주세요.')
                return false
            end
            return true
        end
        edit_box:setConfirmCB(confirm_cb)

        local function close_cb(str)
            local text = edit_box.vars['editBox']:getText()
            g_serverData:applyServerData(text, 'local', 'idfa')
            self:doNextWork()
        end
        edit_box:setCloseCB(close_cb)
    end
end
function UI_TitleScene:workCheckUserID_click()
end

-------------------------------------
-- function workPlatformLogin
-- @brief 플랫폼 서버에 게스트 로그인
-------------------------------------
function UI_TitleScene:workPlatformLogin()
    self.m_loadingUI:showLoading(Str('플랫폼 서버에 로그인 중...'))

    local uid = g_serverData:get('local', 'uid')
    local idfa = g_serverData:get('local', 'idfa') or uid

    local player_id = nil
    local uid = uid
    local idfa = idfa
    local deviceOS = '3'
    local pushToken = 'temp'

    local success_cb = function(ret)
        -- UID 저장
        g_serverData:applyServerData(ret['uid'], 'local', 'uid')
        self:doNextWork()
    end

    local fail_cb = function(ret)
        self:makeFailPopup(nil, ret)
    end

    Network_platform_guest_login(player_id, uid, idfa, deviceOS, pushToken, success_cb, fail_cb)
end
function UI_TitleScene:workPlatformLogin_click()
end

-------------------------------------
-- function workGameLogin
-- @brief 게임서버에 로그인
-------------------------------------
function UI_TitleScene:workGameLogin()
    self.m_loadingUI:showLoading(Str('게임 서버에 로그인 중...'))

    local uid = g_serverData:get('local', 'uid')
    local nickname = g_userData:get('nick') or g_serverData:get('local', 'idfa')

    local success_cb = function(ret)
        g_serverData:lockSaveData()
        g_serverData:applyServerData(ret['user'], 'user')

        -- 드래곤 정보 갱신
        g_serverData:applyServerData({}, 'dragons') -- 로컬 세이브 데이터 초기화
        g_dragonsData:applyDragonData_list(ret['dragons'])

        g_serverData:unlockSaveData()

        -- server_info 정보를 갱신
        g_serverData:networkCommonRespone(ret)
        
        self:doNextWork()
    end

    local fail_cb = function(ret)
        self:makeFailPopup(nil, ret)
    end

    Network_login(uid, nickname, success_cb, fail_cb)
end
function UI_TitleScene:workGameLogin_click()
end

-------------------------------------
-- function workGetDeck
-- @brief
-------------------------------------
function UI_TitleScene:workGetDeck()
    self.m_loadingUI:showLoading(Str('덱 정보 요청 중...'))

    local uid = g_serverData:get('local', 'uid')

    local success_cb = function(ret)
        g_serverData:applyServerData(ret['deck'], 'deck')
        
        self:doNextWork()
    end

    local fail_cb = function(ret)
        self:makeFailPopup(nil, ret)
    end

    Network_get_deck(uid, success_cb, fail_cb)
end
function UI_TitleScene:workGetDeck_click()
end

-------------------------------------
-- function workGetServerInfo
-- @brief
-------------------------------------
function UI_TitleScene:workGetServerInfo()
    local function coroutine_function(dt)
        local co = CoroutineHelper()

        local fail_cb = function(ret)
            self:makeFailPopup(nil, ret)
        end

        -- 탐험 정보 받기
        co:work()
        local ui_network = g_explorationData:request_explorationInfo(co.NEXT)
        ui_network:setRevocable(false)
        ui_network:setFailCB(fail_cb)
        if co:waitWork() then return end

        co:close()

        -- 다음 work로 이동
        self:doNextWork()
    end

    Coroutine(coroutine_function)
end
function UI_TitleScene:workGetServerInfo_click()
end

-------------------------------------
-- function workCollection
-- @brief
-------------------------------------
function UI_TitleScene:workCollection()
    self.m_loadingUI:showLoading(Str('도감 정보 받는 중...'))

    local success_cb = function(ret)
        self:doNextWork()
    end

    local fail_cb = function(ret)
        self:makeFailPopup(nil, ret)
        return true
    end

    local ui_network = g_collectionData:request_collectionInfo(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setLoadingMsg('')
end
function UI_TitleScene:workCollection_click()
end


-------------------------------------
-- function workLobbyUserList
-- @brief
-------------------------------------
function UI_TitleScene:workLobbyUserList()
    self.m_loadingUI:showLoading(Str('광장에 들어가고 있습니다...'))

    local uid = g_serverData:get('local', 'uid')

    local success_cb = function(ret)
        self:doNextWork()
    end

    local fail_cb = function(ret)
        self:makeFailPopup(nil, ret)
    end

    g_lobbyUserListData:requestLobbyUserList(uid, success_cb, fail_cb)
end
function UI_TitleScene:workLobbyUserList_click()
end

-------------------------------------
-- function workFinish
-- @brief 로그인 완료 Scene 전환
-------------------------------------
function UI_TitleScene:workFinish()
    -- 로딩창 숨김
    self.m_loadingUI:hideLoading()

    -- 화면을 터치하세요. 출력
    self:setTouchScreen()
end
function UI_TitleScene:workFinish_click()
    -- 모든 작업이 끝난 경우 로비로 전환
    local scene = SceneLobby()

    -- 로딩 UI를 사용함(암전, 밝아짐 효과를 위해서)
    scene.m_bUseLoadingUI = true
    scene.m_loadingUIDuration = nil -- LoadingUI가 반드시 보여져야 하는 시간(nil일 경우 무시)

    scene:runScene()
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function makeFailPopup
-- @brief
-------------------------------------
function UI_TitleScene:makeFailPopup(msg, ret)
    local function ok_btn_cb()
        self.m_loadingUI:showLoading()
        self:retryCurrWork()
    end

    local msg = msg or '{@BLACK}네트워크 연결에 실패하였습니다. 다시 시도하시겠습니까?'

    if ret then
        local add_msg = '(status : ' .. tostring(ret['status']) .. ', message : ' .. tostring(ret['message']) .. ')'
        msg =  msg .. '\n\n' .. add_msg
    end

    self.m_loadingUI:hideLoading()
    MakeSimplePopup(POPUP_TYPE.OK, msg, ok_btn_cb)
end

--@CHECK
UI:checkCompileError(UI_TitleScene)
