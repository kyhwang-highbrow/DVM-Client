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
        m_isSuccess = 'boolean', -- 성공
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_CouponPopup:init(couponType)
    self.m_couponType = couponType or ''
    self.m_couponCode = ''
    self.m_isSuccess = false

    local vars = self:load('coupon_input.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CouponPopup')

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
    self.m_maxCodeLength = 16
    self.m_titleText = Str("'드래곤빌리지M' 쿠폰 입력")
    self.m_editText = Str('{1}~{2}자리의 쿠폰 번호를 입력하세요.',12, self.m_maxCodeLength)
    self.m_dscText = Str("지급되는 상품은 '우편함'에서 수령 가능하며,\n입력 시 쿠폰의 유효기한 및 횟수 제한을 확인하시기 바랍니다.\n('드래곤빌리지 콜렉션게임카드'의 '아이템 코드'는 '드빌전용관'을 통해 이용 가능합니다.)")
    self.m_errText = Str('쿠폰 번호의 길이가 맞지 않습니다.')
    self.m_errSubText = Str('{1}~{2}자리의 쿠폰 번호를 입력해 주세요.',12, self.m_maxCodeLength)
   

    -- highbrow
    if self.m_couponType == 'highbrow' then
        self.m_titleText = Str("'아이템 코드' 입력")
        self.m_editText = Str('16자리의 아이템 코드를 입력하세요.')
        self.m_dscText = Str("구매하신 '드래곤빌리지 콜렉션 게임 카드'의 '아이템코드'를 입력하시면,\n드래곤빌리지M에서 획득 가능한 보상을 확인할 수 있습니다.\n(단, 드래곤빌리지 콜렉션 게임 카드 16탄 부터 적용되며, 1~15탄 카드, 특별카드 및 기타상품은 사용불가능합니다.)")
        self.m_errText = Str('아이템 코드의 길이가 맞지 않습니다.')
        self.m_errSubText = Str('16자리의 아이템 코드를 입력해 주세요.')
        self.m_maxCodeLength = 16
    end

    vars['titleLabel']:setString(self.m_titleText)
    vars['dscLabel']:setString(self.m_dscText)
    vars['editBox']:setMaxLength(self.m_maxCodeLength)
    vars['editBox']:setPlaceHolder(self.m_errSubText)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CouponPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
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
            self.m_couponCode = vars['editBox']:getText()
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
    local len = string.len(self.m_couponCode or '')
    if len ~= 12 and len ~= self.m_maxCodeLength then
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
    local function success_cb(t_ret)

        --ccdump(t_ret)
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

        local itemId = couponData['item_id'] or 0
        if itemId > 0 then
            self.m_isSuccess = true
            UI_CouponPopup_Confirm(couponCode, couponData)
            self:close()
        else
            MakeSimplePopup(POPUP_TYPE.OK, Str('유효하지 않은 아이템 코드입니다.\n다시 입력해 주세요.'))
        end
    end

    local function result_cb(t_ret)
        --ccdump(t_ret)
        if t_ret['web'] then
            local function yes_cb()
                SDKManager:goToWeb(t_ret['web'])
            end
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str("'드빌.net'에서 사용 가능한 코드입니다.\n'드빌.net'으로 이동하시겠습니까?"), yes_cb)
            self:close()
            return true
        end

        local msg = ''
        if t_ret['rs'] == 1 then
            msg = Str('유효하지 않은 아이템 코드입니다.\n다시 입력해 주세요.')
        elseif t_ret['rs'] == 2 then
            msg = Str('이미 사용된 아이템 코드입니다.\n다시 입력해 주세요.')
        elseif t_ret['rs'] == 3 then
            msg = Str('본 게임에서 사용할 수 없는 아이템 코드입니다.\n카드를 다시 확인해 주세요.')
        elseif t_ret['rs'] == 6 then
            msg = Str('서버 점검 중입니다.\n잠시 후 다시 시도해 주세요.')
        else
            return false
        end

        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return true
    end

    g_highbrowData:request_couponCheck(couponCode, success_cb, result_cb)
end

-------------------------------------
-- function normal_coupon
-- @brief ok~
-------------------------------------
function UI_CouponPopup:normal_coupon(couponCode)
    local function success_cb(ret)
        self.m_isSuccess = true
        UIManager:toastNotificationGreen(Str('쿠폰의 상품이 우편함으로 지급되었습니다.'))
        MakeSimplePopup(POPUP_TYPE.OK, Str('쿠폰 사용에 성공하였습니다.'))

        if couponCode == '51MF53D5H4FA' then
            g_settingData:setHbrwLoungeCheckCoupon(true)
        end

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
