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