--------------------------------------------
-- Constant Skill
-- @brief - 스킬과 관련된 상수 모음
--------------------------------------------

--------------------------------------------
-- 각 스킬에서 사용하는 상수
--------------------------------------------
--# Common
SKILL_ANGLE_LIMIT = 60

-- # SkillLaser
LASER_ATK_DELAY = 0.5

-- # SkillLeafBlade
LEAF_COLLISION_SIZE = 30
LEAF_STRAIGHT_ANGLE = 30
LEAF_INDICATOR_EFFECT_DELAY = 5/1000

-- # SkillVoltesX
VOLTES_ATTACK_INTERVAL = 0.3
VOLTES_FINAL_ATTACK_TIME = 2

-- #SkillPenetration - Sitael
PENERATION_ATK_START_POS_DIST = 100				-- 드래곤 원점과 스킬 중심좌표 사이의 거리
PENERATION_TOTAL_LENGTH = 500					-- 발사체를 늘어놓는 전체 거리 (무기간 간격 = 전체거리/발사체 개수)
PENERATION_ANGLE_LIMIT = 45						-- 시전 각도 제한
PENERATION_DIST_LIMIT = 200						-- 시전 거리 제한
PENERATION_APPEAR_INTERVAR = ONE_FRAME * 2		-- 발사체 등장 간격
PENERATION_FIRE_DELAY = 0.5						-- 등장 후 발사 딜레이 

--------------------------------------------
-- 인디케이터 리소스 경로
--------------------------------------------
RES_INDICATOR = 
{
	STRAIGHT = 'res/indicator/indicator_type_straight/indicator_type_straight.vrp',
    STRAIGHT_WIDTH = 'res/indicator/indicator_type_straight_wide/indicator_type_straight_wide.vrp',
	HEALING_WIND = 'res/indicator/indicator_healing_wind/indicator_healing_wind.vrp',
	
	CONE20 = 'res/indicator/indicator_type_cone_20/indicator_type_cone_20.vrp',
	CONE30 = 'res/indicator/indicator_type_cone_30/indicator_type_cone_30.vrp',
	CONE40 = 'res/indicator/indicator_type_cone_30/indicator_type_cone_40.vrp',

	RANGE = 'res/indicator/indicator_type_range/indicator_type_range.vrp', --> 과거에 서펀트 드래곤이 사정거리 표시할때 사용하던 인디케이터
	BEZIER = 'res/indicator/indicator_bezier/indicator_bezier.vrp',
	X = 'res/indicator/indicator_type_x/indicator_type_x.vrp',

	COMMON = 'res/indicator/indicator_common/indicator_common.vrp',
	TARGET = 'res/indicator/indicator_type_target/indicator_type_target.vrp',
	EFFECT = 'res/indicator/indicator_effect_target/indicator_effect_target.vrp',
}

-- 스킬 시전후 스킬 시전 범위 나타내는 이펙트..빨간색
RES_RANGE = 'res/effect/skill_range/skill_range.vrp'
