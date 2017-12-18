-------------------------------------
-- class StructAttrTowerFloorData
-- @brief 시험의 탑 층 데이터
-------------------------------------
StructAttrTowerFloorData = class({
        m_stage = 'number',

        m_attr = 'string',              -- 시험의 탑 속성
        m_floor = 'number',             -- 층
        m_myScore = 'number',           -- 내 점수
        m_myTopUserScore = 'number',    -- 최고 유저 점수
        m_topUserInfo = 'StructUserInfo',                  
    })

-------------------------------------
-- function init
-------------------------------------
function StructAttrTowerFloorData:init(data)
    if data then
        self:applyTableData(data)
        self.m_floor = self.m_stage % ANCIENT_TOWER_STAGE_ID_START
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructAttrTowerFloorData:applyTableData(data)

    local replacement = {}
    replacement['stage']            = 'm_stage'
    replacement['attr']             = 'm_attr'
    replacement['attr_tower_score'] = 'm_myScore'
    replacement['topuser_score']    = 'm_myTopUserScore'
    replacement['topuser']          = 'm_topUserInfo'

    for k, v in pairs(data) do
        local key = replacement[k] and replacement[k] or k
        self[key] = v
    end
end

-------------------------------------
-- function getReward
-- @breif 최초 보상, 반복 보상 구분해서 반환
-------------------------------------
function StructAttrTowerFloorData:getReward()
    local id, cnt
    local current_floor = self.m_floor
    local clear_floor = g_attrTowerData.m_clearFloor

    if (current_floor > clear_floor) then
        id, cnt = self:getFirstReward()
    else
        id, cnt = self:getRepeatReward()
    end

    return id, cnt
end

-------------------------------------
-- function getFirstReward
-- @breif 최초 보상 정보
-------------------------------------
function StructAttrTowerFloorData:getFirstReward()
    local stage_id = self.m_stage
    local attr = g_attrTowerData:getSelAttr()
    local t_reward = TABLE:get('anc_floor_reward')[stage_id]
    local l_str = seperate(t_reward['reward_first_'..attr], ';')
    local item_type = l_str[1]
    local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
    local cnt = l_str[2]
    return id, cnt
end

-------------------------------------
-- function getRepeatReward
-- @breif 반복 보상 정보
-------------------------------------
function StructAttrTowerFloorData:getRepeatReward()
    local stage_id = self.m_stage
    local t_reward = TABLE:get('anc_floor_reward')[stage_id]
    local attr = g_attrTowerData:getSelAttr()
    local l_str = seperate(t_reward['reward_repeat_'..attr], ';')
    local item_type = l_str[1]
    local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
    local cnt = l_str[2]
    return id, cnt
end

-------------------------------------
-- function getMonsterList
-- @breif 출현 몬스터
-------------------------------------
function StructAttrTowerFloorData:getMonsterList()
    local stage_id = self.m_stage
    return TableStageDesc():getMonsterIDList(stage_id)
end