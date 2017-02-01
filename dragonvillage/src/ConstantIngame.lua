--------------------------------------------
-- Constant Ingame
-- @brief - 각종 인게임 내부 동작에 필요한 상수 모음
--------------------------------------------

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

-- # 드래곤 스킬 HIT 콤보에 따른 쿨타임 시간 감축 단위 계수 
COOLTIME_BUFF_RATE = 0.2

-- # 웨이브 인터미션 맵 스크롤 가감 속도
WAVE_INTERMISSION_MAP_SPEED = 2000

-- # 인게임 시작 시 드래곤 등장 시간 .. 등장과 함께 맵 스크롤 속도 느려짐
DRAGON_APPEAR_TIME = 1
MAP_SCROLL_SPEED_DOWN_ACCEL = 350

-- # 액티브 스킬 글로벌 쿨타임(테이머 스킬 포함)
SKILL_GLOBAL_COOLTIME = 1

-- # StatusEffect Global cool time
STATUEEFFECT_GLOBAL_COOL = 0.5

-- # 화면 떨림 연출 시간
SHAKE_DURATION = 0.5

-- # 스크립트 제어 화면 떨림 변수
SHAKE_CUSTOM_MIN_POS = 10
SHAKE_CUSTOM_MAX_POS = 15

-- # 빠른 모드시 배속
QUICK_MODE_TIME_SCALE = 1.5

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
-- 친구 드래곤(임시)
--------------------------------------------
FRIEND_HERO = {
    skill_0 = 1,
    skill_1 = 1,
    skill_2 = 1,
    skill_3 = 1,
    eclv = 0,
	runes = {},
	lv = 10,
	evolution = 3,
	grade = 1,
	did = 120011
}