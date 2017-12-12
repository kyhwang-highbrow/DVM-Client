local PARENT = Structure

-------------------------------------
-- class StructDailyMission
-------------------------------------
StructDailyMission = class(PARENT, {
		curr_day = '',
		progress = '',
		mission_key = '',
		is_clear = '',
		status = '',
    })

local THIS = StructDailyMission

-------------------------------------
-- function init
-------------------------------------
function StructDailyMission:init(data)

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