-------------------------------------
-- class AncientTowerScoreCalc
-------------------------------------
AncientTowerScoreCalc = class({
        m_lrecorder = 'list',

        m_score = 'number',         -- 스코어
        m_bonusAttr = 'string',
    })

local CLEAR_BONUS       = 500   -- 클리어 보너스
local NODEATH_BONUS     = 700   -- 생존 보너스
local BOSS_BONUS        = 0     -- 보스 제거 보너스
local ACTIVE_BONUS      = 0     -- 드래그 스킬 보너스
local WAVE_TOTAL_TIME   = 300
local ATTR_BONUS        = 480   -- 속성덱보너스

-------------------------------------
-- function init
-------------------------------------
function AncientTowerScoreCalc:init(recorder, stage_id)
    self.m_lrecorder = recorder or nil
    self.m_score = 0

    local t_info = TABLE:get('anc_floor_reward')[stage_id]
    self.m_bonusAttr = t_info['bonus_attr']

    self:calcFinalScore()
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
    local v6 = self:calcAttrBonus()

    self.m_score = (v1 + v2 + v3 + v4 + v5 + v6)
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
-- function calcAttrBonus
-- @brief 드래곤 속성 보너스
-- @brief 조건 : 스테이지에 지정된 속성의 드래곤
-------------------------------------
function AncientTowerScoreCalc:calcAttrBonus()
    -- 시험의 탑은 속성 보너스 제외
    if (g_ancientTowerData:isAttrChallengeMode()) then
        return 0
    end

    local recorder_info = self.m_lrecorder
    local active_count = 0

    local attr = nil
    if (self.m_bonusAttr and (self.m_bonusAttr ~= '')) then
        attr = self.m_bonusAttr
    end

    if attr then
        active_count = (recorder_info.m_attrCnt[attr] or 0)
    end

    return (ATTR_BONUS * active_count)
end

-------------------------------------
-- function getFinalScore
-------------------------------------
function AncientTowerScoreCalc:getFinalScore()
    return math_floor(self.m_score)
end


