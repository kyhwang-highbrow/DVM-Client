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

        -- 로비 채팅에서 사용
        m_tamerID = 'number',
        m_tamerCostumeID = 'number', -- nil이면 기본 복장
        m_tamerPosX = 'float',
        m_tamerPosY = 'float',

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
    replacement['lv'] = 'm_lv'
    replacement['leader_dragon_object'] = 'm_leaderDragonObject'
    
    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
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

    local card = UI_DragonCard(dragon_obj)
    card.root:setSwallowTouch(false)
    return card
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
-- function getUserData
-- @breif 스크립트어에서 getter setter에 대해 생각이 바뀌는 중이지만 getter는 있어야 한다.
-------------------------------------
function StructUserInfo:getUserData()
    return self.m_userData
end

-------------------------------------
-- function makeTierIcon
-- @brief 티어 아이콘 생성
-- @return ServerData_ArenaNew에서 받아온것을 전달
-------------------------------------
function StructUserInfo:makeTierIcon(tier, type)
    local tier_icon

    if (g_userData:get('uid') == self.m_uid) then 
        local tier_icon g_arenaNewData.m_playerUserInfo:makeTierIcon(tier, type)
    end
    
    if (not self.m_lastArenaTier) then self.m_lastArenaTier = 'beginner' end

    local tier_icon = StructUserInfoArenaNew:makeTierIcon(self.m_lastArenaTier, type)

    if (tier_icon) then tier_icon:setScale(1.4) end

    return tier_icon
end