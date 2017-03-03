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

-------------------------------------
-- function getMissionDescList
-------------------------------------
function StructAdventureStageInfo:getMissionDescList()
    local table_stage_mission = TableStageMission()

    local table_drop = TableDrop(self.stage_id)
    local t_drop = table_drop:get(self.stage_id)

    local t_ret = {}

    for i=1, 3 do
        local mission_str = t_drop['mission_0' .. i]
        cclog('mission_str ' .. mission_str)
        local trim_execution = true
        local l_list = table_drop:seperate(mission_str, ',', trim_execution)
        local type = l_list[1]
        local value_1 = l_list[2]
        local value_2 = l_list[3]

        local org_str = table_stage_mission:getValue(type, 't_desc')
        --ccdump(org_str)
        local str = Str(org_str, value_1, value_2)
        t_ret[i] = str
    end

    return t_ret
end