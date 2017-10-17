local PARENT = TableClass

-------------------------------------
-- class TableFriendshipVariables
-------------------------------------
TableFriendshipVariables = class(PARENT, {
    })

local THIS = TableFriendshipVariables

-------------------------------------
-- function init
-------------------------------------
function TableFriendshipVariables:init()
    self.m_tableName = 'table_dragon_friendship_variables'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getFeelMax
-------------------------------------
function TableFriendshipVariables:getFeelMax()
    if (self == THIS) then
        self = THIS()
    end

    local v = self:getValue('value', 'feel_max')
    return v
end

-------------------------------------
-- function getAtkMax
-------------------------------------
function TableFriendshipVariables:getAtkMax()
    if (self == THIS) then
        self = THIS()
    end

    local v = self:getValue('value', 'atk_max')
    return v
end

-------------------------------------
-- function getDefMax
-------------------------------------
function TableFriendshipVariables:getDefMax()
    if (self == THIS) then
        self = THIS()
    end

    local v = self:getValue('value', 'def_max')
    return v
end

-------------------------------------
-- function getHpMax
-------------------------------------
function TableFriendshipVariables:getHpMax()
    if (self == THIS) then
        self = THIS()
    end

    local v = self:getValue('value', 'hp_max')
    return v
end

-------------------------------------
-- function getFeelUpEmoji
-- @brief µå·¡°ï¿¡°Ô ¿­¸Å¸¦ ¸ÔÀÏ ¶§ º¸³Ê½º È¹µæ °è»ê
-------------------------------------
function TableFriendshipVariables:getFeelUpEmoji()
    if (self == THIS) then
        self = THIS()
    end

    -- 1.5¹è È®·ü °è»ê
    local emoji_150_rate = (self:getValue('value', 'emoji_super') * 100)
    if (math_random(0, 100) <= emoji_150_rate) then
        return '150p'
    end

    -- 1.2¹è È®·ü °è»ê
    local emoji_120_rate = (self:getValue('value', 'emoji_big') * 100)
    if (math_random(0, 100) <= emoji_120_rate) then
        return '120p'
    end

    -- 1¹è¼ö
    return '100p'
end