-------------------------------------
-- DragonSkillBonusHelper
-------------------------------------
DragonSkillBonusHelper = {}

-------------------------------------
-- function getBonusLevel
-- @brief 해당 스킬 타겟수 점수(%)에 해당하는 보너스 단계를 얻음(0이면 보너스 없음)
-------------------------------------
function DragonSkillBonusHelper:getBonusLevel(dragon, score)
    local list = TableDragonSkillBonus():getLevelCondition(dragon.m_dragonID)

    if (list) then
        for i = #list, 1, -1 do
            if (score >= list[i]) then
                return i
            end
        end
    end
    
    return 0
end