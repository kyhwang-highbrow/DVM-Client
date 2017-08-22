local PARENT = UI

-------------------------------------
-- class UI_Network
-------------------------------------
UI_Network = class(PARENT,{
        m_bRevocable = 'boolean',   -- 취소 가능 여부
        m_bReuse = 'boolean', -- 재사용 가능 여부

        m_url = 'string',
        m_method = 'string', -- 'GET' or 'POST'
        m_bHmac = 'boolean', -- false or true
        m_tData = 'table', -- request 파라미터

        m_successCB = 'function',
        m_failCB = 'function',
        m_responseStatusCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Network:init()
    self.m_uiName = 'UI_Network'
    local vars = self:load('network_loading.ui')
    UIManager:open(self, UIManager.LOADING)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_Network')

    self:init_MemberVariable()

    self:setLoadingMsg(Str('네트워크 통신 중...'))
end

-------------------------------------
-- function init_MemberVariable
-------------------------------------
function UI_Network:init_MemberVariable()
    self.m_bRevocable = false
    self.m_bReuse = false

    self.m_url = nil
    self.m_method = 'POST' or 'GET'

    -- 라이브 서버에서는 true, 그외에는 false
    self.m_bHmac = false

    self.m_tData = {}

    self.m_successCB = nil
    self.m_failCB = nil
end

-------------------------------------
-- function softReset
-------------------------------------
function UI_Network:softReset()
    self.m_tData = {}
end

-------------------------------------
-- function setRevocable
-------------------------------------
function UI_Network:setRevocable(revocable)
    self.m_bRevocable = revocable
end

-------------------------------------
-- function setReuse
-------------------------------------
function UI_Network:setReuse(reuse)
    self.m_bReuse = reuse
end

-------------------------------------
-- function setUrl
-------------------------------------
function UI_Network:setUrl(url)
    self.m_url = url
end

-------------------------------------
-- function setMethod
-------------------------------------
function UI_Network:setMethod(method)
    if not isExistValue(method, 'POST', 'GET') then
        error('method : ' .. method)
    end

    self.m_method = method
end

-------------------------------------
-- function setHmac
-------------------------------------
function UI_Network:setHmac(hmac)
    self.m_bHmac = hmac
end

-------------------------------------
-- function setSuccessCB
-------------------------------------
function UI_Network:setSuccessCB(success_cb)
    self.m_successCB = success_cb
end

-------------------------------------
-- function setFailCB
-------------------------------------
function UI_Network:setFailCB(fail_cb)
    self.m_failCB = fail_cb
end

-------------------------------------
-- function setResponseStatusCB
-------------------------------------
function UI_Network:setResponseStatusCB(response_status_cb)
    self.m_responseStatusCB = response_status_cb
end

-------------------------------------
-- function setParam
-------------------------------------
function UI_Network:setParam(key, value)
    self.m_tData[key] = value
end

-------------------------------------
-- function setLoadingMsg
-------------------------------------
function UI_Network:setLoadingMsg(msg)
    self.vars['loadingLabel']:setString(msg)
end

-------------------------------------
-- function hideLoading
-------------------------------------
function UI_Network:hideLoading()
	self:setLoadingMsg('')
	self.vars['bgLayerColor']:setVisible(false)
end

-------------------------------------
-- function success
-------------------------------------
function UI_Network.success(self, ret)
    
    if self:statusHandler(ret) then
        return
    end

    if self.m_successCB then
        self.m_successCB(ret)
    end

    if (self.m_bReuse == false) and (self.closed == false) then
        self:close()
    end
end

-------------------------------------
-- function fail
-------------------------------------
function UI_Network.fail(self, ret)
    if self.m_failCB then
        self.m_failCB(ret)
    else
        self:makeFailPopup(nil, ret)
    end
end

local S_ERROR_STATUS = {
    -- not exist
    [-1101] = Str('상대방을 검색하지 못하였습니다.\n잠시 후에 다시 시도해주세요.'), -- not exist user
    [-1160] = Str('상대방의 방어덱이 없습니다.'), -- not exist deck

    -- not enough
    [-1211] = Str('골드가 부족합니다.'), -- not enough gold
    [-1212] = Str('다이아몬드가 부족합니다.'), -- not enough cash
    [-1216] = Str('날개가 부족합니다.'), -- not enough stamina
    [-1222] = Str('열매가 부족합니다.'), -- not enough fruit
    [-1223] = Str('진화재료가 부족합니다.'), -- not enough evolution stone
    [-1265] = Str('고대의탑 입장권이 부족합니다.'), -- not enough st_tower
    [-1266] = Str('콜로세움 입장권이 부족합니다.'), -- not enough st_pvp

    -- invalid
    [-1350] = Str('이미 종료된 던전입니다.'), -- invalid stage
    [-1351] = Str('잘못된 시간 정보입니다.'), -- invalid time
    [-1364] = Str('시즌이 종료되었습니다.'), -- invalid season

    -- already
    [-3026] = Str('이미 존재하는 닉네임입니다.'), -- already exist nick
    [-3259] = Str('이미 요청한 친구입니다.'), -- already send friend request
    [-3907] = Str('이미 친구입니다.'), -- already friend

    -- full
    [-1407] = Str('상대방에게 더 이상 친구요청을 할 수 없습니다.'), -- full friend

    -- highbrow coupon
    [-1367] = Str('일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'), -- invalid item 연결이 안되거나 에러인 경우
    [-1167] = Str('존재하지 않는 쿠폰입니다.'), -- not exist item 존재하지 않는 쿠폰
    [-3367] = Str('이미 사용한 쿠폰입니다.'), -- already receive item 이미 사용한 쿠폰
    [-187] = Str('하이브로 서버가 점검중입니다.\n잠시 후에 다시 시도 해주세요.'), -- maintenance access 서버가 점검중인 경우
}

local S_ERROR_STATUS_SHOP = {
    [-1211] = 'gold',
    [-1212] = 'cash',
}

-- 재시작
local S_ERROR_STATUS_RESTART = {
    [-100] = '', -- 점검 server text
}

-- 종료 
local S_ERROR_STATUS_CLOSE = {
    [-1386] = Str('불법적인 클라이언트 데이터 조작 프로그램 또는 매크로 프로그램이 감지되었습니다.\n\n회원번호가 수집되었으며 지속적인 클라이언트 조작 시도, 관련 파일 배포 등의 행위가 감지될 경우 고소 등 법적 처분의 대상이 될 수 있음을 알려 드립니다. 정상적인 방법으로 재접속해 주시기 바랍니다.'),
    [-1397] = Str('다른 디바이스에서 현재 계정으로 다시 로그인되어 더 이상의 플레이가 불가능합니다.\n앱을 완전 종료 후 다시 접속해주세요.'),
}
 
-------------------------------------
-- function statusHandler
-------------------------------------
function UI_Network:statusHandler(ret)
    local status = ret['status']
    local message = ret['message']

    if (not status) then
        return false
    end

    if (status == 0) then
        return false
    end

    if (status == 0) then
        return false
    end

    -- 응답 상태 처리 함수 확인
    if (self.m_responseStatusCB) then
        if self.m_responseStatusCB(ret) then
            self:close()
            return true
        end
    end

    local error_str = S_ERROR_STATUS_RESTART[status]
    if (error_str) then
        local notice = ret['notice']
        error_str = (notice) and notice 
        MakeNetworkPopup(POPUP_TYPE.OK, error_str, function() CppFunctions:restart() end)
        self:close()
        return true
    end

    local error_str = S_ERROR_STATUS_CLOSE[status]
    if (error_str) then
        MakeNetworkPopup(POPUP_TYPE.OK, error_str, function() closeApplication() end)
        self:close()
        return true
    end

    local error_str = S_ERROR_STATUS[status]
    local shop_tab = S_ERROR_STATUS_SHOP[status]
    if (error_str) then
        if (shop_tab) then
            self:makeShopPopup(error_str .. Str('\n\n상점으로 이동하시겠습니까??'), ret, shop_tab)
        else
            self:makeCommonPopup(error_str)
        end
        return true
    end

    -- 미리 정의 되지 못한 error_status
    self:makeFailPopup(nil, ret)
    return true
end

-------------------------------------
-- function makeFailPopup
-- @brief
-------------------------------------
function UI_Network:makeFailPopup(msg, ret)
    local function ok_btn_cb()
        self:request()
    end

    local function cancel_btn_cb()
        if self.m_failCB then
            self.m_failCB(ret)
        end
        self:close()
    end

    local msg = msg or '네트워크 연결에 실패하였습니다. 다시 시도하시겠습니까?'

    if ret then
        local add_msg = '(status : ' .. tostring(ret['status']) .. ', message : ' .. tostring(ret['message']) .. ')'
        msg =  msg .. '\n\n' .. add_msg
    end

    local popup_type

    if (self.m_bRevocable == true) then
        popup_type = POPUP_TYPE.YES_NO
    else
        popup_type = POPUP_TYPE.OK
    end

    MakeNetworkPopup(popup_type, msg, ok_btn_cb, cancel_btn_cb)
    self:close()
end

-------------------------------------
-- function makeShopPopup
-- @brief
-------------------------------------
function UI_Network:makeShopPopup(msg, ret, type)
    self:close()
    local function cb()
        g_shopDataNew:openShopPopup(type)
    end
    
    MakeNetworkPopup(POPUP_TYPE.YES_NO, msg, cb)
end

-------------------------------------
-- function makeCommonPopup
-- @brief
-------------------------------------
function UI_Network:makeCommonPopup(msg)
    self:close()
    MakeNetworkPopup(POPUP_TYPE.OK, Str(msg), self.m_failCB)
end


-------------------------------------
-- function request
-------------------------------------
function UI_Network:request()
    local t_request = {}

    t_request['url'] = self.m_url
    t_request['method'] = self.m_method
    t_request['data'] = self.m_tData

    t_request['success'] = function(ret) UI_Network.success(self, ret) end
    t_request['fail'] = function(ret) UI_Network.fail(self, ret) end
    
    if (self.m_bHmac == true) then
        Network:HMacRequest(t_request, true)
    else
        Network:SimpleRequest(t_request)
    end

	-- @E.T.
	g_errorTracker:appendAPI(self.m_url)
end

-------------------------------------
-- function close
-------------------------------------
function UI_Network:close()
    if (not self.closed) then
        PARENT.close(self)
    end
end



-- 네트워크 통신 테스트
function UI_NetworkTest()
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)

    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/login')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false) -- 통신 실패 시 취소 가능 여부
    ui_network:setReuse(false) -- 재사용 여부
    ui_network:request()
end