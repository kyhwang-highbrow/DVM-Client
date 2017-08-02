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
        return Str('맹독의 샘')

    elseif (chapter == 8) then
        return Str('밤사냥꾼 둥지')

    elseif (chapter == 9) then
        return Str('심연의 바다')

    elseif (chapter == 10) then
        return Str('바이델 외곽 숲')

    elseif (chapter == 11) then
        return Str('황혼의 신전')

    elseif (chapter == 12) then
        return Str('부서진 검은 요새')

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
        return Str('맹독거미여왕')

    elseif (chapter == 8) then
        return Str('밤사냥꾼')

    elseif (chapter == 9) then
        return Str('심연의 군주')

    elseif (chapter == 10) then
        return Str('퀸즈라미아')

    elseif (chapter == 11) then
        return Str('종말예언장치')

    elseif (chapter == 12) then
        return Str('부활한 다크닉스')

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
-- function dragonRoleTypeName
-- @brief 
-------------------------------------
function dragonRoleTypeName(role_type)
    if (role_type == 'dealer') or (role_type == 1) then
        return Str('공격형')
    elseif (role_type == 'tanker') or (role_type == 2) then
        return Str('방어형')
    elseif (role_type == 'supporter') or (role_type == 3) then
        return Str('지원형')
    elseif (role_type == 'healer') or (role_type == 4) then
        return Str('회복형')
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
-- function monsterRarityName
-- @brief 아직 명칭 미정
-------------------------------------
function monsterRarityName(rarity)
    if (rarity == 'common') then
        return Str('일반')
    elseif (rarity == 'elite') then
        return Str('보스')
    elseif (rarity == 'subboss') then
        return Str('보스')
    elseif (rarity == 'boss') then
        return Str('보스')
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

    if (skill_type == 'basic') then
        skill_type_str = Str('기본공격')

    elseif (skill_type == 'passive') then
        skill_type_str = Str('패시브 스킬')

    elseif (skill_type == 'active') then
        skill_type_str = Str('드래그 스킬')

	elseif (skill_type == 'leader') then
        skill_type_str = Str('리더 스킬')

    elseif (skill_type == 'colosseum') then
        skill_type_str = Str('콜로세움 스킬')

    elseif (skill_type == 'normal') then
        skill_type_str = Str('일반 스킬')

    else
        skill_type_str = Str('패시브 스킬')

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
    local skill_type = ''

	if (evolution == 0) then
        skill_type = 'normal'
    elseif (evolution == 1) then
        skill_type = 'passive'
    elseif (evolution == 2) then
        skill_type = 'passive'
    elseif (evolution == 3) then
        skill_type = 'active'
    else
        error('evolution : ' .. evolution)
    end

	return getSkillTypeStr(skill_type, false)
end

-------------------------------------
-- function getSkillType_Tamer
-- @brief 테이머 스킬 이름
-------------------------------------
function getSkillType_Tamer(skill_idx)
    local skill_type = ''

	if (skill_idx == 1) then
        skill_type = 'active'
    elseif (skill_idx == 2) then
        skill_type = 'passive'
    elseif (skill_idx == 3) then
        skill_type = 'passive'
    elseif (skill_idx == 4) then
        skill_type = 'colosseum'
    else
        error('skill_idx : ' .. skill_idx)
    end

	return getSkillTypeStr(skill_type, false)
end

-------------------------------------
-- function getUserInfoText
-- @brief 유저 상세 정보의 텍스트
-------------------------------------
local T_TITLE = {
	clr_stage_cnt = '클리어한 스테이지 수',
    play_cnt = '게임 플레이 횟수',
    clogin_max = '최대 연속 접속일',
    pvp_win = '콜로세움 누적 승률',
    tier = '현재 콜로세움 Tier',
    pvp_cnt = '콜로세움 누적 플레이 횟수',
    adv_time = '총 탐험 시간',
    d_6g_cnt = '6등급 드래곤의 수',
    d_cnt = '만난 드래곤 수',
    d_maxlv_cnt = 'Max 레벨 달성한 드래곤의 수',
    d_have_cnt = '현재 보유한 드래곤 수',
    created_at = '최초 접속일',
    ancient_score = '고대의 탑 최대 점수 총 합',
    login_days = '누적 접속일',
	enter = '',
}
function getUserInfoTitle(key)
    local title = T_TITLE[key] or Str('미정의된 플레이 기록')

	return Str(title)
end
