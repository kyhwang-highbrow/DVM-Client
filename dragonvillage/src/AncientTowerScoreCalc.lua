-------------------------------------
-- class AncientTowerScoreCalc
-------------------------------------
AncientTowerScoreCalc = class({
        m_lrecorder = 'list',
        m_score = 'number'
    })

local CLEAR_BONUS       = 500   -- 클리어 보너스
local NODEATH_BONUS     = 700   -- 생존 보너스
local BOSS_BONUS        = 500   -- 보스 제거 보너스
local ACTIVE_BONUS      = 25    -- 드래그 스킬 보너스
local WAVE_TOTAL_TIME   = 180

-------------------------------------
-- function init
-------------------------------------
function AncientTowerScoreCalc:init(recorder)
    self.m_lrecorder = recorder or nil
    self.m_score = 0
    self:calcFinalScore()
end

-------------------------------------
-- function calcFinalScore
-------------------------------------
function AncientTowerScoreCalc:calcFinalScore()
    if (not self.m_lrecorder) then return end

    local recorder_info = self.m_lrecorder
    
    local clear_time    = recorder_info:getLog('lap_time')
    local death_count   = recorder_info:getLog('death_cnt')
    local finish_type   = recorder_info:getLog('finish_')
    local active_count  = recorder_info:getLog('active_kill_cnt')

    local v1 = self:calcClearBonus()
    local v2 = self:calcClearTimeBonus(clear_time)
    local v3 = self:calcClearNoDeathBonus(death_count)
    local v4 = self:calcKillBossBonus(finish_type)
    local v5 = self:calcAcitveSkillBonus(active_count)

    local weak_grade = self:getWeakGrade()

    cclog('-- 클리어 타임 : ' .. clear_time)
    cclog('-- 드래곤 사망수 : ' .. death_count)
    cclog('-- 보스 막타 : ' .. finish_type)
    cclog('-- 드래그 스킬로 적 처치 : ' .. active_count)
    cclog('-- 약화등급 + 1 : '.. weak_grade)

    -- 최종 계산에서만 소수점 절삭
    self.m_score = math_floor((v1 + v2 + v3 + v4 + v5) / (weak_grade))
    cclog('######################################')
    cclog('-- 최종 점수 : ' .. self.m_score)
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
function AncientTowerScoreCalc:calcClearTimeBonus(clear_time)
    return (WAVE_TOTAL_TIME - clear_time) * 5
end

-------------------------------------
-- function calcClearNoDeathBonus
-- @brief 생존 보너스 
-------------------------------------
function AncientTowerScoreCalc:calcClearNoDeathBonus(death_count)
    return (death_count == 0) and NODEATH_BONUS or 0
end

-------------------------------------
-- function calcKillBossBonus
-- @brief 보스 제거 보너스
-- @brief 조건 : 보스 막타가 드래그 스킬인 경우
-------------------------------------
function AncientTowerScoreCalc:calcKillBossBonus(attack_type)
    return (attack_type == 'active') and BOSS_BONUS or 0
end

-------------------------------------
-- function calcAcitveSkillBonus
-- @brief 드래그 스킬 보너스
-- @brief 조건 : 드래그 스킬로 적을 처치한 경우
-------------------------------------
function AncientTowerScoreCalc:calcAcitveSkillBonus(active_count)
    return (ACTIVE_BONUS * active_count)
end

-------------------------------------
-- function getWeakGrade
-- @brief 약화효과 등급
-------------------------------------
function AncientTowerScoreCalc:getWeakGrade()
    local weak_grade = g_ancientTowerData:getChallengingCount()
    return (weak_grade + 1)
end

-------------------------------------
-- function getScore
-------------------------------------
function AncientTowerScoreCalc:getScore()
    return self.m_score
end


