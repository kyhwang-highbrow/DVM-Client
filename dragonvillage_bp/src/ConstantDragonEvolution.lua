-- 레어도 1~4
MAX_DRAGON_RAIRITY = 4
MAX_DRAGON_EVOLUTION = 3

-------------------------------------
-- function evolutionName
-- @brief 드래곤 진화 단계별 표현 이름
-------------------------------------
function evolutionName(evolution_lv)
    local evolution_lv = evolution_lv
    -- 리더일때는 성룡으로 판단.
    if (evolution_lv == 'Leader') then
        evolution_lv = 3
    end

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