local PARENT = UI

-------------------------------------
-- class UI_Network
-------------------------------------
UI_Network = class(PARENT,{
        m_bRevocable = 'boolean',   -- 취소 가능 여부
        m_bReuse = 'boolean', -- 재사용 가능 여부

        m_fullUrl = 'string', -- full url이 있을 경우 우선 사용
        m_url = 'string', -- 지정된 게임 서버 url과 조합해서 사용
        m_method = 'string', -- 'GET' or 'POST'
        m_bHmac = 'boolean', -- false or true
        m_tData = 'table', -- request 파라미터
        m_bSkipDefaultParams = 'boolean', -- uid, 버전 정보와 같은 기본 파라미터 추가 여부

        m_successCBDelayTime = 'number', -- 성공 통신 딜레이 타임 (개발 환경에서 통신 지연 테스트 용도로 사용)

        m_successCB = 'function',
        m_failCB = 'function',
        m_responseStatusCB = 'function',

        m_retryCount = 'number', -- 통신 실패시 최대 재시도 횟수
        m_currRetryCount = 'number', -- 현재 재시도 횟수
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

    self.m_fullUrl = nil
    self.m_url = nil
    self.m_method = 'POST' or 'GET'

    -- 클라이언트에서는 모든 통신에 hmac을 전달하는 것으로 결정
    -- 2017-08-23 sgkim (검증 여부는 서버에서 판단하기 때문)
    self.m_bHmac = true

    self.m_tData = {}
    self.m_bSkipDefaultParams = false

    self.m_successCB = nil
    self.m_failCB = nil

    self.m_retryCount = 0
    self.m_currRetryCount = 0
end

-------------------------------------
-- function softReset
-------------------------------------
function UI_Network:softReset()
    self.m_tData = {}
end

-------------------------------------
-- function setRevocable
-- @brief 통신 실패 시 취소 가능 여부
-------------------------------------
function UI_Network:setRevocable(revocable)
    self.m_bRevocable = revocable
end

-------------------------------------
-- function setReuse
-- @brief 재사용 여부
-------------------------------------
function UI_Network:setReuse(reuse)
    self.m_bReuse = reuse
end

-------------------------------------
-- function setRetryCount
-------------------------------------
function UI_Network:setRetryCount(retry_count)
    self.m_retryCount = retry_count
    self.m_currRetryCount = 0
end

-------------------------------------
-- function setRetryCount_forGameFinish
-- @brief 모든 종류의 연속 전투에서 
-- 통신 실패 시 사용하는 재시도 카운트 설정 함수
-------------------------------------
function UI_Network:setRetryCount_forGameFinish()
    self:setRetryCount(15)
end

-------------------------------------
-- function setFullUrl
-------------------------------------
function UI_Network:setFullUrl(full_url)
    self.m_fullUrl = full_url
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
-- @breif 통신은 성공을 하고 ret['status']값을 제어하고 싶을 때 사용
-- @param response_status_cb function(ret)
--                              -- true를 리턴하면 처리를 직접 했다는 뜻
--                              return true or false
--                           end
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
-- function setSKipDefaultParams
-------------------------------------
function UI_Network:setSKipDefaultParams(skip_default_params)
    self.m_bSkipDefaultParams = skip_default_params
end

-------------------------------------
-- function setLoadingMsg
-------------------------------------
function UI_Network:setLoadingMsg(msg)
    self.vars['loadingLabel']:setString(msg)
end

-------------------------------------
-- function setSuccessCBDelayTime
-- @brief 성공 통신 딜레이 타임 (개발 환경에서 통신 지연 테스트 용도로 사용)
-------------------------------------
function UI_Network:setSuccessCBDelayTime(sec)
    self.m_successCBDelayTime = sec
end

-------------------------------------
-- function hideLoading
-------------------------------------
function UI_Network:hideLoading()
	self:setLoadingMsg('')
	self.vars['bgLayerColor']:setVisible(false)
    
    if self.vars['visual'] then
        self.vars['visual']:setVisible(false)
    end
end

-------------------------------------
-- function showLoadingAnimation
-------------------------------------
function UI_Network:showLoadingAnimation()
    if self.vars['visual'] then
        self.vars['visual']:setVisible(true)
    end
end

-------------------------------------
-- function hideBGLayerColor
-------------------------------------
function UI_Network:hideBGLayerColor()
    self.vars['bgLayerColor']:setVisible(false)
end

-------------------------------------
-- function success
-------------------------------------
function UI_Network.success(self, ret)

    -- 설정된 딜레이 타임이 있을 경우
    local delay_time = tonumber(self.m_successCBDelayTime)
    if (delay_time and 0 < delay_time) then
        
        local function reserve_func()
            UI_Network.successCore(self, ret)
        end

        -- 지정된 시간 이후에 성공 콜백 호출
        local node = cc.Node:create()
        self.root:addChild(node)
        cca.reserveFunc(node, delay_time, reserve_func)
        return
    end

    -- 설정된 딜레이 타임이 없거나 0인 경우 즉시 호출
    UI_Network.successCore(self, ret)
end

-------------------------------------
-- function successCore
-------------------------------------
function UI_Network.successCore(self, ret)
    
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
-- @comment 통신을 실패한 케이스로 타임아웃 되거나 잘못된 주소인 경우		
--			통신은 성공했으나 서버에서 에러로 처리된 경우는 success로 간다.
--			fail handler 동작부 : net.lua line 154
--			대부분 타임아웃으로 판단되나 잘못된 주소인 경우는 판별할 수 없다.
-------------------------------------
function UI_Network.fail(self, ret)
    if (self.m_currRetryCount < self.m_retryCount) then
        self.m_currRetryCount = (self.m_currRetryCount + 1)
        local duration = 1
        cca.reserveFunc(self.root, duration, function()
            --ccdisplay('통신 재시도 ' .. tostring(self.m_currRetryCount))
            self:request()
        end)
        return
    end


    if self.m_failCB then
        self.m_failCB(ret)
    else
        self:makeNetworkFailPopup(ret)
    end

    -- @kwkang 실패할 경우에도 재사용할 여지가 많다. 기존에 success_CB에만 쓰이던 조건 추가
    if (self.m_bReuse == false) then
        self:close()
    end
end

local S_ERROR_STATUS = {
    -- not exist
    [-1101] = Str('존재하지 않는 사용자입니다.'), -- not exist user
    [-1102] = Str('조건에 해당하는 드래곤이 없습니다.'), 
    [-1160] = Str('상대방의 콜로세움 덱이 없습니다.'), -- not exist deck
	[-1152] = Str('상품이 모두 소진되었습니다.'), -- not exist reward (캡슐 뽑기)

    -- not enough
	[-1210] = Str('캡슐 코인이 부족합니다.'), -- not enough capsule_coin
    [-1211] = Str('골드가 부족합니다.'), -- not enough gold
    [-1212] = Str('다이아몬드가 부족합니다.'), -- not enough cash
    [-1216] = Str('날개가 부족합니다.'), -- not enough stamina
    [-1222] = Str('열매가 부족합니다.'), -- not enough fruit
    [-1223] = Str('진화재료가 부족합니다.'), -- not enough evolution stone
    [-1224] = Str('레벨이 부족합니다.'),
    [-1263] = Str('가방이 가득 찼습니다.\n가방 공간을 확보 후 전투를 시작할 수 있습니다.'), -- not enough inventory
    [-1265] = Str('고대의탑 입장권이 부족합니다.'), -- not enough st_tower
    [-1266] = Str('콜로세움 입장권이 부족합니다.'), -- not enough st_pvp

    -- invalid
    [-1350] = Str('이미 종료된 던전입니다.'), -- invalid stage
    [-1351] = Str('잘못된 시간 정보입니다.'), -- invalid time
    [-1364] = Str('시즌이 종료되었습니다.'), -- invalid season
	
	-- 원기님 제보 사항 추후 처리! : 통신 실패로 서버에 콜은 들어갔으나 response를 못 받은 경우 발생 이 경우 앱 재시작해야함
	--[-1393] = Str(''), -- invalid game key

    -- already
    [-3026] = Str('이미 존재하는 닉네임입니다.'), -- already exist nick
    [-3259] = Str('이미 요청한 친구입니다.'), -- already send friend request
    [-3907] = Str('이미 친구입니다.'), -- already friend

    -- full
    [-1407] = Str('상대방에게 더 이상 친구요청을 할 수 없습니다.'), -- full friend
    [-1507] = Str('더는 우정포인트를 보낼 수 없습니다.'), -- too many friend
    [-2607] = Str('상대방의 친구 목록이 가득 찼습니다.'), 

    -- highbrow coupon
    [-1367] = Str('일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'), -- invalid item 연결이 안되거나 에러인 경우
    [-1167] = Str('존재하지 않는 쿠폰입니다.'), -- not exist item 존재하지 않는 쿠폰
    [-3367] = Str('이미 사용한 쿠폰입니다.'), -- already receive item 이미 사용한 쿠폰
    [-187] = Str('하이브로 서버가 점검중입니다.\n잠시 후에 다시 시도 해주세요.'), -- maintenance access 서버가 점검중인 경우

    -- 클랜
    [-1103] = Str('존재하지 않는 클랜입니다.'), -- not exist clan

    -- 신규 아레나
    [-1360] = Str('콜로세움 덱이 설정되지 않았습니다.'), -- not exist clan

	-- common
	[-1391] = Str('잘못된 요청입니다.')
}

local S_ERROR_STATUS_SHOP = {
    [-1211] = 'gold',
    [-1212] = 'cash',
}

-- 재시작
local S_ERROR_STATUS_RESTART = {
    [-100] = Str('서버 점검 중입니다.\n잠시 후 다시 시도해 주세요.'), -- 점검 server text
    [-1111] = Str('클라이언트와 서버가 동기화 되지 않았습니다.\n앱을 재시작합니다.'), -- 서버와 동기화 에러 (골드)
    [-1125] = Str('클라이언트와 서버가 동기화 되지 않았습니다.\n앱을 재시작합니다.'), -- 서버와 동기화 에러 (드래곤 경험치)
}

-- 종료 
local S_ERROR_STATUS_CLOSE = {
    [-1368] = { -- @yjkil 22.03.08 서버에서 토큰 불일치 시 1368로 처리하여 추가
        ['msg'] = Str('불법적인 클라이언트 데이터 조작 프로그램 또는 매크로 프로그램이 감지되었습니다.\n\n회원번호가 수집되었으며 지속적인 클라이언트 조작 시도, 관련 파일 배포 등의 행위가 감지될 경우 고소 등 법적 처분의 대상이 될 수 있음을 알려 드립니다. 정상적인 방법으로 재접속해 주시기 바랍니다.'),
        ['submsg'] = nil,
    },
    [-1386] = {
            ['msg'] = Str('불법적인 클라이언트 데이터 조작 프로그램 또는 매크로 프로그램이 감지되었습니다.\n\n회원번호가 수집되었으며 지속적인 클라이언트 조작 시도, 관련 파일 배포 등의 행위가 감지될 경우 고소 등 법적 처분의 대상이 될 수 있음을 알려 드립니다. 정상적인 방법으로 재접속해 주시기 바랍니다.'),
            ['submsg'] = nil,
        },
    [-1397] = {
            ['msg'] = Str('앱 재시작이 필요합니다.\n앱을 완전 종료 후 다시 접속해주세요.'),
            ['submsg'] = Str('앱 재시작은 다른 기기에서 중복 로그인을 하거나 서버 점검 등으로 인해 요청될 수 있습니다.'),
        },

    -- 이용 제한
    [-9101] = {
            ['msg'] = Str('접속이 제한되었습니다.'),
            ['submsg'] = Str('문의 사항은 dvm@highbrow-inc.com으로 접수해주시기 바랍니다.'),
        }
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

    if (type(status) == 'table') and (status['retcode'] == 0) then
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
        error_str = notice or error_str
        MakeNetworkPopup(POPUP_TYPE.OK, error_str, function() CppFunctions:restart() end)
        self:close()
        return true
    end

    
    -- 앱을 종료하는 에러 메시지 처리
    local t_error_msg = S_ERROR_STATUS_CLOSE[status]
    if (t_error_msg) then
        local msg = t_error_msg['msg'] or ''
        local submsg = t_error_msg['submsg']

        -- 제한된 계정의 경우 서버에서 문구가 왔을 때 서버 문구로 처리
        if (status == -9101) and (ret['ban_msg']) and (type(ret['ban_msg']) == 'string') then
            msg = ret['ban_msg'] or msg
        end

        if submsg then
            MakeNetworkPopup2(POPUP_TYPE.OK, Str(msg), Str(submsg), function() closeApplication() end)
        else
            MakeNetworkPopup(POPUP_TYPE.OK, Str(msg), function() closeApplication() end)
        end
        self:close()
        return true
    end

    local error_str = S_ERROR_STATUS[status]
    local shop_tab = S_ERROR_STATUS_SHOP[status]
    if (error_str) then
        if (shop_tab) then
            self:makeShopPopup(Str(error_str).. Str('\n\n상점으로 이동하시겠습니까?'), ret, shop_tab)
        else
            self:makeCommonPopup(Str(error_str))
        end
        return true
    end

    -- 미리 정의 되지 못한 error_status
    self:makeErrorPopup(nil, ret)
    return true
end

-------------------------------------
-- function makeErrorPopup
-- @brief 서버에서의 에러를 처리하는 팝업
-------------------------------------
function UI_Network:makeErrorPopup(_msg, ret)
	-- popup_type
	local popup_type
    if (self.m_bRevocable == true) then
        popup_type = POPUP_TYPE.YES_NO
    else
        popup_type = POPUP_TYPE.OK
    end

	-- msg
    local msg
    if ret then    
        msg = _msg or Str('오류가 발생하였습니다.\n다시 시도하시겠습니까?')
			.. '\n\n' 
			.. '(status : ' .. tostring(ret['status']) .. ', message : ' .. tostring(ret['message']) .. ')'
	else
		msg = _msg or Str('오류가 발생하였습니다.\n다시 시도하시겠습니까?')
    end

	-- ok_btn_cb
	local function ok_btn_cb()
        self:request()
    end

	-- cancel_btn_cb
    local function cancel_btn_cb()
        if self.m_failCB then
            self.m_failCB(ret)
        end
        self:close()
    end

    MakeNetworkPopup(popup_type, msg, ok_btn_cb, cancel_btn_cb)
    self:close()
end

-------------------------------------
-- function makeNetworkFailPopup
-- @brief 통신 실패된 경우 처리하는 팝업
-------------------------------------
function UI_Network:makeNetworkFailPopup(t_error)
	-- popup_type
	local popup_type
    if (self.m_bRevocable == true) then
        popup_type = POPUP_TYPE.YES_NO
    else
        popup_type = POPUP_TYPE.OK
    end

	-- msg
	local msg = nil
	do
		local staus = t_error['status'] or 0

		-- status -9998 : 통신 실패
		if (staus == -9998) then
			msg = Str('통신이 지연되고 있습니다.\n네트워크 상태를 확인해주세요.')
			
			-- 추후에 메세지를 정리해보자
			-- local error_msg = t_error['message']
		
		-- status -9999 : 서버 통신 후 unknown error 발생
		elseif (staus == -9999) then
			msg = Str('오류가 발생하였습니다.\n다시 시도하시겠습니까?')

		end
	end

	-- ok_btn_cb
	local function ok_btn_cb()
        self:request()
    end

	-- cancel_btn_cb
    local function cancel_btn_cb()
        self:close()
    end

    MakeNetworkPopup(popup_type, msg, ok_btn_cb, cancel_btn_cb)
end

-------------------------------------
-- function makeShopPopup
-- @brief
-------------------------------------
function UI_Network:makeShopPopup(msg, ret, type)
    self:close()

    local function cb()
        if (type == 'cash') then
            UINavigatorDefinition:goTo('package_shop', 'diamond_shop')

        else
            g_shopDataNew:openShopPopup(type)

        end

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

    -- full url이 있을 경우 우선 사용
    if self.m_fullUrl then
        t_request['full_url'] = self.m_fullUrl
    else
        t_request['url'] = self.m_url
    end

    t_request['method'] = self.m_method
    t_request['data'] = self.m_tData
    t_request['skip_default_params'] = self.m_bSkipDefaultParams

    t_request['success'] = function(ret) UI_Network.success(self, ret) end
    t_request['fail'] = function(ret) UI_Network.fail(self, ret) end
    
    if (self.m_bHmac == true) then
        Network:HMacRequest(t_request)
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
    ui_network:setRetryCount(5) -- 통신 실패시 1초 간격으로 재통신
    ui_network:request()
end