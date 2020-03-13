local PARENT = TableClass

-------------------------------------
-- class TableDragonRecommend
-------------------------------------
TableDragonRecommend = class(PARENT, {
    })

local THIS = TableDragonRecommend

-------------------------------------
-- function init
-------------------------------------
function TableDragonRecommend:init()
    self.m_tableName = 'table_dragon_recommend'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRecommendHeroDragonData
-------------------------------------
function TableDragonRecommend:getRecommendHeroDragonData()
	if (self == THIS) then
        self = THIS()
    end

    if true then
        return self:getRandomRow()
    end

    -- 한 번도 획득하지 않은 드래곤 중 인연포인트를 수집하고 있는 드래곤 우선
    local t_data = self:getRecommendHeroDragonData_needsDragon()
    if t_data then
        return t_data
    end
    
    local dragon_list = {}
    local max_priority = 0
    for did, t_data in pairs(self.m_orgTable) do
        if g_bookData then
            local is_exist = g_bookData:isExist_byDidAndEvolution(did, 1) -- param : did, evolution

            -- 도감에 등록되지 않은 드래곤
            if (is_exist == false) then
                table.insert(dragon_list, t_data)
            end
        end
    end

    local dragon_cnt = table.count(dragon_list)
    if (0 < dragon_cnt) then
        table.sort(dragon_list, function(a, b)
            return a['priority'] > b['priority']
        end)
        local random_cnt = math_min(dragon_cnt, 3)
        local idx = math_random(1, random_cnt)
        return dragon_list[idx]
    end
    
    -- 모든 드래곤이 도감에 있을 경우 임의의 드래곤 하나를 리턴
    return self:getRandomRow()
end

-------------------------------------
-- function getRecommendHeroDragonData_needsDragon
-------------------------------------
function TableDragonRecommend:getRecommendHeroDragonData_needsDragon()
	if (self == THIS) then
        self = THIS()
    end

    local needs_dragon_list = {}
    for did, t_data in pairs(self.m_orgTable) do
        if g_bookData then
            local is_exist = g_bookData:isExist_byDidAndEvolution(did, 1) -- param : did, evolution

            -- 도감에 등록되지 않은 드래곤
            if (is_exist == false) then
                local req_rpoint = TableDragon():getRelationPoint(did)
                local cur_rpoint = g_bookData:getRelationPoint(did)

                -- 인연포인트가 0보다 크고 인연소환에 필요한 값보다 적을 경우
                if (0 < cur_rpoint) and (cur_rpoint < req_rpoint) then
                    -- 드래곤을 획득하고자 하는 needs가 있다고 가정 (마녀의 상점에서 인연 포인트 구매)
                    table.insert(needs_dragon_list, t_data)
                end
            end
        end
    end

    local needs_dragon_cnt = table.count(needs_dragon_list)
    if (0 < needs_dragon_cnt) then
        table.sort(needs_dragon_list, function(a, b)
            return a['priority'] > b['priority']
        end)
        local random_cnt = math_min(needs_dragon_cnt, 3)
        local idx = math_random(1, random_cnt)
        return needs_dragon_list[idx]
    end

    return nil
end

-------------------------------------
-- function getRecommedText
-------------------------------------
function TableDragonRecommend:getRecommedText(did)
	if (self == THIS) then
        self = THIS()
    end

    local t_data = self:get(did)
    if (not t_data) then
        return ''
    end

    
    local l_tag = {}
    for key, value in pairs(t_data) do
        if pl.stringx.startswith(key, 'tag_') then
            local value_number = tonumber(value)
            if value_number then
                local content_str = string.gsub(key, 'tag_', '')
                table.insert(l_tag, {priority=value_number, content=content_str})
            end
        end
    end


    table.sort(l_tag, function(a, b)
        return a['priority'] > b['priority']
    end)

    local ret_str = ''
    for i, t_tag in ipairs(l_tag) do
        local str = getContentName(t_tag['content'])
        if (ret_str == '') then
            ret_str = str
        else
            ret_str = ret_str .. ', ' .. str
        end
    end

    return ret_str
end