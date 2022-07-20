local PARENT = UI

-------------------------------------
-- class UI_AccountDeleteRequestPopup
-- @brief 계정 삭제 요청 팝업
-------------------------------------
UI_AccountDeleteRequestPopup = class(PARENT,{
    m_bIsGuest = 'boolean', -- 게스트 여부
})

-------------------------------------
-- function init
-------------------------------------
function UI_AccountDeleteRequestPopup:init(is_guest)
    self.m_uiName = 'UI_AccountDeleteRequestPopup'
    self.m_bIsGuest = is_guest
end

-------------------------------------
-- function init
---@param is_guest boolean
-------------------------------------
function UI_AccountDeleteRequestPopup:init_after(is_guest)
    self:load('user_secession.ui')
    --self:load('popup_02.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, self.m_uiName)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AccountDeleteRequestPopup:initUI()
    local vars = self.vars
    local is_guest = self.m_bIsGuest

    do -- 탈퇴 경고 문구
        local msg = Str('탈퇴가 진행되면 게임을 이용할 수 없습니다.')
        if true or (is_guest == false) then
            msg = msg .. '\n\n' .. Str('단, 탈퇴일로부터 7일 이내에 해당 계정으로 재접속하면 탈퇴를 취소할 수 있습니다.')
        end
        msg = msg .. '\n\n' .. Str('탈퇴일로부터 7일이 지난 뒤에는 이용자를 식별할 수 있는 정보가 모두 삭제되기 때문에\n모든 게임 데이터 및 유료 아이템 정보를 복구할 수 없습니다.')
 
        vars['noticeLabel']:setString(msg)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AccountDeleteRequestPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end) -- 탈퇴 신청
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end) -- 나가기
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AccountDeleteRequestPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_AccountDeleteRequestPopup:click_okBtn()
    local is_guest = g_clanData:isClanGuest()

    if (is_guest == false) then
        local ui = MakeSimplePopup(POPUP_TYPE.OK, Str('클랜 탈퇴 후에 진행하실 수 있습니다.'))

        ui:setCloseCB(function() self:click_cancelBtn() end)
        return
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('계정 탈퇴를 정말로 진행하시겠습니까?'), function() LoginHelper:requestDeleteAccount() end)
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_AccountDeleteRequestPopup:click_cancelBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_AccountDeleteRequestPopup)
