-------------------------------------
-- class StructUserInfo
-- @instance
-------------------------------------
StructUserInfo = class({
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
    if (not self.m_leaderDragonObject) then
        return nil
    end

    local card = UI_DragonCard(self.m_leaderDragonObject)
    return card
end

-------------------------------------
-- function applyDragonsDataList
-- @brief 드래곤 데이터 리스트 적용
-------------------------------------
function StructUserInfo:applyDragonsDataList(l_data)
    self.m_dragonsObject = {}

    for i,v in pairs(l_data) do
        local struct_dragon_object = StructDragonObject(v)
        local doid = v['id']
        self.m_dragonsObject[doid] = struct_dragon_object
    end
end

-------------------------------------
-- function applyRunesDataList
-- @brief 룬 데이터 리스트 적용
-------------------------------------
function StructUserInfo:applyRunesDataList(l_data)
    self.m_runesObject = {}

    for i,v in pairs(l_data) do
        local struct_rune_object = StructRuneObject(v)
        local roid = v['id']
        self.m_runesObject[roid] = struct_rune_object
    end
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
-- function getSDRes
-- @breif
-------------------------------------
function StructUserInfo:getSDRes()
    local tamer_id = tonumber(self.m_tamerID)

    if (not tamer_id) then
        error('tamer_id : ' .. tamer_id)
    end

    local res = TableTamer():getValue(tamer_id, 'res_sd')
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
    self.m_tamerID = server_user['tamer']
    self.m_lv = server_user['level']
    self.m_nickname = server_user['nickname']
    self.m_tamerPosX = server_user['x']
    self.m_tamerPosY = server_user['y']

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
        self.m_leaderDragonObject = StructDragonObject(data)
    end
end