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

    elseif (chapter == SPECIAL_CHAPTER.RUNE_FESTIVAL) then
        return Str('할로윈 비밀 스테이지')

    elseif (chapter == SPECIAL_CHAPTER.ADVENT) then
        return Str('깜짝 출현')

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
-- function getSkillTypeStr_Tamer
-- @brief 테이머쪽 스킬이름은 줄여서 씀, 드래그 스킬도 액티브로 보여줌
-------------------------------------
function getSkillTypeStr_Tamer(skill_type)
    local skill_type_str = ''
    local color 
    if (skill_type == 'basic') then
        skill_type_str =  Str('기본')
        color = cc.c3b(255,255,255)

    elseif (skill_type == 'leader') then
        skill_type_str = Str('리더')
        color = cc.c3b(199,69,255)

    elseif (skill_type == 'active') then
        skill_type_str = Str('액티브')
        color = cc.c3b(244,191,5)

    elseif (skill_type == 'passive') then
        skill_type_str = Str('패시브')
        color = cc.c3b(255,231,160)

    elseif (skill_type == 'colosseum') then
        skill_type_str = Str('콜로세움')
        color = cc.c3b(255,85,149)
    else
        skill_type_str = Str('패시브')
        color = cc.c3b(255,231,160)
    end

    return skill_type_str, color
end

-------------------------------------
-- function getSkillType_Tamer
-- @brief 테이머 스킬 이름
-------------------------------------
function getSkillType_Tamer(skill_idx)
    local skill_type = ''

	if (skill_idx == 0) then
        skill_type = 'active'
    elseif (skill_idx == 1) then
        skill_type = 'passive'
    elseif (skill_idx == 2) then
        skill_type = 'passive'
    elseif (skill_idx == 3) then
        skill_type = 'colosseum'
    else
        error('skill_idx : ' .. skill_idx)
    end

	return getSkillTypeStr(skill_type, false)
end

-------------------------------------
-- function getContentName
-- @brief 컨텐츠 이름
-- @param content_type string
        -- sgkim 2017-08-03
        -- table_content_lock.csv와 용어 통일
        -- adventure	모험
        -- exploration	탐험
        -- nest_tree	[네스트] 거목 던전
        -- nest_evo_stone	[네스트] 진화재료 던전
        -- ancient	고대의 탑
        -- colosseum	콜로세움
        -- nest_nightmare	[네스트] 악몽 던전
        -- secret_relation 인연던전
-------------------------------------
function getContentName(content_type)
    local content_name = ''

    if (content_type == 'adventure') then
        content_name = Str('모험')
    
    elseif (content_type == 'exploration') or (content_type == 'exploation') then
        content_name = Str('탐험')
    
    elseif (content_type == 'colosseum') then
        content_name = Str('콜로세움')

    elseif (content_type == 'arena_new') then
        content_name = Str('콜로세움')

    elseif (content_type == 'ancient') then
        content_name = Str('고대의 탑')

    elseif (content_type == 'attr_tower') then
        content_name = Str('시험의 탑')

    elseif (content_type == 'nest_tree') then
        content_name = Str('거목 던전')

    elseif (content_type == 'nest_evo_stone') then
        content_name = Str('거대용 던전')

    elseif (content_type == 'nest_nightmare') then
        content_name = Str('악몽 던전')

    elseif (content_type == 'secret_relation') then
        content_name = Str('인연 던전')

    elseif (content_type == 'clan') then
        content_name = Str('클랜')

    elseif (content_type == 'clan_raid') then
        content_name = Str('클랜 던전')

    elseif (content_type == 'clan_raid_1') then
        content_name = Str('클랜던전(1공격대)')

    elseif (content_type == 'clan_raid_2') then
        content_name = Str('클랜던전(2공격대)')

    elseif (content_type == 'ancient_ruin') then
        content_name = Str('고대 유적 던전')

    elseif (content_type == 'gold_dungeon') then
        content_name = Str('황금 던전')

    elseif (content_type == 'challenge_mode') then
        content_name = Str('그림자의 신전')

    elseif (content_type == 'rune_guardian') then
        content_name = Str('룬 수호자 던전')

    elseif (content_type == 'grand_arena') then
        content_name = Str('그랜드 콜로세움')
    
    elseif (content_type == 'shop_random') then
        content_name = Str('마녀의 상점')

    elseif (content_type == 'forest') then
        content_name = Str('드래곤의 숲')

    elseif (content_type == 'capsule') then
        content_name = Str('캡슐 뽑기')

	elseif (content_type == 'daily_shop') or (content_type == 'shop_daily')then
        content_name = Str('일일 상점')

    elseif (content_type == 'clan_war') then
        content_name = Str('클랜전')
        
    elseif (content_type == 'dmgate') then
        content_name = Str('차원문')
    else
        error('content_type : ' .. content_type)
    end

    return content_name
end

-------------------------------------
-- function getUserInfoText
-- @brief 유저 상세 정보의 텍스트
-------------------------------------
local T_TITLE = {
	clr_stage_cnt = Str('클리어한 스테이지 수'),
    play_cnt = Str('게임 플레이 횟수'),
    clogin_max = Str('최대 연속 접속일'),
    pvp_win = Str('콜로세움 누적 승률'),
    tier = Str('현재 콜로세움 Tier'),
    pvp_cnt = Str('콜로세움 누적 플레이 횟수'),
    adv_time = Str('총 탐험 시간'),
    d_6g_cnt = Str('6등급 드래곤의 수'),
    d_cnt = Str('만난 드래곤 수'),
    d_maxlv_cnt = Str('Max 레벨 달성한 드래곤의 수'),
    d_have_cnt = Str('현재 보유한 드래곤 수'),
    created_at = Str('최초 접속일'),
    ancient_score = Str('고대의 탑 최대 점수 총 합'),
    login_days = Str('누적 접속일'),
	enter = '',
}
function getUserInfoTitle(key)
    local title = T_TITLE[key] or Str('미정의된 플레이 기록')

	return Str(title)
end

-------------------------------------
-- function addToTranslation
-- @brief 번역 수집 되도록 동작하지 않는 함수에 묶어 저장
-------------------------------------
function addToTranslation()
	Str('고급 소환 ★5 전설 확정')
	Str('★5 전설 확정까지 {1}회 남음')
	Str('고급 소환, 확률UP 고급소환을 100번 진행하면 ★5 전설 드래곤을 확정으로 획득할 수 있습니다.')
end

-------------------------------------
-- function GetLoadingStrList
-- @brief 로딩 문구 테이블 반환
-------------------------------------
function GetLoadingStrList()
    return {
        Str('드래곤들 멱을 감는 중...'),
        Str('테이머 장비를 조이는 중...'),
        Str('드래곤들 발톱을 닦아주는 중...'),
        Str('떠날 곳 지도를 확인하는 중...'),
        Str('간식 거리를 챙기는 중...'),
        Str('드래곤들 날개를 닦아주는 중...'),
    }
end

-------------------------------------
-- function getIndicatorName
-- @brief 인디케이터 이름
-------------------------------------
function getIndicatorName(indicator_type)
    local indicator_name = ''

    if (indicator_type == 'bar') then
        indicator_name = Str('직선')
    
    elseif (indicator_type == 'cross') then
        indicator_name = Str('교차')
    
    elseif (indicator_type == 'curve_twin') then
        indicator_name = Str('곡선')
    
    elseif (indicator_type == 'round') then
        indicator_name = Str('원형')

    elseif (indicator_type == 'square_height') then
        indicator_name = Str('세로')

    elseif (indicator_type == 'square_height_top') then
        indicator_name = Str('세로')

    elseif (indicator_type == 'square_height_touch') then
        indicator_name = Str('세로')

    elseif (indicator_type == 'square_width') then
        indicator_name = Str('가로')

    elseif (indicator_type == 'square_width_right') then
        indicator_name = Str('가로')

    elseif (indicator_type == 'square_width_touch') then
        indicator_name = Str('가로')

    elseif (indicator_type == 'target_cone') then
        indicator_name = Str('원뿔')

    elseif (indicator_type == 'voltes_x') then
        indicator_name = Str('교차')

    elseif (indicator_type == 'wedge') then
        indicator_name = Str('확산')

    else
        error('indicator_type : ' .. indicator_type)
    end

    return indicator_name
end

-------------------------------------
-- function getIndicatorSizeName
-- @brief 인디케이터 사이즈 명
-------------------------------------
function getIndicatorSizeName(size)
    local indicator_size_name
    if (size == 1) then
        indicator_size_name = Str('소')

    elseif (size == 2) then
        indicator_size_name = Str('중')

    elseif (size == 3) then
        indicator_size_name = Str('대')

    else
        error('indicator_size : ' .. size)
    end

    return indicator_size_name
end

-------------------------------------
-- function getItemNameWithStar
-- @brief 아이템 알인 경우 부화등급까지 표시
-------------------------------------
function getItemNameWithStar(item_id)
    local map_grade = {}
    map_grade['703001'] = '★5' -- 신화의 알
    map_grade['703005'] = '★5' -- 전설의 알
    map_grade['703003'] = '★4~5' -- 초월의 알
    map_grade['703019'] = '★4~5' -- 고대의 알

    local item_name = TableItem():getItemName(item_id)
    local grade = map_grade[tostring(item_id)]
    if (grade) then
        item_name = grade .. ' ' .. item_name
    end
    return item_name
end

-------------------------------------
-- function getWeekdayName
-- @brief
-------------------------------------
function getWeekdayName(weekday_name)
    local weekday_name_lower = weekday_name:lower()

    if (weekday_name_lower == 'mon') then
        return Str('월요일')
    elseif (weekday_name_lower == 'tue') then
        return Str('화요일')
    elseif (weekday_name_lower == 'wed') then
        return Str('수요일')
    elseif (weekday_name_lower == 'thu') then
        return Str('목요일')
    elseif (weekday_name_lower == 'fri') then
        return Str('금요일')
    elseif (weekday_name_lower == 'sat') then
        return Str('토요일')
    elseif (weekday_name_lower == 'sun') then
        return Str('일요일')
    end

    return ''
end