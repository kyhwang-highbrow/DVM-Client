-------------------------------------
-- class ServerData_SpotSale
-- @brief 깜짝 할인 상품
-- @instance g_spotSaleData
-- https://perplelab.atlassian.net/wiki/x/O4B9Lg
-------------------------------------
ServerData_SpotSale = class({
        m_serverData = 'ServerData',
		m_spotSaleInfo = 'table',
		m_sortedSpotSaleList = 'list',

        m_bDebugLog = 'boolean', -- 클래스 로그 출력 여부
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_SpotSale:init(server_data)
    self.m_serverData = server_data
    self.m_bDebugLog = false
end

-------------------------------------
-- function getSortedSpotSaleList
-- @brief priority값이 낮은 순서로 정렬된 table_spot_sale
-------------------------------------
function ServerData_SpotSale:getSortedSpotSaleList()

    -- 없으면 생성
    if (not self.m_sortedSpotSaleList) then
	    self.m_sortedSpotSaleList = TableSpotSale:getSortedSpotSaleList()
    end

    return self.m_sortedSpotSaleList
end

-------------------------------------
-- function getSpotSaleLackItemID
-- @brief 부족한 상품 체크/ 부족한 상품 없으면 nil 반환
-- @return table_spot_sale테이블의 id 값 (spot_sale_id)
-------------------------------------
function ServerData_SpotSale:getSpotSaleLackItemID(item_id)
    self:log('====================================================')
    self:log('## ServerData_SpotSale:getSpotSaleLackItemID() START')


    -- 1. 현재 활성화된 깜짝 할인 상품이 있을 경우
    if (self:hasSpotSaleItem() == true) then
        self:log('## 현재 활성화된 깜짝 할인 상품이 있음')
        self:log('## ServerData_SpotSale:getSpotSaleLackItemID() END')
        return nil
    end

	-- 2. 글로벌 쿨타임(global_cool_down) 확인
	if (not self:getGlobalCoolTimeDone()) then
        self:log('## 글로벌 쿨타임')
        self:log('## ServerData_SpotSale:getSpotSaleLackItemID() END')
		return nil
	end 

    -- priority값이 낮은 순서로 정렬된 table_spot_sale
    local sorted_spot_sale_lsit = self:getSortedSpotSaleList()

    -- 수량 체크를 스킵할지 여부. 지정 상품이 있다는 것은 강제로 노출시키기 위함이기 때문에 condition 수량 확인을 skip함
    local skip_condition = false
    if item_id then
        skip_condition = true
    end
	for _,v in ipairs(sorted_spot_sale_lsit) do
        local spot_sale_id = v['id']

        -- 지정 아이템이 없거나 지정된 아이템인 경우만 동작
        if (not item_id) or (item_id == v['item']) then
            if (self:checkCondition(spot_sale_id, skip_condition)) then
                self:log('## ServerData_SpotSale:getSpotSaleLackItemID() END')
			    return spot_sale_id
		    end
        end
	end

    self:log('## ServerData_SpotSale:getSpotSaleLackItemID() END')
	return nil
end

-------------------------------------
-- function checkCondition
-- @brief 개별 상품에 대한 조건 검사
-------------------------------------
function ServerData_SpotSale:checkCondition(id, skip_conditon)
    
    local table_spot_sale = TableSpotSale()
    if (not table_spot_sale:exists(id)) then
        return false
    end

    self:log('# id ' .. id)

    do-- 1. 개별 쿨타임(cooldown) 확인
        local cool_down = self:getSpotSaleInfo_coolDown(id)
        local curr_time = Timer:getServerTime_Milliseconds()

        if (curr_time < cool_down) then
            if self.m_bDebugLog then
                local desc = datetime.makeTimeDesc((cool_down-curr_time)/1000, true) -- param : sec, showSeconds, firstOnly, timeOnly
                self:log('개별 쿨 ' .. desc .. '남음')
            end
            return false
        end
    end

    do-- 2. 레벨(user_lv) 제한 확인
        local lv = g_userData:get('lv') -- 유저 레벨
        local require_lv = table_spot_sale:getRequiredLevel(id)
        
        if (lv < require_lv) then
            self:log('레벨 제한 ' .. require_lv)
            return false
        end
    end

    -- 3. 수량(condition) 확인
    if (not skip_conditon) then
        local condition = table_spot_sale:getCondition(id)
        local item_id = table_spot_sale:getItemID(id)

        -- 2018.11.08 처리 중인 타입 cash, gold, staminas_st
	    local item_type = TableItem:getItemType(item_id)
        local curr_cnt = 0
        if (item_type == 'staminas_st') then
            curr_cnt = g_staminasData:getStaminaCount('st')
        else
            -- cash, gold의 케이스
            curr_cnt = g_userData:get(item_type)
        end
		
		-- 현재 아이템 갯수가 조건보다 적다면 
		if (condition < curr_cnt) then
            self:log('아이템 수량 충분함 ' .. curr_cnt .. '/' .. condition)
            return false
		end

    end

    return true
end

-------------------------------------
-- function getSpotSaleInfo_coolDown
-- @brief 서버에서 받은 개별 쿨종료 시간 반환
-- @return timestamp 값이 없을 경우 0으로 리턴
--                  (현재보다 과거 시간으로 처리하기 위해)
-------------------------------------
function ServerData_SpotSale:getSpotSaleInfo_coolDown(id)
    local id = tostring(id)
    local spot_sale_info = self:getSpotSaleInfo()

    if (not spot_sale_info['cool_down_list']) then
        return 0
    end

    return (spot_sale_info['cool_down_list'][id] or 0)
end

-------------------------------------
-- function getSpotSaleInfo
-- @brief 서버로부터 받은 정보
-------------------------------------
function ServerData_SpotSale:getSpotSaleInfo()
    if (not self.m_spotSaleInfo) then
        return {}
    end

    return self.m_spotSaleInfo
end

-------------------------------------
-- function getGlobalCoolTimeDone
-- @brief
-- @return boolean false일 경우 쿨타임 중 (상품 발동 불가 상태)
-------------------------------------
function ServerData_SpotSale:getGlobalCoolTimeDone()
    local spot_sale_info = self:getSpotSaleInfo()
    local global_cool_down = spot_sale_info['global_cool_down']

    -- 해당 계정이 한 번도 발동하지 않은 경우 값이 없을 수 있음
    if (not global_cool_down) then
        return true
    end

    -- 현재 시간    
    local curr_time = Timer:getServerTime_Milliseconds()

    if self.m_bDebugLog then
        if (curr_time < global_cool_down) then
            local desc = datetime.makeTimeDesc((global_cool_down-curr_time)/1000, true) -- param : sec, showSeconds, firstOnly, timeOnly
            self:log(desc .. '남음')
        end
    end

    return (global_cool_down <= curr_time)
end

-------------------------------------
-- function applySpotSaleInfo
-- @brief 로비 통신에서 받아오는 SpotSale 정보 적용
-------------------------------------
function ServerData_SpotSale:applySpotSaleInfo(t_spot_sale)
    if (not t_spot_sale) then
        return
    end

    -- t_spot_sale ex
    --"spot_sale":{
    --    "active_list":{
    --      "100010":1541675830386
    --    },
    --    "global_cool_down":1541747830386,
    --    "cool_down_list":{
    --      "100010":1541834230386
    --    }
    --  }

	self.m_spotSaleInfo = t_spot_sale
end

-------------------------------------
-- function getSpotSaleInfo_activeProduct
-- @brief 
-- @return spot_sale_id, endtime(timestamp 상품 판매 종료 시점 시간)
-------------------------------------
function ServerData_SpotSale:getSpotSaleInfo_activeProduct()
    local spot_sale_info = self:getSpotSaleInfo()

    if (not spot_sale_info['active_list']) then
        return nil, nil
    end

    -- 현재 시간
    local curr_time = Timer:getServerTime_Milliseconds()

    -- 우선 깜짝 할인 상품은 동시에 1개만 발동된다고 가정함 (기획의도)
	for spot_sale_id, endtime in pairs(spot_sale_info['active_list']) do

        -- 상품 만료 시간 이전일 경우
        if (curr_time < endtime) then
            return tonumber(spot_sale_id), endtime
        end
	end
end

-------------------------------------
-- function hasSpotSaleItem
-- @brief 판매 중인 깜짝 할인 상품이 있는지 여부
-------------------------------------
function ServerData_SpotSale:hasSpotSaleItem()
    local spot_slae_id, endtime = self:getSpotSaleInfo_activeProduct()

    if spot_slae_id then
        return true
    else
        return false
    end
end

-------------------------------------
-- function request_startSpotSale
-- @brief 깜짝 세일 상품 발동
-- @param id table_spot_sale에서 key값
-------------------------------------
function ServerData_SpotSale:request_startSpotSale(id, finish_cb)
	local func_request
	local fail_cb
	local response_status_cb
	local success_cb
    local finish_cb = finish_cb or function() end

	 -- 네트워크 통신
	func_request = function()
        local uid = g_userData:get('uid')

		local ui_network = UI_Network()
		ui_network:setUrl('/shop/spot_sale')
		ui_network:setParam('uid', uid)
		ui_network:setParam('id', id)
		ui_network:setMethod('POST')
		ui_network:setSuccessCB(success_cb)
		ui_network:setFailCB(fail_cb)
		ui_network:setResponseStatusCB(response_status_cb)
		ui_network:setRevocable(false)
		ui_network:setReuse(false)
		ui_network:request()
	end

    -- 통신 성공 콜백
	success_cb = function(ret)
		self:applySpotSaleInfo(ret['spot_sale'])
		finish_cb()
    end

	-- 통신 실패 콜백
	fail_cb = function(ret)
        -- 깜짝 할인 상품 통신은 오류가 발생해도 유저에게 아무런 표시를 하지 않음
		finish_cb()
	end

	-- 통신 에러 리턴 콜백 (true를 리턴하면 자체적으로 처리를 완료했다는 뜻)
    response_status_cb = function(ret)
        -- 깜짝 할인 상품 통신은 오류가 발생해도 유저에게 아무런 표시를 하지 않음
        finish_cb()
        return true
    end

	func_request()
end

-------------------------------------
-- function log
-- @brief 개발 용도 로그 함수
-------------------------------------
function ServerData_SpotSale:log(data)
    if (not self.m_bDebugLog) then
        return
    end

    local data_type = type(data)
    if (data_type == 'string') then
        cclog(data)
    elseif (data_type == 'number') then
        cclog(tostring(data))
    elseif (data_type == 'table') then
        ccdump(data)
    else
        ccdump(tostring(data))
    end
end

-------------------------------------
-- function getSpotSaleInfo_EndOfSaleTime
-- @brief 판매 종료 시간
-------------------------------------
function ServerData_SpotSale:getSpotSaleInfo_EndOfSaleTime(spot_sale_id)
    local spot_sale_id = tostring(spot_sale_id)
    local spot_sale_info = self:getSpotSaleInfo()

    if (not spot_sale_info['active_list']) then
        return 0
    end

    return (spot_sale_info['active_list'][spot_sale_id] or 0)
end


-------------------------------------
-- function checkSpotSale
-- @brief
-------------------------------------
function ServerData_SpotSale:checkSpotSale(item_type, item_value, finish_cb)
    local item_id = TableItem:getItemIDFromItemType(item_type)

    -- 깜짝 할인 상품 리스트 확인 후 없으면 skip
	local lack_item_id = g_spotSaleData:getSpotSaleLackItemID(item_id)
    if (not lack_item_id) then
        return false
    end

    local func_request
    local func_finish_cb
    local func_simple_popup
    local func_spot_sale_popup

    -- 서버에 깜짝 상품 판매 시작 요청
    func_request = function()
        g_spotSaleData:request_startSpotSale(lack_item_id, func_finish_cb)
    end

    -- 서버 통신 response
    func_finish_cb = function()
        -- 깜짝 상품이 있는 경우
        if g_spotSaleData:hasSpotSaleItem() then
            func_simple_popup(item_type)

        -- 깜짝 상품이 없는 경우
        else
            if (item_type == 'st') then
                -- @ kwkang 날개 상품의 경우 날개 충전 팝업이 먼저 뜨는 것으로 변경
                -- MakeSimplePopup(POPUP_TYPE.YES_NO, Str('날개가 부족합니다.\n상점으로 이동하시겠습니까?'), function() g_shopData:openShopPopup('st', finish_cb) end)
            else
                ConfirmPrice_original(item_type, item_value)
            end
        end
    end

    -- 재화가 부족하다는 것을 유저에게 알림
    func_simple_popup = function(item_type)

        local msg = ''
        if (item_type == 'cash') then
            msg = Str('다이아몬드가 부족합니다.')
        elseif (item_type == 'gold') then
            msg = Str('골드가 부족합니다.')
        elseif (item_type == 'st') then
            --msg = Str('날개가 부족합니다.')
            func_spot_sale_popup()
            return
        end

        MakeSimplePopup(POPUP_TYPE.OK, msg, func_spot_sale_popup)
    end

    -- 깜작 할인 상품 팝업 띄움
    func_spot_sale_popup = function()
        UI_Package_SpotSale(lack_item_id)
    end

    func_request()

    return true
end