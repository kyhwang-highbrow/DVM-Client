local PARENT = UI_CouponPopup
-------------------------------------
--- @class UI_CodeCouponPopup
-------------------------------------
UI_CodeCouponPopup = class(PARENT, {
 })

-------------------------------------
-- function initUI
-------------------------------------
function UI_CodeCouponPopup:initUI()
    local vars = self.vars

    self.m_maxCodeLength = 12
    self.m_titleText = Str("'드래곤빌리지M' 쿠폰 입력")
    self.m_editText = Str('{1}~{2}자리의 쿠폰 번호를 입력하세요.',8, self.m_maxCodeLength)
    self.m_dscText = Str("지급되는 상품은 '우편함'에서 수령 가능하며,\n입력 시 쿠폰의 유효기한 및 횟수 제한을 확인하시기 바랍니다.")
    self.m_errText = Str('쿠폰 번호의 길이가 맞지 않습니다.')
    self.m_errSubText = Str('{1}~{2}자리의 쿠폰 번호를 입력해 주세요.',8, self.m_maxCodeLength)
   
    vars['titleLabel']:setString(self.m_titleText)
    vars['dscLabel']:setString(self.m_dscText)
    vars['editBox']:setMaxLength(self.m_maxCodeLength)
    vars['editBox']:setPlaceHolder(self.m_errSubText)
end

-------------------------------------
--- @function click_okBtn
-------------------------------------
function UI_CodeCouponPopup:click_okBtn()
    -- 쿠폰코드 길이 검증
    local len = string.len(self.m_couponCode or '')
    if len < 8 or len > 12 then
        MakeSimplePopup2(POPUP_TYPE.OK, self.m_errText, self.m_errSubText)
        return
    end

    local couponCode = self.m_couponCode
    local function success_cb(ret)
        UIManager:toastNotificationGreen(Str('쿠폰의 상품이 우편함으로 지급되었습니다.'))
        MakeSimplePopup(POPUP_TYPE.OK, Str('쿠폰 사용에 성공하였습니다.'))
        self:close()
    end

    local function result_cb(ret)
        local msg = Str('쿠폰 번호를 처리하는 과정에 오류가 발생하였습니다.\n다시 시도해 주세요.')
        msg = msg .. '\n' .. Str('문제가 지속될 경우 고객센터로 문의해주시기를 바랍니다.')

        if (ret['status'] == -3167) then
            msg = Str('이미 사용된 쿠폰 번호입니다.\n다시 입력해 주세요.')            
        elseif (ret['status'] == -1167) then
            msg = Str('유효하지 않은 쿠폰 번호입니다.\n다시 입력해 주세요.')
        elseif (ret['status'] == -1667) then
            msg = Str('사용 기한이 만료된 쿠폰 번호입니다.\n다시 입력해 주세요.')
        elseif (ret['status'] == -1767) then
            msg = Str('사용 가능한 횟수가 초과된 쿠폰 번호입니다.\n다시 입력해 주세요.')
        elseif (ret['status'] == -1367) then
            msg = Str('유효하지 않은 쿠폰 번호입니다.\n다시 입력해 주세요.')
        end

        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return true;
    end

    g_highbrowData:request_cardCouponUse(couponCode, success_cb, result_cb)
end