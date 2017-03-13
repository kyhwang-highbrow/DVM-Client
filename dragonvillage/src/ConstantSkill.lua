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
LEAF_ANGLE_LIMIT = 60
LEAF_DIST_LIMIT = 400

-- # SkillVoltesX
VOLTES_ATTACK_INTERVAL = 0.3
VOLTES_FINAL_ATTACK_TIME = 2

-- #SkillEnumrate_Penetration - Sitael
PENERATION_ATK_START_POS_DIST = 100				-- 드래곤 원점과 스킬 중심좌표 사이의 거리
PENERATION_TOTAL_LENGTH = 500					-- 발사체를 늘어놓는 전체 거리 (무기간 간격 = 전체거리/발사체 개수)
PENERATION_ANGLE_LIMIT = 45						-- 시전 각도 제한
PENERATION_DIST_LIMIT = 200						-- 시전 거리 제한
PENERATION_APPEAR_INTERVAR = ONE_FRAME * 2		-- 발사체 등장 간격
PENERATION_FIRE_DELAY = 0.5						-- 등장 후 발사 딜레이 

-- #SkillRapidShot
RAPIDSHOT_Y_POS_RANGE = 50						-- 발사체를 y 좌표 상에서 랜덤하게 등장시킬 범위 (+ ~ -)
RAPIDSHOT_INTERVAL = ONE_FRAME * 3				-- 발사체 등장 간격 
RAPIDSHOT_FIRE_DELAY = 0.5						-- 등장 후 발사 딜레이

-- #SkillEnumrate_Curve -- 삐에로 드래곤
RANDOM_CARD_HEIGHT_RANGE = 200						-- 발사체 곡선 궤적의 최대 높이 범위 (+ ~ -)
RANDOM_CARD_INTERVAL = ONE_FRAME * 5				-- 발사체 등장 간격 
RANDOM_CARD_FIRE_DELAY = 0.7						-- 등장 후 발사 딜레이
RANDOM_CARD_SPEED = 0.15							-- 타겟한테까지 가는 시간 (mp/s 가 아닌 sec)
RANDOM_CARD_PENTAGON_POS = {						-- 5각형의 발사 전 준비 위치 (임시)
	{x = 0, y = 100},
	{x = 100, y = 50},
	{x = 80, y = -100},
	{x = -80, y = -100},
	{x = -100, y = 50}
}

-- # 자룡 액티브
JARYONG_APPEAR_INTERVAR = ONE_FRAME * 1			-- 발사체 등장 간격
JARYONG_FIRE_DELAY = ONE_FRAME					-- 발사체 발사 딜레이

-- # 수라드래곤 액티브
SURA_ADD_HEIGHT_RANGE = 200													-- 추가 탄의 궤적 높이
SURA_ADD_POWER_RATE = 50													-- 추가 탄의 power_rate
SURA_ADD_ATK_TYPE = 'basic'													-- 추가 탄의 공격타입
SURA_ADD_MISSILE_RES = 'res/missile/missile_lotus/missile_lotus_@.png'		-- 추가 탄의 미사일 리소스
SURA_ADD_MOTION_STREAK_RES = 'res/effect/motion_streak/motion_streak_fire.png'	-- 추가 탄의 모션스트릭 리소스