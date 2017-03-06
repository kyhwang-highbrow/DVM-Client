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
        first_clear_reward_received = 'boolean',
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
        local key = i
        if (key == 'm_1') then  key = 'mission_1'
        elseif (key == 'm_2') then  key = 'mission_2'
        elseif (key == 'm_3') then  key = 'mission_3'
        elseif (key == 'cl_cnt') then  key = 'clear_cnt'
        elseif (key == 'cl_rew') then  key = 'first_clear_reward_received'
        end
        self[key] = v
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
	local l_mission = TableDrop():getStageMissionList(self.stage_id)

    local t_ret = {}

    for i, mission in pairs(l_mission) do
		local type = mission[1]
        local value_1 = mission[2]
        local value_2 = mission[3]
        local value_3 = mission[4]

        local org_str = table_stage_mission:getValue(type, 't_desc')

        t_ret[i] = self:createDescByMissionType(type, org_str, value_1, value_2, value_3)
    end

    return t_ret
end

-------------------------------------
-- function createDescByMissionType
-------------------------------------
function StructAdventureStageInfo:createDescByMissionType(type, org_str, val1, val2, val3)

    -- {1} 속성 드래곤을 {2}기 이상 사용하여 클리어
    if (type == 'attribute_cnt') then
        local attr = val1
        val1 = dragonAttributeName(attr)

    -- {1} 상태의 드래곤을 {2}기 이상 사용하여 클리어
    elseif (type == 'evolution_state') then
        local evolution_lv = tonumber(val1)
        val1 = evolutionName(evolution_lv)

    -- {1} 테이머를 사용하여 클리어
    elseif (type == 'use_tamer') then
        local tid = tonumber(val1)
        val1 = TableTamer():getValue(tid, 't_name')
        val1 = Str(val1)

    -- {1} 진형을 사용하여 클리어
    elseif (type == 'use_formation') then
        local mfid = val1
        val1 = TableFormation():getValue(mfid, 't_name')
        val1 = Str(val1)

    -- {1} 드래곤을 사용하여 클리어
    elseif (type == 'use_dragon') then
        local did = tonumber(val1)
        val1 = TableDragon():getValue(did, 't_name')
        val1 = Str(val1)

    -- {1} 직업의 드래곤을 사용하지 않고 클리어
    elseif (type == 'not_use_role') then
        local role = val1
        val1 = dragonRoleName(role)

    end


    local desc = Str(org_str, val1, val2, val3)
    return desc
end

-------------------------------------
-- function getFirstClearRewardState
-- @brief 최초 보상 클리어 정보
-------------------------------------
function StructAdventureStageInfo:getFirstClearRewardState()
    -- 보상을 미이 받은 상태
    if (self.first_clear_reward_received == true) then
        return 'received'

    -- 보상 받기 가능 상태
    elseif (self.clear_cnt >= 1) then
        return 'opend'

    -- 잠금 상태
    else
        return 'lock'
    end
end