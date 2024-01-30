local PARENT = StructMilestone
-------------------------------------
---@class StructMilestoneWorldRaidBoard:Structure
-------------------------------------
StructMilestoneWorldRaidBoard = class(PARENT, {
})

local THIS = StructMilestoneWorldRaidBoard
-------------------------------------
-- virtual function getClassName override
-------------------------------------
function StructMilestoneWorldRaidBoard:getClassName()
    return 'StructMilestoneWorldRaidBoard'
end

-------------------------------------
-- virtual function getThis override
-------------------------------------
function StructMilestoneWorldRaidBoard:getThis()
    return THIS
end

-------------------------------------
--- @function isActivate
-------------------------------------
function StructMilestoneWorldRaidBoard:isActivate()
    if g_worldRaidData:isAvailableWorldRaid() == false then
        return false
    end

    if g_worldRaidData:isAvailableWorldRaidReward() == false then
        return false
    end

    return true
end
