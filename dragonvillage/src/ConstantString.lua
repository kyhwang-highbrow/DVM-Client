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

    elseif (chapter == 7) then
        return Str('미지정')

    elseif (chapter == 8) then
        return Str('미지정')

    elseif (chapter == 9) then
        return Str('미지정')

    elseif (chapter == 10) then
        return Str('미지정')

    elseif (chapter == 11) then
        return Str('미지정')

    elseif (chapter == 12) then
        return Str('미지정')

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
        return Str('용암거미여왕')

    elseif (chapter == 5) then
        return Str('질서유지장치')

    elseif (chapter == 6) then
        return Str('다크닉스')

    elseif (chapter == 7) then
        return Str('')

    elseif (chapter == 8) then
        return Str('')

    elseif (chapter == 9) then
        return Str('')

    elseif (chapter == 10) then
        return Str('')

    elseif (chapter == 11) then
        return Str('')

    elseif (chapter == 12) then
        return Str('')

    else
        return Str('개발용 or 미지정')

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

-------------------------------------
-- function getSkillTypeStr
-- @param is_use_brakets : 괄호 사용 여부 
-------------------------------------
function getSkillTypeStr(skill_type, is_use_brakets)
	local skill_type_str = ''
	local is_use_brakets = is_use_brakets or true

    if (skill_type == 'basic') then
        skill_type_str = Str('기본공격')

    elseif isExistValue(skill_type, 'basic_turn', 'basic_rate', 'indie_turn', 'indie_rate', 'indie_time', 'under_atk_turn', 'under_atk_rate') then
        skill_type_str = Str('일반')

    elseif (skill_type == 'passive') then
        skill_type_str = Str('패시브')

    elseif (skill_type == 'touch') then
        skill_type_str = Str('액티브')

    elseif (skill_type == 'active') then
        skill_type_str = Str('액티브')

    else
        cclog('## 정의되지 않은 skill_type : ' .. skill_type)
    end

	if is_use_brakets then
		skill_type_str = '(' .. skill_type_str .. ')'
	end

	return skill_type_str
end

-------------------------------------
-- function getSkillType_byEvolution
-- @brief 진화 단계에 따른 스킬 타입명
-------------------------------------
function getSkillType_byEvolution(evolution)
    local str = ''

	if (evolution == 0) then
        str = Str('일반 스킬')
    elseif (evolution == 1) then
        str = Str('패시브 스킬')
    elseif (evolution == 2) then
        str = Str('패시브 스킬')
    elseif (evolution == 3) then
        str = Str('액티브 스킬')
    else
        error('evolution : ' .. evolution)
    end

	return str
end