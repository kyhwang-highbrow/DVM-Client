-------------------------------------
-- class ServerData_Shop
-------------------------------------
ServerData_Shop = class({
        m_serverData = 'ServerData',
        m_dicProduct = '[tab_category][struct_product]',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Shop:init(server_data)
    self.m_serverData = server_data

    self.m_dicProduct = {}
    self.m_dicProduct['money'] = {}
    self.m_dicProduct['cash'] = {}
    self.m_dicProduct['amethyst'] = {}
    self.m_dicProduct['topaz'] = {}
    self.m_dicProduct['mileage'] = {}
    self.m_dicProduct['honor'] = {}
    self.m_dicProduct['capsule'] = {}
end

-------------------------------------
-- function localTableTest
-------------------------------------
function ServerData_Shop:localTableTest()
    
    local table_shop_cash = TABLE:loadCSVTable('table_shop_cash', nil, 'product_id')
    local table_shop_basic = TABLE:loadCSVTable('table_shop_basic', nil, 'product_id')
    local table_shop_list = TABLE:loadCSVTable('table_shop_list', nil, 'list_id')
    
    local date_format = 'yyyy-mm-dd HH:MM:SS'
    local parser = pl.Date.Format(date_format)
    
    local date_str = '2017-06-23 00:00:00'


    local date = parser:parse(date_str)
    --ccdump(date)

    --local 
    for i,v in pairs(table_shop_list) do
        --v['start_date'] = '2017-06-01 00:00:00'
        --v['end_date'] = '2017-06-27 00:00:00'

        local start_date = parser:parse(v['start_date'])
        local end_date = parser:parse(v['end_date'])

        local active = false

        -- 시작 시간이 없거나 시작 시간 이후이면 true
        if (not start_date) or (start_date < date) then
            active = true
        end

        -- 시작 조건을 충족한 상태
        if active then
            -- 종료 시간이 명시되어있고 현재 시간이 종료시간보다 이전일 경우
            if end_date and (end_date < date) then
                active = false
            end
        end

        if active then
            --cclog(v['list_id'])

            local tab_category = v['tab_category']
            local product_id = v['product_id']
            local dependency = v['dependency']
            local ui_priority = v['ui_priority'] and tonumber(v['ui_priority'])
            if (not ui_priority) then
                ui_priority = 0
            end
            local t_product = nil

            if (tab_category == 'money') then
                t_product = table_shop_cash[product_id]
            else
                t_product = table_shop_basic[product_id]
            end

            local struct_product = StructProduct(t_product)
            struct_product:setTabCategory(tab_category)
            struct_product:setStartDate(start_date)
            struct_product:setEndDate(end_date)
            struct_product:setDependency(dependency)
            struct_product:setUIPriority(ui_priority)
            self:insertProduct(struct_product)
        end
    end

    for i,v in pairs(self.m_dicProduct) do
        cclog(i, table.count(v))
    end
end

-------------------------------------
-- function clearProduct
-------------------------------------
function ServerData_Shop:clearProduct()
    for i,_ in pairs(self.m_dicProduct) do
        self.m_dicProduct[i] = {}
    end
end

-------------------------------------
-- function insertProduct
-------------------------------------
function ServerData_Shop:insertProduct(struct_product)
    local tab_category = struct_product:getTabCategory()
    table.insert(self.m_dicProduct[tab_category], struct_product)
end


-------------------------------------
-- function getProductList
-------------------------------------
function ServerData_Shop:getProductList(tab_category)
    local l_product = self.m_dicProduct[tab_category]

    if (not l_product) then
        return {}
    end

    -- 리스트를 맵 형태로 변환 (key가 product_id가 되도록)
    local product_map = {}
    for i,v in pairs(l_product) do
        local product_id = v['product_id']
        product_map[product_id] = v
    end

    -- 의존성 검사
    local l_remove_product_id = {}
    for i,v in pairs(product_map) do

        -- 상품의 의존관계 체크
        local dependency = v:getDependency()
        if dependency then

            -- 해당 상품이 구매가 가능한 상태면 의존 상품을 제거
            if v:isItBuyable() then
                table.insert(l_remove_product_id, dependency)
            -- 그렇지 않을 경우 해당 상품 제거
            else
                table.insert(l_remove_product_id, v['product_id'])
            end
        end
    end

    -- 의존성에 의해 노출되지 말아야 하는 상품 제거
    while l_remove_product_id[1] do
        local product_id = l_remove_product_id[1]
        product_map[product_id] = nil
        table.remove(l_remove_product_id, 1)
    end

    return product_map
end