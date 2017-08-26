-------------------------------------
-- class UI_CouponPopupPreOccupancyNick
-- @breif 사전등록 님네임 쿠폰 입력
-------------------------------------
UI_CouponPopupPreOccupancyNick = class(UI, {
        m_couponCode = 'string',
        m_maxCodeLength = 'number',
        m_editText = 'string',
        m_errText = 'string',
        m_errSubText = 'string',
        m_retNick = 'string',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_CouponPopupPreOccupancyNick:init()
    self.m_couponCode = ''
    self.m_retNick = nil

    local vars = self:load('coupon_input.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CouponPopupPreOccupancyNick')

    self:initUI()
    self:initButton()
    self:initEditHandler()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CouponPopupPreOccupancyNick:initUI()
    local vars = self.vars

    self.m_editText = Str('8자리 코드를 입력하세요.')
    self.m_maxCodeLength = 8
    self.m_errText = Str('코드의 길이가 맞지 않습니다.')
    self.m_errSubText = Str('8자리의 코드를 입력해 주세요.')

    vars['titleLabel']:setString(Str('사전등록 닉네임 코드 입력'))
    vars['editLabel']:setString(self.m_editText)
    vars['editBox']:setPlaceHolder(self.m_editText)
    vars['dscLabel']:setString(Str('사회통념 상 욕설이나 부적절한 단어에 해당하는 경우 또는 운영 상 혼란 야기의 가능성이 있는 단어,\n시나리오 진행 및 운영 복적 상 사용이 제한된 단어는 사용이 불가능할 수 있습니다.'))
    vars['editBox']:setMaxLength(self.m_maxCodeLength)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CouponPopupPreOccupancyNick:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['editBtn']:registerScriptTapHandler(function() self:click_editBtn() end)
end

-------------------------------------
-- function initEditHandler
-------------------------------------
function UI_CouponPopupPreOccupancyNick:initEditHandler()
    local vars = self.vars

    -- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            -- editLabel에 글자를 찍어준다.
            self.m_couponCode = vars['editBox']:getText()
            self.m_couponCode = string.upper(self.m_couponCode)
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
function UI_CouponPopupPreOccupancyNick:click_editBtn()
	self.vars['editBox']:openKeyboard()
end

-------------------------------------
-- function click_okBtn
-- @brief ok~
-------------------------------------
function UI_CouponPopupPreOccupancyNick:click_okBtn()
    -- 쿠폰코드 길이 검증
    if string.len(self.m_couponCode or '') ~= self.m_maxCodeLength then
        MakeSimplePopup2(POPUP_TYPE.OK, self.m_errText, self.m_errSubText)
        return
    end

    self:request_preOccupancyNick(self.m_couponCode)
end

-------------------------------------
-- function request_preOccupancyNick
-- @brief
-------------------------------------
function UI_CouponPopupPreOccupancyNick:request_preOccupancyNick(coupon_code)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 에러코드 처리
    local function result_cb(ret)
        if (ret['status'] == -1155) then
            local msg = Str('유효하지 않은 쿠폰 번호입니다.\n다시 입력해 주세요.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return true -- 자체적으로 통신 처리를 완료했다는 뜻
        end
    end

    -- 콜백 함수
    local function success_cb(ret)
        if (not IsValidText(ret['nick'], true)) then
            local msg = Str('사회통념 상 욕설이나 부적절한 단어에 해당하는 경우 또는 운영 상 혼란 야기의 가능성이 있는 단어, 시나리오 진행 및 운영 복적 상 사용이 제한된 단어가 포함되어 사용이 불가능한 닉네임입니다.')
            MakeSimplePopup2(POPUP_TYPE.OK, msg, Str('사전등록 닉네임 : {1}', ret['nick']))
            return
        end

        -- close callback을 통해서 m_retNick이 포함되어 있으면 사용 가능 상태
        self.m_retNick = ret['nick']
        self:close()
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_preoccupancynick')
    ui_network:setParam('uid', uid)
    ui_network:setParam('code', coupon_code)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(result_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end
