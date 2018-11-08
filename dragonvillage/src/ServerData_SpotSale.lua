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
			return v['id']
		end
	end

	return nil
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