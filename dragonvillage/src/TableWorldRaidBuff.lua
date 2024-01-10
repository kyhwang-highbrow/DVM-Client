local PARENT = TableClass
-------------------------------------
-- class TableWorldRaidBuff
-------------------------------------
TableWorldRaidBuff = class(PARENT, {
    m_bonusAttrListMap = 'List<string>',
    m_penaltyAttrListMap = 'List<string>',
})

local instance = nil
-------------------------------------
---@function init
-------------------------------------
function TableWorldRaidBuff:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_world_raid_buff'
    self.m_orgTable = TABLE:get(self.m_tableName)
    self:makeAttrList()
end

-------------------------------------
-- @function getInstance
---@return TableWorldRaidBuff instance
-------------------------------------
function TableWorldRaidBuff:getInstance()
    if (instance == nil) then
        instance = TableWorldRaidBuff()
    end
    return instance
end

-------------------------------------
---@function makeAttrList
---@brief 속성 리스트 생성
-------------------------------------
function TableWorldRaidBuff:makeAttrList()
    self.m_bonusAttrListMap = {}
    self.m_penaltyAttrListMap = {}

    local all_attr_list = {'earth', 'water', 'fire', 'light', 'dark'}
    for _, attr in ipairs(all_attr_list) do
               
        self.m_bonusAttrListMap[attr] = {}

        -- 상성
        local adv_attr = getAttrDisadvantage(attr)
        table.insert(self.m_bonusAttrListMap[attr], adv_attr)

        -- 역상성은 상성을 제외한 전부
        self.m_penaltyAttrListMap[attr] = {}
        for _, other_attr in ipairs(all_attr_list) do
            if adv_attr ~= other_attr then
                table.insert(self.m_penaltyAttrListMap[attr], other_attr)
            end
        end
    end
end

-------------------------------------
--- @function getBonusInfo
--- @brief 보너스 상성 정보
-------------------------------------
function TableWorldRaidBuff:getBonusInfo(stage_id, attr, is_buff)
    local ret = self:getStageBuffList(stage_id, attr)
    local map_attr = {}
    local map_buff_type = {}
    local str = '' 
    for _, v in ipairs(ret) do
        local buff_attr = v['condition_value']
        local buff_type = v['buff_type']
        local buff_value = v['buff_value']

        -- 보너스
        if (buff_value) and ((is_buff == true and buff_value > 0) or ((is_buff == false and buff_value < 0))) then
            if (map_buff_type[buff_type] == nil) then
                local str_buff = TableOption:getOptionDesc(buff_type, math_abs(buff_value))
                -- 드래그 스킬은 맨 처음 출력
                if (string.find(buff_type, 'drag_cool_add')) then
                    str = (str == '') and str_buff or str_buff .. '\n' .. str
                else
                    str = (str == '') and str_buff or str..'\n'..str_buff
                end
                map_buff_type[buff_type] = true
            end 

            if (map_attr[buff_attr] == nil) then
                map_attr[buff_attr] = true
            end
        end
    end

    return str, map_attr
end

-------------------------------------
--- @function getStageBuffList
-------------------------------------
function TableWorldRaidBuff:getStageBuffList(stage_id, attr)    
    local bonus_attr_list, penalty_attr_list = self:getStageAttrList(attr)
    local synastry_info_list = self:makeStageStageBuffList(stage_id, bonus_attr_list, penalty_attr_list)
    return synastry_info_list
end

-------------------------------------
--- @function getStageAttrList
--- @brief 상성/역상성 리스트 반환
-------------------------------------
function TableWorldRaidBuff:getStageAttrList(attr_str)
    local bonus_attr = self.m_bonusAttrListMap[attr_str]
    local penalty_attr = self.m_penaltyAttrListMap[attr_str]
    return bonus_attr, penalty_attr
end

-------------------------------------
--- @function makeStageStageBuffList
--- @brief 버프 리스트
-------------------------------------
function TableWorldRaidBuff:makeStageStageBuffList(stage_id, bonus_attr_list, penalty_attr_list)
    local table_buff = TABLE:get('table_world_raid_buff')
    local l_buff = {}
    for buff_name, value in pairs(table_buff[stage_id]) do
        if (buff_name ~= 'r_value' and buff_name ~= 'stage') then
            local attr_list
            
            -- 1. 수치가 양수이면 보너스, 음수이면 패널티 버프로 분류
            if (tonumber(value) < 0) then
                attr_list = penalty_attr_list
            else
                attr_list = bonus_attr_list
            end

            -- 2. 속성이 여러개일 경우, 해당 버프를 속성마다 부여
            for _, attr in ipairs(attr_list) do
                local _ret = {}
                _ret['condition_type'] = 'attr'
                _ret['condition_value'] = attr
                _ret['buff_type'] = buff_name
                _ret['buff_value'] = value

                table.insert(l_buff, _ret)
            end
        end
    end

    table.sort(l_buff, function(a, b)
        local sort_val_a = a['buff_type']
        local sort_val_b = b['buff_type']
        return sort_val_a < sort_val_b
    end)

    return l_buff
end