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
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_SpotSale:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getSortedSpotSaleList
-- @brief priority값이 낮은 순서로 정렬된 table_spot_sale
-------------------------------------
function ServerData_SpotSale:getSortedSpotSaleList()

    -- 없으면 생성
    if (not self.m_sortedSpotSaleList) then
        local table_spot_sale = TABLE:get('table_spot_sale')

        -- 정렬을 위해 list형태로 변환
        local l_spot_sale = table.MapToList(table_spot_sale)

        -- priority가 낮은 순서로 정렬
	    function sortByPriority(a, b)
		    return a['priority'] < b['priority']
	    end
	    table.sort(l_spot_sale, sortByPriority)
	    self.m_sortedSpotSaleList = l_spot_sale
    end

    return self.m_sortedSpotSaleList
end

-------------------------------------
-- function showSpotSale
-------------------------------------
function ServerData_SpotSale:showSpotSale(id, finish_cb)
	MakeSimplePopup(POPUP_TYPE.OK, '깜짝 상품 세일' .. tostring(id), finish_cb, finish_cb)
end

-------------------------------------
-- function getSpotSaleLackItemID
-- @brief 부족한 상품 체크/ 부족한 상품 없으면 nil 반환
-- @return table_spot_sale테이블의 id 값 (spot_sale_id)
-------------------------------------
function ServerData_SpotSale:getSpotSaleLackItemID()

	-- 1. 글로벌 쿨타임(global_cool_down) 확인
	if (not self:getGlobalCoolTimeDone()) then
		return nil
	end 

    -- priority값이 낮은 순서로 정렬된 table_spot_sale
    local sorted_spot_sale_lsit = self:getSortedSpotSaleList()

	for _,v in ipairs(sorted_spot_sale_lsit) do
        local spot_sale_id = v['id']
        if (self:checkCondition(spot_sale_id)) then
			return spot_sale_id
		end
	end

	return nil
end

-------------------------------------
-- function checkCondition
-- @brief 개별 상품에 대한 조건 검사
-------------------------------------
function ServerData_SpotSale:checkCondition(id)

    local table_spot_sale = TABLE:get('table_spot_sale')
    if (not table_spot_sale) then
        return false
    end

    local t_spot_sale = table_spot_sale[id]
    if (not t_spot_sale) then
        return false
    end

    do-- 1. 개별 쿨타임(cooldown) 확인
        local cool_down = self:getSpotSaleInfo_coolDown(id)
        local curr_time = Timer:getServerTime()

        if (curr_time < cool_down) then
            return false
        end
    end

    do-- 2. 레벨(user_lv) 제한 확인
        local lv = g_userData:get('lv') -- 유저 레벨
        local require_lv = t_spot_sale['user_lv']
        
        if (lv < require_lv) then
            return false
        end
    end

    do-- 3. 수량(condition) 확인
        local condition = t_spot_sale['condition']
        local item_id = t_spot_sale['item']

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
    local curr_time = Timer:getServerTime()

    return (global_cool_down <= curr_time)
end

-------------------------------------
-- function applySpotSaleInfo
-- @brief 로비 통신에서 받아오는 SpotSale 정보 적용
-------------------------------------
function ServerData_SpotSale:applySpotSaleInfo(t_spot_sale)
	self.m_spotSaleInfo = t_spot_sale
end

-------------------------------------
-- function getSpotSaleInfo_activeProduct
-- @brief 
-------------------------------------
function ServerData_SpotSale:getSpotSaleInfo_activeProduct()
	for i,v in pairs(self.m_spotSaleInfo['active_list']) do
		if (i) then
			return i, v
		end
	end
end

-------------------------------------
-- function request_startSpotSale
-- @brief 깜짝 세일 상품 발동
-------------------------------------
function ServerData_SpotSale:request_startSpotSale(id, succ_cb)
    
	local func_request
	local fail_cb
	local response_status_cb
	local success_cb
	local uid = g_userData:get('uid')

	 -- 네트워크 통신
	func_request = function()
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

	success_cb = function(ret)
		self:applySpotSaleInfo(ret)
		succ_cb()
    end

	-- 통신 실패 콜백
	fail_cb = function(ret)
		succ_cb()
	end

	-- 통신 에러 리턴 콜백 (true를 리턴하면 자체적으로 처리를 완료했다는 뜻)
    response_status_cb = function(ret)
        if (ret['status'] == -1108) then
            return true
        end

        return false
    end

	func_request()
end