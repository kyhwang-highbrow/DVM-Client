-------------------------------------
-- class ServerData_SpotSale
-- @brief 깜짝 할인 상품
-- @instance g_spotSaleData
-- https://perplelab.atlassian.net/wiki/x/O4B9Lg
-------------------------------------
ServerData_SpotSale = class({
        m_serverData = 'ServerData',
		m_spotSaleInfo = 'table',
		m_spotSaleTable = 'table',
		m_spotSaleList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_SpotSale:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function setSpotSale
-- @brief 서버csv테이블 세팅/list 정렬
-------------------------------------
function ServerData_SpotSale:setSpotSale()
    self.m_spotSaleTable = TABLE:get('table_spot_sale')
	self.m_spotSaleList = ServerData_SpotSale:sortByPriority(self.m_spotSaleTable)
end

-------------------------------------
-- function showSpotSale
-------------------------------------
function ServerData_SpotSale:showSpotSale(id, finish_cb)
	MakeSimplePopup(POPUP_TYPE.OK, '깜짝 상품 세일', finish_cb, finish_cb)
end

-------------------------------------
-- function checkLackItem
-- @brief 부족한 상품 체크/ 부족한 상품 없으면 nil 반환
-------------------------------------
function ServerData_SpotSale:getLackItem()
    if (nil == self.m_spotSaleTable) then
		self:setSpotSale()
	end
	-- 글로벌 쿨타임 확인
	if (self:getGlobalCoolTimeDone()) then
		return nil
	end 

	for _,v in ipairs(self.m_spotSaleList) do
		local item_id = v['item']
		local item_type = TableItem:getItemType(item_id)
		
		local curr_cnt = g_userData:get(item_type)
		
		-- 날개는 예외처리
		if (not curr_cnt) then
			curr_cnt = g_staminasData:getStaminaCount('st')
		end
		
		-- 현재 아이템 갯수가 조건보다 적다면 
		if (curr_cnt < v['condition']) then
			local lack_id = v['id']
			if (self:checkCondition(lack_id)) then
				return lack_id
			end
		end
	end

	return nil
end

-------------------------------------
-- function checkCondition
-- @brief 개별 상품에 대한 조건 검사
-------------------------------------
function ServerData_SpotSale:checkCondition(id)
	-- 레벨 검사
	if (g_userData:get('lv') < self:getSpotSaleTable_lv(id)) then
		return false
	end
	
	-- 개별 쿨타임 종료 시간 검사
	local cool_down = self:getSpotSaleInfo_coolDown(id)
	if (cool_down) then
		-- 현재 쿨타임 종료 시간을 넘은 경우
		if(cool_down < Timer:getServerTime()) then
			return true
		else
			return false
		end		
	end

	return true
end

-------------------------------------
-- function getSpotSaleTable_lv
-- @brief 테이블에서 해당 키의 타입 값 반환
-------------------------------------
function ServerData_SpotSale:getSpotSaleTable_lv(id)
	return self.m_spotSaleTable[id]['user_lv']
end

-------------------------------------
-- function getSpotSaleInfo_coolDown
-- @brief 서버에서 받은 개별 쿨종료 시간 반환
-------------------------------------
function ServerData_SpotSale:getSpotSaleInfo_coolDown(id)
	return self.m_spotSaleInfo['cool_down_list'][id]
end

-------------------------------------
-- function sortByPriority
-------------------------------------
function ServerData_SpotSale:sortByPriority(t_spot_sale)
	local l_spot_sale = table.MapToList(t_spot_sale)
	
	function sortByPriority(a, b)
		return a['priority'] < b['priority']
	end
	-- priority 기준으로 정렬
	table.sort(l_spot_sale, sortByPriority)

	return l_spot_sale
end

-------------------------------------
-- function getGlobalCoolTimeDone
-- @brief
-------------------------------------
function ServerData_SpotSale:getGlobalCoolTimeDone()  
	 return self.m_spotSaleInfo['global_cool_down']
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