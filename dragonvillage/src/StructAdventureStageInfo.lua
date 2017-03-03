-------------------------------------
-- class StructAdventureStageInfo
-- @instance chap_achieve_info
-------------------------------------
StructAdventureStageInfo = class({
        stage_id = 'number',
        mission_1 = 'boolean',
        mission_2 = 'boolean',
        mission_3 = 'boolean',
        clear_cnt = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StructAdventureStageInfo:init(data)
    self.stage_id = 0
    self.mission_1 = false
    self.mission_2 = false
    self.mission_3 = false
    self.clear_cnt = 0

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructAdventureStageInfo:applyTableData(data)
    for i,v in pairs(data) do
        self[i] = v
    end
end

-------------------------------------
-- function getNumberOfStars
-------------------------------------
function StructAdventureStageInfo:getNumberOfStars()
    local num = 0

    if self.mission_1 then
        num = (num + 1)
    end

    if self.mission_2 then
        num = (num + 1)
    end

    if self.mission_3 then
        num = (num + 1)
    end

    return num
end