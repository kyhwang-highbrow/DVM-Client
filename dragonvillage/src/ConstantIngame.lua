--------------------------------------------------------------------------
-- 인게임 관련 상수
--------------------------------------------------------------------------

-- # 게임에 등장하는 테이머 ID
TAMER_ID = 110001

-- # 게임에 참여하는 드래곤 수
PARTICIPATE_DRAGON_CNT = 5

-- # 공용탄 미사일이 목표를 지나치고 난 후 사라지는 시간
MISSILE_FADE_OUT_TIME = 0.3

-- # 공용탄 미사일 발사 주기, (발사 주기 / 미사일 발사 수 = 발사 간격)
FIRE_LIMIT_TIME = 0.5

-- # 드래곤 스킬 콤보에 따른 쿨타임 버프 단위 계수
COOLTIME_BUFF_RATE = 0.2

-- # 웨이브 인터미션 시간과 맵 스크롤 가감 속도
WAVE_INTERMISSION_TIME = 1.5
WAVE_INTERMISSION_MAP_SPEED = 2000

-- # 인게임 시작 시 드래곤 등장 시간 .. 등장과 함께 맵 스크롤 속도 느려짐
DRAGON_APPEAR_TIME = 1
MAP_SCROLL_SPEED_DOWN_ACCEL = 350

-- # 테이머 스킬 글로벌 쿨타임
TAMER_SKILL_GLOBAL_COOLTIME = 1

--------------------------------------------
-- 피버모드
--------------------------------------------
-- #  피버모드 지속 시간
FEVER_KEEP_TIME = 6

-- #  피버 포인트 증감 시간
FEVER_POINT_UPDATE_TIME = 0.5

-- #  피버모드 스킬 캔슬시 점수
PERFECT_SKILL_CANCEL_FEVER_POINT = 30
GREAT_SKILL_CANCEL_FEVER_POINT = 25
GOOD_SKILL_CANCEL_FEVER_POINT = 15

-- #  피버모드 데미지 배율
FEVER_ATTACK_DAMAGE_RATE = 0.8

--------------------------------------------
-- 인게임 Flow 연출
--------------------------------------------
-- #  드래곤/몬스터 배치 후 흔들림 랜덤 범위(- ~ +)
CHARACTER_FLOATING_MIN_X_SCOPE = 5
CHARACTER_FLOATING_MAX_X_SCOPE = 8
CHARACTER_FLOATING_MIN_Y_SCOPE = 14
CHARACTER_FLOATING_MAX_Y_SCOPE = 20
-- #  드래곤/몬스터 배치 후 흔들림 반복 주기 시간(초)
CHARACTER_FLOATING_TIME = 1

-- # 배경 백판 floating 흔들림 범위(- ~ +)
MAP_FLOATING_Y_SCOPE = 6
-- # 배경 백판 floating 흔들림 반복 주기 시간(초)
MAP_FLOATING_TIME = 3
-- # 배경 백판 floating 회전 범위(- ~ +)
MAP_FLOATING_ROTATE_SCOPE = 0
-- # 배경 백판 floating 회전 반복 주기 시간
MAP_FLOATING_ROTATE_TIME = 5

--------------------------------------------
-- 각 스킬에서 공유하는 상수
--------------------------------------------
-- # SkillLeafBlade
 LEAF_COLLISION_SIZE = 30
 LEAF_STRAIGHT_ANGLE = 30
 LEAF_INDICATOR_EFFECT_DELAY = 5/1000

 -- # StatusEffect_PassiveSpatter
 STATUEEFFECT_GLOBAL_COOL = 0.5

--------------------------------------------
-- 인디케이터 리소스 경로
--------------------------------------------
RES_INDICATOR = 
{
	STRAIGHT = 'res/indicator/indicator_type_straight/indicator_type_straight.vrp',
	TARGET = 'res/indicator/indicator_type_target/indicator_type_target.vrp',
	CONE20 = 'res/indicator/indicator_type_cone_20/indicator_type_cone_20.vrp',
	CONE30 = 'res/indicator/indicator_type_cone_30/indicator_type_cone_30.vrp',
	RANGE = 'res/indicator/indicator_type_range/indicator_type_range.vrp',
	COMMON = 'res/indicator/indicator_common/indicator_common.vrp',
	EFFECT = 'res/indicator/indicator_effect_target/indicator_effect_target.vrp',

	BEZIER = 'res/indicator/indicator_bezier/indicator_bezier.vrp',
	HEALING_WIND = 'res/indicator/indicator_healing_wind/indicator_healing_wind.vrp',
}

RES_RANGE = 'res/effect/skill_range/skill_range.vrp'

--------------------------------------------
-- 유닛
--------------------------------------------
function isDragon(id)
    return ( math_floor(id / 10000) == 12 )
end

function isMonster(id)
    return ( math_floor(id / 10000) == 13 )
end

 --------------------------------------------
-- 디버깅용 
--------------------------------------------
-- # 드래곤 활성화 스킬을 출력한다. 
PRINT_DRAGON_SKILL = false

-- # 인게임 공격 정보를 콘솔에 출력한다
PRINT_ATTACK_INFO = false

-- # 보호막량을 인게임에 표시한다.
DISPLAY_SHIELD_HP = false

-- # 메모리 사용량 등 각종 디버깅 정보를 인게임에 출력한다
DISPLAY_DEBUG_INFO = false