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
-- function getStoryDungeonEventEndDate
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventEndDate(season_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(season_id, 'end_date')
end


-------------------------------------
-- function getStoryDungeonEventTicketKey
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventTicketKey()
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

-------------------------------------
-- function getStoryDungeonEventSpecialStageId
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventSpecialStageId(season_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(season_id, 'special_stage_id')
end

-------------------------------------
-- function getStoryDungeonEventEndTimeStamp
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventEndTimeStamp(season_id)
    if (self == THIS) then
        self = THIS()
    end

    local end_date = self:getStoryDungeonEventEndDate(season_id)
    return ServerTime:getInstance():datestrToTimestampMillisec(end_date)
end

-------------------------------------
-- function getStoryDungeonEventBgRes
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonEventBgRes(season_id)
    if (self == THIS) then
        self = THIS()
    end

    local bg_res = self:getValue(season_id, 'bg_res')
    return bg_res
end

-------------------------------------
-- function getStoryDungeonLobbyBgRes
-------------------------------------
function TableStoryDungeonEvent:getStoryDungeonLobbyBgRes(season_id)
    if (self == THIS) then
        self = THIS()
    end

    local bg_res = self:getValue(season_id, 'lobby_res')
    return bg_res
end