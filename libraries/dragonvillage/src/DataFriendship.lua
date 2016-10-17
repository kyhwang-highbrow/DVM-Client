-- g_friendshipData

-------------------------------------
-- class DataFriendship
-------------------------------------
DataFriendship = class({
        m_userData = 'UserData',
        m_tData = 'table',

        m_emptyFriendshipData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function DataFriendship:init(user_data_instance, user_data)
    self.m_userData = user_data_instance

    if (not user_data['friendship']) then
        user_data['friendship'] = {}
        self.m_userData:setDirtyLocalSaveData()
    end

    self.m_tData = user_data['friendship']

    -- 친밀도가 없는 드래곤을 위한 비어있는 데이터
    self.m_emptyFriendshipData = self:makeFriendshipData()
end

-------------------------------------
-- function getFriendship
-- @brief
-------------------------------------
function DataFriendship:getFriendship(dragon_id)
    local dragon_id = tostring(dragon_id)

    --[[
    -- 유저가 보유중인 친밀도 데이터
    local t_friendship_data
    if self.m_tData[dragon_id] then
        t_friendship_data = self.m_tData[dragon_id]
    else
        t_friendship_data = self.m_emptyFriendshipData
    end
    --]]

    if (not self.m_tData[dragon_id]) then
        self.m_tData[dragon_id] = self:makeFriendshipData()
    end
    local t_friendship_data = self.m_tData[dragon_id]

    -- 테이블상의 친밀도 데이터
    local friendship_lv = t_friendship_data['lv']
    local t_friendship = self:getFriendshipTable(friendship_lv)

    return t_friendship_data, t_friendship
end

-------------------------------------
-- function getFriendshipTable
-- @brief
-------------------------------------
function DataFriendship:getFriendshipTable(lv)
    local lv = tonumber(lv)
    local table_friendship = TABLE:get('friendship')

    for _,t_data in pairs(table_friendship) do
        if (t_data['lv_min'] <= lv) and (lv <= t_data['lv_max']) then
            return t_data
        end
    end

    error('lv : ' .. lv)

    return nil
end

-------------------------------------
-- function makeFriendshipData
-- @brief
-------------------------------------
function DataFriendship:makeFriendshipData()

    local t_friendship_data = {}
    t_friendship_data['lv'] = 0
    t_friendship_data['lv_up_log'] = {} -- fruit_type, value

    -- 세부 능력치(실제로 올라가는 능력치)
    t_friendship_data['stats'] = {}
    for _,stat_name in ipairs(L_FRUIT_DETAILED_STATS) do
        if v ~= 'reset' then
            t_friendship_data['stats'][stat_name] = 0
        end
    end

    return t_friendship_data
end


-------------------------------------
-- function feedFruit
-- @brief
-------------------------------------
function DataFriendship:feedFruit(dragon_id, rarity, detailed_stats_type)
    local t_friendship_data, t_friendship = g_friendshipData:getFriendship(dragon_id)

    -- 최대 레벨
    local max_friendship_lv = 200
    if (max_friendship_lv <= t_friendship_data['lv']) then
        return false, Str('친밀도가 최대치입니다.')
    end

    -- 기존의 능력치
    local before_value = t_friendship_data['stats'][detailed_stats_type]

    -- 드래곤의 stat_type을 얻어옴
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]
    local stat_type = t_dragon['stat_type']
    --stat_type = string.upper(stat_type)

    --[[
    -- 최대 능력치
    local table_friendship_max_stats = TABLE:get('friendship_max_stats')
    local max_value = table_friendship_max_stats[stat_type][detailed_stats_type]

    if (max_value <= before_value) then
        return false, Str('해당 열매를 더이상 줄 수 없습니다.')
    end
    --]]

    -- 레벨 상승
    t_friendship_data['lv'] = t_friendship_data['lv'] + 1

    local fruit_full_type = DataFruit:makeFruitFullType(rarity, detailed_stats_type)

    local table_fruit = TABLE:get('fruit')
    local t_fruit = table_fruit[fruit_full_type]

    -- 최종적 상승량
    local add_value = math_random((t_fruit['min'] * 10), (t_fruit['max'] * 10)) / 10
    --add_value = math_min(add_value, (max_value - before_value))    

    t_friendship_data['stats'][detailed_stats_type] = (before_value + add_value)

    self.m_userData:setDirtyLocalSaveData(true)

    local name = Str(t_fruit['t_name'])
    local detailed_stat_name = Str(L_FRUIT_DETAILED_STATS_STR[detailed_stats_type])
    local msg = Str('[{1}] 열매로 [{2}] +{3}이 증가하였습니다.', name, detailed_stat_name, add_value)

    return true, msg
end

-------------------------------------
-- function resetFriendship
-- @brief
-------------------------------------
function DataFriendship:resetFriendship(dragon_id)

    local t_friendship_data, t_friendship = g_friendshipData:getFriendship(dragon_id)

    -- 내가 보유한 망각의 열매 개수, 망각에 필요한 망각의 열매 개수
    local own_reset_fruit_cnt = g_fruitData:getFruitCount(1, 'reset')
    local need_reset_fruit_cnt = t_friendship['reset_fruit_cnt'] or 0

    -- 소모
    g_fruitData:useFruit(1, 'reset', need_reset_fruit_cnt)

    -- 초기화
    self.m_tData[tostring(dragon_id)] = self:makeFriendshipData()

    self.m_userData:setDirtyLocalSaveData(true)
end