local PARENT = TableClass

-------------------------------------
-- class TablePackageBundle
-------------------------------------
TablePackageBundle = class(PARENT, {
    m_namePackageBundleMap = 'map',
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TablePackageBundle:init()
    -- 여기 2번 이상 들어오면 안된다.
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_package_bundle'
    self.m_orgTable = TABLE:get(self.m_tableName)
    self.m_namePackageBundleMap = {}

    for _, v in pairs(self.m_orgTable) do        
        self.m_namePackageBundleMap[v['t_name']] = v
    end
end

-------------------------------------
-- function getInstance
-------------------------------------
function TablePackageBundle:getInstance()
    if (instance == nil) then
        instance = TablePackageBundle()
    end
    return instance
end

-------------------------------------
-- function getTableViewMap
-- @brief 패키지 번들 테이블에 등록되있고 서버에서 상품 정보를 주는 것들만 테이블뷰 맵형태로 반환
-------------------------------------
function TablePackageBundle:getTableViewMap()
    local map = {}
    local tb_instance = TablePackageBundle:getInstance()

    local l_item_list = g_shopDataNew:getProductList('package')
    for i, v in ipairs(tb_instance.m_orgTable) do

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
                        break -- 이 라인을 주석처리하면 두 패키지가 모두 노출됨
                    end
                end                
                ----------------------------------------------------------------------------------

                map[tostring(target_pid)] = struct_product
        
                -- 레벨 제한
                if (v['buyable_from_lv'] ~= '') or (v['buyable_to_lv'] ~= '') then
                    local user_lv = g_userData:get('lv')
                    local from_lv = v['buyable_from_lv'] ~= '' and v['buyable_from_lv'] or 1
                    local to_lv = v['buyable_to_lv'] ~= '' and v['buyable_to_lv'] or 100

                    -- from_lv ~ to_lv 사이에 있는지 체크 없다면 삭제
                    if (from_lv <= user_lv) and (user_lv <= to_lv) then
                    else
                        map[tostring(target_pid)] = nil
                    end
                end

                -- 컨텐츠 해금 제한
                if (v['buyable_unlock_content'] ~= '') then
                    local content_name = v['buyable_unlock_content']
                    local is_lock = g_contentLockData:isContentLock(content_name)

                    if (is_lock) then
                        map[tostring(target_pid)] = nil
                    end

                end

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
    local tb_instance = TablePackageBundle:getInstance()

    local val = tb_instance.m_namePackageBundleMap[package_name]
    if val ~= nil then
        return val
    end

--[[     for _, v in pairs(tb_instance.m_orgTable) do        
        if (v['t_name'] == package_name) then
            return v
        end
    end ]]

    return nil
end

-------------------------------------
-- function checkBundleWithName
-- @brief 등록된 패키지인지 
-------------------------------------
function TablePackageBundle:checkBundleWithName(package_name)
    local tb_instance = TablePackageBundle:getInstance()

    local val = tb_instance.m_namePackageBundleMap[package_name]
    if val ~= nil then
        return true
    end

--[[     for _, v in pairs(self.m_orgTable) do        
        if (v['t_name'] == package_name) then
            return true
        end
    end ]]

    return false
end

-------------------------------------
-- function getPackageNameWithPid
-------------------------------------
function TablePackageBundle:getPackageNameWithPid(pid)
    local tb_instance = TablePackageBundle:getInstance()

    for _, v in pairs(tb_instance.m_orgTable) do
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
    local tb_instance = TablePackageBundle:getInstance()

    for _, v in pairs(tb_instance.m_orgTable) do
        local t_pids = v['t_pids']
        if (string.find(t_pids, tostring(pid))) then
            return Str(v['t_desc'])
        end
    end

    return nil
end

-------------------------------------
-- function getPidsWithName
-------------------------------------
function TablePackageBundle:getPidsWithName(package_name)
    local tb_instance = TablePackageBundle:getInstance()

    for _, v in pairs(tb_instance.m_orgTable) do
        if (v['t_name'] == package_name) then
            local t_pids = tostring(v['t_pids'])
            local l_str = pl.stringx.split(t_pids, ',')
            return l_str
        end
    end

    return {}
end

-------------------------------------
-- function getPids
-------------------------------------
function TablePackageBundle:getPids(pid)
    local tb_instance = TablePackageBundle:getInstance()

    for _, v in pairs(tb_instance.m_orgTable) do
        local t_pids = v['t_pids']
        if (string.find(t_pids, tostring(pid))) then
            return t_pids
        end
    end

    return nil
end

-------------------------------------
-- function getPidsAsList
-------------------------------------
function TablePackageBundle:getPidsAsList(pid)
    local tb_instance = TablePackageBundle:getInstance()
    local result = {}
    local t_pids = tb_instance:getPids(pid)
    if (t_pids ~= nil) and (t_pids ~= '') then
        local pid_str_list = pl.stringx.split(t_pids, ',')
        for index, pid_str in ipairs(pid_str_list) do
            local pid = tonumber(pid_str)
            table.insert(result, pid)
        end
    end

    return result
end

-------------------------------------
-- function getPidsNum
-------------------------------------
function TablePackageBundle:getPidsNum(pid)
    local tb_instance = TablePackageBundle:getInstance()
    local list = tb_instance:getPidsAsList(pid)
    return table.count(list)
end

-------------------------------------
-- function getPidsIndex
-------------------------------------
function TablePackageBundle:getPidsIndex(pid)
    local tb_instance = TablePackageBundle:getInstance()
    local list = tb_instance:getPidsAsList(pid)

    for index, product_id in ipairs(list) do
        if (product_id == pid) then
            return index
        end
    end

    return nil
end

-------------------------------------
-- function isSelectOnePackage
-------------------------------------
function TablePackageBundle:isSelectOnePackage(package_name)
    local tb_instance = TablePackageBundle:getInstance()

    for _, v in pairs(tb_instance.m_orgTable) do        
        if (v['t_name'] == package_name) then
            return (v['select_one'] == 1)
        end
    end

    return false
end

-------------------------------------
-- function isBuyableLv
-------------------------------------
function TablePackageBundle:isBuyableLv(package_name, user_lv)
    local tb_instance = TablePackageBundle:getInstance()

	if (not user_lv) then
		return false
	end

    for _, v in pairs(tb_instance.m_orgTable) do        
        if (v['t_name'] == package_name) then
            -- 레벨 제한
            if (v['buyable_from_lv'] ~= '') or (v['buyable_to_lv'] ~= '') then
                local from_lv = v['buyable_from_lv'] ~= '' and v['buyable_from_lv'] or 1
                local to_lv = v['buyable_to_lv'] ~= '' and v['buyable_to_lv'] or 100

                -- from_lv ~ to_lv 사이에 있는지
                return (from_lv <= user_lv) and (user_lv <= to_lv)

			-- 레벨 제한 명시 하지 않은 경우
			else
				return true
            end
        end
    end

    return false
end

-------------------------------------
-- function getBundleValueByPackageName
-------------------------------------
function TablePackageBundle:getBundleValueByPackageName(name, key)
    local tb_instance = TablePackageBundle:getInstance()
    local val = tb_instance.m_namePackageBundleMap[name]
    if val == nil then
        return nil
    end

    return val[key]
end