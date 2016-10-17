FRUIT_SORT_TYPE = {}
FRUIT_SORT_TYPE.DEFAULT = 1
FRUIT_SORT_TYPE.RARITY = 2
FRUIT_SORT_TYPE.MAX = 3

-------------------------------------
-- class DataFruit_ListHelper
-- @breif 보유한 열매의 정렬을 돕는 클래스
-------------------------------------
DataFruit_ListHelper = class({
        m_lOwnedFruitList = 'list',
        m_sortType = 'string',
        m_tDetailedStatsIdx = 'table', -- 열매 상세 능력치 타입별 idx 리스트
    })

-------------------------------------
-- function init
-------------------------------------
function DataFruit_ListHelper:init()
    self.m_lOwnedFruitList = nil
    self.m_sortType = FRUIT_SORT_TYPE.DEFAULT

    -- 열매 상세 능력치 타입별 idx 리스트
    if (type(DataFruit_ListHelper.m_tDetailedStatsIdx) == 'string') then
        DataFruit_ListHelper.m_tDetailedStatsIdx = {}
        for i,v in pairs(L_FRUIT_DETAILED_STATS) do
            DataFruit_ListHelper.m_tDetailedStatsIdx[v] = i
        end
    end

    self:refresh()
end

-------------------------------------
-- function refresh
-- @brief 유저데이터에 저장된 보유한 열매리스트를 갱신
-------------------------------------
function DataFruit_ListHelper:refresh()
    self.m_lOwnedFruitList = {}

    -- 희귀도 1~4
    for rarity=1, MAX_DRAGON_RAIRITY do

        -- 열매 상세 능력치
        for _,detailed_stats_type in ipairs(L_FRUIT_DETAILED_STATS) do

            -- 망각의 열매 제외
            if (detailed_stats_type ~= 'reset') then
                local fruit_count = g_fruitData:getFruitCount(rarity, detailed_stats_type)

                -- 보유한 열매일 경우 list에 추가
                if fruit_count and (0 < fruit_count) then
                    local t_fruit_data = {}
                    t_fruit_data['rarity'] = rarity
                    t_fruit_data['detailed_stats_type'] = detailed_stats_type
                    t_fruit_data['count'] = fruit_count
                    table.insert(self.m_lOwnedFruitList, t_fruit_data)
                end
            end
        end
    end

    -- 정렬
    return self:sort()
end

-------------------------------------
-- function getList
-- @brief
-------------------------------------
function DataFruit_ListHelper:getList()
    return self.m_lOwnedFruitList
end

-------------------------------------
-- function sort_default
-- @brief 열매 정렬
-------------------------------------
function DataFruit_ListHelper.sort_default(a, b)
    -- 1. 열매 종류로 정렬
    local a_stats_type = a['detailed_stats_type']
    local b_stats_type = b['detailed_stats_type']

    local a_stats_idx = DataFruit_ListHelper.m_tDetailedStatsIdx[a_stats_type]
    local b_stats_idx = DataFruit_ListHelper.m_tDetailedStatsIdx[b_stats_type]

    if (a_stats_idx < b_stats_idx) then
        return true
    elseif (b_stats_idx < a_stats_idx) then
        return false
    end

    -- 2. 열매 희귀도로 정렬
    local a_rarity = a['rarity']
    local b_rarity = b['rarity']

    return (a_rarity > b_rarity)
end

-------------------------------------
-- function sort_rarity
-- @brief 열매 정렬
-------------------------------------
function DataFruit_ListHelper.sort_rarity(a, b)
    -- 1. 열매 희귀도로 정렬
    local a_rarity = a['rarity']
    local b_rarity = b['rarity']

    if (a_rarity > b_rarity) then
        return true
    elseif (a_rarity < b_rarity) then
        return false
    end

    -- 2. 열매 종류로 정렬
    local a_stats_type = a['detailed_stats_type']
    local b_stats_type = b['detailed_stats_type']

    local a_stats_idx = DataFruit_ListHelper.m_tDetailedStatsIdx[a_stats_type]
    local b_stats_idx = DataFruit_ListHelper.m_tDetailedStatsIdx[b_stats_type]

    return (a_stats_idx < b_stats_idx)
end

-------------------------------------
-- function sort
-- @brief 열매 정렬
-------------------------------------
function DataFruit_ListHelper:sort(sort_type)
    self.m_sortType = (sort_type or self.m_sortType)

    -- 기본
    if (self.m_sortType == FRUIT_SORT_TYPE.DEFAULT) then
        table.sort(self.m_lOwnedFruitList, DataFruit_ListHelper.sort_default)

    -- 희귀도
    elseif (self.m_sortType == FRUIT_SORT_TYPE.RARITY) then
        table.sort(self.m_lOwnedFruitList, DataFruit_ListHelper.sort_rarity)

    else
        error()
    end

    return self.m_lOwnedFruitList
end