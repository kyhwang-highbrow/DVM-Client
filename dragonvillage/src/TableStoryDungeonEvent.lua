local PARENT = TableClass
-------------------------------------
-- class TableStoryDungeonEvent
-------------------------------------
TableStoryDungeonEvent = class(PARENT, {
})

local THIS = TableStoryDungeonEvent

-------------------------------------
-- function init
-------------------------------------
function TableStoryDungeonEvent:init()
    self.m_tableName = 'table_story_dungeon_event'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getStoryDungeonEventName
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventName(season_id)
    if (self == THIS) then
        self = THIS()
    end

    return Str(self:getValue(season_id, 't_name'))
end

-------------------------------------
-- function getStoryDungeonSeasonCode
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonSeasonCode(season_id)
    if (self == THIS) then
        self = THIS()
    end

    return Str(self:getValue(season_id, 'season_code'))
end

-------------------------------------
-- function getStoryDungeonEventDid
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventDid(season_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(season_id, 'did')
end

-------------------------------------
-- function getStoryDungeonEventTicketKey
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventTicketKey(season_id)
    return 'ticket_story_dungeon'
--[[     if (self == THIS) then
        self = THIS()
    end

    local code = self:getStoryDungeonSeasonCode(season_id)
    return 'ticket_event_' .. code  ]]
end

-------------------------------------
-- function getStoryDungeonEventTokentKey
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventTokentKey(season_id)
    return 'token_story_dungeon'
--[[     if (self == THIS) then
        self = THIS()
    end

    local code = self:getStoryDungeonSeasonCode(season_id)
    return 'token_event_' .. code ]]
end


-------------------------------------
-- function getStoryDungeonEventTicketReplaceId
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventTicketReplaceId(season_id)
    if (self == THIS) then
        self = THIS()
    end


    return self:getValue(season_id, 'ui_ticket_id')
end

-------------------------------------
-- function getStoryDungeonEventTokenReplaceId
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventTokenReplaceId(season_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(season_id, 'ui_token_id')
end

-------------------------------------
-- function getStoryDungeonEventShopTabKey
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventShopTabKey(season_id)
    if (self == THIS) then
        self = THIS()
    end

    local code = self:getStoryDungeonSeasonCode(season_id)
    return 'sd_' .. code
end