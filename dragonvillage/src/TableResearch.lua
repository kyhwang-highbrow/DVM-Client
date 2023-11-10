local PARENT = TableClass
-------------------------------------
--- @class TableResearch
-------------------------------------
TableResearch = class(PARENT, {
    m_accAbilityMap = 'Map<id, string>',
    m_buffList = 'List<string, number>'
})

local instance = nil
-------------------------------------
---@function init
-------------------------------------
function TableResearch:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_research'
    self.m_orgTable = TABLE:get(self.m_tableName)
    self:makeAccumulateBuffMap()
end

-------------------------------------
---@function getInstance
---@return TableResearch instance
-------------------------------------
function TableResearch:getInstance()
    if (instance == nil) then
        instance = TableResearch()
    end
    return instance
end

-------------------------------------
---@function makeAccumulateBuffMap
---@brief 아이디에 따른 누적 능력치 계산한 맵 만들기
-------------------------------------
function TableResearch:makeAccumulateBuffMap()
    local buff_list = {
        'atk_multi',
        'def_multi',
        'hp_multi',
        'cri_chance_add',
        'cri_dmg_add',
        'cri_avoid_add',
        'hit_rate_add',
        'avoid_add',
        'accuracy_add',
        'resistance_add',
    }

    self.m_buffList = buff_list
    self.m_accAbilityMap = {}
    for type = 1,2 do
        local id_list = self:getIdListByType(type)
        self:getBuffMapByIdList(id_list, self.m_accAbilityMap)
    end
end

-------------------------------------
---@function getBuffMapByIdList
---@brief 능력치 맵 계산
-------------------------------------
function TableResearch:getBuffMapByIdList(id_list, acc_str_map)
    local acc_map = {}
    for _, id in ipairs(id_list) do
        for _, buff in ipairs(self.m_buffList) do
            local val = self:getValue(id, buff)
            if val ~= nil and val ~= '' then
                if acc_map[buff] == nil then
                    acc_map[buff] = 0
                end
                acc_map[buff] = acc_map[buff] + tonumber(val)
            end

            if acc_str_map ~= nil then
                -- 누적 능력치를 문자열로 생성 저장
                acc_str_map[id] = self:getBuffMapToString(acc_map)
            end
        end
    end
    return acc_map
end

-------------------------------------
---@function getBuffMapToString
---@brief 버프맵을 스트링으로 변환
-------------------------------------
function TableResearch:getBuffMapToString(acc_map)
    local str = ''
    for buff_type, buff_val in pairs(acc_map) do
        local buff_str = string.format('%s:%d', buff_type,buff_val)
        if str == '' then
            str = buff_str
        else
            str = str .. ',' .. buff_str
        end
    end
    return str
end

-------------------------------------
---@function getAccumulatedBuffList
---@brief 누적 능력치 스트링을 통상적으로 사용하는 리스트로 변환하여 반환
-------------------------------------
function TableResearch:getAccumulatedBuffList(research_id_list)
    local buff_map = {}
    for _, research_id in ipairs(research_id_list) do
        local str = self.m_accAbilityMap[research_id]
        if str ~= nil then
            local buff_str_list = plSplit(str, ',')
            for _, buff_str in ipairs(buff_str_list) do
                local list = plSplit(buff_str, ':')
                if list ~= nil then
                    local buff_type = list[1]
                    local buff_value = tonumber(list[2])
                    if buff_map[buff_type] == nil then
                        buff_map[buff_type] = buff_value
                    else
                        buff_map[buff_type] = buff_map[buff_type] + buff_value
                    end
                end
            end
        end
    end
    return buff_map
end

-------------------------------------
---@function getIdListByType
---@brief 타입별 아이디 반환
-------------------------------------
function TableResearch:getIdListByType(type)
    local id_list = self:filterColumnList('type', type, 'id')
    table.sort(id_list, function(a, b) return a < b end)
    return id_list
end

-------------------------------------
---@function getResearchIconRes
---@brief 아이콘
-------------------------------------
function TableResearch:getResearchIconRes(research_id)
    for _, buff in ipairs(self.m_buffList) do
        local val = self:getValue(research_id, buff)
        if val ~= nil and val ~= '' then
            return string.format('res/ui/icons/research/%s.png', buff)
        end
    end
    return 'res/temp/DEV.png'
end


-------------------------------------
---@function getResearchCostItemId
---@brief 연구 소모 재화 아이템, 일단 아이템 아이디 고정으로 처리
-------------------------------------
function TableResearch:getResearchCostItemId(research_id)
    return 705091
end

-------------------------------------
---@function getResearchCost
---@brief 연구 비용
-------------------------------------
function TableResearch:getResearchCost(research_id)
    local val = self:getValue(research_id, 'cost_eoa')
    return val
end

-------------------------------------
---@function getResearchName
---@brief 연구 이름
-------------------------------------
function TableResearch:getResearchName(research_id)
    local val = self:getValue(research_id, 't_name')
    return Str(val)
end

-------------------------------------
---@function getResearchType
---@brief 연구 타입
-------------------------------------
function TableResearch:getResearchType(research_id)
    local val = math_floor(research_id/10000)
    return val
end

-------------------------------------
--- @function getResearchBuffStr
--- @brief 버프 문자열 반환
-------------------------------------
function TableResearch:getResearchBuffStr(research_id_list)
    local ret = self:getBuffMapByIdList(research_id_list)
    return self:getResearchBuffMapToStr(ret)
end

-------------------------------------
--- @function getResearchBuffStr
--- @brief 버프 문자열 반환
-------------------------------------
function TableResearch:getResearchBuffMapToStr(buff_map)
    local str = '' 
    for buff_type, buff_value in pairs(buff_map) do
        local str_buff = TableOption:getOptionDesc(buff_type, math_abs(buff_value))
        if str_buff ~= nil then
            str = (str == '') and str_buff or str..'\n'..str_buff
        end
    end
    return str
end


