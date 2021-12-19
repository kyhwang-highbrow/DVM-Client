FRIENDSHIP_MAX_LV = 10

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
        frarity = 'string',
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
    self['frarity'] = ''

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
function StructFriendshipObject:getFriendshipInfo(flv)
    local flv = (flv or self['flv'])

    local table_friendship = TableFriendship()
    local t_table = table_friendship:get(flv)

    -- 기분 게이지
    local table_friendship_variables = TableFriendshipVariables()
    local nickname = g_userData:get('nick')
    local is_myth_dragon = self['frarity'] == 'myth'

    local t_friendship_info = {}
    t_friendship_info['name'] = Str(t_table['t_name'])
    t_friendship_info['desc'] = Str(t_table['t_desc'], nickname)
    t_friendship_info['atk_max'] = table_friendship_variables:getAtkMax()
    t_friendship_info['def_max'] = table_friendship_variables:getDefMax()
    t_friendship_info['hp_max'] = table_friendship_variables:getHpMax()
    t_friendship_info['max_exp'] = table_friendship:getFriendshipReqExp(self['flv'], is_myth_dragon)
    t_friendship_info['exp_percent'] = (self['fexp'] / t_friendship_info['max_exp']) * 100

    return t_friendship_info
end

-------------------------------------
-- function isMaxFriendshipLevel
-- @breif
-------------------------------------
function StructFriendshipObject:isMaxFriendshipLevel()
    local flv = self['flv']
    local is_myth_dragon = self['frarity'] == 'myth'
    local is_max_friendship_lv = TableFriendship:isMaxFriendshipLevel(flv, is_myth_dragon)
    return is_max_friendship_lv
end

-------------------------------------
-- function isMaxFriendshipLevel
-- @breif
-------------------------------------
function StructFriendshipObject:getAllMaxExp()
    local flv = self['flv']
    local is_myth_dragon = self['frarity'] == 'myth'
    local table = TableFriendship:getAllMaxExp(flv, is_myth_dragon)
    return table
end

-------------------------------------
-- function makeFeelUpInfo
-- @breif 열매를 줄 때 보너스 확률 계산, 증가 feel 계산
-------------------------------------
function StructFriendshipObject:makeFeelUpInfo(fid)
    local emoji = TableFriendshipVariables:getFeelUpEmoji()
    local feel = TableFruit:getFruitFeel(fid)

    if (emoji == '100p') then

    elseif (emoji == '120p') then
        feel = math_floor(feel * 1.2)

    elseif (emoji == '150p') then
        feel = math_floor(feel * 1.5)

    else
        error('emoji : ' .. emoji)
    end

    return feel, emoji
end

-------------------------------------
-- function makeFriendshipIcon
-- @breif 친밀도 아이콘 생성
-------------------------------------
function StructFriendshipObject:makeFriendshipIcon(flv)
    -- 친밀도는 0레벨부터 시작하기 때문에 1을 더해줌
    local flv = (flv or self['flv']) + 1
    local res = string.format('res/ui/icons/friendship/friendship_level_01%.2d.png', flv)
    local icon = cc.Sprite:create(res)

    if (not icon) then
        error('res : ' .. res)
    end

    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))

    return icon
end

-------------------------------------
-- function getFriendshipDisplayText
-- @breif 친밀도 아이콘 생성
-------------------------------------
function StructFriendshipObject:getFriendshipDisplayText(flv)
    -- 친밀도는 0레벨부터 시작하기 때문에 1을 더해줌
    local flv = (flv or self['flv']) + 1

    local str = Str('친밀도 {1}/{2}', flv, FRIENDSHIP_MAX_LV)

    return str
end

-------------------------------------
-- function getStringData
-------------------------------------
function StructFriendshipObject:getStringData()
    local str = string.format('%d;%d;%d;%d;%d', 
        self['flv'],
        self['fexp'],
        self['fatk'],
        self['fhp'],
        self['fdef']
    )

    return str
end
