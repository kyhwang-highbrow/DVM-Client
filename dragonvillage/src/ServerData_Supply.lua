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

    if (ret['supply_list'] == false) then
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
-- @return supply_info table
-- {
--  "type":"daily_cash", // 30일 다이아 상품
--  "start":1587976361007,
--  "end":1587976361584,
--  "update":1587976361007,
--  "reward":1 // 수령 완료 상태 sample
-- }
-------------------------------------
function ServerData_Supply:getSupplyInfoByType(supply_type)
    if (self.m_tSupplyMap == nil) then
        return nil
    end

    return self.m_tSupplyMap[supply_type]
end

-------------------------------------
-- function request_supplyReward
-- @brief 보급소(정액제) 일일 보상
-- @api /users/supply/reward
-------------------------------------
function ServerData_Supply:request_supplyReward(supply_type, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
       self:applySupplyList_fromRet(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/supply/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', supply_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end