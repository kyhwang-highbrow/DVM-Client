-------------------------------------
-- class StructUserInfo
-- @instance
-------------------------------------
StructUserInfo = class({
        m_bStruct = 'boolean',
        m_tag ='unknown',
        m_userData = 'unknown',

        m_uid = 'number',
        m_lv = 'number',
        m_nickname = 'string',
        m_tamerTitleID = 'number', --> 서버에는 user - tamer_title 로 저장
        m_leaderDragonObject = '',
        m_profileFrame = 'number', -- 프로필 프레임
        m_profileFrameExpiredAt = 'timestamp', -- 프로필 프레임 만료 기간

        -- 로비 채팅에서 사용
        m_tamerID = 'number',
        m_tamerCostumeID = 'number', -- nil이면 기본 복장
        m_tamerPosX = 'float',
        m_tamerPosY = 'float',
        m_lairStats = 'List<number>', -- 라테아 스탯
        m_researchStats = 'List<number>', -- 연구 스탯

        -- 드래곤, 룬
        m_dragonsObject = 'StructDragonObject',
        m_runesObject = 'StructRuneObject',

        -- 클랜
        m_structClan = 'StructClan',

        -- 최근 콜로세움 티어
        m_lastArenaTier = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function StructUserInfo:init(data)
    self.m_bStruct = true
    self.m_lv = 1
    self.m_tamerPosX = 0
    self.m_tamerPosY = 0

    self.m_dragonsObject = {}
    self.m_runesObject = {}
    self.m_lairStats = {}
    self.m_researchStats = {}

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructUserInfo:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    replacement['uid'] = 'm_uid'
    replacement['nickname'] = 'm_nickname'
    replacement['nick'] = 'm_nickname'
    replacement['lv'] = 'm_lv'
    replacement['leader_dragon_object'] = 'm_leaderDragonObject'
    replacement['lair_stats'] = 'm_lairStats'
    replacement['research_stats'] = 'm_researchStats'
    replacement['profile_frame'] = 'm_profileFrame'
    replacement['profile_frame_expired_at'] = 'm_profileFrameExpiredAt'
    
    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        if key then
            if rawget(self, key) then
                self[key] = v
            else
                if not string.find(key, 'm_') then
                    key = 'm_' .. key
                end
                rawset(self, key, v)
            end
        end
    end
end

-------------------------------------
-- function getLeaderDragonCard
-- @brief
-------------------------------------
function StructUserInfo:getLeaderDragonCard()
    local dragon_obj = self.m_leaderDragonObject

    -- 플레이어 유저인지 확인
    if (not dragon_obj) and (g_userData:get('uid') == self.m_uid) then
        dragon_obj = g_dragonsData:getLeaderDragon()
    end

    if (not dragon_obj) then
        return nil
    end

    local card = UI_DragonCard(dragon_obj, nil, nil, nil,true)
    card.root:setSwallowTouch(false)

    -- 프로필 테두리 추가
    local profile_frame_animator = self:makeProfileFrameAnimator()
    if profile_frame_animator ~= nil then
        card.root:addChild(profile_frame_animator.m_node)
    end

    return card
end

-------------------------------------
--- @function makeProfileFrameAnimator
--- @brief 프로필 프레임 에니메이터 생성
--- @return table
-------------------------------------
function StructUserInfo:makeProfileFrameAnimator()
    local dragon_obj = self.m_leaderDragonObject
    local profile_frame_id = 0

    -- 플레이어 유저인지 확인
    if (not dragon_obj) and (g_userData:get('uid') == self.m_uid) then        
        profile_frame_id = g_profileFrameData:getSelectedProfileFrame()
    else
        profile_frame_id = self:getProfileFrame()
    end

    --profile_frame_id = 900002
    return IconHelper:getProfileFrameAnimator(profile_frame_id)
end

-------------------------------------
-- function applyDragonsDataList
-- @brief 드래곤 데이터 리스트 적용
-------------------------------------
function StructUserInfo:applyDragonsDataList(l_data)
    local l_data = l_data or {}
    self.m_dragonsObject = {}

    local table_dragon = TableDragon()

    for i,v in pairs(l_data) do

        -- 드래곤 테이블에 존재하지 않는 did는 제외
        local did = v['did']
        if table_dragon:get(did) then
            local struct_dragon_object = StructDragonObject(v)
            
            -- 축복 추가 능력치 적용
            struct_dragon_object.lair_stats = self.m_lairStats

            -- 연구 추가 능력치 적용
            struct_dragon_object.research_stats = self.m_researchStats

            local doid = v['id']
            self.m_dragonsObject[doid] = struct_dragon_object
        end
    end
end

-------------------------------------
-- function applyRunesDataList
-- @brief 룬 데이터 리스트 적용
-------------------------------------
function StructUserInfo:applyRunesDataList(l_data)
    local l_data = l_data or {}
    self.m_runesObject = {}
    
    for i,v in pairs(l_data) do
        local struct_rune_object = StructRuneObject(v)
        local roid = v['id']
        self.m_runesObject[roid] = struct_rune_object
    end
end

-------------------------------------
-- function getDragonObject
-- @brief
-------------------------------------
function StructUserInfo:getDragonObject(doid)
    -- 클래스 내부에 드래곤 정보가 있으면 리턴
    if (self.m_dragonsObject and self.m_dragonsObject[doid]) then
        return self.m_dragonsObject[doid]
    end

    -- 없을 경우 플레이어의 서버데이터의 드래곤 정보 리턴
    return g_dragonsData:getDragonObject(doid)
end
















-------------------------------------
-- function getUid
-------------------------------------
function StructUserInfo:getUid()
    return self.m_uid
end

-------------------------------------
-- function getLv
-------------------------------------
function StructUserInfo:getLv()
    return self.m_lv
end

-------------------------------------
-- function getNickname
-------------------------------------
function StructUserInfo:getNickname()
    return self.m_nickname
end

-------------------------------------
-- function getLeaderDragonObject
-------------------------------------
function StructUserInfo:getLeaderDragonObject()
    return self.m_leaderDragonObject
end

-------------------------------------
-- function getGuild
-------------------------------------
function StructUserInfo:getGuild()
    return ''
end

-------------------------------------
-- function getPosition
-- @breif
-------------------------------------
function StructUserInfo:getPosition()
    local x = self.m_tamerPosX
    local y = self.m_tamerPosY
    return x, y
end

-------------------------------------
-- function getTamer
-- @breif
-------------------------------------
function StructUserInfo:getTamer()
    return self.m_tamerID
end

-------------------------------------
-- function getTamerTitleStr
-- @breif 칭호
-------------------------------------
function StructUserInfo:getTamerTitleStr()
    local tamer_title_id = self.m_tamerTitleID
    return TableTamerTitle:getTamerTitleStr(tamer_title_id)
end

-------------------------------------
--- @function getProfileFrame
--- @breif 프로필 프레임
-------------------------------------
function StructUserInfo:getProfileFrame()
    if self:isProfileFrameExpired() == true then
        return 0
    end

    return self.m_profileFrame or 0
end

-------------------------------------
--- @function isProfileFrameExpired
--- @breif 프로필 프레임 만료기간 체크
-------------------------------------
function StructUserInfo:isProfileFrameExpired()
    local expired_at = self.m_profileFrameExpiredAt or 0
    if expired_at == 0 then
        return false
    end

    local curr_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    return curr_time > expired_at
end

-------------------------------------
-- function getSDRes
-- @breif
-------------------------------------
function StructUserInfo:getSDRes()
    
    -- 코스츔 정보가 있으면 우선
    if (self.m_tamerCostumeID) then
        local res = TableTamerCostume:getTamerResSD(self.m_tamerCostumeID)
        if res then
            return res
        end
    end

    local tamer_id = tonumber(self.m_tamerID)

    if (not tamer_id) then
        error('tamer_id : ' .. tamer_id)
    end

    local res = TableTamer:getTamerResSD(tamer_id)
    return res
end

-------------------------------------
-- function createSUser
-- @breif 채팅 서버에서 사용하는 protobuf용 데이터를 활용한 생성
-------------------------------------
function StructUserInfo:createSUser(server_user)
    local struct_user_info = StructUserInfo()
    struct_user_info:syncSUser(server_user)
    return struct_user_info
end

-------------------------------------
-- function syncSUser
-- @breif
-------------------------------------
function StructUserInfo:syncSUser(server_user)
    self.m_uid = server_user['uid']
    self.m_lv = server_user['level']
    self.m_nickname = server_user['nickname']
    self.m_tamerPosX = server_user['x']
    self.m_tamerPosY = server_user['y']
    self.m_tamerTitleID = server_user['tamerTitleID']


    local tamer_str = server_user['tamer']
    local tamer_id = tonumber(tamer_str)

    -- 코스츔 정보가 있으면 문자열을 분석해서 추가
    if tamer_id then
        self.m_tamerID = tamer_id
        self.m_tamerCostumeID = nil
    else
        local l_str = pl.stringx.split(tamer_str, ';')
        self.m_tamerID = tonumber(l_str[1])
        self.m_tamerCostumeID = tonumber(l_str[2])
    end

    -- 드래곤 정보
    local did_str = server_user['did']
    if (did_str and (did_str ~= '')) then
        local str_list = pl.stringx.split(did_str, ';')

        local data = {}
        if str_list[1] then
            data['did'] = tonumber(str_list[1])
        end

        if str_list[2] then
            data['evolution'] = tonumber(str_list[2])
        end

        if str_list[3] then
            data['transform'] = tonumber(str_list[3])
        end

        --@dhkim todo str_list[3]로 스킨 아이디 받아와서 갱신해야 됨
        if str_list[4] then
            data['dragon_skin'] = tonumber(str_list[4])
        end


        self.m_leaderDragonObject = StructDragonObject(data)
    end

    -- 클랜 정보
    local t_json = dkjson.decode(server_user['json'] or '{}')
    if t_json['clan'] then
        local struct_clan = StructClan(t_json['clan'])
        self:setStructClan(struct_clan)
    else
        self:setStructClan(nil)
    end

    if t_json['last_arena_tier'] then
        self.m_lastArenaTier = t_json['last_arena_tier']
    end
end

-------------------------------------
-- function setStructClan
-- @breif
-------------------------------------
function StructUserInfo:setStructClan(struct_clan)
    self.m_structClan = struct_clan
end

-------------------------------------
-- function getStructClan
-- @breif
-------------------------------------
function StructUserInfo:getStructClan()
    return self.m_structClan
end

-------------------------------------
--- @function getLairStats
--- @breif 축복 능력치
-------------------------------------
function StructUserInfo:getLairStats()
    return self.m_lairStats
end

-------------------------------------
--- @function getResearchStats
--- @breif 연구 능력치
-------------------------------------
function StructUserInfo:getResearchStats()
    return self.m_researchStats
end

-------------------------------------
-- function getUserData
-- @breif 스크립트어에서 getter setter에 대해 생각이 바뀌는 중이지만 getter는 있어야 한다.
-------------------------------------
function StructUserInfo:getUserData()
    return self.m_userData
end

-------------------------------------
-- function setLeaderDragonObject
-------------------------------------
function StructUserInfo:setLeaderDragonObject(data)
    self.m_leaderDragonObject = StructDragonObject(data)
end

-------------------------------------
-- function makeTierIcon
-- @brief 티어 아이콘 생성
-- @return ServerData_ArenaNew에서 받아온것을 전달
-------------------------------------
function StructUserInfo:makeTierIcon(tier, type)
    local tier_icon

    if (g_userData:get('uid') == self.m_uid) then 
        tier_icon = g_arenaNewData.m_playerUserInfo:makeTierIcon(g_arenaNewData:getMyLastTier(), type)
    else
        if (not self.m_lastArenaTier) then self.m_lastArenaTier = 'beginner' end
    
        tier_icon = StructUserInfoArenaNew:makeTierIcon(self.m_lastArenaTier, type)   
    end

    if (tier_icon) then tier_icon:setScale(1.4) end

    return tier_icon
end



-------------------------------------
-- function getTierName
-- @brief
-------------------------------------
-- function StructUserInfo:getTierName(tier)

-- end










local S_TIER_NAME_MAP = {}
S_TIER_NAME_MAP['legend']   = Str('레전드')
S_TIER_NAME_MAP['hero']     = Str('히어로')
S_TIER_NAME_MAP['master']   = Str('마스터')
S_TIER_NAME_MAP['diamond']  = Str('다이아')
S_TIER_NAME_MAP['platinum'] = Str('플래티넘')
S_TIER_NAME_MAP['gold']     = Str('골드')
S_TIER_NAME_MAP['silver']   = Str('실버')
S_TIER_NAME_MAP['bronze']   = Str('브론즈')
S_TIER_NAME_MAP['beginner'] = Str('입문자')

-------------------------------------
-- function getTierName
-- @brief
-------------------------------------
function StructUserInfo:getTierName(tier)
    local tier = (tier or self.m_tier)

    local pure_tier, tier_grade = self:perseTier(tier)


    if (S_TIER_NAME_MAP[pure_tier]) then
        if (tier_grade > 0) then
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
-- @return icon cc.Sprite 경우에 따라 nil이 리턴될 수 있음
-------------------------------------
-- function StructUserInfo:makeTierIcon(tier, type)
--     local tier = (tier or self.m_tier)
    
--     local pure_tier, tier_grade = self:perseTier(tier)
--     if (not pure_tier) then
--         return
--     end

--     if (type == 'big') then
--         res = string.format('res/ui/icons/pvp_tier/pvp_tier_%s.png', pure_tier)
--     else
--         res = string.format('res/ui/icons/pvp_tier/pvp_tier_s_%s.png', pure_tier)
--     end

--     local icon = cc.Sprite:create(res)
--     if (icon) then
--         icon:setDockPoint(cc.p(0.5, 0.5))
--         icon:setAnchorPoint(cc.p(0.5, 0.5))
--     end
--     return icon
-- end

-------------------------------------
-- function perseTier
-- @brief 티어 구분 (bronze_3 -> bronze, 3)
-------------------------------------
function StructUserInfo:perseTier(tier_str)
    local tier_str = (tier_str or self.m_tier)
    if (not tier_str) then
        return
    end

    local str_list = pl.stringx.split(tier_str, '_')
    local pure_tier = str_list[1]
    local tier_grade = tonumber(str_list[2]) or 0
    return pure_tier, tier_grade
end

-------------------------------------
-- function getUserText
-- @brief
-------------------------------------
function StructUserInfo:getUserText()
    local str
    if self.m_lv and (0 < tonumber(self.m_lv)) then
        str = Str('Lv.{1} {2}', self.m_lv, self.m_nickname)
    else
        str = self.m_nickname
    end
    return str
end