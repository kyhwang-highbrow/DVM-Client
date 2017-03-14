-- 레어도 1~4
MAX_DRAGON_RAIRITY = 4
MAX_DRAGON_EVOLUTION = 3

-------------------------------------
-- function evolutionName
-- @brief 드래곤 진화 단계별 표현 이름
-------------------------------------
function evolutionName(evolution_lv)
    if (evolution_lv == 1) then
        return Str('해치')
    elseif (evolution_lv == 2) then
        return Str('해츨링')
    elseif (evolution_lv == 3) then
        return Str('성룡')
    else
        error('evolution_lv : ' .. evolution_lv)
    end
end

-------------------------------------
-- function getEvolutionWeightStatus
-- @brief 진화 가중 능력치 (기초 능력치에 반영)
-------------------------------------
function getEvolutionWeightStatus(evolution_lv)
    if (evolution_lv == 1) then
        return 1
    elseif (evolution_lv == 2) then
        return 4
    elseif (evolution_lv == 3) then
        return 8
    else
        error('evolution_lv : ' .. evolution_lv)
    end
end

-------------------------------------
-- function dragonMaxLevel
-- @brief 드래곤 승급(grade)별 최대 레벨
-------------------------------------
function dragonMaxLevel(dragon_grade, eclv)
    if (dragon_grade == 1) then
        return 15
    elseif (dragon_grade == 2) then
        return 20
    elseif (dragon_grade == 3) then
        return 25
    elseif (dragon_grade == 4) then
        return 30
    elseif (dragon_grade == 5) then
        return 35
    elseif (dragon_grade == 6) then
        return 40 + (eclv * 2)
    else
        error('dragon_grade : ' .. dragon_grade)
    end
end