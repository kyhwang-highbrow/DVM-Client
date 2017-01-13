--------------------------------------------------------------------------
-- PhysKey 상수
--------------------------------------------------------------------------
PHYS = {
	HERO = 'hero',
	ENEMY = 'enemy',
	EFFECT = 'effect',
	MISSILE = {
		HERO = 'missile_h',
		ENEMY = 'missile_e'
	}
}

--------------------------------------------------------------------------
-- 인게임 관련 상수
--------------------------------------------------------------------------
-- # 게임에 등장하는 테이머 ID
TAMER_ID = 110001

-- # 1 frame
ONE_FRAME = 1/30

-- # 게임에 참여하는 드래곤 수
PARTICIPATE_DRAGON_CNT = 5

-- # 공용탄 미사일이 목표를 지나치고 난 후 사라지는 시간
MISSILE_FADE_OUT_TIME = 0.2

-- # 공용탄 미사일 발사 주기, (발사 주기 / 미사일 발사 수 = 발사 간격)
FIRE_LIMIT_TIME = 0.5

-- # 드래곤 스킬 콤보에 따른 쿨타임 버프 단위 계수
COOLTIME_BUFF_RATE = 0.2

-- # 웨이브 인터미션 맵 스크롤 가감 속도
WAVE_INTERMISSION_MAP_SPEED = 2000

-- # 인게임 시작 시 드래곤 등장 시간 .. 등장과 함께 맵 스크롤 속도 느려짐
DRAGON_APPEAR_TIME = 1
MAP_SCROLL_SPEED_DOWN_ACCEL = 350

-- # 테이머 스킬 글로벌 쿨타임
TAMER_SKILL_GLOBAL_COOLTIME = 1

-- # StatusEffect Global cool time
STATUEEFFECT_GLOBAL_COOL = 0.5

-- # 화면 떨림 연출 시간
SHAKE_DURATION = 0.5

-- # 스크립트 제어 화면 떨림 변수
SHAKE_CUSTOM_DURATION = 0.3
SHAKE_CUSTOM_MIN_POS = 5
SHAKE_CUSTOM_MAX_POS = 50

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
-- 각 스킬에서 사용하는 상수
--------------------------------------------
-- # SkillLaser
LASER_ATK_DELAY = 0.5

-- # SkillLeafBlade
LEAF_COLLISION_SIZE = 30
LEAF_STRAIGHT_ANGLE = 30
LEAF_INDICATOR_EFFECT_DELAY = 5/1000

-- # SkillVoltesX
VOLTES_ATTACK_INTERVAL = 0.3
VOLTES_FINAL_ATTACK_TIME = 2

--------------------------------------------
-- 인디케이터 리소스 경로
--------------------------------------------
RES_INDICATOR = 
{
	STRAIGHT = 'res/indicator/indicator_type_straight/indicator_type_straight.vrp',
    STRAIGHT_WIDTH = 'res/indicator/indicator_type_straight_wide/indicator_type_straight_wide.vrp',
	CONE20 = 'res/indicator/indicator_type_cone_20/indicator_type_cone_20.vrp',
	CONE30 = 'res/indicator/indicator_type_cone_30/indicator_type_cone_30.vrp',
	RANGE = 'res/indicator/indicator_type_range/indicator_type_range.vrp',
	BEZIER = 'res/indicator/indicator_bezier/indicator_bezier.vrp',
	HEALING_WIND = 'res/indicator/indicator_healing_wind/indicator_healing_wind.vrp',
	X = 'res/indicator/indicator_type_x/indicator_type_x.vrp',

	COMMON = 'res/indicator/indicator_common/indicator_common.vrp',
	TARGET = 'res/indicator/indicator_type_target/indicator_type_target.vrp',
	EFFECT = 'res/indicator/indicator_effect_target/indicator_effect_target.vrp',
}

RES_RANGE = 'res/effect/skill_range/skill_range.vrp'
