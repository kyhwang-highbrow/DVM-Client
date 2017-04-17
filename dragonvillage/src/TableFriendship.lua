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
function TableFriendship:isMaxFriendshipLevel(flv)
    if (self == THIS) then
        self = THIS()
    end

    local req_exp = self:getValue(flv, 'req_exp')
    return (req_exp == 0) or (req_exp == '')
end

-------------------------------------
-- function getFriendshipReqExp
-------------------------------------
function TableFriendship:getFriendshipReqExp(flv)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(flv)
    if (not t_table) then
        error('flv : ' .. flv)
    end

    -- 테이블의 key값이 중간에 바뀌어서 둘 다 처리
    local req_exp = (t_table['cumulative_req_exp'] or t_table['req_exp'])

    if (not req_exp) or (req_exp == 0) or (req_exp == '') then
        return 0
    end

    -- 이전 레벨의 필요 경험치를 제거
    if (0 < flv) then
        local t_table = self:get(flv - 1)
        local req_exp2 = (t_table['cumulative_req_exp'] or t_table['req_exp'])
        req_exp = (req_exp - req_exp2)
    end

    return req_exp
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