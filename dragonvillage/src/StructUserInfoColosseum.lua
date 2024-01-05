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

        --------------------------------------
        --------------------------------------
        -- StructUserInfo의 변수들 참고용 (2017-06-30)
        m_bStruct = 'boolean',

        m_uid = 'number',
        m_lv = 'number',
        m_nickname = 'string',
        m_leaderDragonObject = '',

        -- 로비 채팅에서 사용
        m_tamerID = 'string', -- ?? number??
        m_tamerPosX = 'float',
        m_tamerPosY = 'float',

        -- 드래곤, 룬
        m_dragonsObject = 'StructDragonObject',
        m_runesObject = 'StructRuneObject',
        --------------------------------------
        --------------------------------------


        m_winCnt = 'number',
        m_loseCnt = 'number',

        m_rp = 'number',         -- ranking point
        m_rank = 'number',       -- 월드 랭킹
        m_rankPercent = 'float',-- 월드 랭킹 퍼센트
        m_tier = 'string',       -- 티어
        m_straight = 'number',   -- 연승 정보

        -- 덱 정보
        m_pvpAtkDeck = 'table',
        m_pvpAtkDeckCombatPower = 'number',
        m_pvpDefDeck = 'table',
        m_pvpDefDeckCombatPower = 'number',

        m_matchResult = 'number', -- -1:매치 전, 0:패, 1:승
        m_matchTime = 'timestamp',
    })

-------------------------------------
-- function create_forRanking
-- @brief 랭킹 유저 정보
-------------------------------------
function StructUserInfoColosseum:create_forRanking(t_data)
    local user_info = StructUserInfoColosseum()

    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_rank = t_data['rank']
    user_info.m_rankPercent = t_data['rate']
    user_info.m_tier = t_data['tier']
    user_info.m_rp = t_data['rp']
    user_info.m_profileFrame = t_data['profile_frame']
    user_info.m_profileFrameExpiredAt = t_data['profile_frame_expired_at']

    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])

    -- 드래곤 룬 세팅
    user_info.m_leaderDragonObject:setRuneObjects(t_data['runes'])

    -- 클랜
    if (t_data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(t_data['clan_info'])
        user_info:setStructClan(struct_clan)
    end

    return user_info
end

-------------------------------------
-- function create_forHistory
-- @brief 전투 기록
-------------------------------------
function StructUserInfoColosseum:create_forHistory(t_data)
    local user_info = StructUserInfoColosseum()

    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_rank = t_data['rank']
    user_info.m_rankPercent = t_data['rate']
    user_info.m_tier = t_data['tier']
    user_info.m_rp = t_data['rp']
    user_info.m_profileFrame = t_data['profile_frame']
    user_info.m_profileFrameExpiredAt = t_data['profile_frame_expired_at']

    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])
    
    -- 룬 & 드래곤 리스트 저장
    user_info:applyRunesDataList(t_data['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
    user_info:applyDragonsDataList(t_data['dragons'])

    -- 공격 덱 저장
    user_info:applyPvpAtkDeckData(t_data['deck'])

    -- 매치 한 시간
    user_info.m_matchTime = t_data['match_at']

    -- 승패 결과
    user_info.m_matchResult = t_data['match']

    -- 클랜
    if (t_data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(t_data['clan_info'])
        user_info:setStructClan(struct_clan)
    end

    return user_info
end

-------------------------------------
-- function create
-- @brief 전투 기록
-------------------------------------
function StructUserInfoColosseum:create(t_data, deck_type)
    local user_info = StructUserInfoColosseum()

    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_rank = t_data['rank']
    user_info.m_rankPercent = t_data['rate']
    user_info.m_tier = t_data['tier']
    user_info.m_rp = t_data['rp']
    user_info.m_profileFrame = t_data['profile_frame']
    user_info.m_profileFrameExpiredAt = t_data['profile_frame_expired_at']

    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])
    
    -- 룬 & 드래곤 리스트 저장
    user_info:applyRunesDataList(t_data['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
    user_info:applyDragonsDataList(t_data['dragons'])

    -- 덱 저장
    if (deck_type == 'atk') then
        user_info:applyPvpAtkDeckData(t_data['deck'])
    elseif (deck_type == 'def') then
        user_info:applyPvpDefDeckData(t_data['deck'])
    end

    return user_info
end

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
            return Str(S_TIER_NAME_MAP[pure_tier]) .. ' ' .. tostring(tier_grade)
        else
            return Str(S_TIER_NAME_MAP[pure_tier])
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
        res = string.format('res/ui/icons/pvp_tier/pvp_tier_%s.png', pure_tier)
    else
        res = string.format('res/ui/icons/pvp_tier/pvp_tier_s_%s.png', pure_tier)
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
    local tier_str = (tier_str or self.m_tier)
    local str_list = pl.stringx.split(tier_str, '_')
    local pure_tier = str_list[1]
    local tier_grade = tonumber(str_list[2]) or 0
    return pure_tier, tier_grade
end

-------------------------------------
-- function getUserText
-- @brief
-------------------------------------
function StructUserInfoColosseum:getUserText()
    local str = Str('Lv.{1} {2}', self.m_lv, self.m_nickname)
    return str
end

-------------------------------------
-- function getRankText
-- @brief
-------------------------------------
function StructUserInfoColosseum:getRankText(detail)
    if (not self.m_rank) then
        return Str('기록 없음')
    end

    -- 자세히 출력 (순위와 퍼센트)
    if detail then
        if (not self.m_rankPercent) then
            return Str('{1}위', comma_value(self.m_rank))
        else
            local percent_text = string.format('%.2f', self.m_rankPercent * 100)
            local text = Str('{1}위 ({2}%)', comma_value(self.m_rank), percent_text)
            return text
        end
    else
        -- 100위 이상은 퍼센트로 표시
        if self.m_rankPercent and (100 < self.m_rank) then
            return string.format('%.2f%%', self.m_rankPercent * 100)
        else
            return Str('{1}위', comma_value(self.m_rank))
        end
    end
end

-------------------------------------
-- function getRP
-- @brief
-------------------------------------
function StructUserInfoColosseum:getRP()
    if (not self.m_rp) then
        return 0
    end

    return self.m_rp
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
-- function getWinCnt
-- @brief 승수
-------------------------------------
function StructUserInfoColosseum:getWinCnt()
	return self.m_winCnt
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
-- function applyPvpAtkDeckData
-- @brief
-------------------------------------
function StructUserInfoColosseum:applyPvpAtkDeckData(t_data)
    self.m_pvpAtkDeck = t_data
end

-------------------------------------
-- function applyPvpDefDeckData
-- @brief
-------------------------------------
function StructUserInfoColosseum:applyPvpDefDeckData(t_data)
    self.m_pvpDefDeck = t_data
    --{
    --  "tamer":110001,
    --  "deck":{
    --    "4":"59521cbce891934dae344a98",
    --    "1":"5952132de891934dae344a7f",
    --    "5":"5950cab0e891934dae34398f",
    --    "2":"595210afe891934dae344a79",
    --    "3":"59521d8ae891934dae344a9e"
    --  },
    --  "formation":"attack",
    --  "leader":4,
    --  "deckName":"def"
    --}
end

-------------------------------------
-- function getAtkDeck_dragonList
-- @brief
-------------------------------------
function StructUserInfoColosseum:getAtkDeck_dragonList(use_doid)
    if (not self.m_pvpAtkDeck) then
        return {}
    end

    local t_deck = {}

    for i,v in pairs(self.m_pvpAtkDeck['deck']) do
        local idx = tonumber(i)
        local doid = v
        
        -- doid로 저장 혹은 오브젝트로 저장
        if use_doid then
            t_deck[idx] = doid
        else
            t_deck[idx] = self:getDragonObject(doid)
        end
    end

    return t_deck
end

-------------------------------------
-- function getAtkDeckCombatPower
-- @brief 공격 덱 전투력
-------------------------------------
function StructUserInfoColosseum:getAtkDeckCombatPower(force)
    if (not self.m_pvpAtkDeckCombatPower) or force then
        if (not self.m_pvpAtkDeck) then
            return 0
        end

        local t_deck_dragon_list = self:getAtkDeck_dragonList()
        local formation_lv = self.m_pvpAtkDeck['formationlv'] or 1

        -- 드래곤
        local total_combat_power = 0
        for i,v in pairs(t_deck_dragon_list) do
            total_combat_power = (total_combat_power + v:getCombatPower())
        end

        -- 진형
        total_combat_power = total_combat_power + (formation_lv * g_constant:get('UI', 'FORMATION_LEVEL_COMBAT_POWER'))

        self.m_pvpAtkDeckCombatPower = total_combat_power
    end

    return self.m_pvpAtkDeckCombatPower
end

-------------------------------------
-- function getDefDeck_dragonList
-- @brief
-------------------------------------
function StructUserInfoColosseum:getDefDeck_dragonList(use_doid)
    if (not self.m_pvpDefDeck) then
        return {}
    end

    local t_deck = {}

    for i,v in pairs(self.m_pvpDefDeck['deck']) do
        local idx = tonumber(i)
        local doid = v

        -- doid로 저장 혹은 오브젝트로 저장
        if use_doid then
            t_deck[idx] = doid
        else
            t_deck[idx] = self:getDragonObject(doid)
        end
    end

    return t_deck
end

-------------------------------------
-- function getDefDeckCombatPower
-- @brief 방어 덱 전투력
-------------------------------------
function StructUserInfoColosseum:getDefDeckCombatPower(force)
    if (not self.m_pvpDefDeckCombatPower) or force then
        if (not self.m_pvpDefDeck) then
            return 0
        end

        local t_deck_dragon_list = self:getDefDeck_dragonList()
        local formation_lv = self.m_pvpDefDeck['formationlv']

        -- 드래곤
        local total_combat_power = 0
        for i,v in pairs(t_deck_dragon_list) do
            total_combat_power = (total_combat_power + v:getCombatPower())
        end

        -- 진형
        total_combat_power = total_combat_power + (formation_lv * g_constant:get('UI', 'FORMATION_LEVEL_COMBAT_POWER'))

        self.m_pvpDefDeckCombatPower = total_combat_power
    end

    return self.m_pvpDefDeckCombatPower
end

-------------------------------------
-- function getDeck
-- @brief ServerData_Deck과 동일한 폼 유지
-------------------------------------
function StructUserInfoColosseum:getDeck(type)
    local tamer_id = g_tamerData:getCurrTamerID()

    -- 공격덱
    if (type == 'atk') or (type == 'pvp_atk') or (type == 'fatk') or (type == 'fpvp_atk')then
        local l_doid = self:getAtkDeck_dragonList(true)
        local formation = 'attack'
        local leader = 0
        local formation_lv = 1
        if self.m_pvpAtkDeck then
            formation = self.m_pvpAtkDeck['formation']
            leader = self.m_pvpAtkDeck['leader']
            tamer_id = self.m_pvpAtkDeck['tamer'] or tamer_id
            formation_lv = self.m_pvpAtkDeck['formationlv'] 
        end
        return l_doid, formation, type, leader, tamer_id, formation_lv

    -- 방어덱
    elseif (type == 'def') or (type == 'pvp_def') then
        local l_doid = self:getDefDeck_dragonList(true)
        local formation = 'attack'
        local leader = 0

        if self.m_pvpDefDeck then
            formation = self.m_pvpDefDeck['formation']
            leader = self.m_pvpDefDeck['leader']
            tamer_id = self.m_pvpDefDeck['tamer'] or tamer_id
        end
        return l_doid, formation, type, leader, tamer_id

    else
        return {}, 'attack', type, 1, tamer_id
    end
end

-------------------------------------
-- function getPvpAtkDeck
-- @brief 공격덱 정보 리턴
-- @return table
-- {
--      ['formationlv']=1;
--      ['tamer']=110001;
--      ['tamerInfo']={
--          ['skill_lv4']=1;
--  	    ['skill_lv3']=1;
--          ['skill_lv2']=1;
--		    ['tid']=110001;
--		    ['skill_lv1']=1;
--	    };
--      ['deck']={
--          ['4']='598dd775e8919371d1bdb64b';
--          ['1']='598db431e8919371d1bdb157';
--          ['5']='598eb17ae8919371d1bdc157';
--          ['2']='598dcdade8919371d1bdb528';
--          ['3']='598dd019e8919371d1bdb57d';
--      };
--      ['formation']='attack';
--      ['leader']=5;
--      ['deckName']='atk';
-- }
-------------------------------------
function StructUserInfoColosseum:getPvpAtkDeck()
    return self.m_pvpAtkDeck or {}
end

-------------------------------------
-- function getPvpDefDeck
-- @brief 방어덱 정보 리턴
-- @return table
-- {
--      ['formationlv']=1;
--      ['tamer']=110001;
--      ['tamerInfo']={
--          ['skill_lv4']=1;
--  	    ['skill_lv3']=1;
--          ['skill_lv2']=1;
--		    ['tid']=110001;
--		    ['skill_lv1']=1;
--	    };
--      ['deck']={
--          ['4']='598dd775e8919371d1bdb64b';
--          ['1']='598db431e8919371d1bdb157';
--          ['5']='598eb17ae8919371d1bdc157';
--          ['2']='598dcdade8919371d1bdb528';
--          ['3']='598dd019e8919371d1bdb57d';
--      };
--      ['formation']='attack';
--      ['leader']=5;
--      ['deckName']='def';
-- }
-------------------------------------
function StructUserInfoColosseum:getPvpDefDeck()
    return self.m_pvpDefDeck or {}
end

-------------------------------------
-- function getAtkDeckTamerID
-- @brief 공격덱 테이머
-- @return tamer_id number
-------------------------------------
function StructUserInfoColosseum:getAtkDeckTamerID()
    local tamer_id = self:getPvpAtkDeck()['tamer'] or 110001
    return tamer_id
end

-------------------------------------
-- function getDefDeckTamerID
-- @brief 방어덱 테이머
-- @return tamer_id number
-------------------------------------
function StructUserInfoColosseum:getDefDeckTamerID()
    local tamer_id = self:getPvpDefDeck()['tamer'] or 110001
    return tamer_id
end

-------------------------------------
-- function getDefDeckCostumeID
-- @brief 방어덱 코스튬 ID
-- @return costume_id number
-------------------------------------
function StructUserInfoColosseum:getDefDeckCostumeID()
    local tamer_id = self:getPvpDefDeck()['tamer'] or 110001
    local tamer_info = self:getPvpDefDeck()['tamerInfo']
    local costume_id = nil
    if (tamer_info) then
        costume_id = tamer_info['costume'] 
    else
        costume_id = TableTamerCostume:getDefaultCostumeID(tamer_id)
    end

    return costume_id
end

-------------------------------------
-- function getAtkDeckTamerInfo
-- @brief 공격덱 테이머
-- @return tamer_id number
-------------------------------------
function StructUserInfoColosseum:getAtkDeckTamerInfo()
    local tamer_info = self:getPvpAtkDeck()['tamerInfo']
    return tamer_info
end

-------------------------------------
-- function getDefDeckTamerInfo
-- @brief 방어덱 테이머
-- @return tamer_id number
-------------------------------------
function StructUserInfoColosseum:getDefDeckTamerInfo()
    local tamer_info = self:getPvpDefDeck()['tamerInfo']
    return tamer_info
end

-------------------------------------
-- function getAtkDeckTamerReadyIcon
-- @brief 공격덱 테이머 준비화면 아이콘
-------------------------------------
function StructUserInfoColosseum:getAtkDeckTamerReadyIcon()
    local tamer_info = self:getAtkDeckTamerInfo()
    if (tamer_info) then
        return self:makeTamerReadyIconWithCostume(tamer_info)
    else
        local tamer_id = self:getAtkDeckTamerID()
        return self:makeTamerReadyIcon(tamer_id)
    end
end

-------------------------------------
-- function getDefDeckTamerReadyIcon
-- @brief 방어덱 테이머 준비화면 아이콘
-------------------------------------
function StructUserInfoColosseum:getDefDeckTamerReadyIcon()
    local tamer_info = self:getDefDeckTamerInfo()
    if (tamer_info) then
        return self:makeTamerReadyIconWithCostume(tamer_info)
    else
        local tamer_id = self:getDefDeckTamerID()
        return self:makeTamerReadyIcon(tamer_id)
    end
end

-------------------------------------
-- function makeTamerReadyIcon
-- @brief
-------------------------------------
function StructUserInfoColosseum:makeTamerReadyIcon(tamer_id)
    return IconHelper:makeTamerReadyIcon(tamer_id)
end

-------------------------------------
-- function makeTamerReadyIconWithCostume
-- @brief
-------------------------------------
function StructUserInfoColosseum:makeTamerReadyIconWithCostume(tamer_info)
    local costume_id = tamer_info['costume'] or 110001
    return IconHelper:getTamerProfileIconWithCostumeID(costume_id)
end