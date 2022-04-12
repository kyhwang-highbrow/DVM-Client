-------------------------------------
-- function getGradeWeightStatus
-- @brief 등급 가중 능력치 (최종 능력치에 반영)
-------------------------------------
function getGradeWeightStatus(grade)
    if (grade == 1) then
        return 1
    elseif (grade == 2) then
        return 1.5
    elseif (grade == 3) then
        return 2
    elseif (grade == 4) then
        return 2.5
    elseif (grade == 5) then
        return 3
    elseif (grade == 6) then
        return 3.5
    else
        error()
    end
end

-------------------------------------
-- function getDragonRarityName
-- @brief 드래곤 희귀 단계별 표현 이름
-------------------------------------
function getDragonRarityName(rarity)
    if (rarity == 1) then
        return '일반'
    elseif (rarity == 2) then
        return '희귀'
    elseif (rarity == 3) then
        return '영웅'
    elseif (rarity == 4) then
        return '전설'
    elseif (rarity == 5) then
        return '신화'
    else
        error()
    end
end

-------------------------------------
-- function dragonRarityNumToStr
-- @brief 
-------------------------------------
function dragonRarityNumToStr(rarity_num)
    if (type(rarity_num) == 'string') then
        return rarity_num
    end

    if (rarity_num == 1) then
        return 'common'

    elseif (rarity_num == 2) then
        return 'rare'

    elseif (rarity_num == 3) then
        return 'hero'

    elseif (rarity_num == 4) then
        return 'legend'

    elseif (rarity_num == 5) then
        return 'myth'

    else
        error('rarity_num : ' .. rarity_num)
    end
end

-------------------------------------
-- function dragonRarityStrToNum
-- @brief 
-------------------------------------
function dragonRarityStrToNum(rarity_str)
    if (type(rarity_str) == 'number') then
        return rarity_str
    end

    if (rarity_str == 'common') then
        return 1

    elseif (rarity_str == 'rare') then
        return 2

    elseif (rarity_str == 'hero') then
        return 3

    elseif (rarity_str == 'legend') then
        return 4

    elseif (rarity_str == 'myth') then
        return 5

    else
        error('rarity_str : ' .. rarity_str)
    end
end

-------------------------------------
-- function evolutionStoneRarityStrToNum
-- @brief 
-------------------------------------
function evolutionStoneRarityStrToNum(rarity_str)
    if (type(rarity_str) == 'number') then
        return rarity_str
    end

    if (rarity_str == 'common') then
        return 1

    elseif (rarity_str == 'rare') then
        return 2

    elseif (rarity_str == 'hero') then
        return 3

    elseif (rarity_str == 'legend') then
        return 4

    elseif (rarity_str == 'myth') then
        return 5

    else
        error('rarity_str : ' .. rarity_str)
    end
end

-------------------------------------
-- function evolutionStoneRarityNumToStr
-- @brief 
-------------------------------------
function evolutionStoneRarityNumToStr(rarity_num)
    if (type(rarity_num) == 'string') then
        return rarity_num
    end

    if (rarity_num == 1) then
        return 'common'

    elseif (rarity_num == 2) then
        return 'rare'

    elseif (rarity_num == 3) then
        return 'hero'

    elseif (rarity_num == 4) then
        return 'legend'

    elseif (rarity_num == 5) then
        return 'myth'

    else
        error('rarity_num : ' .. rarity_num)
    end
end