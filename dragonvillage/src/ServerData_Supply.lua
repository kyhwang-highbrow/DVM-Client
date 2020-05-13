-------------------------------------
-- class ServerData_Supply
-- @instance g_supply
-- @brief 보급소(정액제)
-------------------------------------
ServerData_Supply = class({
        m_serverData = 'ServerData',
        m_tSupplyList = 'list',
        m_tSupplyMap = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Supply:init(server_data)
    self.m_serverData = server_data
    self.m_tSupplyList = {}
    self.m_tSupplyMap = {}
end

-------------------------------------
-- function applySupplyList_fromRet
-- @brief
-- @used_at
-------------------------------------
function ServerData_Supply:applySupplyList_fromRet(ret)
    if (ret == nil) then
        return
    end

    if (ret['supply_list'] == nil) then
        return
    end

    self:applySupplyList(ret['supply_list'])
end

-------------------------------------
-- function applySupplyList
-- @brief
-------------------------------------
function ServerData_Supply:applySupplyList(l_data)
    self.m_tSupplyList = l_data
    self.m_tSupplyMap = {}

    for i,v in pairs(self.m_tSupplyList) do
        local supply_type = v['type']
        if supply_type then
            self.m_tSupplyMap[supply_type] = v
        end
    end
end

-------------------------------------
-- function getSupplyInfoByType
-- @brief
-- @param supply_type string
-------------------------------------
function ServerData_Supply:getSupplyInfoByType(supply_type)
    if (self.m_tSupplyMap == nil) then
        return nil
    end

    return self.m_tSupplyMap[supply_type]
end