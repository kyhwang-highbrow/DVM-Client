-------------------------------------
--- @class ServerData_Research
-------------------------------------
ServerData_Research = class({
    m_serverData = 'ServerData',
    m_lastResearchIdList = 'List<number>',
    m_availableResearchIdList = 'List<number>',
})

-------------------------------------
--- @function init
-------------------------------------
function ServerData_Research:init(server_data)
    self.m_serverData = server_data
    self.m_lastResearchIdList = {}
    self.m_availableResearchIdList = {}
end

-------------------------------------
--- @function getResearchStats
-------------------------------------
function ServerData_Research:getResearchStats()
    return self.m_lastResearchIdList
end

-------------------------------------
--- @function getResearchStatsString
-------------------------------------
function ServerData_Research:getResearchStatsStringData()
    local str = ''
    local list = {}
    for _, research_id in ipairs(self.m_lastResearchIdList) do
        local id = math_floor(research_id/10000)
        if id > 0 then            
            table.insert(list, research_id)
        end
    end

    if #list == 0 then
        return ''
    end

    return table.concat(list, ',')
end

-------------------------------------
--- @function getLastResearchId
-------------------------------------
function ServerData_Research:getLastResearchId(type)
    return self.m_lastResearchIdList[type] or (type * 10000)
end

-------------------------------------
--- @function getUserRearchItem
--- @return number
-------------------------------------
function ServerData_Research:getUserRearchItem(item_id)
    return g_userData:get('research_item', tostring(item_id)) or 0
end

-------------------------------------
--- @function getUserRearchItemSum
--- @return number
-------------------------------------
function ServerData_Research:getUserRearchItemSum()
    local item_id_list = {705091}
    local sum = 0

    for _, item_id in ipairs(item_id_list) do
        sum = sum + self:getUserRearchItem(item_id)
    end
    
    return 0
end

-------------------------------------
--- @function getAvailableResearchIdList
--- @return list, map
-------------------------------------
function ServerData_Research:getAvailableResearchIdList(_last_research_id, type)
    local begin_research_id = self:getLastResearchId(type)
    local all_list = TableResearch:getInstance():getIdListByType(type)
    local last_research_id = _last_research_id or all_list[#all_list]
    local result_list = {}
    local cost_sum_map = {}

    for research_id = begin_research_id + 1, last_research_id do
        local cost = TableResearch:getInstance():getResearchCost(research_id)        
        local cost_item_id = TableResearch:getInstance():getResearchCostItemId(research_id)
        local user_item_count = self:getUserRearchItem(cost_item_id)

        if cost_sum_map[cost_item_id] == nil then
            cost_sum_map[cost_item_id] = 0
        end

        local cost_sum = cost_sum_map[cost_item_id] + cost
        if user_item_count >= cost_sum then
            table.insert(result_list, research_id)
            cost_sum_map[cost_item_id] = cost_sum
        else
            break
        end
    end

    return result_list, cost_sum_map
end

-------------------------------------
--- @function calcAvailableLastResearchId
--- @brief 사용 가능한 researchId 계산
-------------------------------------
function ServerData_Research:calcAvailableLastResearchId(research_type)
    local id_list, cost_map = self:getAvailableResearchIdList(nil, research_type)
    local last_available_research_id = id_list[#id_list]

    local t_data = {['last_id'] = last_available_research_id, ['cost'] = self:getUserRearchItemSum()}
    self.m_availableResearchIdList[research_type] = t_data
end

-------------------------------------
--- @function isAvailableResearchId
--- @return boolean 현재 보유한 비용으로 사용이 가능한지?
-------------------------------------
function ServerData_Research:isAvailableResearchId(research_id)
    local research_type = TableResearch:getInstance():getResearchType(research_id)
    local t_data = self.m_availableResearchIdList[research_type]

    if t_data == nil or t_data['cost'] ~= self:getUserRearchItemSum() then
        self:calcAvailableLastResearchId(research_type)
        t_data = self.m_availableResearchIdList[research_type]
    end

    local available_research_id = t_data['last_id']
    return available_research_id > research_id
end

-------------------------------------
--- @function getResearchCostSumMap
--- @return map
-------------------------------------
function ServerData_Research:getResearchCostSumMap(begin_research_id, last_research_id)
    local cost_sum_map = {}
    for research_id = begin_research_id, last_research_id do
        local cost = TableResearch:getInstance():getResearchCost(research_id)
        local cost_item_id = TableResearch:getInstance():getResearchCostItemId(research_id)
        if cost_sum_map[cost_item_id] == nil then
            cost_sum_map[cost_item_id] = 0
        end
        cost_sum_map[cost_item_id] = cost_sum_map[cost_item_id] + cost
    end
    return cost_sum_map
end

-------------------------------------
--- @function getMyResearchAbilityMap
--- @return table 현재 보유한 능력치 맵
-------------------------------------
function ServerData_Research:getMyResearchAbilityMap()
    local list = TableResearch:getInstance():getAccumulatedBuffList(self.m_lastResearchIdList)
    return list
end

-------------------------------------
--- @function response_researchInfo
-------------------------------------
function ServerData_Research:response_researchInfo(ret)
    if ret['research'] ~= nil then
        local t_research = ret['research']['r']
        if t_research ~= nil then
            for idx = 1,2 do
                self.m_lastResearchIdList[idx] = t_research[tostring(idx)] or idx*10000
            end
        end
    end
end

-------------------------------------
--- @function request_researchInfo
--- @brief 정보 요청
-------------------------------------
function ServerData_Research:request_researchInfo(finish_cb, fail_cb)
    local uid = g_userData:get('uid')    

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        self:response_researchInfo(ret)        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/research/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end

-------------------------------------
--- @function request_researchUpgrade
--- @brief 연구하기
-------------------------------------
function ServerData_Research:request_researchUpgrade(research_id, price, finish_cb, fail_cb)
    local uid = g_userData:get('uid')    

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        self:response_researchInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/research/buy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('id', research_id)
    ui_network:setParam('price', price)

    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end

-------------------------------------
--- @function request_researchReset
--- @brief 리셋
-------------------------------------
function ServerData_Research:request_researchReset(finish_cb, fail_cb)
    local uid = g_userData:get('uid')    

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        self.m_lastResearchIdList = {}
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/research/reset')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end
