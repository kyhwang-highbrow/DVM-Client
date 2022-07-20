local PARENT = UI

-------------------------------------
---@class UI_AccountDeleteWaitPopup
-- @brief 계정 삭제 대기 팝업
-------------------------------------
UI_AccountDeleteWaitPopup = class(PARENT, {
    m_deleteTimestamp = 'number', -- timestamp(millisec)
    m_elapsedTime = ''
}) 

-------------------------------------
-- function init
-------------------------------------
function UI_AccountDeleteWaitPopup:init(timestamp)
    self.m_uiName = 'UI_AccountDeleteWaitPopup'
    self.m_deleteTimestamp = timestamp
    self.m_elapsedTime = 0
end

-------------------------------------
-- function init
-------------------------------------
function UI_AccountDeleteWaitPopup:init_after(timestamp)
    self:load('user_secession_cancel.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, self.m_uiName)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()


    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AccountDeleteWaitPopup:initUI()
    local vars = self.vars

    do -- 탈퇴 경고 문구
        local msg = Str('해당 계정은 탈퇴 예정입니다.')
        msg = msg .. '\n\n' .. Str('단, 탈퇴일로부터 7일 이내에 해당 계정으로 재접속하면 탈퇴를 취소할 수 있습니다.')
        msg = msg .. '\n\n' .. Str('탈퇴일로부터 7일이 지난 뒤에는 이용자를 식별할 수 있는 정보가 모두 삭제되기 때문에\n모든 게임 데이터 및 유료 아이템 정보를 복구할 수 없습니다.')
     
        vars['noticeLabel']:setString(msg)
    end

    do -- 탈퇴 예정 시간안에
        local timestamp_sec = self.m_deleteTimestamp / 1000
        local time_str = ServerTime:getInstance():getServerTimeTextForUI(timestamp_sec, Str('탈퇴 예정 시간 : {1}'))
        vars['deleteTimeLabel']:setString(time_str)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AccountDeleteWaitPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end) -- 탈퇴 취소
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end) -- 나가기
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AccountDeleteWaitPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_AccountDeleteWaitPopup:click_okBtn()
    local function ok_cb()
        local function success_cb(ret)
            MakeSimplePopup(POPUP_TYPE.OK, Str('계정 탈퇴가 취소되었습니다.'), function() CppFunctions:restart() end)
        end
    
        local function fail_cb(ret)
            local status = ret['status'] or 0
    
            local main_msg = Str('오류가 발생했습니다.') .. '\n' .. Str('오류코드와 함께 고객센터로 문의해주시기를 바랍니다.')
            local sub_msg = Str('에러코드 : {1}', status)
    
            MakeSimplePopup2(POPUP_TYPE.OK, main_msg, sub_msg, function() self:click_cancelBtn() end)
        end

        local function response_status_cb(ret)
            local status = ret['status'] or 0

            if (status == -4301) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('이미 계정 탈퇴가 처리된 계정입니다.'), function() self:click_cancelBtn() end)
            elseif (status == -4201) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('계정 탈퇴를 신청하지 않은 계정입니다.'), function() self:click_cancelBtn() end)
            else
                fail_cb(ret)
            end

            return true
        end
    
        LoginHelper:requestCancelDeleteAccount(success_cb, fail_cb, response_status_cb)
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('계정 탈퇴를 정말로 취소하시겠습니까?'), ok_cb)
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_AccountDeleteWaitPopup:click_cancelBtn()
    if (isWin32() == false) then
        PerpleSDK:logout()
        PerpleSDK:googleLogout()
        PerpleSDK:facebookLogout()
        PerpleSDK:twitterLogout()
    end

    -- 로컬 세이브 데이터 삭제
    removeLocalFiles()

     -- 어플 재시작
     CppFunctions:restart()
end

-------------------------------------
-- function update
-------------------------------------
function UI_AccountDeleteWaitPopup:update(dt)
    self.m_elapsedTime = self.m_elapsedTime + dt

    if (self.m_elapsedTime < 1) then
        return
    else
        self.m_elapsedTime = 0
    end

    self:refreshServerTime()
end

-------------------------------------
-- function refreshServerTime
-- @brief 서버 시간 표기
-------------------------------------
function UI_AccountDeleteWaitPopup:refreshServerTime()
    local vars = self.vars

    -- e.g. '서버 시간 : 2020-05-06 00:00:00 (UTC +9)'
    local server_time_str = ServerTime:getInstance():getServerTimeTextForUI()
    vars['serverTimeLabel']:setString(server_time_str)
end

--@CHECK
UI:checkCompileError(UI_AccountDeleteWaitPopup)
