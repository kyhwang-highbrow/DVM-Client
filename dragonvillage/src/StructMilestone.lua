-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure
-------------------------------------
---@class StructMilestone:Structure
-------------------------------------
StructMilestone = class(PARENT, {
    m_objectLobbyType = 'string',
    m_objectPos = 'cc.p',
})

local THIS = StructMilestone
-------------------------------------
-- virtual function getClassName override
-------------------------------------
function StructMilestone:getClassName()
    return 'StructMilestone'
end

-------------------------------------
--- @function init
-------------------------------------
function StructMilestone:init(type, pos)
    self.m_objectLobbyType = type
    self.m_objectPos = pos
end

-------------------------------------
-- virtual function getThis override
-------------------------------------
function StructMilestone:getThis()
    return THIS
end

-------------------------------------
--- @function getObjectPos
-------------------------------------
function StructMilestone:getObjectPos()
    return self.m_objectPos
end

-------------------------------------
--- @function getObjectLobbyType
-------------------------------------
function StructMilestone:getObjectLobbyType()
    return self.m_objectLobbyType
end

-------------------------------------
--- @function getObjectLobbyDirection
-------------------------------------
function StructMilestone:getObjectLobbyDirection()
    local cur_lobby_type = g_lobbyChangeMgr:getLobbyType()

    if self.m_objectLobbyType == cur_lobby_type then
        return 0
    end
    
    if self.m_objectLobbyType == LOBBY_TYPE.NORMAL then
        return 1
    end

    if self.m_objectLobbyType == LOBBY_TYPE.CLAN then
        return -1
    end

    return 0
end

-------------------------------------
--- @function isActivate
-------------------------------------
function StructMilestone:isActivate()
    return false
end

-------------------------------------
--- @function getAllMilestoneList
-------------------------------------
function StructMilestone.getAllMilestoneList()
    local list = {}
    -- 월드 레이드
    do
        local struct_milestone = StructMilestoneWorldRaidBoard()
        struct_milestone.m_objectLobbyType = LOBBY_TYPE.NORMAL
        struct_milestone.m_objectPos = cc.p(650, 200)
        table.insert(list, struct_milestone)
    end

    return list
end
