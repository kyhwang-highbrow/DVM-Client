local PARENT = StructUserInfo

-------------------------------------
-- 티어 정보 (tier)
-------------------------------------
-- legend(레전드)
-- master(마스터)
-- diamond(다이아몬드)
-- gold(골드)
-- silver(실버)
-- bronze(브론즈)
-- beginner(입문자)
-------------------------------------

-------------------------------------
-- class StructUserInfoColosseum
-- @instance
-------------------------------------
StructUserInfoColosseum = class(PARENT, {
        m_winCnt = 'number',
        m_loseCnt = 'number',

        m_rp = 'number',         -- ranking point
        m_rank = 'number',       -- 월드 랭킹
        m_rankPercent = 'float',-- 월드 랭킹 퍼센트
        m_tier = 'string',       -- 티어
        m_straight = 'number',   -- 연승 정보

        -- 덱 정보
        m_deckCombatPower = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StructUserInfoColosseum:init()
        self.m_winCnt = 0
        self.m_loseCnt = 0

        self.m_rp = 0
        self.m_rank = 0
        self.m_rankPercent = nil
        self.m_tier = 'beginner'
        self.m_straight = 0
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructUserInfoColosseum:applyTableData(data)
end

local S_TIER_NAME_MAP = {}
S_TIER_NAME_MAP['legend']   = Str('레전드')
S_TIER_NAME_MAP['master']   = Str('마스터')
S_TIER_NAME_MAP['diamond']  = Str('다이아')
S_TIER_NAME_MAP['gold']     = Str('골드')
S_TIER_NAME_MAP['silver']   = Str('실버')
S_TIER_NAME_MAP['bronze']   = Str('브론즈')
S_TIER_NAME_MAP['beginner'] = Str('입문자')

-------------------------------------
-- function getTierName
-- @brief
-------------------------------------
function StructUserInfoColosseum:getTierName(tier)
    local tier = (tier or self.m_tier)

    local pure_tier, tier_grade = self:perseTier(tier)


    if (S_TIER_NAME_MAP[pure_tier]) then
        if (pure_tier ~= 'master') and (0 < tier_grade) then
            return S_TIER_NAME_MAP[pure_tier] .. ' ' .. tostring(tier_grade)
        else
            return S_TIER_NAME_MAP[pure_tier]
        end
    else
        return '지정되지 않은 티어 이름'
    end
end

-------------------------------------
-- function makeTierIcon
-- @brief 티어 아이콘 생성
-------------------------------------
function StructUserInfoColosseum:makeTierIcon(tier, type)
    local tier = (tier or self.m_tier)

    local pure_tier, tier_grade = self:perseTier(tier)

    if (type == 'big') then
        res = string.format('res/ui/icon/pvp_tier/pvp_tier_%s.png', pure_tier)
    else
        res = string.format('res/ui/icon/pvp_tier/pvp_tier_s_%s.png', pure_tier)
    end

    local icon = cc.Sprite:create(res)
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))

    return icon
end

-------------------------------------
-- function perseTier
-- @brief 티어 구분 (bronze_3 -> bronze, 3)
-------------------------------------
function StructUserInfoColosseum:perseTier(tier_str)
    local str_list = pl.stringx.split(tier_str, '_')
    local pure_tier = str_list[1]
    local tier_grade = tonumber(str_list[2]) or 0
    return pure_tier, tier_grade
end

-------------------------------------
-- function getRankText
-- @brief
-------------------------------------
function StructUserInfoColosseum:getRankText(simple)
    if (not self.m_rank) then
        return Str('기록 없음')
    end

    if simple or (not self.m_rankPercent) then
        return Str('{1}위', comma_value(self.m_rank))
    end

    local percent_text = string.format('%.2f', self.m_rankPercent * 100)

    local text = Str('{1}위 ({2}%)', comma_value(self.m_rank), percent_text)
    return text
end

-------------------------------------
-- function getRPText
-- @brief
-------------------------------------
function StructUserInfoColosseum:getRPText()
    if (not self.m_rp) then
        return Str('기록 없음')
    end

    local text = Str('{1}점', comma_value(self.m_rp))
    return text
end

-------------------------------------
-- function getWinRateText
-- @brief 승률
-------------------------------------
function StructUserInfoColosseum:getWinRateText()
    local sum = math_max(self.m_winCnt + self.m_loseCnt, 1)
    local win_rate_text = math_floor(self.m_winCnt / sum * 100)
    local text = Str('{1}승 {2}패 ({3}%)', self.m_winCnt, self.m_loseCnt, win_rate_text)
    return text
end

-------------------------------------
-- function getWinstreakText
-- @brief 연승
-------------------------------------
function StructUserInfoColosseum:getWinstreakText()
    if (not self.m_straight) then
        return Str('기록 없음')
    end

    local straight = math_max(self.m_straight, 0)
    local text = Str('{1}연승', comma_value(straight))
    return text
end

-------------------------------------
-- function applyDragonsDataList
-- @brief
-------------------------------------
function StructUserInfoColosseum:applyDragonsDataList(l_data)
    PARENT.applyDragonsDataList(self, l_data)

    -- 룬 정보 연결
    for i,v in pairs(self.m_dragonsObject) do
        v.m_mRuneObjects = self.m_runesObject
    end
end

-------------------------------------
-- function getDeck_dragonList
-- @brief
-------------------------------------
function StructUserInfoColosseum:getDeck_dragonList()
    local t_deck = {}
    local idx = 0

    for i,v in pairs(self.m_dragonsObject) do
        idx = (idx + 1)
        t_deck[idx] = v
        if (5 <= idx) then
            break
        end
    end

    return t_deck
end

-------------------------------------
-- function getDeckCombatPower
-- @brief 덱 전투력
-------------------------------------
function StructUserInfoColosseum:getDeckCombatPower()
    if (not self.m_deckCombatPower) then
        local t_deck_dragon_list = self:getDeck_dragonList()

        local total_combat_power = 0
        for i,v in pairs(t_deck_dragon_list) do
            total_combat_power = (total_combat_power + v:getCombatPower())
        end

        self.m_deckCombatPower = total_combat_power
    end

    return self.m_deckCombatPower
end
