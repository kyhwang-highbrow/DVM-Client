 -- # 콜로세움 적군 캐스팅 시간
COLOSSEUM__ENEMY_CASTING_TIME = 2

 -- # 콜로세움 적군 게이지
COLOSSEUM__ENEMY_START_GAUGE_LIST = { 80, 60, 40, 20, 0 }

-- # 개발 스테이지 진입시 콜로세움 활성화 여부
if (TARGET_SERVER ~= 'FGT') then
    COLOSSEUM_SCENE_ACTIVE = true
end