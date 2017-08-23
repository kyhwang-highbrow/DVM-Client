-------------------------------------
-- class UI_CouponPopup
-------------------------------------
UI_CouponPopup = class(UI, {
        m_couponCode = 'string',
        m_couponType = 'string',
        m_maxCodeLength = 'number',
        m_titleText = 'string',
        m_editText = 'string',
        m_dscText = 'string',
        m_errText = 'string',
        m_errSubText = 'string',
        m_resultTextSuccess = 'string',
        m_resultTextFail = 'string',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_CouponPopup:init(couponType)
    self.m_couponType = couponType or ''
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

    -- normal
    self.m_titleText = Str("'드래곤빌리지M' 쿠폰 입력")
    self.m_editText = Str('12자리의 쿠폰 번호를 입력하세요.')
    self.m_dscText = Str("지급되는 상품은 '우편함'에서 수령 가능하며,\n입력 시 쿠폰의 유효기간 및 횟수 제한을 확인하시기 바랍니다.\n('드래곤빌리지 콜렉션게임카드'의 '아이템 코드'는 '드빌전용관'을 통해 이용 가능합니다.)")
    self.m_errText = Str('쿠폰 번호의 길이가 맞지 않습니다.')
    self.m_errSubText = Str('12자리의 쿠폰 번호를 입력해 주세요.')
    self.m_resultTextSuccess = Str('쿠폰 사용에 성공하였습니다.')
    self.m_resultTextFail = Str('쿠폰 번호를 잘못 입력하셨거나, 드래곤빌리지M에서는 적용 불가능한 쿠폰 번호입니다.')
    self.m_maxCodeLength = 12

    -- highbrow
    if self.m_couponType == 'highbrow' then
        self.m_titleText = Str("'아이템 코드' 입력")
        self.m_editText = Str('16자리의 아이템 코드를 입력하세요.')
        self.m_dscText = Str("구매하신 드래곤빌리지 콜렉션 게임 카드의 '아이템코드'를 입력하시면,\n드래곤빌리지M에서 획득 가능한 보상을 확인할 수 있습니다.\n(단, 드래곤빌리지 콜렉션게임카드 16탄 부터 적용되며, 1~15탄 카드, 특별카드 및 기타상품은 입력 불가 합니다.)")
        self.m_errText = Str('아이템 코드의 길이가 맞지 않습니다.')
        self.m_errSubText = Str('16자리의 아이템 코드를 입력해 주세요.')
        self.m_resultTextSuccess = Str('아이템 코드 사용에 성공하였습니다.')
        self.m_resultTextFail = Str('아이템 코드를 잘못 입력하셨거나, 드래곤빌리지M에서는 적용 불가능한 아이템 코드입니다.')
        self.m_maxCodeLength = 16
    end

    vars['titleLabel']:setString(self.m_titleText)
    vars['editLabel']:setString(self.m_editText)
    vars['editBox']:setPlaceHolder(self.m_editText)
    vars['dscLabel']:setString(self.m_dscText)
    vars['editBox']:setMaxLength(self.m_maxCodeLength)
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
            if string.len(self.m_couponCode) > 0 then
                vars['editLabel']:setString(self.m_couponCode)
            else
                vars['editLabel']:setString(self.m_editText)
            end
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
    if string.len(self.m_couponCode or '') ~= self.m_maxCodeLength then
        MakeSimplePopup2(POPUP_TYPE.OK, self.m_errText, self.m_errSubText)
        return
    end

    if self.m_couponType == 'highbrow' then
        self:highbrow_coupon(self.m_couponCode)
    else
        self:normal_coupon(self.m_couponCode)
    end
end

-------------------------------------
-- function highbrow_coupon
-- @brief ok~
-------------------------------------
function UI_CouponPopup:highbrow_coupon(couponCode)
    local function cb_func(t_ret)

        --[[
        ['item_info']={
                ['oids']={
                };
                ['count']=0;
                ['item_id']=0;
        };
        ['status']=0;
        ['message']='success';
        ['item_type']='';
        --]]

        local couponData = t_ret['item_info'] or {}
        UI_CouponPopup_Confirm(couponCode, couponData)
        self:close()
    end
    g_highbrowData:request_couponCheck(couponCode, cb_func)
end

-------------------------------------
-- function normal_coupon
-- @brief ok~
-------------------------------------
function UI_CouponPopup:normal_coupon(couponCode)
    local function success_cb(ret)
        UIManager:toastNotificationGreen(Str('쿠폰에 대한 상품이 우편함으로 지급되었습니다.'))
        MakeSimplePopup(POPUP_TYPE.OK, self.m_resultTextSuccess)
        self:close()
    end

    local function result_cb(ret)
        local msg = ''
        if (ret['status'] == -3167) then
            msg = Str('이미 사용된 쿠폰 번호입니다.\n다시 입력해 주세요.')
        elseif (ret['status'] == -1167) then
            msg = Str('유효하지 않은 쿠폰 번호입니다.\n다시 입력해 주세요.')
        elseif (ret['status'] == -1667) then
            msg = Str('사용 기한이 만료된 쿠폰 번호입니다.\n다시 입력해 주세요.')
        elseif (ret['status'] == -1767) then
            msg = Str('사용 가능한 횟수가 초과된 쿠폰 번호입니다.\n다시 입력해 주세요.')
        elseif (ret['status'] == -1367) then
            msg = Str('쿠폰 번호를 처리하는 과정에 오류가 발생하였습니다.\n다시 시도해 주세요.')
        else
            return false;
        end

        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return true;
    end

    ServerData_Shop:request_useCoupon(couponCode, success_cb, result_cb)
end
