local PARENT = SortManager

-------------------------------------
-- class SortManager_TeamBonus
-- @breif 팀보너스 정렬
-------------------------------------
SortManager_TeamBonus = class(PARENT, {
        m_map_recommend = 'map'
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_TeamBonus:init(b_recommend)
    -- 적용중인 팀보너스
    self:addSortType('active', false, function(a, b, ascending) return self:sort_active(a, b, ascending) end)

    -- 추천 배치 활성화 : 내 드래곤 리스트로 적용 가능한 팀보너스 체크
    if (b_recommend) then
        self.m_map_recommend = {}
        self.m_map_recommend[TEAMBONUS_EMPTY_TAG] = true
        local l_my_dragon_list = g_dragonsData:getDragonsList()
        local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_my_dragon_list)
        for _, struct_teambonus in ipairs(l_teambonus_data) do
            local id = struct_teambonus:getID()
            self.m_map_recommend[id] = true
        end

        self:addSortType('recommend', false, function(a, b, ascending) return self:sort_recommend(a, b, ascending) end)
    end
    
    -- 우선순위 기본 정렬
    self:setDefaultSortFunc(function(a, b, ascending) return self:sort_priority(a, b, ascending) end)
end

-------------------------------------
-- function sort_active
-- @brief 활성화된 팀보너스 
-------------------------------------
function SortManager_TeamBonus:sort_active(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:isSatisfied() and 99 or 0
    local b_value = b_data:isSatisfied() and 99 or 0

    if (a_value == b_value) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end

-------------------------------------
-- function sort_recommend
-- @brief 추천 팀보너스
-------------------------------------
function SortManager_TeamBonus:sort_recommend(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_id = a_data:getID()
    local b_id = b_data:getID()
    local a_value = self.m_map_recommend[a_id] and 99 or 0
    local b_value = self.m_map_recommend[b_id] and 99 or 0

    if (a_value == b_value) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end

-------------------------------------
-- function sort_priority
-- @brief priority로 정렬
-------------------------------------
function SortManager_TeamBonus:sort_priority(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data.m_priority or 0
    local b_value = b_data.m_priority or 0

    -- 최종 정렬 조건으로 사용하기때문에 같은 경우에도 리턴함
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end