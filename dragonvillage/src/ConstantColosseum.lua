-- # 개발 스테이지 진입시 콜로세움 활성화 여부
if (TARGET_SERVER ~= 'FGT') then
    COLOSSEUM_SCENE_ACTIVE = true
end

-- # 콜로세움 게임 속도
COLOSSEUM__TIME_SCALE = 1

-- # 콜로세움 적군 캐스팅 시간
COLOSSEUM__ENEMY_CASTING_TIME = 2

 -- # 콜로세움 적군 게이지
COLOSSEUM__ENEMY_START_GAUGE_LIST = { 80, 60, 40, 20, 0 }

-- # 콜로세움 적군 진형과 덱 아군과 동일시킴
COLOSSEUM__ENEMY_EQUAL_HERO = true

-- # 콜로세움 적군 진형
COLOSSEUM__ENEMY_FORMATION = 'attack'

-- # 콜로세움 적군 덱
COLOSSEUM__ENEMY = {}
COLOSSEUM__ENEMY[1] = {
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
COLOSSEUM__ENEMY[2] = {
    skill_0 = 1,
    skill_1 = 1,
    skill_2 = 1,
    skill_3 = 1,
    eclv = 0,
	runes = {},
	lv = 10,
	evolution = 3,
	grade = 1,
	did = 120071
}
COLOSSEUM__ENEMY[3] = {
    skill_0 = 1,
    skill_1 = 1,
    skill_2 = 1,
    skill_3 = 1,
    eclv = 0,
	runes = {},
	lv = 10,
	evolution = 3,
	grade = 1,
	did = 120213
}
COLOSSEUM__ENEMY[4] = {
    skill_0 = 1,
    skill_1 = 1,
    skill_2 = 1,
    skill_3 = 1,
    eclv = 0,
	runes = {},
	lv = 10,
	evolution = 3,
	grade = 1,
	did = 120021
}
COLOSSEUM__ENEMY[5] = {
    skill_0 = 1,
    skill_1 = 1,
    skill_2 = 1,
    skill_3 = 1,
    eclv = 0,
	runes = {},
	lv = 10,
	evolution = 3,
	grade = 1,
	did = 120191
}