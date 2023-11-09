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

    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    replacement['m_1'] = 'mission_1'
    replacement['m_2'] = 'mission_2'
    replacement['m_3'] = 'mission_3'
    replacement['cl_cnt'] = 'clear_cnt'
    replacement['cl_rew'] = 'first_clear_reward_received'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
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


-------------------------------------
-- function getStageRichName
-- @brief "{@diff_normal'}보통 {@default}1-7" 형태의 텍스트 출력
-------------------------------------
function StructAdventureStageInfo:getStageRichName()
    local stage_id = self['stage_id']
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    local diff_str = ''
    local color_str = ''

    if (difficulty == 1) then
        color_str = 'diff_normal'
        diff_str = Str('보통')

    elseif (difficulty == 2) then
        color_str = 'diff_hard'
        diff_str = Str('어려움')

    elseif (difficulty == 3) then
        color_str = 'diff_hell'
        diff_str = Str('지옥')

    elseif (difficulty == 4) then
        color_str = 'diff_hellfire'
        diff_str = Str('불지옥')

    elseif (difficulty == 5) then
        color_str = 'diff_abyss_0'
        diff_str = Str('심연')

    elseif (difficulty == 6) then
        color_str = 'diff_abyss_1'
        diff_str = Str('심연 1')

    end

    local ret_str = '{@' .. color_str .. '}' .. diff_str .. ' {@default}' .. chapter .. '-' .. stage
    return ret_str
end