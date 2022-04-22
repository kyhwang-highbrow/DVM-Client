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

-- function TableP:getEtcTableViewMap()
--     local map = {}

--     local item_list = g_shopData:getProductList('etc')
--     for i, v in ipairs(self.m_orgTable) do
--     end
-- end

-------------------------------------
-- function getTableViewMap
-- @brief 패키지 번들 테이블에 등록되있고 서버에서 상품 정보를 주는 것들만 테이블뷰 맵형태로 반환
-------------------------------------
function TablePackageBundle:getTableViewMap()
    local map = {}
    local l_item_list = g_shopData:getProductList('package')
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
                    local valid_step_package = g_shopData:getValidStepPackage()

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
-- function getPidsWithName
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
-- function getPids
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

-------------------------------------
-- function isSelectOnePackage
-------------------------------------
function TablePackageBundle:isSelectOnePackage(package_name)
    if (self == THIS) then
        self = THIS()
    end

    for _, v in pairs(self.m_orgTable) do        
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
    if (self == THIS) then
        self = THIS()
    end

	if (not user_lv) then
		return false
	end

    for _, v in pairs(self.m_orgTable) do        
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