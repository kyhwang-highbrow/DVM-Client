-- g_fruitData

L_FRUIT_DETAILED_STATS = {}
-- 공격
table.insert(L_FRUIT_DETAILED_STATS, 'atk')
table.insert(L_FRUIT_DETAILED_STATS, 'aspd')
table.insert(L_FRUIT_DETAILED_STATS, 'cri_chance')
-- 방어
table.insert(L_FRUIT_DETAILED_STATS, 'def')
table.insert(L_FRUIT_DETAILED_STATS, 'hp')
table.insert(L_FRUIT_DETAILED_STATS, 'cri_avoid')
-- 전술
table.insert(L_FRUIT_DETAILED_STATS, 'avoid')
table.insert(L_FRUIT_DETAILED_STATS, 'hit_rate')
table.insert(L_FRUIT_DETAILED_STATS, 'cri_dmg')
-- 망각의 열매
table.insert(L_FRUIT_DETAILED_STATS, 'reset')


-- 사용하는 시점에서 Str함수로 감싸서 번역처리
L_FRUIT_DETAILED_STATS_STR = {}
-- 공격
L_FRUIT_DETAILED_STATS_STR['atk'] =  '공격력'
L_FRUIT_DETAILED_STATS_STR['aspd'] = '공격속도'
L_FRUIT_DETAILED_STATS_STR['cri_chance'] = '치명확률'
-- 방어
L_FRUIT_DETAILED_STATS_STR['def'] =  '방어력'
L_FRUIT_DETAILED_STATS_STR['hp'] = '생명력'
L_FRUIT_DETAILED_STATS_STR['cri_avoid'] = '치명방어'
-- 전술
L_FRUIT_DETAILED_STATS_STR['avoid'] =  '회피'
L_FRUIT_DETAILED_STATS_STR['hit_rate'] = '적중'
L_FRUIT_DETAILED_STATS_STR['cri_dmg'] = '치명피해'



-------------------------------------
-- class DataFruit
-------------------------------------
DataFruit = class({
        m_userData = 'UserData',
        m_tData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function DataFruit:init(user_data_instance, user_data)

    self.m_userData = user_data_instance

    if (not user_data['fruit']) then
        user_data['fruit'] = {}

        for i=1, MAX_DRAGON_RAIRITY do
            local rarity = tostring(i)
            user_data['fruit'][rarity] = {}    

            for _,detailed_stats_type in ipairs(L_FRUIT_DETAILED_STATS) do
                user_data['fruit'][rarity][detailed_stats_type] = 0
            end
        end
        self.m_userData:setDirtyLocalSaveData()
    end

    -- 'fruit'
    self.m_tData = user_data['fruit']
end

-------------------------------------
-- function getFruitCount
-- @brief
-- @param rarity number 레어도
-- @param detailed_stats_type string 상세 능력지 타입
-------------------------------------
function DataFruit:getFruitCount(rarity, detailed_stats_type)

    -- rarity가 string일 경우 fruit_full_type이 리턴되었다고 간주
    if (type(rarity) == 'string') then
        local fruit_full_type = rarity
        local table_fruit = TABLE:get('fruit')
        local t_fruit = table_fruit[fruit_full_type]

        rarity = t_fruit['rarity']
        detailed_stats_type = t_fruit['type']
    end

    local rarity = tostring(rarity)
    
    if (not self.m_tData[rarity]) then
        return 0
    end

    if (not self.m_tData[rarity][detailed_stats_type]) then
        return 0
    end

    return self.m_tData[rarity][detailed_stats_type]
end

-------------------------------------
-- function addFruit
-- @brief 열매 추가
-- @param rarity number 레어도
-- @param detailed_stats_type string 상세 능력지 타입
-------------------------------------
function DataFruit:addFruit(rarity, detailed_stats_type, count)
    local rarity = tostring(rarity)
    
    if (not self.m_tData[rarity]) then
        self.m_tData[rarity] = {}
    end

    if (not self.m_tData[rarity][detailed_stats_type]) then
        self.m_tData[rarity][detailed_stats_type] = 0
    end

    self.m_tData[rarity][detailed_stats_type] = self.m_tData[rarity][detailed_stats_type] + count
    self.m_userData:setDirtyLocalSaveData()
end

-------------------------------------
-- function useFruit
-- @brief 열매 사용
-------------------------------------
function DataFruit:useFruit(rarity, detailed_stats_type, count)
    local rarity = tostring(rarity)
    
    if (not self.m_tData[rarity]) then
        self.m_tData[rarity] = {}
    end

    if (not self.m_tData[rarity][detailed_stats_type]) then
        self.m_tData[rarity][detailed_stats_type] = 0
    end

    self.m_tData[rarity][detailed_stats_type] = self.m_tData[rarity][detailed_stats_type] - count
    self.m_userData:setDirtyLocalSaveData()

    -- 남은 갯수 리턴
    return self.m_tData[rarity][detailed_stats_type]
end

-------------------------------------
-- function makeFruitFullType
-- @brief 열매 FullType 문자열 생성
-- @return string FullType
-------------------------------------
function DataFruit:makeFruitFullType(rarity, detailed_stats_type)
    local full_type = 'fruit_' .. detailed_stats_type .. '_0' .. rarity
    return full_type
end

-------------------------------------
-- function getFruitName
-- @brief 열매 이름
-- @return string
-------------------------------------
function DataFruit:getFruitName(rarity, detailed_stats_type)
    local full_type = DataFruit:makeFruitFullType(rarity, detailed_stats_type)
    local table_item = TABLE:get('item_sort_by_type')
    local t_item = table_item[full_type]
    local t_name = t_item['t_name']
    return t_name
end

-------------------------------------
-- function fruitRarityNumToStr
-- @brief 열매 레어도
-- @return string
-------------------------------------
function DataFruit:fruitRarityNumToStr(fruit_rarity)
    if (type(fruit_rarity) == 'string') then
        return fruit_rarity
    end

    if (fruit_rarity == 1) then
        return Str('하급')

    elseif (fruit_rarity == 2) then
        return Str('중급')

    elseif (fruit_rarity == 3) then
        return Str('상급')

    elseif (fruit_rarity == 4) then
        return Str('최상급')

    else
        error()

    end
end

-------------------------------------
-- function getFruitNextRarity
-- @brief 다음 레어도의 열매
-------------------------------------
function DataFruit:getFruitNextRarity(fruit_full_type)
    local table_fruit = TABLE:get('fruit')
    local t_fruit = table_fruit[fruit_full_type]

    local next_rarity = t_fruit['rarity'] + 1

    if (next_rarity < 1) or (4 < next_rarity) then
        return nil
    end
    
    local next_rarity_full_type = DataFruit:makeFruitFullType(next_rarity, t_fruit['type'])
    return next_rarity_full_type
end

-------------------------------------
-- function getUpgradeInfo
-- @brief
-------------------------------------
function DataFruit:getUpgradeInfo(fruit_full_type)
    -- 열매 정보 얻어옴
    local table_fruit = TABLE:get('fruit')
    local t_fruit = table_fruit[fruit_full_type]

    -- rarity
    local rarity = t_fruit['rarity']

    -- 업그레이드 정보 테이블 얻어옴
    local table_fruit_upgrade = TABLE:get('fruit_upgrade')
    local t_fruit_upgrade = table_fruit_upgrade[rarity]

    -- 필요환 열매 수, 필요한 골드 얻어옴
    local need_fruit_count = t_fruit_upgrade['fruit_up_0' .. rarity]
    local need_gold = t_fruit_upgrade['fruit_up_gold_0' .. rarity]

    -- 필요한 열매 수, 필요한 골드 리턴
    return need_fruit_count, need_gold
end

-------------------------------------
-- function isPossibleFruitUpgrade
-- @brief
-------------------------------------
function DataFruit:isPossibleFruitUpgrade(fruit_full_type, count)
    -- 유효성 검사 도우미 클래스
    local validation_assistant = ValidationAssistant()

    local table_fruit = TABLE:get('fruit')
    local t_fruit = table_fruit[fruit_full_type]

    -- 존재하지 않는 열매
    if (not t_fruit) then
        validation_assistant:addInvalidData(Str('존재하지 않는 열매입니다.'))

        -- 결과 리턴
        local is_valide = validation_assistant:isValid()
        local l_invalid_data_list = validation_assistant:getInvalidDataList()
        return is_valide, l_invalid_data_list
    end

    -- 최고 등급의 열매
    local need_fruit_count, need_gold = self:getUpgradeInfo(fruit_full_type)
    if (not need_fruit_count) or (not need_gold) then
        validation_assistant:addInvalidData(Str('최고 등급의 열매입니다.'))

        -- 결과 리턴
        local is_valide = validation_assistant:isValid()
        local l_invalid_data_list = validation_assistant:getInvalidDataList()
        return is_valide, l_invalid_data_list
    end

    -- 개수 부족
    local fruit_count = self:getFruitCount(fruit_full_type)
    local total_need_fruit_count = (need_fruit_count * count)
    if (fruit_count < total_need_fruit_count) then
        local name = Str(t_fruit['t_name'])
        local cnt = (total_need_fruit_count - fruit_count)
        validation_assistant:addInvalidData(Str('{1} {2}개가 부족합니다.', name, cnt))
    end

    -- 골드 부족
    local total_need_gold = (need_gold * count)
    if (self.m_userData.m_userData['gold'] < total_need_gold) then
        local lack_gold = (total_need_gold - self.m_userData.m_userData['gold'])
        validation_assistant:addInvalidData(Str('{1}골드가 부족합니다.', comma_value(lack_gold)))
    end
    
    -- 결과 리턴
    local is_valide = validation_assistant:isValid()
    local l_invalid_data_list = validation_assistant:getInvalidDataList()
    return is_valide, l_invalid_data_list
end

-------------------------------------
-- function upgradeFruit
-- @brief
-------------------------------------
function DataFruit:upgradeFruit(fruit_full_type, count)
    local is_valide, l_invalid_data_list = self:isPossibleFruitUpgrade(fruit_full_type, count)
    if (not is_valide) then
        return is_valide, l_invalid_data_list
    end

    local table_fruit = TABLE:get('fruit')
    local t_fruit = table_fruit[fruit_full_type]

    -- 망각의 열매 예외처리
    if (t_fruit['type'] == 'reset') then
        return false
    end

    local need_fruit_count, need_gold = self:getUpgradeInfo(fruit_full_type)

    local total_need_fruit = (need_fruit_count * count)
    local total_need_gold = (need_gold * count)

    -- 열매 소모
    local rarity = t_fruit['rarity']
    local type = t_fruit['type']
    self:useFruit(rarity, type, total_need_fruit)

    -- 골드 소모
    self.m_userData.m_userData['gold'] = self.m_userData.m_userData['gold'] - total_need_gold

    do -- 열매 추가
        local next_fruit_full_type = self:getFruitNextRarity(fruit_full_type)
        local t_fruit = table_fruit[next_fruit_full_type]
        local rarity = t_fruit['rarity']
        local type = t_fruit['type']
        self:addFruit(rarity, type, count)
    end

    g_topUserInfo:refreshData()
    self.m_userData:setDirtyLocalSaveData(true)
    return true
end