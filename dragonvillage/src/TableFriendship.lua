local PARENT = TableClass

-------------------------------------
-- class TableFriendship
-------------------------------------
TableFriendship = class(PARENT, {
    })

local THIS = TableFriendship

-------------------------------------
-- function init
-------------------------------------
function TableFriendship:init()
    self.m_tableName = 'table_dragon_friendship'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function isMaxFriendshipLevel
-------------------------------------
function TableFriendship:isMaxFriendshipLevel(flv, is_myth_dragon)
    if (self == THIS) then
        self = THIS()
    end

    local column_name = is_myth_dragon and 'cumulative_req_exp_myth' or 'cumulative_req_exp'

    local req_exp = self:getValue(flv, column_name)
    return (req_exp == 0) or (req_exp == '')
end

-------------------------------------
-- function getFriendshipReqExp
-------------------------------------
function TableFriendship:getFriendshipReqExp(flv, is_myth_dragon)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(flv)
    if (not t_table) then
        error('flv : ' .. flv)
    end

    local column_name = is_myth_dragon and 'cumulative_req_exp_myth' or 'cumulative_req_exp'
    local req_exp = t_table[column_name]

    if (not req_exp) or (req_exp == 0) or (req_exp == '') then
        return 0
    end

    return req_exp
end

-------------------------------------
-- function getFriendshipName
-------------------------------------
function TableFriendship:getFriendshipName(flv)
    if (self == THIS) then
        self = THIS()
    end

    local name = self:getValue(flv, 't_name')
    if (name) then
        name = Str(name)
        return name
    else
        return ''
    end
end

-------------------------------------
-- function getFriendshipIcon
-------------------------------------
function TableFriendship:getFriendshipIcon(flv)
    if (self == THIS) then
        self = THIS()
    end

    local flv = (flv + 1) -- 리소스는 1번부터 시작
    local res = string.format('res/ui/icons/friendship/friendship_level_01%.2d.png', flv)
    local icon = cc.Sprite:create(res)
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    return icon
end


-------------------------------------
-- function getTextColorWithFlv
-- @breif 친밀도 레벨별 텍스트 컬러값
-------------------------------------
function TableFriendship:getTextColorWithFlv(flv)
    if (self == THIS) then
        self = THIS()
    end

    -- 친밀도는 0레벨부터 시작하기 때문에 1을 더해줌
    local flv = (flv + 1)

    -- 레벨별 칼라값
    local LEVEL_COLOR = {
        cc.c3b(170, 179, 189), -- lv 1
        cc.c3b(95,  157, 238), -- lv 2
        cc.c3b(56,  197, 177), -- lv 3
        cc.c3b(22,  206, 48),  -- lv 4
        cc.c3b(166, 223, 40),  -- lv 5
        cc.c3b(255, 221, 43),  -- lv 6
        cc.c3b(255, 191, 44),  -- lv 7
        cc.c3b(255, 163, 40),  -- lv 8
        cc.c3b(255, 116, 79),  -- lv 9
        cc.c3b(255, 81,  114), -- lv 10
    }

    if (LEVEL_COLOR[flv]) then
        return LEVEL_COLOR[flv]
    else
        return cc.c3b(255, 255, 255)
    end
end

--[[
-------------------------------------
-- function getFriendshipLvAndExpInfo
-- @brief 
-------------------------------------
function TableFriendship:getFriendshipLvAndExpInfo(t_dragon_data)
    if (self == TableFriendship) then
        self = TableFriendship()
    end

    local flv = (t_dragon_data['flv'] or 1)
    local exp = (t_dragon_data['fexp'] or 0)

    local t_table = self:get(flv)
    local req_exp = t_table['req_exp']
    local percentage
    local percentage_str
    local is_max

    -- MAX ëąę¸
    if (not req_exp) or (req_exp == 0) then
        percentage = 100
        is_max = true
        percentage_str = 'MAX'
    else
        percentage = (exp / req_exp) * 100
        percentage = math_clamp(percentage, 0, 100)
        is_max = false
        percentage_str = Str('{1} %', percentage)
    end
    percentage = math_floor(percentage)

    local t_friendship_info = {}
    t_friendship_info['name'] = Str(t_table['t_name'])
    t_friendship_info['percentage'] = percentage
    t_friendship_info['percentage_str'] = percentage_str
    t_friendship_info['exp'] = exp
    t_friendship_info['req_exp'] = req_exp
    t_friendship_info['is_max'] = is_max

    return t_friendship_info
end
--]]