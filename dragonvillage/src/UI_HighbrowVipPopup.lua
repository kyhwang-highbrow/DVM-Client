local PARENT = UI

-------------------------------------
-- Class UI_HighbrowVipPopup
-------------------------------------
UI_HighbrowVipPopup = class(PARENT, {
    --m_touchBlock = 'bool', -- 팝업이 열리자 마자 닫히는 오류를 방지
    m_isChecked = 'boolean',
})


-------------------------------------
-- function init
-------------------------------------
function UI_HighbrowVipPopup:init(is_popup)
    local vars = self:load('event_highbrow_vip.ui')

    if is_popup then
        UIManager:open(self, UIManager.POPUP)

        vars['closeBtn']:setVisible(true)
        
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_HighbrowVipPopup')
    end

    self.m_isChecked = false

    
    self:doActionReset()
    self:doAction()


    self:initUI()
    self:initButton()
    self:refresh()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_HighbrowVipPopup:initUI()
    local vars = self.vars
    -- 타이틀
    local original_str = vars['titleLabel']:getString()
    local vip_name = g_highbrowVipData:getVipName()
    vars['titleLabel']:setString(Str(original_str, Str(vip_name)))

    -- 좌측 상단 아이콘
    local vip_icon_res = g_highbrowVipData:getVipIconRes()
    UIManager:replaceResource(vars['iconNode'], vip_icon_res)

    -- 아래 프레임
    local bottom_frame_res = g_highbrowVipData:getBottomFrameRes()
    UIManager:replaceResource(vars['frameNode'], bottom_frame_res)

    -- 아이템 박스
    local item_box_res = g_highbrowVipData:getItemBoxRes()
    UIManager:replaceResource(vars['rewardFrameNode1'], item_box_res)
    UIManager:replaceResource(vars['rewardFrameNode2'], item_box_res)

    
    local is_reward_exist = g_highbrowVipData:checkItemExist()
    if (is_reward_exist == true) then
        vars['rewardMenu1']:setVisible(true)
        -- 보상 이미지
        local item_icon_res = g_highbrowVipData:getItemIconRes()
        UIManager:replaceResource(vars['rewardNode'], item_icon_res)

        -- 보상 String
        local item_str = g_highbrowVipData:getItemStr()
        vars['rewardLabel']:setString(item_str)

        vars['silverMenu']:setVisible(not is_reward_exist)
        vars['goldMenu']:setVisible(is_reward_exist)
    else
        -- 타이틀 변경
        vars['titleLabel']:setString(Str('{1} 등급 테이머님 환영합니다!', Str(vip_name)))

        vars['rewardMenu1']:setVisible(false)
        vars['rewardMenu2']:setPositionX(0)
        vars['benefitLabel']:setString(Str('혜택'))

        vars['silverMenu']:setVisible(not is_reward_exist)
        vars['goldMenu']:setVisible(is_reward_exist)
    end    

    self:initEditBox()
end



-------------------------------------
-- function initButton
-------------------------------------
function UI_HighbrowVipPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)

    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    end

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_HighbrowVipPopup:initEditBox()
    local vars = self.vars
    -- 이름
    vars['nameEditBox']:setMaxLength(10) -- 입력 제한
    
    -- 이메일
    vars['emailEditBox']:setMaxLength(300) -- 입력 제한

    -- 연락처
    vars['phoneEditBox']:setMaxLength(13)  -- 입력 제한

    -- 입력 콜백
    local function editBoxTextEventHandle(event_name, editbox)
        if (event_name == 'changed') then
            local text = editbox:getText()
            text = string.gsub(text, '[^%d]+', '')
            
            local phone_format_str_list = {}
            table.insert(phone_format_str_list, string.sub(text, 1, 3))
            local middle_idx = 7
            -- 10자리일땐 000-000-0000 꼴
            if (#text == 10) then
                middle_idx = 6
            end
            table.insert(phone_format_str_list, string.sub(text, 4, middle_idx))
            table.insert(phone_format_str_list, string.sub(text, (middle_idx + 1), -1))
            table.removeAllItemFromList(phone_format_str_list, '')
            local phone_format_str = table.concat(phone_format_str_list, '-')
            
            editbox:setText(phone_format_str)
        end
    end

    vars['phoneEditBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_HighbrowVipPopup:refresh()
    local vars = self.vars

    if (g_highbrowVipData:checkVipStatus() == true) then
        vars['okLabel']:setString(Str('하이브로 멤버십 등록'))
        vars['okBtn']:setEnabled(true)
    else
        vars['okLabel']:setString(Str('등록 완료'))
        vars['okBtn']:setEnabled(false)
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_HighbrowVipPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_checkBtn
-------------------------------------
function UI_HighbrowVipPopup:click_checkBtn()
    local vars = self.vars

    self.m_isChecked = (not self.m_isChecked)

    vars['checkSprite']:setVisible(self.m_isChecked)
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_HighbrowVipPopup:click_okBtn()
    local vars = self.vars

    -- 이름
    local name = vars['nameEditBox']:getText()
    local len = uc_len(name)
    if (len == 0) then
        UIManager:toastNotificationRed(Str('이름을 입력하세요.'))
        return
    end

    -- 연락처 
    local phone = vars['phoneEditBox']:getText()
    len = uc_len(phone)
    if (len == 0) then
        UIManager:toastNotificationRed(Str('연락처를 입력하세요.'))
        return
    end

    -- 이메일 검사
    local email = vars['emailEditBox']:getText()
    if (isValidMail(email) == false) then
        UIManager:toastNotificationRed(Str('유효하지 않은 이메일 주소입니다.'))
        return
    end

    -- 개인정보 수집 및 이용 동의 여부
    if (self.m_isChecked == false) then
        UIManager:toastNotificationRed(Str('개인정보 수집 및 이용에 동의해 주세요.'))
        return
    end

    local function success_cb()
        self:refresh()
        --self:click_closeBtn()
    end

    -- local function fail_cb()
    --     UIManager:toastNotificationRed(Str('일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'))
    -- end

    UI_HighbrowVipConfirm(name, phone, email, success_cb)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_HighbrowVipPopup:click_infoBtn()
    UI_HighbrowVipInfo()
end











-------------------------------------
-- Class UI_HighbrowVipInfo
-------------------------------------
UI_HighbrowVipInfo = class(UI, {

})

-------------------------------------
-- function init
-------------------------------------
function UI_HighbrowVipInfo:init()
    local vars = self:load('event_highbrow_vip_info_popup.ui')

    UIManager:open(self, UIManager.POPUP)
    
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HighbrowVipInfo')
    
    self:doActionReset()
    self:doAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HighbrowVipInfo:initUI()
    local vars = self.vars

    -- 좌측 상단 아이콘
    local vip_icon_res = g_highbrowVipData:getVipIconRes()
    UIManager:replaceResource(vars['iconNode'], vip_icon_res)

    -- 아래 프레임
    local bottom_frame_res = g_highbrowVipData:getBottomFrameRes()
    UIManager:replaceResource(vars['frameNode'], bottom_frame_res)

    do -- 설명
        local desc = Str('(주)하이브로에서는 멤버십 등록에 동의하신 대상자에게 등급 별 혜택 및 게임 관련 소식 안내를 위해 아래와 같이 개인 정보를 수집 및 이용합니다.')
        desc = desc .. '\n\n' .. Str('- 개인 정보 수집 및 이용목적 : 등급 별 혜택, 게임 관련 소식 안내')
        desc = desc .. '\n' .. Str('- 수집하는 개인 정보 항목 : 이름, 연락처, 이메일주소')
        desc = desc .. '\n' .. Str('- 개인 정보 보유 및 이용 기간 : 별도 해지 요청 시까지')
        desc = desc .. '\n\n' .. Str('멤버십 관련 개인 정보 수집 및 이용에 동의하지 않으실 수 있으며, 동의 거부 시에는 등급 별 혜택 및 게임 관련 소식 안내를 받으실 수 없습니다.')
        desc = desc .. '\n\n' .. Str('※ 기타 문의 사항은 언제든지 고객센터로 문의하시기 바라며, 동의 철회를 원하시는 경우 고객센터 또는, (무료수신거부) 0808571380을 통해 수신거부하실 수 있습니다.') 
        desc = desc .. ' ' .. Str('수신 철회 또는 거부 시, 일부 이벤트 참여 및 경품(쿠폰 등) 발송이 제한될 수 있습니다.')
        desc = desc .. '\n\n' .. Str('그 외의 개인정보 처리에 관한 자세한 사항은 {@#orange;url;{1}}개인정보 처리방침{@default}을 참고하시기 바랍니다.', 'https://highbrow.oqupie.com/portals/1555/articles/30815')
        vars['descLabel']:setString(desc)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HighbrowVipInfo:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HighbrowVipInfo:refresh()
    
end




-------------------------------------
-- Class UI_HighbrowVipConfirm
-------------------------------------
UI_HighbrowVipConfirm = class(UI, {
    m_name = 'string',
    m_number = '',
    m_email = 'string',

    m_okCallback = 'function',
    m_failCallback = 'function'
})

-------------------------------------
-- function init
-------------------------------------
function UI_HighbrowVipConfirm:init(name, number, email, ok_callback, fail_callback)
    local vars = self:load('event_highbrow_vip_confirm_popup.ui')

    UIManager:open(self, UIManager.POPUP)
    
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_HighbrowVipConfirm')
    
    self:doActionReset()
    self:doAction()

    self.m_okCallback = ok_callback
    self.m_failCallback = fail_callback

    self.m_name = name
    self.m_number = number
    self.m_email = email

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HighbrowVipConfirm:initUI()
    local vars = self.vars 

    -- 좌측 상단 아이콘
    local vip_icon_res = g_highbrowVipData:getVipIconRes()
    UIManager:replaceResource(vars['iconNode'], vip_icon_res)

    -- 아래 프레임
    local bottom_frame_res = g_highbrowVipData:getBottomFrameRes()
    UIManager:replaceResource(vars['frameNode'], bottom_frame_res)

    -- 이름
    vars['nameLabel']:setString(self.m_name)

    -- 번호
    vars['numberLabel']:setString(self.m_number)

    -- 이메일
    vars['mailLabel']:setString(self.m_email)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HighbrowVipConfirm:initButton()
    local vars = self.vars 

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HighbrowVipConfirm:refresh()
    
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_HighbrowVipConfirm:click_okBtn()
    local function success_callback()
        UIManager:toastNotificationGreen(Str('멤버십 등록이 완료되었습니다.'))

        self:click_closeBtn()
    end

    g_highbrowVipData:request_reward(self.m_name, self.m_number, self.m_email, success_callback, self.m_failCallback)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_HighbrowVipConfirm:click_closeBtn()
    
    self:setCloseCB(function() self.m_okCallback() end)
    
    self:close()
end