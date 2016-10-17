-- g_dragonListData

-------------------------------------
-- class DataDragonList
-------------------------------------
DataDragonList = class({
        m_userData = 'UserData',
        m_tData = 'table',

        m_lDragonList = 'list',
        m_lDragonDeck = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function DataDragonList:init(user_data_instance, user_data)

    self.m_userData = user_data_instance

	-- dragon table 상 문제때문에 발생하는 오류 수정
	self:retrieveDragon(user_data)

    if (not user_data['dragon']) then
        user_data['dragon'] = {}
        user_data['dragon']['dragon_list'] = {}
        user_data['dragon']['deck'] = {}

        self.m_tData = user_data['dragon']
        self.m_lDragonList = user_data['dragon']['dragon_list']
        self.m_lDragonDeck = user_data['dragon']['deck']

        -- @ TODO 임시로 모든 드래곤 추가
        local table_dragon = TABLE:get('dragon')
        local count = 0
        for i,v in pairs(table_dragon) do
            local dragon_id = i
            self:addDragon(dragon_id)

            if count < 5 then
                count = count + 1
                self:setDeck(count, dragon_id)
            end
        end

        self.m_userData:setDirtyLocalSaveData()
    end


    -- 'dragon'
    self.m_tData = user_data['dragon']
    self.m_lDragonList = user_data['dragon']['dragon_list']
    self.m_lDragonDeck = user_data['dragon']['deck']
end

-------------------------------------
-- function makeDragonData
-- @brief
--{
--    "did": 0,
--},
-------------------------------------
function DataDragonList:makeDragonData(dragon_id)
    local dragon_id = tostring(dragon_id)

    local t_dragon_data = {}
    t_dragon_data['did'] = dragon_id
    t_dragon_data['lv'] = 1
    t_dragon_data['exp'] = 0
    t_dragon_data['grade'] = 1
    t_dragon_data['evolution'] = 1
    t_dragon_data['cnt'] = 0

    return t_dragon_data
end

-------------------------------------
-- function retrieveDragon
-- @brief
-------------------------------------
function DataDragonList:retrieveDragon(user_data)
	local table_dragon = TABLE:get('dragon')
	
	local isDirty = false

	if (nil == user_data['dragon']) then return end 

	for dragon_id, dragon in pairs(user_data['dragon']['dragon_list']) do
		if (nil == table_dragon[tonumber(dragon_id)])	then
			isDirty = true
			break
		end
	end

	if isDirty then
		user_data['dragon'] = nil
	end
end

-------------------------------------
-- function addDragon
-- @brief
-------------------------------------
function DataDragonList:addDragon(dragon_id)
    local dragon_id = tostring(dragon_id)

    local t_dragon_data = self.m_lDragonList[dragon_id]

    if (not t_dragon_data) then
        t_dragon_data = self:makeDragonData(dragon_id)
        self.m_lDragonList[dragon_id] = t_dragon_data
    else
        t_dragon_data['cnt'] = t_dragon_data['cnt'] + 1
    end    

    self.m_userData:setDirtyLocalSaveData()

    return t_dragon_data
end

-------------------------------------
-- function getDragon
-- @brief
-------------------------------------
function DataDragonList:getDragon(dragon_id)
    local dragon_id = tostring(dragon_id)
    return self.m_lDragonList[dragon_id]
end

-------------------------------------
-- function setDeck
-- @brief
-------------------------------------
function DataDragonList:setDeck(idx, dragon_id)
    if (not dragon_id) then
        return
    end

    local idx = tostring(idx)
    local dragon_id = tostring(dragon_id)

    if (not self.m_lDragonList[dragon_id]) then
        error('dragon_id ' .. dragon_id)
    end

    local prev_dragon_id = self.m_lDragonDeck[idx]
    self.m_lDragonDeck[idx] = dragon_id

    return prev_dragon_id
end

-------------------------------------
-- function isSettedDargon
-- @brief
-------------------------------------
function DataDragonList:isSettedDargon(dragon_id)

    local dragon_id = tostring(dragon_id)
    for i,v in pairs(self.m_lDragonDeck) do
        if (v == dragon_id) then
            return true, tonumber(i)
        end
    end

    return false
end

-------------------------------------
-- function addDragonExp
-- @brief
-------------------------------------
function DataDragonList:addDragonExp(dragon_id, add_exp)
    local t_ret_data = {}

    local t_dragon_data = self:getDragon(dragon_id)

    local curr_lv = t_dragon_data['lv']
    local curr_exp = t_dragon_data['exp']

    t_ret_data['prev_lv'] = t_dragon_data['lv']
    t_ret_data['prev_exp'] = t_dragon_data['exp']

    local table_exp = TABLE:get('exp_dragon')

    -- 최대레벨 여부
    local is_max_level = false

    -- 실제 증가된 경험치
    local org_add_exp = add_exp
    local real_add_exp = 0

    -- 최대 레벨
    local max_level = dragonMaxLevel(t_dragon_data['evolution'])

    while true do
        local t_exp = table_exp[curr_lv]

        -- 최대 레벨일 경우
        if (t_exp['exp_d'] == 0) or (max_level <= curr_lv) then
            is_max_level = true
            break
        end

        -- 경험치가 없을 경우
        if (add_exp <= 0) then
            break
        end

        local prev_exp = curr_exp
        curr_exp = (curr_exp + add_exp)

        if (t_exp['exp_d'] <= curr_exp) then
            add_exp = curr_exp - t_exp['exp_d']
            curr_lv = curr_lv + 1
            curr_exp = 0
            real_add_exp = real_add_exp + (t_exp['exp_d'] - prev_exp)
        else
            real_add_exp = real_add_exp + add_exp
            add_exp = 0
        end
    end    

    local t_exp = table_exp[curr_lv]

    t_dragon_data['lv'] = curr_lv
    t_dragon_data['exp'] = curr_exp

    t_ret_data['curr_lv'] = t_dragon_data['lv']
    t_ret_data['curr_exp'] = t_dragon_data['exp']
    t_ret_data['curr_max_exp'] = t_exp['exp_d']
    t_ret_data['is_max_level'] = is_max_level
    t_ret_data['add_lv'] = (t_ret_data['curr_lv'] - t_ret_data['prev_lv'])
    t_ret_data['add_exp'] = real_add_exp

    self.m_userData:setDirtyLocalSaveData()

    return t_ret_data
end

-------------------------------------
-- function upgradeDragon
-- @brief
-------------------------------------
function DataDragonList:upgradeDragon(dragon_id, force)
    -- 테스트용 업그레이드
    if (force == true) then
        local t_dragon_data = self:getDragon(dragon_id)
        t_dragon_data['grade'] = math_min(t_dragon_data['grade'] + 1, 6)
        g_topUserInfo:refreshData()
        self.m_userData:setDirtyLocalSaveData(true)
        return true
    end

    local t_dragon_data = self:getDragon(dragon_id)

    -- 드래곤이 존재하지 않음
    if (not t_dragon_data) then
        return false, Str('보유하지 않은 드래곤입니다.')
    end

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    local rarity = dragonRarityStrToNum(t_dragon['rarity'])
    local table_upgrade = TABLE:get('upgrade')
    local t_upgrade = table_upgrade[rarity]

    local key = 'cost_card_0' .. t_dragon_data['grade']
    local need_card_count = t_upgrade[key]

    -- 최대 등급
    if (need_card_count == 0) then
        return false, Str('최대 등급의 드래곤입니다.')
    end

    -- 카드가 부족함
    if (t_dragon_data['cnt'] < need_card_count) then
        return false, Str('카드가 부족합니다.')
    end

    -- 금액
    local key = 'cost_gold_0' .. t_dragon_data['grade']
    local need_gold = t_upgrade[key]

    -- 금액 부족
    if (self.m_userData.m_userData['gold'] < need_gold) then
        return false, Str('골드가 부족합니다.')
    end

    -- 등급업
    self.m_userData.m_userData['gold'] = self.m_userData.m_userData['gold'] - need_gold
    t_dragon_data['grade'] = t_dragon_data['grade'] + 1
    t_dragon_data['cnt'] = t_dragon_data['cnt'] - need_card_count
    g_topUserInfo:refreshData()

    self.m_userData:setDirtyLocalSaveData(true)
    return true
end

-------------------------------------
-- function isPossibleEvolution
-- @brief 진화가 가능한지 체크
-------------------------------------
function DataDragonList:isPossibleEvolution(dragon_id)
    
    -- 유효성 검사 도우미 클래스
    local validation_assistant = ValidationAssistant()

    -- 유저의 드래곤 정보
    local t_dragon_data = self:getDragon(dragon_id)    

    -- 드래곤이 존재하지 않음
    if (not t_dragon_data) then
        validation_assistant:addInvalidData(Str('보유하지 않은 드래곤입니다.'))
    end

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    -- 최대 진화 단계의 드래곤
    if (MAX_DRAGON_EVOLUTION <= t_dragon_data['evolution']) then
        validation_assistant:addInvalidData(Str('최대 진화 단계의 드래곤입니다.'))
    end

    -- 해당 진화도의 최대 레벨을 달성했는지 여부
    do
        local max_level = dragonMaxLevel(t_dragon_data['evolution'])
        local curr_level = t_dragon_data['lv']
        if (curr_level < max_level) then
            validation_assistant:addInvalidData(Str('최대 레벨(Lv.{1})에서만 진화할 수 있습니다.', max_level))
        end
    end

    -- 진화도 테이블
    local rarity = dragonRarityStrToNum(t_dragon['rarity'])
    local table_evolution = TABLE:get('evolution')
    local t_evolution = table_evolution[rarity]

    do -- 골드가 부족한지 확인
        local key_gold = 'evo' .. t_dragon_data['evolution'] .. '_gold'
        local need_gold = t_evolution[key_gold]
        if (self.m_userData.m_userData['gold'] < need_gold) then
            local lack_gold = (need_gold - self.m_userData.m_userData['gold'])
            validation_assistant:addInvalidData(Str('{1}골드가 부족합니다.', comma_value(lack_gold)))
        end
    end

    do
        -- 진화석 확인
        local attr = t_dragon['attr']
        for stone_rarity=1, MAX_DRAGON_EVOLUTION do
            -- 키의 형태 'evo1_stone_01'
            local key = 'evo' .. t_dragon_data['evolution'] .. '_stone_0' .. stone_rarity
            local need_stone = t_evolution[key]

            if need_stone > 0 then
                local own_stone = g_evolutionStoneData:getEvolutionStoneCount(stone_rarity, attr)
                if (own_stone < need_stone) then
                    local evolution_stone_name = DataEvolutionStone:getEvolutionStoneName(stone_rarity, attr)
                    local cnt = (need_stone - own_stone)
                    validation_assistant:addInvalidData(Str('{1} {2}개가 부족합니다.', evolution_stone_name, comma_value(cnt)))
                end
            end
        end
    end

    -- 결과 리턴
    local is_valide = validation_assistant:isValid()
    local l_invalid_data_list = validation_assistant:getInvalidDataList()
    return is_valide, l_invalid_data_list
end

-------------------------------------
-- function evolutionDragon
-- @brief
-- MAX. 레벨 상태에만 진화 가능.
-- 진화 시 속성에 맞는 진화석 필요.
-- 진화 시 외형이 변경되며, 1레벨로 돌아감.
-------------------------------------
function DataDragonList:evolutionDragon(dragon_id, force)
    -- 테스트용 진화
    if (force == true) then
        -- 유저의 드래곤 정보
        local t_dragon_data = self:getDragon(dragon_id)  

        t_dragon_data['evolution'] = math_min(t_dragon_data['evolution'] + 1, 3)

        -- 진화 시 1레벨로 돌아감
        t_dragon_data['lv'] = 1
        t_dragon_data['exp'] = 0

        g_topUserInfo:refreshData()
        self.m_userData:setDirtyLocalSaveData(true)
        return true
    end

    local is_valide, l_invalid_data_list = self:isPossibleEvolution(dragon_id)
    if (not is_valide) then
        return is_valide, l_invalid_data_list
    end

    -- 유저의 드래곤 정보
    local t_dragon_data = self:getDragon(dragon_id)  

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    -- 진화도 테이블
    local rarity = dragonRarityStrToNum(t_dragon['rarity'])
    local table_evolution = TABLE:get('evolution')
    local t_evolution = table_evolution[rarity]

    do -- 비용 소모
        -- 진화석 소모
        local attr = t_dragon['attr']
        for stone_rarity=1, MAX_DRAGON_EVOLUTION do
            -- 키의 형태 'evo1_stone_01'
            local key = 'evo' .. t_dragon_data['evolution'] .. '_stone_0' .. stone_rarity
            local stone_count = t_evolution[key]

            if stone_count > 0 then
                g_evolutionStoneData:useEvolutionStone(stone_rarity, attr, stone_count)
            end
        end

        -- 골드 소모
        local key_gold = 'evo' .. t_dragon_data['evolution'] .. '_gold'
        local need_gold = t_evolution[key_gold]
        self.m_userData.m_userData['gold'] = self.m_userData.m_userData['gold'] - need_gold
    end

    do -- 진화 적용
        -- 진화단계 상승
        t_dragon_data['evolution'] = t_dragon_data['evolution'] + 1

        -- 진화 시 1레벨로 돌아감
        t_dragon_data['lv'] = 1
        t_dragon_data['exp'] = 0
    end


    g_topUserInfo:refreshData()
    self.m_userData:setDirtyLocalSaveData(true)
    return true
end

-------------------------------------
-- function makeDragonAnimator
-- @brief
-------------------------------------
function DataDragonList:makeDragonAnimator(dragon_id)
    local dragon_id = tonumber(dragon_id)
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    local res = t_dragon['res']
    local evolution = t_dragon_data['evolution']

    local animator = AnimatorHelper:makeDragonAnimator(res, evolution)

    animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
    animator.m_node:setDockPoint(cc.p(0.5, 0.5))

    return animator
end

-------------------------------------
-- function getTableData
-- @brief dragon_id로 dragon테이블에 있는 특정 키값을 바로 얻어오는 함수
-- @ex    g_dragonListData:getTableData(dragon_id, 't_name')
-------------------------------------
function DataDragonList:getTableData(dragon_id, key)
    local dragon_id = tonumber(dragon_id)
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]
    local value = t_dragon[key]
    return value
end






-------------------------------------
-- function downgradeDragon
-- @TEST
-------------------------------------
function DataDragonList:downgradeDragon(dragon_id)
    -- 테스트용 업그레이드
    local t_dragon_data = self:getDragon(dragon_id)
    t_dragon_data['grade'] = math_max(t_dragon_data['grade'] - 1, 1)
    --self.m_userData:setDirtyLocalSaveData(true)
    return true
end


-------------------------------------
-- function unEvolutionDragon
-- @TEST
-------------------------------------
function DataDragonList:unEvolutionDragon(dragon_id)
    -- 테스트용 진화
    
    -- 유저의 드래곤 정보
    local t_dragon_data = self:getDragon(dragon_id)  

    t_dragon_data['evolution'] = math_max(t_dragon_data['evolution'] - 1, 1)

    -- 진화 시 1레벨로 돌아감
    t_dragon_data['lv'] = 1
    t_dragon_data['exp'] = 0

    --self.m_userData:setDirtyLocalSaveData(true)
    return true
end

-------------------------------------
-- function initializeDragon
-- @TEST
-------------------------------------
function DataDragonList:initializeDragon(dragon_id)
    -- 테스트용 진화
    
    -- 유저의 드래곤 정보
    local t_dragon_data = self:getDragon(dragon_id)  

    t_dragon_data['evolution'] = 1
    t_dragon_data['grade'] = 1
    t_dragon_data['lv'] = 1
    t_dragon_data['exp'] = 0

    --self.m_userData:setDirtyLocalSaveData(true)
    return true
end

-------------------------------------
-- function unEvolutionDragon
-- @TEST
-------------------------------------
function DataDragonList:levelUpDragon(dragon_id)
    -- 유저의 드래곤 정보
    local t_dragon_data = self:getDragon(dragon_id)  
    
    local max_level = dragonMaxLevel(t_dragon_data['evolution'])
    
    -- 레벨업 !
    t_dragon_data['lv'] = math_min( t_dragon_data['lv'] + 1, max_level)
    t_dragon_data['exp'] = 0
    
    --self.m_userData:setDirtyLocalSaveData(true)
    return true
end


