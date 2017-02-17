-------------------------------------
-- class ColosseumUserInfo
-------------------------------------
ColosseumUserInfo = class({
        m_bPlayerUser = '', -- 플레이저 자신의 데이터인지 여부

        m_uid = '',
        m_rp = 'number', -- ranking point

        m_rank = 'number',       -- 월드 랭킹
        m_rankPercent = 'float', -- 월드 랭킹 퍼센트(상위 n%)
        m_friendRank = 'number', -- 친구 중에서 랭킹
        m_tier = 'string',       -- 티어
        m_nickname = 'string',   -- 닉네임
        m_straight = 'number',   -- 연승 정보

        m_dragons = '',
        m_runes = '',
        m_deckInfo = '',  
    })

-------------------------------------
-- function init
-------------------------------------
function ColosseumUserInfo:init()
    self:init_default()
end

-------------------------------------
-- function init_default
-------------------------------------
function ColosseumUserInfo:init_default()
    self.m_bPlayerUser = false
    self.m_uid = nil
    self.m_rp = nil
    self.m_rank = nil
    self.m_friendRank = nil
    self.m_tier = nil
    self.m_nickname = ''
    self.m_dragons = {}
    self.m_runes = {}
    self.m_deckInfo = {}
end

-------------------------------------
-- function setRP
-- @breif 랭킹 포인트
-------------------------------------
function ColosseumUserInfo:setRP(value)
    self.m_rp = self:parseServerData(value)
end

-------------------------------------
-- function setRank
-- @brief 전체 랭킹
-------------------------------------
function ColosseumUserInfo:setRank(value)
    self.m_rank = self:parseServerData(value)
end

-------------------------------------
-- function setFriendRank
-- @brief 친구 랭킹
-------------------------------------
function ColosseumUserInfo:setFriendRank(value)
    self.m_rank = self:parseServerData(value)
end

-------------------------------------
-- function setTier
-- @brief 티어 설정
-------------------------------------
function ColosseumUserInfo:setTier(value)
    self.m_tier = value
end

-------------------------------------
-- function setStraight
-- @brief 연승 정보
-------------------------------------
function ColosseumUserInfo:setStraight(value)
    self.m_straight = value
end

-------------------------------------
-- function parseServerData
-------------------------------------
function ColosseumUserInfo:parseServerData(value)
    if (value == 0) or (value == -1) or (value == '') then
        return nil
    end

    return value
end

-------------------------------------
-- function setRankPercent
-- @brief 랭킹 비율 (상위 n%)
-------------------------------------
function ColosseumUserInfo:setRankPercent(value)
    self.m_rankPercent = value
end

-------------------------------------
-- function setNickname
-- @brief 닉네임 설정
-------------------------------------
function ColosseumUserInfo:setNickname(value)
    self.m_nickname = value
end

-------------------------------------
-- function setUid
-- @brief 유저아이디 설정
-------------------------------------
function ColosseumUserInfo:setUid(value)
    self.m_uid = value
end

-------------------------------------
-- function setDragons
-- @brief 보유 드래곤
-------------------------------------
function ColosseumUserInfo:setDragons(value)
    self.m_dragons = value
end

-------------------------------------
-- function setRunes
-- @brief 보유 룬(드래곤에 장착된 룬만 포함되면 됨)
-------------------------------------
function ColosseumUserInfo:setRunes(value)
    self.m_runes = value

    for _,t_rune_data in pairs(self.m_runes) do
        t_rune_data['information'] = g_runesData:makeRuneInfomation(t_rune_data)
    end
end

-------------------------------------
-- function setDeckInfo
-- @brief 콜로세움 덱 정보
-------------------------------------
function ColosseumUserInfo:setDeckInfo(value)
    self.m_deckInfo = value
end


-------------------------------------
-- function getDeck
-- @brief 콜로세움 덱 정보
-------------------------------------
function ColosseumUserInfo:getDeck()
    -- 드래곤의 doid가 있는 슬롯 리스트
    local l_deck = self.m_deckInfo['deck']

    -- 진형
    local formation = self.m_deckInfo['formation']
    formation = ServerData_Deck:adjustFormationName(formation)

    -- 덱 이름
    local deckname = self.m_deckInfo['deckname']

    return l_deck, formation, deckname
end

-------------------------------------
-- function getDragon
-- @brief 드래곤
-------------------------------------
function ColosseumUserInfo:getDragon(doid)
    for i,v in pairs(self.m_dragons) do
        if (v['id'] == doid) then
            return clone(v)
        end
    end
end

-------------------------------------
-- function getRuneData
-- @brief 룬
-------------------------------------
function ColosseumUserInfo:getRuneData(roid)
    for i,v in pairs(self.m_runes) do
        if (v['id'] == roid) then
            return clone(v)
        end
    end
end

-------------------------------------
-- function makeDragonStatusCalculator
-- @brief 콜로세움 상대방의 능력치 계산기 생성
-------------------------------------
function ColosseumUserInfo:makeDragonStatusCalculator(doid)
    local t_dragon_data = self:getDragon(doid)

    -- 드래곤 룬 정보
    local l_runes = t_dragon_data['runes']
    local l_rune_obj_map = {}
    local l_runes_for_set = {}
    for _,roid in pairs(l_runes) do
        local t_rune_data = self:getRuneData(roid)
        l_rune_obj_map[roid] = t_rune_data
        table.insert(l_runes_for_set, t_rune_data)
    end

    -- 룬 세트 효과 지정
    t_dragon_data['rune_set'] = g_runesData:makeRuneSetData(l_runes_for_set[1], l_runes_for_set[2], l_runes_for_set[3])

    -- 룬은 친밀도, 수련과 달리 Rune Object가 별도로 존재하여
    -- 외부의 함수를 통해 룬 보너스 리스트를 얻어옴
    local l_rune_bonus = ServerData_Dragons:makeRuneBonusList(t_dragon_data, l_rune_obj_map)

    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data, l_rune_bonus)
end