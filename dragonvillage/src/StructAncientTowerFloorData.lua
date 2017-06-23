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

local MAX_WEAK_GRADE = 5 -- 최대 약화 등급
local NEED_STAMINA = 5 -- 필요 활동력

-------------------------------------
-- function init
-------------------------------------
function StructAncientTowerFloorData:init(data)
    if data then
        self:applyTableData(data)
    end
    
    self.m_floor = self.m_stage % 100
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
-- function getMonsterList
-- @breif 출현 몬스터
-------------------------------------
function StructAncientTowerFloorData:getMonsterList()
    local stage_id = self.m_stage
    return TableStageDesc():getMonsterIDList(stage_id)
end

-------------------------------------
-- function getCurrentWeakGrade
-- @breif 현재 약화 등급
-------------------------------------
function StructAncientTowerFloorData:getCurrentWeakGrade()
    local fail_cnt = self.m_failCnt
    local weak_grade = (fail_cnt > MAX_WEAK_GRADE) and MAX_WEAK_GRADE or fail_cnt
    return weak_grade
end

-------------------------------------
-- function getNeedStamina
-- @breif 필요 활동력
-------------------------------------
function StructAncientTowerFloorData:getNeedStamina()
    return NEED_STAMINA
end

-------------------------------------
-- function getNeedStamina
-- @breif 현재 층 랭커 닉네임
-------------------------------------
function StructAncientTowerFloorData:getTopUserNick()
    local top_user_info = self.m_topUserInfo
    -- 랭커 없을 경우 
    if (not top_user_info) then return '' end

    return top_user_info['nick'] or ''
end
