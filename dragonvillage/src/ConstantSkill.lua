--------------------------------------------
-- Constant Skill
-- @brief - 스킬과 관련된 상수 모음
--------------------------------------------

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

-- #SkillPenetration - Sitael
PENERATION_STD_DIST = 100
PENERATION_ANGLE_LIMIT = 45
PENERATION_DIST_LIMIT = 200

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
