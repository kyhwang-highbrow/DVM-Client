local PARENT = TableClass
-------------------------------------
-- class TableDealkingBuff
-------------------------------------
TableDealkingBuff = class(PARENT, {
    m_bonusAttrListMap = 'List<string>',
    m_penaltyAttrListMap = 'List<string>',
})

local instance = nil
-------------------------------------
---@function init
-------------------------------------
function TableDealkingBuff:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_dealking_buff'
    self.m_orgTable = TABLE:get(self.m_tableName)
    self:makeAttrList()
end

-------------------------------------
-- @function getInstance
---@return TableDealkingBuff instance
-------------------------------------
function TableDealkingBuff:getInstance()
    if (instance == nil) then
        instance = TableDealkingBuff()
    end
    return instance
end

-------------------------------------
---@function makeAttrList
---@brief 속성 리스트 생성
-------------------------------------
function TableDealkingBuff:makeAttrList()
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
--- @function getDealkingBonusInfo
--- @brief 보너스 상성 정보
-------------------------------------
function TableDealkingBuff:getDealkingBonusInfo(stage_id, attr, is_buff)
    local ret = self:getDealkingStageBuffList(stage_id, attr)
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
--- @function getDealkingStageBuffList
-------------------------------------
function TableDealkingBuff:getDealkingStageBuffList(stage_id, attr)    
    local bonus_attr_list, penalty_attr_list = self:getDealkingStageAttrList(attr)
    local synastry_info_list = self:makeDealkingStageStageBuffList(stage_id, bonus_attr_list, penalty_attr_list)
    return synastry_info_list
end

-------------------------------------
--- @function getDealkingStageAttrList
--- @brief 상성/역상성 리스트 반환
-------------------------------------
function TableDealkingBuff:getDealkingStageAttrList(attr_str)
    local bonus_attr = self.m_bonusAttrListMap[attr_str]
    local penalty_attr = self.m_penaltyAttrListMap[attr_str]
    return bonus_attr, penalty_attr
end

-------------------------------------
--- @function makeDealkingStageStageBuffList
--- @brief 버프 리스트
-------------------------------------
function TableDealkingBuff:makeDealkingStageStageBuffList(stage_id, bonus_attr_list, penalty_attr_list)
    
    -- 1. 수치가 양수이면 보너스, 음수이면 패널티 버프로 분류
    -- 2. 속성이 여러개일 경우, 해당 버프를 속성마다 부여 ex)  풀 : 공격력 증가 10%, 물 : 공격력 증가 10% ...
    -- 3. drag_cool이 아니고 보스가 light or dark 속성이라면 수치의 반만 적용
    -- 4. 아래와 같은 값을 가지는 버프 테이블 생성
    --[[
        {
                ['condition_type']='attr';
                ['condition_value']='light';
                ['buff_type']='atk_multi';
                ['buff_value']=5;
        };
    --]]

    --local cur_clan_raid_attr = g_clanData:getCurSeasonBossAttr()UI_EventDealkingRankingTotalTab

    local table_buff = TABLE:get('table_dealking_buff')
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

--[[                 -- 3. drag_cool이 아니고 light, dark 속성이라면 수치의 반만 적용, (light 와 dark의 보너스 속성은 그대로)
                if (not string.match(buff_name, 'drag_cool')) then
                    if (cur_clan_raid_attr == 'light' or cur_clan_raid_attr == 'dark') then
                        if (getAttrAdvantage(cur_clan_raid_attr) == attr and tonumber(value) > 0) then
                            _ret['buff_value'] = _ret['buff_value']
                        else
                            _ret['buff_value'] = _ret['buff_value']/2
                        end
                    end
                end ]]

                table.insert(l_buff, _ret)
            end
        end
    end

    return l_buff
end