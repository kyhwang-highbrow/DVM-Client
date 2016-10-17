----------------------------------------------------------------------------
-- 고정된 ENEMY_POS 기준 해상도 : 1280 x 960 (720)
-- 외곽 여유분 + 
-- 기준은 좌측 중간
-- 화면 밖의 적은 삭제되지 않으므로 충분히 멀리서 소환하면 됨
----------------------------------------------------------------------------

local alpha_test_1 = 0
local alpha_test_2 = 300

ENEMY_POS = {}

ENEMY_POS['LEFT0'] = {x=-80, y=400}
ENEMY_POS['LEFT1'] = {x=-80, y=320}
ENEMY_POS['LEFT2'] = {x=-80, y=240}
ENEMY_POS['LEFT3'] = {x=-80, y=160}
ENEMY_POS['LEFT4'] = {x=-80, y=80}
ENEMY_POS['LEFT5'] = {x=-80, y=0}
ENEMY_POS['LEFT6'] = {x=-80, y=-80}
ENEMY_POS['LEFT7'] = {x=-80, y=-160}
ENEMY_POS['LEFT8'] = {x=-80, y=-240}
ENEMY_POS['LEFT9'] = {x=-80, y=-320}
ENEMY_POS['LEFT10'] = {x=-80, y=-400}

ENEMY_POS['RIGHT0'] = {x=1360, y=400}
ENEMY_POS['RIGHT1'] = {x=1360, y=320}
ENEMY_POS['RIGHT2'] = {x=1360, y=240}
ENEMY_POS['RIGHT3'] = {x=1360, y=160}
ENEMY_POS['RIGHT4'] = {x=1360, y=80}
ENEMY_POS['RIGHT5'] = {x=1360, y=0}
ENEMY_POS['RIGHT6'] = {x=1360, y=-80}
ENEMY_POS['RIGHT7'] = {x=1360, y=-160}
ENEMY_POS['RIGHT8'] = {x=1360, y=-240}
ENEMY_POS['RIGHT9'] = {x=1360, y=-320}
ENEMY_POS['RIGHT10'] = {x=1360, y=-400}

ENEMY_POS['TOP18'] = {x=1360, y=400}
ENEMY_POS['TOP17'] = {x=1280, y=400}
ENEMY_POS['TOP16'] = {x=1200, y=400}
ENEMY_POS['TOP15'] = {x=1120, y=400}
ENEMY_POS['TOP14'] = {x=1040, y=400}
ENEMY_POS['TOP13'] = {x=960, y=400}
ENEMY_POS['TOP12'] = {x=880, y=400}
ENEMY_POS['TOP11'] = {x=800, y=400}
ENEMY_POS['TOP10'] = {x=720, y=400}
ENEMY_POS['TOP9'] = {x=640, y=400}
ENEMY_POS['TOP8'] = {x=560, y=400}
ENEMY_POS['TOP7'] = {x=480, y=400}
ENEMY_POS['TOP6'] = {x=400, y=400}
ENEMY_POS['TOP5'] = {x=320, y=400}
ENEMY_POS['TOP4'] = {x=240, y=400}
ENEMY_POS['TOP3'] = {x=160, y=400}
ENEMY_POS['TOP2'] = {x=80, y=400}
ENEMY_POS['TOP1'] = {x=0, y=400}
ENEMY_POS['TOP0'] = {x=-80, y=400}


ENEMY_POS['BOTTOM18'] = {x=1360, y=-400}
ENEMY_POS['BOTTOM17'] = {x=1280, y=-400}
ENEMY_POS['BOTTOM16'] = {x=1200, y=-400}
ENEMY_POS['BOTTOM15'] = {x=1120, y=-400}
ENEMY_POS['BOTTOM14'] = {x=1040, y=-400}
ENEMY_POS['BOTTOM13'] = {x=960, y=-400}
ENEMY_POS['BOTTOM12'] = {x=880, y=-400}
ENEMY_POS['BOTTOM11'] = {x=800, y=-400}
ENEMY_POS['BOTTOM10'] = {x=720, y=-400}
ENEMY_POS['BOTTOM9'] = {x=640, y=-400}
ENEMY_POS['BOTTOM8'] = {x=560, y=-400}
ENEMY_POS['BOTTOM7'] = {x=480, y=-400}
ENEMY_POS['BOTTOM6'] = {x=-400, y=-400}
ENEMY_POS['BOTTOM5'] = {x=320, y=-400}
ENEMY_POS['BOTTOM4'] = {x=240, y=-400}
ENEMY_POS['BOTTOM3'] = {x=160, y=-400}
ENEMY_POS['BOTTOM2'] = {x=80, y=-400}
ENEMY_POS['BOTTOM1'] = {x=0, y=-400}
ENEMY_POS['BOTTOM0'] = {x=-80, y=-400}


ENEMY_POS['AREA1'] = {x=800, y=240}
ENEMY_POS['AREA2'] = {x=800, y=160}
ENEMY_POS['AREA3'] = {x=800, y=80}
ENEMY_POS['AREA4'] = {x=800, y=0}
ENEMY_POS['AREA5'] = {x=800, y=-80}
ENEMY_POS['AREA6'] = {x=800, y=-160}
ENEMY_POS['AREA7'] = {x=800, y=-240}

ENEMY_POS['AREA8'] = {x=880, y=240}
ENEMY_POS['AREA9'] = {x=880, y=160}
ENEMY_POS['AREA10'] = {x=880, y=80}
ENEMY_POS['AREA11'] = {x=880, y=0}
ENEMY_POS['AREA12'] = {x=880, y=-80}
ENEMY_POS['AREA13'] = {x=880, y=-160}
ENEMY_POS['AREA14'] = {x=880, y=-240}

ENEMY_POS['AREA15'] = {x=960, y=240}
ENEMY_POS['AREA16'] = {x=960, y=160}
ENEMY_POS['AREA17'] = {x=960, y=80}
ENEMY_POS['AREA18'] = {x=960, y=0}
ENEMY_POS['AREA19'] = {x=960, y=-80}
ENEMY_POS['AREA20'] = {x=960, y=-160}
ENEMY_POS['AREA21'] = {x=960, y=-240}

ENEMY_POS['AREA22'] = {x=1040, y=240}
ENEMY_POS['AREA23'] = {x=1040, y=160}
ENEMY_POS['AREA24'] = {x=1040, y=80}
ENEMY_POS['AREA25'] = {x=1040, y=0}
ENEMY_POS['AREA26'] = {x=1040, y=-80}
ENEMY_POS['AREA27'] = {x=1040, y=-160}
ENEMY_POS['AREA28'] = {x=1040, y=-240}

ENEMY_POS['AREA29'] = {x=1120, y=240}
ENEMY_POS['AREA30'] = {x=1120, y=160}
ENEMY_POS['AREA31'] = {x=1120, y=80}
ENEMY_POS['AREA32'] = {x=1120, y=0}
ENEMY_POS['AREA33'] = {x=1120, y=-80}
ENEMY_POS['AREA34'] = {x=1120, y=-160}
ENEMY_POS['AREA35'] = {x=1120, y=-240}

ENEMY_POS['AREA36'] = {x=1200, y=240}
ENEMY_POS['AREA37'] = {x=1200, y=160}
ENEMY_POS['AREA38'] = {x=1200, y=80}
ENEMY_POS['AREA39'] = {x=1200, y=0}
ENEMY_POS['AREA40'] = {x=1200, y=-80}
ENEMY_POS['AREA41'] = {x=1200, y=-160}
ENEMY_POS['AREA42'] = {x=1200, y=-240}

-- 알파버전 타일 r

ENEMY_POS['RF11'] = {x=710, y=240}
ENEMY_POS['RF12'] = {x=710, y=160}
ENEMY_POS['RF13'] = {x=710, y=80}
ENEMY_POS['RF14'] = {x=710, y=0}
ENEMY_POS['RF15'] = {x=710, y=-80}
ENEMY_POS['RF16'] = {x=710, y=-160}
ENEMY_POS['RF17'] = {x=710, y=-240}
ENEMY_POS['RF21'] = {x=810, y=240}
ENEMY_POS['RF22'] = {x=810, y=160}
ENEMY_POS['RF23'] = {x=810, y=80}
ENEMY_POS['RF24'] = {x=810, y=0}
ENEMY_POS['RF25'] = {x=810, y=-80}
ENEMY_POS['RF26'] = {x=810, y=-160}
ENEMY_POS['RF27'] = {x=810, y=-240}

ENEMY_POS['RM11'] = {x=910, y=240}
ENEMY_POS['RM12'] = {x=910, y=160}
ENEMY_POS['RM13'] = {x=910, y=80}
ENEMY_POS['RM14'] = {x=910, y=0}
ENEMY_POS['RM15'] = {x=910, y=-80}
ENEMY_POS['RM16'] = {x=910, y=-160}
ENEMY_POS['RM17'] = {x=910, y=-240}
ENEMY_POS['RM21'] = {x=1010, y=240}
ENEMY_POS['RM22'] = {x=1010, y=160}
ENEMY_POS['RM23'] = {x=1010, y=80}
ENEMY_POS['RM24'] = {x=1010, y=0}
ENEMY_POS['RM25'] = {x=1010, y=-80}
ENEMY_POS['RM26'] = {x=1010, y=-160}
ENEMY_POS['RM27'] = {x=1010, y=-240}

ENEMY_POS['RB11'] = {x=1110, y=240}
ENEMY_POS['RB12'] = {x=1110, y=160}
ENEMY_POS['RB13'] = {x=1110, y=80}
ENEMY_POS['RB14'] = {x=1110, y=0}
ENEMY_POS['RB15'] = {x=1110, y=-80}
ENEMY_POS['RB16'] = {x=1110, y=-160}
ENEMY_POS['RB17'] = {x=1110, y=-240}
ENEMY_POS['RB21'] = {x=1210, y=240}
ENEMY_POS['RB22'] = {x=1210, y=160}
ENEMY_POS['RB23'] = {x=1210, y=80}
ENEMY_POS['RB24'] = {x=1210, y=0}
ENEMY_POS['RB25'] = {x=1210, y=-80}
ENEMY_POS['RB26'] = {x=1210, y=-160}
ENEMY_POS['RB27'] = {x=1210, y=-240}

-- 알파버전 타일 l

ENEMY_POS['LF11'] = {x=570, y=240}
ENEMY_POS['LF12'] = {x=570, y=160}
ENEMY_POS['LF13'] = {x=570, y=80}
ENEMY_POS['LF14'] = {x=570, y=0}
ENEMY_POS['LF15'] = {x=570, y=-80}
ENEMY_POS['LF16'] = {x=570, y=-160}
ENEMY_POS['LF17'] = {x=570, y=-240}
ENEMY_POS['LF21'] = {x=470, y=240}
ENEMY_POS['LF22'] = {x=470, y=160}
ENEMY_POS['LF23'] = {x=470, y=80}
ENEMY_POS['LF24'] = {x=470, y=0}
ENEMY_POS['LF25'] = {x=470, y=-80}
ENEMY_POS['LF26'] = {x=470, y=-160}
ENEMY_POS['LF27'] = {x=470, y=-240}

ENEMY_POS['LM11'] = {x=370, y=240}
ENEMY_POS['LM12'] = {x=370, y=160}
ENEMY_POS['LM13'] = {x=370, y=80}
ENEMY_POS['LM14'] = {x=370, y=0}
ENEMY_POS['LM15'] = {x=370, y=-80}
ENEMY_POS['LM16'] = {x=370, y=-160}
ENEMY_POS['LM17'] = {x=370, y=-240}
ENEMY_POS['LM21'] = {x=270, y=240}
ENEMY_POS['LM22'] = {x=270, y=160}
ENEMY_POS['LM23'] = {x=270, y=80}
ENEMY_POS['LM24'] = {x=270, y=0}
ENEMY_POS['LM25'] = {x=270, y=-80}
ENEMY_POS['LM26'] = {x=270, y=-160}
ENEMY_POS['LM27'] = {x=270, y=-240}

ENEMY_POS['LB11'] = {x=170, y=240}
ENEMY_POS['LB12'] = {x=170, y=160}
ENEMY_POS['LB13'] = {x=170, y=80}
ENEMY_POS['LB14'] = {x=170, y=0}
ENEMY_POS['LB15'] = {x=170, y=-80}
ENEMY_POS['LB16'] = {x=170, y=-160}
ENEMY_POS['LB17'] = {x=170, y=-240}
ENEMY_POS['LB21'] = {x=70, y=240}
ENEMY_POS['LB22'] = {x=70, y=160}
ENEMY_POS['LB23'] = {x=70, y=80}
ENEMY_POS['LB24'] = {x=70, y=0}
ENEMY_POS['LB25'] = {x=70, y=-80}
ENEMY_POS['LB26'] = {x=70, y=-160}
ENEMY_POS['LB27'] = {x=70, y=-240}



ENEMY_POS['RC01'] = {x=960, y=0}

ENEMY_POS['RO01'] = {x=1380, y=240}
ENEMY_POS['RO02'] = {x=1380, y=160}
ENEMY_POS['RO03'] = {x=1380, y=80}
ENEMY_POS['RO04'] = {x=1380, y=0}
ENEMY_POS['RO05'] = {x=1380, y=-80}
ENEMY_POS['RO06'] = {x=1380, y=-160}
ENEMY_POS['RO07'] = {x=1380, y=-240}

ENEMY_POS['LO01'] = {x=-100, y=240}
ENEMY_POS['LO02'] = {x=-100, y=160}
ENEMY_POS['LO03'] = {x=-100, y=80}
ENEMY_POS['LO04'] = {x=-100, y=0}
ENEMY_POS['LO05'] = {x=-100, y=-80}
ENEMY_POS['LO06'] = {x=-100, y=-160}
ENEMY_POS['LO07'] = {x=-100, y=-240}

ENEMY_POS['TO01'] = {x=70, y=400}
ENEMY_POS['TO02'] = {x=170, y=400}
ENEMY_POS['TO03'] = {x=270, y=400}
ENEMY_POS['TO04'] = {x=370, y=400}
ENEMY_POS['TO05'] = {x=470, y=400}
ENEMY_POS['TO06'] = {x=570, y=400}
ENEMY_POS['TO07'] = {x=710, y=400}
ENEMY_POS['TO08'] = {x=810, y=400}
ENEMY_POS['TO09'] = {x=910, y=400}
ENEMY_POS['TO10'] = {x=1010, y=400}
ENEMY_POS['TO11'] = {x=1110, y=400}
ENEMY_POS['TO12'] = {x=1210, y=400}

ENEMY_POS['BO01'] = {x=70, y=-400}
ENEMY_POS['BO02'] = {x=170, y=-400}
ENEMY_POS['BO03'] = {x=270, y=-400}
ENEMY_POS['BO04'] = {x=370, y=-400}
ENEMY_POS['BO05'] = {x=470, y=-400}
ENEMY_POS['BO06'] = {x=570, y=-400}
ENEMY_POS['BO07'] = {x=710, y=-400}
ENEMY_POS['BO08'] = {x=810, y=-400}
ENEMY_POS['BO09'] = {x=910, y=-400}
ENEMY_POS['BO10'] = {x=1010, y=-400}
ENEMY_POS['BO11'] = {x=1110, y=-400}
ENEMY_POS['BO12'] = {x=1210, y=-400}

ENEMY_POS['BOSS'] = {x=2000+alpha_test_2, y=-0+alpha_test_1}
ENEMY_POS['NEST'] = {x=1500, y=0}







-------------------------------------
-- function getEnemyPos
-- @brief 적군의 절대 위치
-------------------------------------
function getEnemyPos(key)
    if (not ENEMY_POS[key]) then
        cclog('ERROE! 존재하지 않는 key : ' .. tostring(key))
        return {x=0, y=0}
    end

    return ENEMY_POS[key]
end

-------------------------------------
-- function getWorldEnemyPos
-- @brief 적군의 상대 위치(현재 월드의 scale을 반영)
-------------------------------------
function getWorldEnemyPos(enemy, key)
    if (not ENEMY_POS[key]) then
        cclog('ERROE! 존재하지 않는 key : ' .. tostring(key))
        return {x=0, y=0}
    end

    -- 현재 월드의 scale을 얻어옴
    local world_scale = enemy.m_world.m_worldScale
    local pos = clone(ENEMY_POS[key])

    -- 절대위치에 scale을 적용
    pos.x = pos.x / world_scale
    pos.y = pos.y / world_scale

    return pos
end


-- [F11][F21] [M11][M21] [R11][R21]
--   
-- [F12][F22] [M12][M22] [R12][R22]
--   
-- [F13][F23] [M13][M23] [R13][R23]
--   
-- [F14][F24] [M14][M24] [R14][R24]
--   
-- [F15][F25] [M15][M25] [R15][R25]

-- [F16][F26] [M16][M26] [R16][R26]

-- [F17][F27] [M17][M27] [R17][R27]

ENEMY_FORMATION_POS = {}
ENEMY_FORMATION_POS[1] = {}
ENEMY_FORMATION_POS[2] = {}
ENEMY_FORMATION_POS[3] = {}

-- size 1
local interval_y = 100
local pos_1_x = 638 + 40
local pos_2_x = 638 + 40 + 80
ENEMY_FORMATION_POS[1]['A11'] = {x=pos_1_x, y=interval_y*3};    ENEMY_FORMATION_POS[1]['A21'] = {x=pos_2_x, y=interval_y*3}; 
ENEMY_FORMATION_POS[1]['A12'] = {x=pos_1_x, y=interval_y*2};    ENEMY_FORMATION_POS[1]['A22'] = {x=pos_2_x, y=interval_y*2}; 
ENEMY_FORMATION_POS[1]['A13'] = {x=pos_1_x, y=interval_y*1};    ENEMY_FORMATION_POS[1]['A23'] = {x=pos_2_x, y=interval_y*1}; 
ENEMY_FORMATION_POS[1]['A14'] = {x=pos_1_x, y=0};               ENEMY_FORMATION_POS[1]['A24'] = {x=pos_2_x, y=0};            
ENEMY_FORMATION_POS[1]['A15'] = {x=pos_1_x, y=-interval_y*1};   ENEMY_FORMATION_POS[1]['A25'] = {x=pos_2_x, y=-interval_y*1};
ENEMY_FORMATION_POS[1]['A16'] = {x=pos_1_x, y=-interval_y*2};   ENEMY_FORMATION_POS[1]['A26'] = {x=pos_2_x, y=-interval_y*2};
ENEMY_FORMATION_POS[1]['A17'] = {x=pos_1_x, y=-interval_y*3};   ENEMY_FORMATION_POS[1]['A27'] = {x=pos_2_x, y=-interval_y*3};

local pos_1_x = 796 + 40
local pos_2_x = 796 + 40 + 80
ENEMY_FORMATION_POS[1]['B11'] = {x=pos_1_x, y=interval_y*3};     ENEMY_FORMATION_POS[1]['B21'] = {x=pos_2_x, y=interval_y*3}; 
ENEMY_FORMATION_POS[1]['B12'] = {x=pos_1_x, y=interval_y*2};     ENEMY_FORMATION_POS[1]['B22'] = {x=pos_2_x, y=interval_y*2}; 
ENEMY_FORMATION_POS[1]['B13'] = {x=pos_1_x, y=interval_y*1};     ENEMY_FORMATION_POS[1]['B23'] = {x=pos_2_x, y=interval_y*1}; 
ENEMY_FORMATION_POS[1]['B14'] = {x=pos_1_x, y=0};                ENEMY_FORMATION_POS[1]['B24'] = {x=pos_2_x, y=0};            
ENEMY_FORMATION_POS[1]['B15'] = {x=pos_1_x, y=-interval_y*1};    ENEMY_FORMATION_POS[1]['B25'] = {x=pos_2_x, y=-interval_y*1};
ENEMY_FORMATION_POS[1]['B16'] = {x=pos_1_x, y=-interval_y*2};    ENEMY_FORMATION_POS[1]['B26'] = {x=pos_2_x, y=-interval_y*2};
ENEMY_FORMATION_POS[1]['B17'] = {x=pos_1_x, y=-interval_y*3};    ENEMY_FORMATION_POS[1]['B27'] = {x=pos_2_x, y=-interval_y*3};

local pos_1_x = 958 + 40
local pos_2_x = 958 + 40 + 80
ENEMY_FORMATION_POS[1]['C11'] = {x=pos_1_x, y=interval_y*3};     ENEMY_FORMATION_POS[1]['C21'] = {x=pos_2_x, y=interval_y*3}; 
ENEMY_FORMATION_POS[1]['C12'] = {x=pos_1_x, y=interval_y*2};     ENEMY_FORMATION_POS[1]['C22'] = {x=pos_2_x, y=interval_y*2}; 
ENEMY_FORMATION_POS[1]['C13'] = {x=pos_1_x, y=interval_y*1};     ENEMY_FORMATION_POS[1]['C23'] = {x=pos_2_x, y=interval_y*1}; 
ENEMY_FORMATION_POS[1]['C14'] = {x=pos_1_x, y=0};                ENEMY_FORMATION_POS[1]['C24'] = {x=pos_2_x, y=0};            
ENEMY_FORMATION_POS[1]['C15'] = {x=pos_1_x, y=-interval_y*1};    ENEMY_FORMATION_POS[1]['C25'] = {x=pos_2_x, y=-interval_y*1};
ENEMY_FORMATION_POS[1]['C16'] = {x=pos_1_x, y=-interval_y*2};    ENEMY_FORMATION_POS[1]['C26'] = {x=pos_2_x, y=-interval_y*2};
ENEMY_FORMATION_POS[1]['C17'] = {x=pos_1_x, y=-interval_y*3};    ENEMY_FORMATION_POS[1]['C27'] = {x=pos_2_x, y=-interval_y*3};

-- size 2
local interval_y = 110
local pos_1_x = 802 + 50
local pos_2_x = 802 + 50 + 100
ENEMY_FORMATION_POS[2]['A11'] = {x=pos_1_x, y=interval_y*3};    ENEMY_FORMATION_POS[2]['A21'] = {x=pos_2_x, y=interval_y*3}; 
ENEMY_FORMATION_POS[2]['A12'] = {x=pos_1_x, y=interval_y*2};    ENEMY_FORMATION_POS[2]['A22'] = {x=pos_2_x, y=interval_y*2}; 
ENEMY_FORMATION_POS[2]['A13'] = {x=pos_1_x, y=interval_y*1};    ENEMY_FORMATION_POS[2]['A23'] = {x=pos_2_x, y=interval_y*1}; 
ENEMY_FORMATION_POS[2]['A14'] = {x=pos_1_x, y=0};               ENEMY_FORMATION_POS[2]['A24'] = {x=pos_2_x, y=0};            
ENEMY_FORMATION_POS[2]['A15'] = {x=pos_1_x, y=-interval_y*1};   ENEMY_FORMATION_POS[2]['A25'] = {x=pos_2_x, y=-interval_y*1};
ENEMY_FORMATION_POS[2]['A16'] = {x=pos_1_x, y=-interval_y*2};   ENEMY_FORMATION_POS[2]['A26'] = {x=pos_2_x, y=-interval_y*2};
ENEMY_FORMATION_POS[2]['A17'] = {x=pos_1_x, y=-interval_y*3};   ENEMY_FORMATION_POS[2]['A27'] = {x=pos_2_x, y=-interval_y*3};

local pos_1_x = 1002 + 50
local pos_2_x = 1002 + 50 + 100
ENEMY_FORMATION_POS[2]['B11'] = {x=pos_1_x, y=interval_y*3};     ENEMY_FORMATION_POS[2]['B21'] = {x=pos_2_x, y=interval_y*3}; 
ENEMY_FORMATION_POS[2]['B12'] = {x=pos_1_x, y=interval_y*2};     ENEMY_FORMATION_POS[2]['B22'] = {x=pos_2_x, y=interval_y*2}; 
ENEMY_FORMATION_POS[2]['B13'] = {x=pos_1_x, y=interval_y*1};     ENEMY_FORMATION_POS[2]['B23'] = {x=pos_2_x, y=interval_y*1}; 
ENEMY_FORMATION_POS[2]['B14'] = {x=pos_1_x, y=0};                ENEMY_FORMATION_POS[2]['B24'] = {x=pos_2_x, y=0};            
ENEMY_FORMATION_POS[2]['B15'] = {x=pos_1_x, y=-interval_y*1};    ENEMY_FORMATION_POS[2]['B25'] = {x=pos_2_x, y=-interval_y*1};
ENEMY_FORMATION_POS[2]['B16'] = {x=pos_1_x, y=-interval_y*2};    ENEMY_FORMATION_POS[2]['B26'] = {x=pos_2_x, y=-interval_y*2};
ENEMY_FORMATION_POS[2]['B17'] = {x=pos_1_x, y=-interval_y*3};    ENEMY_FORMATION_POS[2]['B27'] = {x=pos_2_x, y=-interval_y*3};

local pos_1_x = 1202 + 50
local pos_2_x = 1202 + 50 + 100
ENEMY_FORMATION_POS[2]['C11'] = {x=pos_1_x, y=interval_y*3};     ENEMY_FORMATION_POS[2]['C21'] = {x=pos_2_x, y=interval_y*3}; 
ENEMY_FORMATION_POS[2]['C12'] = {x=pos_1_x, y=interval_y*2};     ENEMY_FORMATION_POS[2]['C22'] = {x=pos_2_x, y=interval_y*2}; 
ENEMY_FORMATION_POS[2]['C13'] = {x=pos_1_x, y=interval_y*1};     ENEMY_FORMATION_POS[2]['C23'] = {x=pos_2_x, y=interval_y*1}; 
ENEMY_FORMATION_POS[2]['C14'] = {x=pos_1_x, y=0};                ENEMY_FORMATION_POS[2]['C24'] = {x=pos_2_x, y=0};            
ENEMY_FORMATION_POS[2]['C15'] = {x=pos_1_x, y=-interval_y*1};    ENEMY_FORMATION_POS[2]['C25'] = {x=pos_2_x, y=-interval_y*1};
ENEMY_FORMATION_POS[2]['C16'] = {x=pos_1_x, y=-interval_y*2};    ENEMY_FORMATION_POS[2]['C26'] = {x=pos_2_x, y=-interval_y*2};
ENEMY_FORMATION_POS[2]['C17'] = {x=pos_1_x, y=-interval_y*3};    ENEMY_FORMATION_POS[2]['C27'] = {x=pos_2_x, y=-interval_y*3};

-- size 3
local interval_y = 120
local pos_1_x = 1139 + 60
local pos_2_x = 1139 + 60 + 120
ENEMY_FORMATION_POS[3]['A11'] = {x=pos_1_x, y=interval_y*3};    ENEMY_FORMATION_POS[3]['A21'] = {x=pos_2_x, y=interval_y*3}; 
ENEMY_FORMATION_POS[3]['A12'] = {x=pos_1_x, y=interval_y*2};    ENEMY_FORMATION_POS[3]['A22'] = {x=pos_2_x, y=interval_y*2}; 
ENEMY_FORMATION_POS[3]['A13'] = {x=pos_1_x, y=interval_y*1};    ENEMY_FORMATION_POS[3]['A23'] = {x=pos_2_x, y=interval_y*1}; 
ENEMY_FORMATION_POS[3]['A14'] = {x=pos_1_x, y=0};               ENEMY_FORMATION_POS[3]['A24'] = {x=pos_2_x, y=0};            
ENEMY_FORMATION_POS[3]['A15'] = {x=pos_1_x, y=-interval_y*1};   ENEMY_FORMATION_POS[3]['A25'] = {x=pos_2_x, y=-interval_y*1};
ENEMY_FORMATION_POS[3]['A16'] = {x=pos_1_x, y=-interval_y*2};   ENEMY_FORMATION_POS[3]['A26'] = {x=pos_2_x, y=-interval_y*2};
ENEMY_FORMATION_POS[3]['A17'] = {x=pos_1_x, y=-interval_y*3};   ENEMY_FORMATION_POS[3]['A27'] = {x=pos_2_x, y=-interval_y*3};

local pos_1_x = 1396 + 60
local pos_2_x = 1396 + 60 + 120
ENEMY_FORMATION_POS[3]['B11'] = {x=pos_1_x, y=interval_y*3};     ENEMY_FORMATION_POS[3]['B21'] = {x=pos_2_x, y=interval_y*3}; 
ENEMY_FORMATION_POS[3]['B12'] = {x=pos_1_x, y=interval_y*2};     ENEMY_FORMATION_POS[3]['B22'] = {x=pos_2_x, y=interval_y*2}; 
ENEMY_FORMATION_POS[3]['B13'] = {x=pos_1_x, y=interval_y*1};     ENEMY_FORMATION_POS[3]['B23'] = {x=pos_2_x, y=interval_y*1}; 
ENEMY_FORMATION_POS[3]['B14'] = {x=pos_1_x, y=0};                ENEMY_FORMATION_POS[3]['B24'] = {x=pos_2_x, y=0};            
ENEMY_FORMATION_POS[3]['B15'] = {x=pos_1_x, y=-interval_y*1};    ENEMY_FORMATION_POS[3]['B25'] = {x=pos_2_x, y=-interval_y*1};
ENEMY_FORMATION_POS[3]['B16'] = {x=pos_1_x, y=-interval_y*2};    ENEMY_FORMATION_POS[3]['B26'] = {x=pos_2_x, y=-interval_y*2};
ENEMY_FORMATION_POS[3]['B17'] = {x=pos_1_x, y=-interval_y*3};    ENEMY_FORMATION_POS[3]['B27'] = {x=pos_2_x, y=-interval_y*3};

local pos_1_x = 1653 + 60
local pos_2_x = 1653 + 60 + 120
ENEMY_FORMATION_POS[3]['C11'] = {x=pos_1_x, y=interval_y*3};     ENEMY_FORMATION_POS[3]['C21'] = {x=pos_2_x, y=interval_y*3}; 
ENEMY_FORMATION_POS[3]['C12'] = {x=pos_1_x, y=interval_y*2};     ENEMY_FORMATION_POS[3]['C22'] = {x=pos_2_x, y=interval_y*2}; 
ENEMY_FORMATION_POS[3]['C13'] = {x=pos_1_x, y=interval_y*1};     ENEMY_FORMATION_POS[3]['C23'] = {x=pos_2_x, y=interval_y*1}; 
ENEMY_FORMATION_POS[3]['C14'] = {x=pos_1_x, y=0};                ENEMY_FORMATION_POS[3]['C24'] = {x=pos_2_x, y=0};            
ENEMY_FORMATION_POS[3]['C15'] = {x=pos_1_x, y=-interval_y*1};    ENEMY_FORMATION_POS[3]['C25'] = {x=pos_2_x, y=-interval_y*1};
ENEMY_FORMATION_POS[3]['C16'] = {x=pos_1_x, y=-interval_y*2};    ENEMY_FORMATION_POS[3]['C26'] = {x=pos_2_x, y=-interval_y*2};
ENEMY_FORMATION_POS[3]['C17'] = {x=pos_1_x, y=-interval_y*3};    ENEMY_FORMATION_POS[3]['C27'] = {x=pos_2_x, y=-interval_y*3};


-------------------------------------
-- function getFormationEnemyPos
-- @brief
-------------------------------------
function getFormationEnemyPos(enemy, key)
    local size = enemy.m_world.m_worldSize

    if (not ENEMY_FORMATION_POS[size][key]) then
        cclog('ERROE! 존재하지 않는 key : ' .. tostring(key))
        return {x=0, y=0}
    end

    return ENEMY_FORMATION_POS[size][key]
end