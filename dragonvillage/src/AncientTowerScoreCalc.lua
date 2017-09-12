-------------------------------------
-- class AncientTowerScoreCalc
-------------------------------------
AncientTowerScoreCalc = class({
        m_lrecorder = 'list',

        m_score = 'number',         -- 약화등급 계산전 스코어
        m_final_score = 'number',   -- 약화등급 계산후 스코어

        m_weak_grade = 'number'
    })

local CLEAR_BONUS       = 500   -- 클리어 보너스
local NODEATH_BONUS     = 700   -- 생존 보너스
local BOSS_BONUS        = 700    -- 보스 제거 보너스
local ACTIVE_BONUS      = 0    -- 드래그 스킬 보너스
local WAVE_TOTAL_TIME   = 240

-------------------------------------
-- function init
-------------------------------------
function AncientTowerScoreCalc:init(recorder)
    self.m_lrecorder = recorder or nil
    self.m_score = 0
    self.m_final_score = 0
    self:setChallengingWeakGrade()
    self:calcFinalScore()
end

-------------------------------------
-- function setChallengingWeakGrade
-------------------------------------
function AncientTowerScoreCalc:setChallengingWeakGrade()
    local fail_cnt = g_ancientTowerData.m_challengingCount
    local weak_grade = g_ancientTowerData:getWeakGrade(fail_cnt)
    self.m_weak_grade = weak_grade
end

-------------------------------------
-- function calcFinalScore
-------------------------------------
function AncientTowerScoreCalc:calcFinalScore()
    if (not self.m_lrecorder) then return end

    local v1 = self:calcClearBonus()
    local v2 = self:calcClearTimeBonus()
    local v3 = self:calcClearNoDeathBonus()
    local v4 = self:calcKillBossBonus()
    local v5 = self:calcAcitveSkillBonus()

    self.m_score = (v1 + v2 + v3 + v4 + v5)

    local weak_grade = self.m_weak_grade + 1

    -- 최종 계산에서만 소수점 절삭
    self.m_final_score = math_floor(self.m_score / (weak_grade))
end

-------------------------------------
-- function calcClearBonus
-- @brief 클리어 보너스 
-------------------------------------
function AncientTowerScoreCalc:calcClearBonus()
    return CLEAR_BONUS
end

-------------------------------------
-- function calcClearTimeBonus
-- @brief 클리어 시간 보너스 
-------------------------------------
function AncientTowerScoreCalc:calcClearTimeBonus()
    local recorder_info = self.m_lrecorder
    local clear_time    = recorder_info:getLog('lap_time')

    return math_max((WAVE_TOTAL_TIME - clear_time) * 8, 0)
end

-------------------------------------
-- function calcClearNoDeathBonus
-- @brief 생존 보너스 
-------------------------------------
function AncientTowerScoreCalc:calcClearNoDeathBonus()
    local recorder_info = self.m_lrecorder
    local death_count   = recorder_info:getLog('death_cnt')

    return (death_count == 0) and NODEATH_BONUS or 0
end

-------------------------------------
-- function calcKillBossBonus
-- @brief 보스 제거 보너스
-- @brief 조건 : 보스 막타가 드래그 스킬인 경우
-------------------------------------
function AncientTowerScoreCalc:calcKillBossBonus()
    local recorder_info = self.m_lrecorder
    local finish_type   = recorder_info:getLog('finish_atk')
    return (finish_type == 'active') and BOSS_BONUS or 0
end

-------------------------------------
-- function calcAcitveSkillBonus
-- @brief 드래그 스킬 보너스
-- @brief 조건 : 드래그 스킬로 적을 처치한 경우
-------------------------------------
function AncientTowerScoreCalc:calcAcitveSkillBonus()
    local recorder_info = self.m_lrecorder
    local active_count  = recorder_info:getLog('active_kill_cnt')

    return (ACTIVE_BONUS * active_count)
end

-------------------------------------
-- function getWeakGradeMinusScore
-- @brief 약화효과로 인한 마이너스 점수 가져옴
-------------------------------------
function AncientTowerScoreCalc:getWeakGradeMinusScore()
    local score = self.m_score
    local final_score = self.m_final_score
    return -math_floor(score - final_score)
end

-------------------------------------
-- function getFinalScore
-------------------------------------
function AncientTowerScoreCalc:getFinalScore()
    return self.m_final_score
end


