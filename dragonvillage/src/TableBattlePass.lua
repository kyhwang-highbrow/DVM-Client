local PARENT = TableClass

-------------------------------------
-- class TableBattlePass
-------------------------------------
TableBattlePass = class(PARENT, {
    })

local THIS = TableBattlePass

-------------------------------------
-- function init
-------------------------------------
function TableBattlePass:init()
    self.m_tableName = 'table_battle_pass'
    self.m_orgTable = TABLE:get(self.m_tableName)
end


-------------------------------------
-- function getTableViewMap
-- @brief 패키지 번들 테이블에 등록되있고 서버에서 상품 정보를 주는 것들만 테이블뷰 맵형태로 반환
-------------------------------------
function TableBattlePass:getTableViewMap()
    local map = {}
    local l_item_list = g_shopDataNew:getProductList('pass')

    for i, v in ipairs(self.m_orgTable) do
        
    end

    return map
end