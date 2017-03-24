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
        m_lv = 'number',         -- 레벨
        m_straight = 'number',   -- 연승 정보

        m_loseCnt = 'number',
        m_winCnt = 'number',

        m_dragons = '',
        m_runes = '',
        m_deckInfo = '',  

        m_leaderDragonData = '',
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
    self.m_lv = 1
    self.m_loseCnt = 0
    self.m_winCnt = 0
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
-- function setLv
-- @brief 레벨 설정
-------------------------------------
function ColosseumUserInfo:setLv(value)
    self.m_lv = value
end

-------------------------------------
-- function setUid
-- @brief 유저아이디 설정
-------------------------------------
function ColosseumUserInfo:setUid(value)
    self.m_uid = value
end

-------------------------------------
-- function setIsPlayer
-- @brief uid를 받아와 플레이어 여부 판별
-------------------------------------
function ColosseumUserInfo:setIsPlayer(value)
	local uid = value or self.m_uid or g_userData:get('uid')
	self.m_bPlayerUser = (uid == g_userData:get('uid'))
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

    -- @delete_rune
    --[[
    -- 룬 세트 효과 지정
    t_dragon_data['rune_set'] = g_runesData:makeRuneSetData(l_runes_for_set[1], l_runes_for_set[2], l_runes_for_set[3])

    -- 룬은 친밀도, 수련과 달리 Rune Object가 별도로 존재하여
    -- 외부의 함수를 통해 룬 보너스 리스트를 얻어옴
    local l_rune_bonus = ServerData_Dragons:makeRuneBonusList(t_dragon_data, l_rune_obj_map)
    --]]
    local l_rune_bonus = {}

    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data, l_rune_bonus)
end

-------------------------------------
-- function getRankText
-- @brief
-------------------------------------
function ColosseumUserInfo:getRankText(simple)
    if (not self.m_rank) then
        return Str('기록이 없습니다.')
    end

    if simple then
        return Str('{1}위', comma_value(self.m_rank))
    end

    local percent_text = string.format('%.2f', self.m_rankPercent * 100)

    local text = Str('{1}위 ({2}%)', comma_value(self.m_rank), percent_text)
    return text
end

-------------------------------------
-- function getFriendRankText
-- @brief
-------------------------------------
function ColosseumUserInfo:getFriendRankText()
    if (not self.m_friendRank) then
        return Str('기록이 없습니다.')
    end

    return Str('{1}위', comma_value(self.m_friendRank))
end

-------------------------------------
-- function getRPText
-- @brief
-------------------------------------
function ColosseumUserInfo:getRPText()
    if (not self.m_rp) then
        return Str('기록이 없습니다.')
    end

    local text = Str('{1}점', comma_value(self.m_rp))
    return text
end

-------------------------------------
-- function getWinRateText
-- @brief 승률
-------------------------------------
function ColosseumUserInfo:getWinRateText()
    local sum = math_max(self.m_winCnt + self.m_loseCnt, 1)
    local win_rate_text = math_floor(self.m_winCnt / sum * 100)
    local text = Str('{1}승 {2}패 ({3}%)', self.m_winCnt, self.m_loseCnt, win_rate_text)
    return text
end

-------------------------------------
-- function getWinstreakText
-- @brief 연승
-------------------------------------
function ColosseumUserInfo:getWinstreakText()
    if (not self.m_straight) then
        return Str('기록이 없습니다.')
    end

    local straight = math_max(self.m_straight, 0)
    local text = Str('{1}연승', comma_value(straight))
    return text
end

-------------------------------------
-- function getTierText
-- @brief
-------------------------------------
function ColosseumUserInfo:getTierText()
    local tier_text = self:getTierName(self.m_tier)
    return tier_text
end

-------------------------------------
-- function getTierName
-- @brief
-------------------------------------
function ColosseumUserInfo:getTierName(tier)
    local l_str = seperate(tier, '_')

    local tier = l_str and l_str[1] or tier
    local grade = l_str and l_str[2] or ''

    -- 오타 방지
    if (tier == 'blonze') then
        tier = 'bronze'
    end

    local str = ''
    if (tier == 'legend') then
        str = '레전드'
    elseif (tier == 'master') then
        str = '마스터'
    elseif (tier == 'challenger') then
        str = '챌린저'
    elseif (tier == 'diamond') then
        str = '다이아'
    elseif (tier == 'platinum') then
        str = '플래티넘'
    elseif (tier == 'gold') then
        str = '골드'
    elseif (tier == 'silver') then
        str = '실버'
    elseif (tier == 'bronze') then
        str = '브론즈'
    else
        
    end

    if (not isExistValue(tier, 'legend', 'master')) and (grade ~= '') then
        str = Str(str) .. ' ' .. grade
    end

    return str
end

-------------------------------------
-- function getTierIcon
-- @brief 티어 아이콘
-- @param type 'big', 'small'
-------------------------------------
function ColosseumUserInfo:getTierIcon(type)
    local icon = self:makeTierIcon(self.m_tier, type)
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    return icon
end

-------------------------------------
-- function makeTierIcon
-- @brief
-- @param type 'big', 'small'
-------------------------------------
function ColosseumUserInfo:makeTierIcon(tier, type)
    local type = type or 'big'
    local l_str = seperate(tier, '_')

    local tier = l_str and l_str[1] or tier
    local grade = l_str and l_str[2] or ''

    -- 오타 방지
    if (tier == 'blonze') then
        tier = 'bronze'
    end

    local number = 1
    if (tier == 'legend') then
        number = 8
    elseif (tier == 'master') then
        number = 7
    elseif (tier == 'challenger') then
        number = 6
    elseif (tier == 'diamond') then
        number = 5
    elseif (tier == 'platinum') then
        number = 4
    elseif (tier == 'gold') then
        number = 3
    elseif (tier == 'silver') then
        number = 2
    elseif (tier == 'bronze') then
        number = 1
    else
        
    end

    local res
    if (type == 'big') then
        res = string.format('res/ui/icon/pvp_tier/pvp_tier_%.2d.png', number)
    else
        res = string.format('res/ui/icon/pvp_tier/pvp_tier_s_%.2d.png', number)
    end
    
    local icon = cc.Sprite:create(res)
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))

    return icon
end

-------------------------------------
-- function getHighRankIcon
-- @brief 1~3위 전용 아이콘 
-------------------------------------
function ColosseumUserInfo:getHighRankIcon()
	local icon_path = string.format('res/ui/icon/rank_%02d.png', self.m_rank)
	local icon = cc.Sprite:create(icon_path)
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    return icon
end

-------------------------------------
-- function setLeaderDragonData
-- @brief
-------------------------------------
function ColosseumUserInfo:setLeaderDragonData(t_dragon_data)
    self.m_leaderDragonData = t_dragon_data
end

-------------------------------------
-- function getLeaderDragonCard
-- @brief
-------------------------------------
function ColosseumUserInfo:getLeaderDragonCard()
    local t_dragon_data = self.m_leaderDragonData
    local card = UI_DragonCard(t_dragon_data)
    return card
end
