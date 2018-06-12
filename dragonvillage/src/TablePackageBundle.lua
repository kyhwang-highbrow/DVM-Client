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

        for _i, _v in ipairs(l_str) do
            local target_pid = l_str[_i]

            -- 우선 순위는 table_shop_list에서 가져옴
            local struct_product = l_item_list[tonumber(target_pid)]
            if (struct_product) then

                ----------------------------------------------------------------------------------
                -- @sgkim 2018-05-29
                -- 단계별 패키지가 2개 이상 동시에 판매되면서 우선 순위 확인
                if (v['t_name'] == 'package_step') or (v['t_name'] == 'package_step_02') then
                    local valid_step_package = g_shopDataNew:getValidStepPackage()

                    -- 현재 유효한 상품이 아닐 경우 맵에 추가하지 않음
                    if (valid_step_package ~= v['t_name']) then
                        --break -- 이 라인을 주석처리하면 두 패키지가 모두 노출됨
                    end
                end                
                ----------------------------------------------------------------------------------

                map[tostring(target_pid)] = struct_product
                break
            end
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
-- function getPackageDescWithPid
-------------------------------------
function TablePackageBundle:getPackageDescWithPid(pid)
    if (self == THIS) then
        self = THIS()
    end

    for _, v in pairs(self.m_orgTable) do
        local t_pids = v['t_pids']
        if (string.find(t_pids, tostring(pid))) then
            return Str(v['t_desc'])
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
