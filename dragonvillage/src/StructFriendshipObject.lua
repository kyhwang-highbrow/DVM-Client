-------------------------------------
-- class StructFriendshipObject
-- @instance friendship_obj
-------------------------------------
StructFriendshipObject = class({
        flv = 'number',
        fexp = 'number',

        ffeel = 'number',

        fatk = 'number',
        fdef = 'number',
        fhp = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StructFriendshipObject:init(data)
    self['flv'] = 0
    self['fexp'] = 0
    self['ffeel'] = 0
    self['fatk'] = 0
    self['fdef'] = 0
    self['fhp'] = 0

    if data and (type(data) == 'table') then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructFriendshipObject:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    replacement['lv'] = 'flv'
    replacement['exp'] = 'fexp'
    replacement['feel'] = 'ffeel'
    replacement['atk'] = 'fatk'
    replacement['def'] = 'fdef'
    replacement['hp'] = 'fhp'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end