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
    self.m_tableName = 'package_bundle'
    self.m_orgTable = TABLE:get(self.m_tableName)
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

