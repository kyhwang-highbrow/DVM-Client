-------------------------------------
-- class IllusionScoreCalc
-------------------------------------
IllusionScoreCalc = class({
        m_damage_score = 'number',
        m_participant_score = 'number',
        m_time_score = 'number',
        m_diff_score = 'number',
    })


local SCORE_DIFF = {[1] = 0, [2] = 1000, [3] = 2000, [4] = 5000}
local SCORE_PART = {['none'] = 0, ['illusion_dragon'] = 2500, ['my_dragon'] = 5000}

-------------------------------------
-- function init
-------------------------------------
function IllusionScoreCalc:init()
    self.m_damage_score = 0
    self.m_participant_score = 0
    self.m_time_score = 0
    self.m_diff_score = 0
end

-------------------------------------
-- function calcFinalScore
-------------------------------------
function IllusionScoreCalc:calcFinalScore()
    local final_score = (self.m_damage_score + self.m_participant_score + self.m_time_score + self.m_diff_score)
    
    -- 최종 계산에서만 소수점 절삭
    final_score = math_floor(final_score)
    return final_score
end

-------------------------------------
-- function calcDamageBonus
-------------------------------------
function IllusionScoreCalc:calcDamageBonus(damage)
    if (not damage) then
        return self.m_damage_score
    end
    self.m_damage_score = (damage / 5000)

    return self.m_damage_score
end

-------------------------------------
-- function calcClearTimeBonus
-------------------------------------
function IllusionScoreCalc:calcClearTimeBonus(time, is_success)
    if (not time) then
        return self.m_time_score
    end

    if (not is_success) then
        return 0
    end

    self.m_time_score = (5000 / 300) * (300 - time)

    return math.max(self.m_time_score, 0)
end

-------------------------------------
-- function calcDiffBonus
-- @brief 난이도 보너스 
-------------------------------------
function IllusionScoreCalc:calcDiffBonus(stage_id)
    if (not stage_id) then
        return self.m_diff_score
    end
    local diff = g_illusionDungeonData:parseStageID(stage_id)
    self.m_diff_score = SCORE_DIFF[tonumber(diff)] or 0

    return self.m_diff_score
end

-------------------------------------
-- function calcParticipantBonus
-------------------------------------
function IllusionScoreCalc:calcParticipantBonus()
    -- 참가 점수
    local participant = g_illusionDungeonData:getParticiPantInfo()
    local participant_score = 0  
    if (participant == 0) then
        participant_score = SCORE_PART['none']
    elseif (participant < 0) then
        participant_score = SCORE_PART['illusion_dragon']
    elseif (participant > 0) then
        participant_score = SCORE_PART['my_dragon']
    end

    self.m_participant_score = participant_score

    return self.m_participant_score
end