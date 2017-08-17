-------------------------------------
-- class UI_CouponPopup
-------------------------------------
UI_CouponPopup = class(UI, {
        m_couponCode = 'string'
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_CouponPopup:init()
    self.m_couponCode = ''

    local vars = self:load('coupon_input.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:closeWithAction() end, 'UI_CouponPopup')

    self:initUI()
    self:initButton()
    self:initEditHandler()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CouponPopup:initUI()
    local vars = self.vars
    vars['editBox']:setMaxLength(16)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CouponPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:closeWithAction() end)
	vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['editBtn']:registerScriptTapHandler(function() self:click_editBtn() end)
end

-------------------------------------
-- function initEditHandler
-------------------------------------
function UI_CouponPopup:initEditHandler()
    local vars = self.vars

    -- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            -- editLabel에 글자를 찍어준다.
            self.m_couponCode = vars['editBox']:getText()
            vars['editLabel']:setString(self.m_couponCode)
        end
    end
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function click_editBtn
-- @brief editBtn 클릭시 editBox를 통해 키보드를 open한다.
-------------------------------------
function UI_CouponPopup:click_editBtn()
	self.vars['editBox']:openKeyboard()
end

-------------------------------------
-- function click_okBtn
-- @brief ok~
-------------------------------------
function UI_CouponPopup:click_okBtn()
    -- 쿠폰코드 길이 검증
    if string.len(self.m_couponCode or '') ~= 16 then
        local msg = Str('쿠폰 번호의 길이가 맞지 않습니다.')
        local submsg = Str('16자리의 쿠폰 번호를 입력해 주세요.')
        MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg)
        return
    end

    -- @todo-coupon, 서버에 쿠폰 조회
    local function cb_func(t_ret)
        local couponId = '1'
        local couponData = {}
        couponData['type'] = 700002
        couponData['no'] = '골드'
        couponData['cnt'] = 5000000

        UI_CouponPopup_Confirm(couponId, couponData)
        self:closeWithAction()
    end
    g_highbrowData:request_couponCheck(self.m_couponCode, cb_func)
end