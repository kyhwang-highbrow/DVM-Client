-------------------------------------
-- function chapterName
-- @breif 챕터의 명칭 리턴
-------------------------------------
function chapterName(chapter)
    if (chapter == 1) then
        return Str('정령의 숲')

    elseif (chapter == 2) then
        return Str('사파이어 해')

    elseif (chapter == 3) then
        return Str('칼바람 협곡')

    elseif (chapter == 4) then
        return Str('화룡의 땅')

    elseif (chapter == 5) then
        return Str('잊혀진 하늘의 유적')

    elseif (chapter == 6) then
        return Str('절규하는 칠흑의 성')

    else
        return Str('개발용')

    end
end

-------------------------------------
-- function bossChapterName
-- @breif 챕터별 보스 이름
-------------------------------------
function bossChapterName(chapter)
    if (chapter == 1) then
        return Str('퀸즈스네이크')

    elseif (chapter == 2) then
        return Str('드레이크')

    elseif (chapter == 3) then
        return Str('코카트리스')

    elseif (chapter == 4) then
        return Str('')

    elseif (chapter == 5) then
        return Str('')

    elseif (chapter == 6) then
        return Str('')

    else
        return Str('개발용')

    end
end

-------------------------------------
-- function dragonRoleName
-- @brief 
-------------------------------------
function dragonRoleName(role_type)
    if (role_type == 'dealer') or (role_type == 1) then
        return Str('공격')
    elseif (role_type == 'tanker') or (role_type == 2) then
        return Str('방어')
    elseif (role_type == 'supporter') or (role_type == 3) then
        return Str('지원')
    elseif (role_type == 'healer') or (role_type == 4) then
        return Str('회복')
    else
        error('role_type: ' .. role_type)
    end
end

-------------------------------------
-- function dragonAttackTypeName
-- @brief 
-------------------------------------
function dragonAttackTypeName(attack_type)
    if (attack_type == 'physical') then
        return Str('물리')
    elseif (attack_type == 'magical') then
        return Str('마법')
    else
        error('attack_type: ' .. attack_type)
    end
end

-------------------------------------
-- function dragonRarityName
-- @brief 
-------------------------------------
function dragonRarityName(rarity)
    if (rarity == 'common') then
        return Str('일반')
    elseif (rarity == 'rare') then
        return Str('희귀')
    elseif (rarity == 'hero') then
        return Str('영웅')
    elseif (rarity == 'legend') then
        return Str('전설')
    else
        error('rarity: ' .. rarity)
    end
end

-------------------------------------
-- function dragonAttributeName
-- @brief 
-------------------------------------
function dragonAttributeName(attr)
    if (attr == 'fire') then
        return Str('불')
    elseif (attr == 'water') then
        return Str('물')
    elseif (attr == 'earth') then
        return Str('땅')
    elseif (attr == 'dark') then
        return Str('어둠')
    elseif (attr == 'light') then
        return Str('빛')
    else
        error('rarity: ' .. attr)
    end
end
