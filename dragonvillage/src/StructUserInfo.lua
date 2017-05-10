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
    })

-------------------------------------
-- function init
-------------------------------------
function StructUserInfo:init(data)
    self.m_bStruct = true
    self.m_lv = 1

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