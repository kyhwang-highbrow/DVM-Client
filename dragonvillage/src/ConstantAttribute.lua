ATTR_NONE = 0
ATTR_EARTH = 1
ATTR_WATER = 2
ATTR_FIRE = 3
ATTR_LIGHT = 4
ATTR_DARK = 5

ATTR_LAST = ATTR_DARK

T_ATTR_LIST = {}
T_ATTR_LIST[ATTR_EARTH] = 'earth'
T_ATTR_LIST[ATTR_WATER] = 'water'
T_ATTR_LIST[ATTR_FIRE] = 'fire'
T_ATTR_LIST[ATTR_LIGHT] = 'light'
T_ATTR_LIST[ATTR_DARK] = 'dark'


local t_attr_synastry = nil -- 속성 상성 정보 테이블 
local t_attr_advantage = nil    -- t_attr_advantage['fire'] = {'earth'}
local t_attr_disadvantage  = nil  -- t_attr_disadvantage['fire'] = {'water'}

-------------------------------------
-- function initAttributeSynastry
-- @brief 속성별 카운터
-- table_attribute테이블을 통해서 속성별 상성과
-- 상성에 따른 옵션의 정보를 캐싱하는 역할을 함
-------------------------------------
function initAttributeSynastry()
    local table_attribute = TABLE:get('attribute')

    t_attr_synastry = {}

    for _,t_line in pairs(table_attribute) do

        local attr1 = t_line['type']
        if (not t_attr_synastry[attr1]) then
            t_attr_synastry[attr1] = {}
        end

        for i=1, ATTR_LAST do
            local key = string.format('strong_type_%.2d', i)
            local attr2 = t_line[key]

            if (attr2 ~= 'x') then
                local option_key = string.format('strong_option_%.2d', i)
                local value_key = string.format('strong_value_%.2d', i)

                if t_attr_synastry[attr1][attr2] then
                    error()
                end

                t_attr_synastry[attr1][attr2] = 1
            end
        end

        for i=1, 6 do
            local key = string.format('weak_type_%.2d', i)
            local attr2 = t_line[key]

            if (attr2 ~= 'x') then
                local option_key = string.format('weak_option_%.2d', i)
                local value_key = string.format('weak_value_%.2d', i)

                if t_attr_synastry[attr1][attr2] then
                    error()
                end

                t_attr_synastry[attr1][attr2] = -1
            end
        end
    end

    -- 상성, 역상성 저장 (테이블부터 생성)
    t_attr_advantage = {}
    t_attr_disadvantage  = {}
    for _,attr_str in ipairs(T_ATTR_LIST) do
        t_attr_advantage[attr_str] = {}
        t_attr_disadvantage[attr_str] = {}
    end

    -- attr1이 attr2에 대한 상성(공격의 입장)
    for attr1,t_list in pairs(t_attr_synastry) do
        for attr2, synastry in pairs(t_list) do
            if (synastry == 1) then
                table.insert(t_attr_disadvantage[attr2], attr1)
            elseif (synastry == -1) then
                table.insert(t_attr_advantage[attr2], attr1)
            end
        end
    end
end

-------------------------------------
-- function getAttrAdvantageList
-- @brief attr이 공격을 당했을 때 attr입장에서 상성이 좋은(데미지를 덜 입는) 속성리스트를 리턴
-------------------------------------
function getAttrAdvantageList(attr)
    if (not t_attr_advantage) then
        initAttributeSynastry()
    end

    if (not t_attr_advantage[attr]) then
        error('attr : ' .. attr)
    end

    return t_attr_advantage[attr]
end

-------------------------------------
-- function getAttrDisadvantageList
-- @brief attr이 공격을 당했을 때 attr입장에서 상성이 좋지 않은(데미지를 더 입는) 속성리스트를 리턴
-------------------------------------
function getAttrDisadvantageList(attr)
    if (not t_attr_disadvantage ) then
        initAttributeSynastry()
    end

    if (not t_attr_disadvantage[attr]) then
        error('attr : ' .. attr)
    end

    return t_attr_disadvantage[attr]
end

-------------------------------------
-- function getCounterAttribute
-- @brief attr1이 attr2의 카운터 속성인지를 확인
-- @return number 1=상성, 0=무상성, -1역상성
-------------------------------------
function getCounterAttribute(attr1, attr2)
    if (attr1 == nil or attr2 == nil) then return 0 end
    if (not t_attr_synastry) then
        initAttributeSynastry()
    end

    -- -1, 0, 1
    return t_attr_synastry[attr1][attr2]
end

-------------------------------------
-- function attributeStrToNum
-- @brief 속성을 number타입으로 표현
-------------------------------------
function attributeStrToNum(attr)
    if (type(attr) == 'number') then
        return rarity_str
    end

    if (attr == 'light') then
        return ATTR_LIGHT

    elseif (attr == 'dark') then
        return ATTR_DARK

    elseif (attr == 'earth') then
        return ATTR_EARTH

    elseif (attr == 'fire') then
        return ATTR_FIRE

    elseif (attr == 'water') then
        return ATTR_WATER

    else
        error('attr : ' .. attr)
    end
end

-------------------------------------
-- function attributeNumToStr
-- @brief 속성을 string타입으로 표현
-------------------------------------
function attributeNumToStr(attr)
    if (type(attr) == 'string') then
        return attr
    end

    return T_ATTR_LIST[attr]
end

-------------------------------------
-- function attributeOption
-- @brief 임시 네이밍
-------------------------------------
function attributeOption(t_data, option_type, value)

    if (not option_type) or (option_type == 'x') then
        return
    end

    local detail_stat_type = nil
    local b_minus = false

    -- 데미지 (damage)
    if (option_type == 'damage_up') then
        detail_stat_type = 'damage'
    elseif (option_type == 'damage_down') then
        detail_stat_type = 'damage'
        b_minus = true

    -- 적중 (hit_rate)
    elseif (option_type == 'hit_rate_up') then
        detail_stat_type = 'hit_rate'
    elseif (option_type == 'hit_rate_down') then
        detail_stat_type = 'hit_rate'
        b_minus = true

    -- 체력 (hp)
    elseif (option_type == 'hp_up') then
        detail_stat_type = 'hp'

    -- 회피 (avoid)
    elseif (option_type == 'avoid_up') then
        detail_stat_type = 'avoid'
    elseif (option_type == 'avoid_down') then
        detail_stat_type = 'avoid'
        b_minus = true

    -- 크리 확률 (cri_chance)
    elseif (option_type == 'cri_chance_up') then
        detail_stat_type = 'cri_chance'
    elseif (option_type == 'cri_chance_down') then
        detail_stat_type = 'cri_chance'
        b_minus = true

    -- 크리 피해 (cri_dmg)
    elseif (option_type == 'cri_dmg_up') then
        detail_stat_type = 'cri_dmg'
    elseif (option_type == 'cri_dmg_down') then
        detail_stat_type = 'cri_dmg'
        b_minus = true

    else
        error('option_type : ' .. option_type)
    end

    -- 100은 100%를 뜻함
    if (not t_data[detail_stat_type]) then
        t_data[detail_stat_type] = 0
    end

    -- 양수, 음수
    if (not b_minus) then
        t_data[detail_stat_type] = t_data[detail_stat_type] + value
    else
        t_data[detail_stat_type] = t_data[detail_stat_type] - value
    end
end

-------------------------------------
-- function getAttrSynastryEffect
-- @brief 속성 상성 효과 얻어옴
-------------------------------------
function getAttrSynastryEffect(attr1, attr2, attr_adj_rate)
    -- attr1이 attr2에 대한 상성 정보를 얻어옴
    local attr_synastry = getCounterAttribute(attr1, attr2)

    -- 무상성
    if (not attr_synastry) or (attr_synastry == 0) then
        return {}
    end

    -- attr1의 속성 테이블 얻어옴
    local attr1_num = attributeStrToNum(attr1)
    local table_attribute = TABLE:get('attribute')
    local t_attribute = table_attribute[attr1_num]

    -- 상성 유리, 불리에 따른 key값
    local synastry_str = ''
    if (attr_synastry == 1) then
        synastry_str = 'strong'
    elseif (attr_synastry == -1) then
        synastry_str = 'weak'
    else
        error('attr_synastry : ' .. attr_synastry)
    end

    -- 테이블에서 옵션 정보를 가져옴
    local t_attr_synastry_effect = {}
    for i=1, 10 do
        local option_key = string.format('%s_option_%.2d', synastry_str, i)
        local value_key = string.format('%s_value_%.2d', synastry_str, i)

        if (not t_attribute[option_key]) then
            break
        end

        if (not t_attribute[value_key]) then
            break
        end

        local option = t_attribute[option_key]
        local value = t_attribute[value_key]
        attributeOption(t_attr_synastry_effect, option, value)
    end
    
	-- 상태 효과에 따른 속성 데미지 수치 조절
	if (attr_adj_rate > 0) then
		if (t_attr_synastry_effect['damage'] > 0) then 
			t_attr_synastry_effect['damage'] = t_attr_synastry_effect['damage'] + attr_adj_rate
		else
			t_attr_synastry_effect['damage'] = t_attr_synastry_effect['damage'] - attr_adj_rate
		end
	end

    return t_attr_synastry_effect
end

-------------------------------------
-- function getRandomAttr
-- @brief 랜덤 속성을 하나 얻는다
-------------------------------------
function getRandomAttr()
    local idx = math_random(1, 5)
    return T_ATTR_LIST[idx]
end

    