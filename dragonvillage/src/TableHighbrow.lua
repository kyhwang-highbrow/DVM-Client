local PARENT = TableClass

-------------------------------------
-- class TableHighbrow
-------------------------------------
TableHighbrow = class(PARENT, {

})

local THIS = TableHighbrow

-------------------------------------
-- function init
-------------------------------------
function TableHighbrow:init()
    self.m_tableName = 'table_highbrow'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function find
-- @param v2 : code or name
-------------------------------------
function TableHighbrow:find(game, v2)
    if (self == THIS) then
        self = THIS()
    end

    for i, v in pairs(self.m_orgTable) do
        if (v['game'] == game) and ((v['code'] == v2) or (v['t_name'] == v2)) then
            return v
        end
    end
end

local t_game_key_str = {
    ['dv1'] = '드빌1',
    ['dv2'] = '드빌2',
}
-------------------------------------
-- function getGameKeyStr
-------------------------------------
function TableHighbrow:getGameKeyStr(game_key)
    return Str(t_game_key_str[game_key])
end

-------------------------------------
-- function getFullName
-------------------------------------
function TableHighbrow:getFullName(game_key, item_name) 
    local game_name = TableHighbrow:getGameKeyStr(game_key)
    return string.format('[%s] %s', game_name, item_name) 
end