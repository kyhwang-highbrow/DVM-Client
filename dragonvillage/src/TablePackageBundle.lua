local PARENT = TableClass

-------------------------------------
-- class TablePackageBundle
-------------------------------------
TablePackageBundle = class(PARENT, {
    })

local THIS = TablePackageBundle

-------------------------------------
-- function init
-------------------------------------
function TablePackageBundle:init()
    self.m_tableName = 'table_package_bundle'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getTableViewMap
-- @brief 패키지 번들 테이블에 등록되있고 서버에서 상품 정보를 주는 것들만 테이블뷰 맵형태로 반환
-------------------------------------
function TablePackageBundle:getTableViewMap()
    local map = {}
    local l_item_list = g_shopDataNew:getProductList('package')
    for i, v in ipairs(self.m_orgTable) do

        local t_pids = v['t_pids']
        local l_str = pl.stringx.split(t_pids, ',')
        local target_pid = l_str[1]

        -- 우선 순위는 table_shop_list에서 가져옴
        local struct_product = l_item_list[tonumber(target_pid)]
        if (struct_product) then
            map[tostring(target_pid)] = struct_product
        end
    end

    return map
end

-------------------------------------
-- function getDataWithName
-------------------------------------
function TablePackageBundle:getDataWithName(package_name)
    if (self == THIS) then
        self = THIS()
    end

    for _, v in pairs(self.m_orgTable) do        
        if (v['t_name'] == package_name) then
            return v
        end
    end

    return nil
end

-------------------------------------
-- function checkBundleWithName
-- @brief 등록된 패키지인지 
-------------------------------------
function TablePackageBundle:checkBundleWithName(package_name)
    if (self == THIS) then
        self = THIS()
    end

    for _, v in pairs(self.m_orgTable) do        
        if (v['t_name'] == package_name) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function getPackageNameWithPid
-------------------------------------
function TablePackageBundle:getPackageNameWithPid(pid)
    if (self == THIS) then
        self = THIS()
    end

    for _, v in pairs(self.m_orgTable) do
        local t_pids = v['t_pids']
        if (string.find(t_pids, tostring(pid))) then
            return v['t_name']
        end
    end

    return nil
end

-------------------------------------
-- function getPids
-------------------------------------
function TablePackageBundle:getPidsWithName(package_name)
    if (self == THIS) then
        self = THIS()
    end

    for _, v in pairs(self.m_orgTable) do
        if (v['t_name'] == package_name) then
            local t_pids = tostring(v['t_pids'])
            local l_str = pl.stringx.split(t_pids, ',')
            return l_str
        end
    end

    return {}
end

-------------------------------------
-- function getPackageNameWithPid
-------------------------------------
function TablePackageBundle:getPids(pid)
    if (self == THIS) then
        self = THIS()
    end

    for _, v in pairs(self.m_orgTable) do
        local t_pids = v['t_pids']
        if (string.find(t_pids, tostring(pid))) then
            return t_pids
        end
    end

    return nil
end
