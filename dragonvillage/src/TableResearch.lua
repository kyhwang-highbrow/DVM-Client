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
        'atk_per',
        'def_per',
        'hp_per',
        'cri_chance',
        'cri_dmg',
        'cri_avoid',
        'hit_rate',
        'avoid',
        'accuracy',
        'resistance',
    }

    self.m_buffList = buff_list
    self.m_accAbilityMap = {}
    for type = 1,2 do
        local id_list = self:getIdListByType(type)
        local acc_map = {}
        for _, id in ipairs(id_list) do
            for _, buff in ipairs(buff_list) do
                local val = self:getValue(id, buff)
                if val ~= nil and val ~= '' then
                    if acc_map[buff] == nil then
                        acc_map[buff] = 0
                    end
                    acc_map[buff] = acc_map[buff] + tonumber(val)
                end
            end
            -- 누적 능력치를 문자열로 생성 저장
            self.m_accAbilityMap[id] = self:getBuffMapToString(acc_map)
        end
    end
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
---@function getBuffList
---@brief 누적 능력치 스트링을 통상적으로 사용하는 리스트로 변환하여 반환
-------------------------------------
function TableResearch:getBuffList(research_id)
    local str = self.m_accAbilityMap[research_id]
    if str == nil then
        return {}
    end

    local l_buffs = {}
    local buff_str_list = plSplit(str, ',')
    for i, buff_str in ipairs(buff_str_list) do
        local list = plSplit(buff_str, ':')
        if list ~= nil then
            local t_ret = {}
            t_ret['buff_type'] = list[1]
            t_ret['buff_value'] = tonumber(list[2])
            table.insert(l_buffs, t_ret)
        end
    end

    return l_buffs
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
---@function getResearchCost
---@brief 연구 비용
-------------------------------------
function TableResearch:getResearchCost(research_id)
    local val = self:getValue(research_id, 'cost')
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
    local val = self:getValue(research_id, 'type')
    return val
end