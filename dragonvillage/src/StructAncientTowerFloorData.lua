-------------------------------------
-- class StructAncientTowerFloorData
-- @brief 고대의 탑 층 데이터
-------------------------------------
StructAncientTowerFloorData = class({
        m_stage = 'number',

        m_floor = 'number',        
        m_myScore = 'number',           -- 현 시즌 내 점수
        m_myHighScore = 'number',       -- 역대 내 최고 점수
        m_seasonHighScore = 'number',   -- 현 시즌 유저 최고 점수

        m_topUserInfo = 'StructUserInfo',
        
        m_failCnt = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StructAncientTowerFloorData:init(data)
    if data then
        self:applyTableData(data)
        self.m_floor = self.m_stage % ANCIENT_TOWER_STAGE_ID_START
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructAncientTowerFloorData:applyTableData(data)

    local replacement = {}
    replacement['stage']            = 'm_stage'
    replacement['score']            = 'm_myScore'
    replacement['hiscore']          = 'm_myHighScore'
    replacement['topuser_score']    = 'm_seasonHighScore'
    replacement['fail_cnt']         = 'm_failCnt'
    replacement['topuser']          = 'm_topUserInfo'

    for k, v in pairs(data) do
        local key = replacement[k] and replacement[k] or k
        self[key] = v
    end

    -- topuser -> StructUserInfoAncientTower 로
    local user_info = clone(self.m_topUserInfo)
    if (user_info) then
        self.m_topUserInfo = StructUserInfoAncientTower(user_info)
        self.m_topUserInfo.m_nickname = user_info['nick']
        if (user_info['clan_info']) then
            local struct_clan = StructClan({})
            struct_clan:applySimple(user_info['clan_info'])
            self.m_topUserInfo:setStructClan(struct_clan)
        end
    end
end

-------------------------------------
-- function getReward
-- @breif 최초 보상, 반복 보상 구분해서 반환
-------------------------------------
function StructAncientTowerFloorData:getReward()
    local id, cnt
    local current_floor = self.m_floor
    local clear_floor = g_ancientTowerData.m_clearFloor

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
function StructAncientTowerFloorData:getFirstReward()
    local stage_id = self.m_stage
    local t_reward = TABLE:get('anc_floor_reward')[stage_id]
    local l_str = seperate(t_reward['reward_first'], ';')
    local item_type = l_str[1]
    local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
    local cnt = l_str[2]
    return id, cnt
end

-------------------------------------
-- function getRepeatReward
-- @breif 반복 보상 정보
-------------------------------------
function StructAncientTowerFloorData:getRepeatReward()
    local stage_id = self.m_stage
    local t_reward = TABLE:get('anc_floor_reward')[stage_id]
    local l_str = seperate(t_reward['reward_repeat'], ';')
    local item_type = l_str[1]
    local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
    local cnt = l_str[2]
    return id, cnt
end

-------------------------------------
-- function getMonsterList
-- @breif 출현 몬스터
-------------------------------------
function StructAncientTowerFloorData:getMonsterList()
    local stage_id = self.m_stage
    return TableStageDesc():getMonsterIDList(stage_id)
end