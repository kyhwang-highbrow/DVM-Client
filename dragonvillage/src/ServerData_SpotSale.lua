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
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_SpotSale:init(server_data)
    self.m_serverData = server_data
	self.m_spotSaleTable = TABLE:get('table_spot_sale')
end

-------------------------------------
-- function setSpotSaleTable
-- @brief 서버csv테이블 세팅 / priority 기준으로 정렬
-------------------------------------
function ServerData_SpotSale:setSpotSaleTable()
    self.m_spotSaleTable = TABLE:get('table_spot_sale')
	self:sortByPriority()
end

-------------------------------------
-- function showSpotSale
-------------------------------------
function ServerData_SpotSale:showSpotSale(finish_cb)
	MakeSimplePopup(POPUP_TYPE.OK, '깜짝 상품 세일', finish_cb)
end

-------------------------------------
-- function checkLackItem
-- @brief 부족한 상품 체크
-------------------------------------
function ServerData_SpotSale:checkLackItem()
    
	return true
	
end

-------------------------------------
-- function sortByPriority
-------------------------------------
function ServerData_SpotSale:sortByPriority()
	local l_spot_sale = table.MapToList(self.m_spotSaleTable)
	
	function sortByPriority(a, b)
		return a['priority'] < b['priority']
	end
	-- priority 기준으로 정렬
	table.sort(l_spot_sale, sortByPriority)

	self.m_spotSaleTable = table.listToMap(l_spot_sale, 'id')
end

-------------------------------------
-- function applySpotSaleInfo
-- @brief 로비 통신에서 받아오는 SpotSale 정보 적용
-------------------------------------
function ServerData_SpotSale:applySpotSaleInfo(t_spot_sale)
	self.m_spotSaleInfo = t_spot_sale
end