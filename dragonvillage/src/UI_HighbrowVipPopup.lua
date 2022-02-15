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
    self:replaceResource(vars['iconNode'], vip_icon_res)

    -- 아래 프레임
    local bottom_frame_res = g_highbrowVipData:getBottomFrameRes()
    self:replaceResource(vars['frameNode'], bottom_frame_res)

    -- 아이템 박스
    local item_box_res = g_highbrowVipData:getItemBoxRes()
    self:replaceResource(vars['rewardFrameNode1'], item_box_res)
    self:replaceResource(vars['rewardFrameNode2'], item_box_res)

    -- 아이템
    local item_icon_res = g_highbrowVipData:getItemIconRes()
    self:replaceResource(vars['rewardNode'], item_icon_res)

    
    local item_str = g_highbrowVipData:getItemStr()
    vars['rewardLabel']:setString(item_str)
end

-------------------------------------
-- function replaceResource
-------------------------------------
function UI_HighbrowVipPopup:replaceResource(parent_node, res_name)
    local child = parent_node:getChildren()[1]
    local ui_size = child:getContentSize()
    local scale_x = child:getScaleX()
    local scale_y  = child:getScaleY()
    local anchor_point = child:getAnchorPoint()
    local dock_point = child:getDockPoint()

    parent_node:removeAllChildren()
    local sprite = cc.Sprite:create(res_name)
    sprite:setContentSize(ui_size.width, ui_size.height)
    sprite:setScale(scale_x, scale_y)
    sprite:setDockPoint(dock_point)
    sprite:setAnchorPoint(anchor_point)
    parent_node:addChild(sprite)
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
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_HighbrowVipPopup:refresh()
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
    vars['okBtn']:setEnabled(self.m_isChecked)
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
        UIManager:toastNotificationGreen(Str('제출해주셔서 감사합니다.'))
    end

    -- local function fail_cb()
    --     UIManager:toastNotificationRed(Str('일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'))
    -- end

    g_highbrowVipData:request_reward(name, phone, email, success_cb)
end












UI_ButtonHighbrowVIP = class(UI_ManagedButton, {

})

function UI_ButtonHighbrowVIP:init()
    self:load('button_highbrow_vip.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

function UI_ButtonHighbrowVIP:initUI()
    local vars = self.vars

    local icon_res = g_highbrowVipData:getVipBtnRes()
    self:replaceResource(vars['vipNode'], icon_res)


end

function UI_ButtonHighbrowVIP:initButton()    
    self.vars['vipBtn']:registerScriptTapHandler(function() self:click_btn() end)
end

function UI_ButtonHighbrowVIP:refresh()

end

function UI_ButtonHighbrowVIP:click_btn()
    g_highbrowVipData:openPopup()
end

-------------------------------------
-- function replaceResource
-------------------------------------
function UI_ButtonHighbrowVIP:replaceResource(parent_node, res_name)
    local child = parent_node:getChildren()[1]
    local ui_size = child:getContentSize()
    local scale_x = child:getScaleX()
    local scale_y  = child:getScaleY()
    local anchor_point = child:getAnchorPoint()
    local dock_point = child:getDockPoint()

    parent_node:removeAllChildren()
    local sprite = cc.Sprite:create(res_name)
    sprite:setContentSize(ui_size.width, ui_size.height)
    sprite:setScale(scale_x, scale_y)

    ccdump(ui_size)
    ccdump(scale_x)
    ccdump(scale_y)

    ccdump(anchor_point)
    ccdump(dock_point)

    sprite:setDockPoint(dock_point)
    sprite:setAnchorPoint(anchor_point)
    parent_node:addChild(sprite)
end