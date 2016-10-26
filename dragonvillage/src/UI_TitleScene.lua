local PARENT = UI

-------------------------------------
-- class UI_TitleScene
-------------------------------------
UI_TitleScene = class(PARENT,{
        m_lWorkList = 'list',
        m_workIdx = 'number',
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
    vars['animator']:changeAni('00', true)
    vars['animator']:addAniHandler(function() vars['animator']:changeAni('02', true) end)

    vars['messageLabel']:setVisible(false)
    vars['downloadLabel']:setVisible(false)

    -- 앱버전과 패치 정보를 출력
    vars['patchIdxLabel']:setString(PatchData:getInstance():getAppVersionAndPatchIdxString())

    --self:setTouchScreen()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TitleScene:initButton()
    --self.vars['okButton']:registerScriptTapHandler(function() self:click_screenBtn() end)
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
    local scene = SceneLobby()
    scene:runScene()
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

    local function ani_handler()
        --vars['animator']:changeAni('02', true)
        self:doNextWork()
    end

    vars['animator']:changeAni('00', false)
    vars['animator']:addAniHandler(ani_handler)
end

-------------------------------------
-- function workCheckUserID
-- @breif uid가 있는지 체크, UID가 없을 경우 유저 닉네임을 받아서
--        idfa로 저장하고 이를 통해서 UID를 발급
-------------------------------------
function UI_TitleScene:workCheckUserID()
    ShowLoading(Str('유저 계정 확인 중...'))

    local user_id = g_userData.m_userData['user_id']
    local idfa = g_userData.m_userData['idfa']

    if (user_id or idfa) then
        self:doNextWork()
    else
        HideLoading()
        local edit_box = UI_EditBoxPopup()
        edit_box:setPopupTitle(Str('닉네임 입력'))
        edit_box:setPopupDsc(Str('사용하실 닉네임을 입력하세요.'))
        edit_box:setPlaceHolder(Str('4~8글자'))

        local function confirm_cb(str)
            local len = uc_len(str)
            if (len < 4) then
                UIManager:toastNotificationRed('4자~8자 이내로 입력해주세요.')
                return false
            end
            return true
        end
        edit_box:setConfirmCB(confirm_cb)

        local function close_cb(str)
            local text = edit_box.vars['editBox']:getText()
            cclog('text', text)
            g_userData.m_userData['idfa'] = text
            g_userData:setDirtyLocalSaveData()
            self:doNextWork()
        end
        edit_box:setCloseCB(close_cb)
    end
end

-------------------------------------
-- function workPlatformLogin
-- @brief 플랫폼 서버에 게스트 로그인
-------------------------------------
function UI_TitleScene:workPlatformLogin()
    ShowLoading(Str('플랫폼 서버에 로그인 중...'))

    local user_id = g_userData.m_userData['user_id']
    local idfa = g_userData.m_userData['idfa'] or user_id

    local player_id = nil
    local uid = user_id
    local idfa = idfa
    local deviceOS = '3'
    local pushToken = 'temp'

    local success_cb = function(ret)
        -- UID 저장
        g_userData.m_userData['user_id'] = ret['uid']
        g_userData:setDirtyLocalSaveData()
        --ccdump(ret)
        self:doNextWork()
    end

    local fail_cb = function(ret)
        ccdebug()
        ccdump(ret)
    end

    Network_platform_guest_login(player_id, uid, idfa, deviceOS, pushToken, success_cb, fail_cb)
end

-------------------------------------
-- function workGameLogin
-- @brief 게임서버에 로그인
-------------------------------------
function UI_TitleScene:workGameLogin()
    ShowLoading(Str('게임 서버에 로그인 중...'))

    local user_id = g_userData.m_userData['user_id']

    local success_cb = function(ret)
        g_serverData:applyServerData(ret['user'], 'user')
        --ccdump(ret)
        self:doNextWork()
    end

    local fail_cb = function(ret)
        ccdebug()
        ccdump(ret)
    end

    Network_login(user_id, success_cb, fail_cb)
end

-------------------------------------
-- function workFinish
-- @brief 로그인 완료 Scene 전환
-------------------------------------
function UI_TitleScene:workFinish()
    -- 로딩창 숨김
    HideLoading()

    -- 모든 작업이 끝난 경우 로비로 전환
    local scene = SceneLobby()

    -- 로딩 UI를 사용함(암전, 밝아짐 효과를 위해서)
    scene.m_bUseLoadingUI = true
    scene.m_loadingUIDuration = nil -- LoadingUI가 반드시 보여져야 하는 시간(nil일 경우 무시)

    scene:runScene()
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

--@CHECK
UI:checkCompileError(UI_TitleScene)
