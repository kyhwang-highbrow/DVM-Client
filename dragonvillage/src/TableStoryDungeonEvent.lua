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
-- function getStoryDungeonEventTicketKey
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventTicketKey(season_id)
    if (self == THIS) then
        self = THIS()
    end

    local code = self:getStoryDungeonSeasonCode(season_id)
    return 'ticket_event_' .. code 
end

-------------------------------------
-- function getStoryDungeonEventTokentKey
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventTokentKey(season_id)
    if (self == THIS) then
        self = THIS()
    end

    local code = self:getStoryDungeonSeasonCode(season_id)
    return 'token_event_' .. code
end
