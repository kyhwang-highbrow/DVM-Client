-------------------------------------
-- class ServerData_SpotSale
-- @brief 깜짝 할인 상품
-- @instance g_spotSaleData
-- https://perplelab.atlassian.net/wiki/x/O4B9Lg
-------------------------------------
ServerData_SpotSale = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_SpotSale:init(server_data)
    self.m_serverData = server_data
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