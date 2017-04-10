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

    if data then
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

-------------------------------------
-- function getFriendshipInfo
-- @breif
-------------------------------------
function StructFriendshipObject:getFriendshipInfo()
    local table_friendship = TableFriendship()
    local t_table = table_friendship:get(self['flv'])

    -- 기분 게이지
    local table_friendship_variables = TableFriendshipVariables()
    local feel_percent = (self['ffeel'] / table_friendship_variables:getFeelMax()) * 100
    feel_percent = math_clamp(feel_percent, 0, 100)

    local t_friendship_info = {}
    t_friendship_info['name'] = Str(t_table['t_name'])
    t_friendship_info['desc'] = Str(t_table['t_desc'])
    t_friendship_info['feel_percent'] = feel_percent
    t_friendship_info['atk_max'] = table_friendship_variables:getAtkMax()
    t_friendship_info['def_max'] = table_friendship_variables:getDefMax()
    t_friendship_info['hp_max'] = table_friendship_variables:getHpMax()
    t_friendship_info['max_exp'] = t_table['req_exp']
    t_friendship_info['exp_percent'] = (self['fexp'] / t_friendship_info['max_exp']) * 100

    return t_friendship_info
end