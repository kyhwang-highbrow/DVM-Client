-- g_evolutionStoneData

-------------------------------------
-- class DataEvolutionStone
-------------------------------------
DataEvolutionStone = class({
        m_userData = 'UserData',
        m_tData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function DataEvolutionStone:init(user_data_instance, user_data)

    self.m_userData = user_data_instance

    if (not user_data['evolution_stone']) then
        user_data['evolution_stone'] = {}

        for i=1, MAX_DRAGON_RAIRITY do
            local rarity = tostring(i)
            user_data['evolution_stone'][rarity] = {}    

            for _,attr in ipairs(T_ATTR_LIST) do
                user_data['evolution_stone'][rarity][attr] = 0
            end
        end
        self.m_userData:setDirtyLocalSaveData()
    end

    -- 'evolution_stone'
    self.m_tData = user_data['evolution_stone']
end

-------------------------------------
-- function getEvolutionStoneCount
-- @brief
-- @param rarity number 레어도
-- @param attr string 속성
-------------------------------------
function DataEvolutionStone:getEvolutionStoneCount(rarity, attr)
    local rarity = tostring(rarity)
    
    if (not self.m_tData[rarity]) then
        return 0
    end

    if (not self.m_tData[rarity][attr]) then
        return 0
    end

    return self.m_tData[rarity][attr]
end

-------------------------------------
-- function addEvolutionStone
-- @brief 진화석 추가
-- @param rarity number 레어도
-- @param attr string 속성
-------------------------------------
function DataEvolutionStone:addEvolutionStone(rarity, attr, count)
    local rarity = tostring(rarity)
    
    if (not self.m_tData[rarity]) then
        self.m_tData[rarity] = {}
    end

    if (not self.m_tData[rarity][attr]) then
        self.m_tData[rarity][attr] = 0
    end

    self.m_tData[rarity][attr] = self.m_tData[rarity][attr] + count
    self.m_userData:setDirtyLocalSaveData()
end

-------------------------------------
-- function useEvolutionStone
-- @brief 진화석 사용
-------------------------------------
function DataEvolutionStone:useEvolutionStone(rarity, attr, count)
    local rarity = tostring(rarity)
    
    if (not self.m_tData[rarity]) then
        self.m_tData[rarity] = {}
    end

    if (not self.m_tData[rarity][attr]) then
        self.m_tData[rarity][attr] = 0
    end

    self.m_tData[rarity][attr] = self.m_tData[rarity][attr] - count
    self.m_userData:setDirtyLocalSaveData()
end

-------------------------------------
-- function makeEvolutionStoneFullType
-- @brief 진화석 추가
-------------------------------------
function DataEvolutionStone:makeEvolutionStoneFullType(rarity, attr)
    local full_type = 'evolution_stone_' .. attr .. '_0' .. rarity
    return full_type
end

-------------------------------------
-- function getEvolutionStoneName
-- @brief 진화석 이름
-------------------------------------
function DataEvolutionStone:getEvolutionStoneName(rarity, attr)
    local full_type = DataEvolutionStone:makeEvolutionStoneFullType(rarity, attr)
    local table_item = TABLE:get('item_sort_by_type')
    local t_item = table_item[full_type]
    local t_name = t_item['t_name']
    return t_name
end

-------------------------------------
-- function getUpgradeInfo
-- @brief
-------------------------------------
function DataEvolutionStone:getUpgradeInfo(rarity, attr)
    -- 업그레이드 정보 테이블 얻어옴
    local table_fruit_upgrade = TABLE:get('fruit_upgrade')
    local t_fruit_upgrade = table_fruit_upgrade[rarity]

    -- 필요환 열매 수, 필요한 골드 얻어옴
    local need_count = t_fruit_upgrade['fruit_up_0' .. rarity]
    local need_gold = t_fruit_upgrade['fruit_up_gold_0' .. rarity]

    -- 필요한 열매 수, 필요한 골드 리턴
    return need_count, need_gold
end

-------------------------------------
-- function evolutionStoneRarityNumToStr
-- @brief 진화석 레어도
-- @return string
-------------------------------------
function DataEvolutionStone:evolutionStoneRarityNumToStr(rarity)
    if (type(rarity) == 'string') then
        return rarity
    end

    if (rarity == 1) then
        return Str('하급')

    elseif (rarity == 2) then
        return Str('중급')

    elseif (rarity == 3) then
        return Str('상급')

    elseif (rarity == 4) then
        return Str('최상급')

    else
        error()

    end
end

-------------------------------------
-- function isPossibleEvolutionStoneUpgrade
-- @brief
-------------------------------------
function DataEvolutionStone:isPossibleEvolutionStoneUpgrade(rarity, attr, count)
    -- 유효성 검사 도우미 클래스
    local validation_assistant = ValidationAssistant()

    -- 최고 등급의 진화석 (즉시 리턴)
    if (rarity >= 4) then
        validation_assistant:addInvalidData(Str('최고 등급의 진화석입니다.'))

        -- 결과 리턴
        local is_valide = validation_assistant:isValid()
        local l_invalid_data_list = validation_assistant:getInvalidDataList()
        return is_valide, l_invalid_data_list
    end

    -- 개수 부족
    local es_count = self:getEvolutionStoneCount(rarity, attr)
    local need_count, need_gold = self:getUpgradeInfo(rarity, attr)
    local total_need_count = (need_count * count)
    if (es_count < total_need_count) then
        local name = self:getEvolutionStoneName(rarity, attr)
        local cnt = (total_need_count - es_count)
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
-- function upgradeEvolutionStone
-- @brief
-------------------------------------
function DataEvolutionStone:upgradeEvolutionStone(rarity, attr, count)
    -- 유효성 검사
    local is_valide, l_invalid_data_list = self:isPossibleEvolutionStoneUpgrade(rarity, attr, count)
    if (not is_valide) then
        return is_valide, l_invalid_data_list
    end

    local need_count, need_gold = g_evolutionStoneData:getUpgradeInfo(rarity, attr)

    local total_need_count = (need_count * count)
    local total_need_gold = (need_gold * count)

    -- 진화석 소모
    self:useEvolutionStone(rarity, attr, total_need_count)

    -- 골드 소모
    self.m_userData.m_userData['gold'] = self.m_userData.m_userData['gold'] - total_need_gold

    -- 진화석 추가
    self:addEvolutionStone(rarity+1, attr, count)

    g_topUserInfo:refreshData()
    self.m_userData:setDirtyLocalSaveData(true)
    return true
end