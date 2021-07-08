local PARENT = Structure

-------------------------------------
-- class StructDailyMission
-------------------------------------
StructDailyMission = class(PARENT, {
		curr_day = 'number',
		progress = 'number',
		mission_key = 'string',
		is_clear = 'bool',
		reward = 'bool',
		status = 'string',
    })

local THIS = StructDailyMission

-------------------------------------
-- function init
-------------------------------------
function StructDailyMission:init(data)
    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructDailyMission:getClassName()
    return 'StructDailyMission'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructDailyMission:getThis()
    return THIS
end

-------------------------------------
-- function getMissionKey
-------------------------------------
function StructDailyMission:getMissionKey()
    return self['mission_key']
end

-------------------------------------
-- function getCurrDay
-------------------------------------
function StructDailyMission:getCurrDay()
    return self['curr_day']
end

-------------------------------------
-- function isCleared
-------------------------------------
function StructDailyMission:isCleared()
    return self['is_clear']
end


-------------------------------------
-- function getStatus
-------------------------------------
function StructDailyMission:getStatus()
    return self['status']
end

-------------------------------------
-- function getStatus
-------------------------------------
function StructDailyMission:hasAvailableReward()
    return (self['reward'] == false) and (self['is_clear'] == true)
end