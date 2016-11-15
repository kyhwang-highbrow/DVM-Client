----------------------------------------------------------------------------
-- 고정된 ENEMY_POS 기준 해상도 : 1280 x 960 (720)
-- 외곽 여유분 + 
-- 기준은 좌측 중간
-- 화면 밖의 적은 삭제되지 않으므로 충분히 멀리서 소환하면 됨
----------------------------------------------------------------------------

local alpha_test_1 = 0
local alpha_test_2 = 300
local pos_x_r = 740
local pos_x_l = 570
local pos_x_add = 95
local pos_y = 240
local pos_y_add = -68

ENEMY_POS = {}


-- 알파버전 타일 r

ENEMY_POS['RF11'] = {x=pos_x_r + (pos_x_add * 0), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['RF12'] = {x=pos_x_r + (pos_x_add * 0), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['RF13'] = {x=pos_x_r + (pos_x_add * 0), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['RF14'] = {x=pos_x_r + (pos_x_add * 0), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['RF15'] = {x=pos_x_r + (pos_x_add * 0), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['RF16'] = {x=pos_x_r + (pos_x_add * 0), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['RF17'] = {x=pos_x_r + (pos_x_add * 0), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['RF21'] = {x=pos_x_r + (pos_x_add * 1), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['RF22'] = {x=pos_x_r + (pos_x_add * 1), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['RF23'] = {x=pos_x_r + (pos_x_add * 1), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['RF24'] = {x=pos_x_r + (pos_x_add * 1), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['RF25'] = {x=pos_x_r + (pos_x_add * 1), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['RF26'] = {x=pos_x_r + (pos_x_add * 1), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['RF27'] = {x=pos_x_r + (pos_x_add * 1), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['RM11'] = {x=pos_x_r + (pos_x_add * 2), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['RM12'] = {x=pos_x_r + (pos_x_add * 2), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['RM13'] = {x=pos_x_r + (pos_x_add * 2), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['RM14'] = {x=pos_x_r + (pos_x_add * 2), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['RM15'] = {x=pos_x_r + (pos_x_add * 2), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['RM16'] = {x=pos_x_r + (pos_x_add * 2), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['RM17'] = {x=pos_x_r + (pos_x_add * 2), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['RM21'] = {x=pos_x_r + (pos_x_add * 3), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['RM22'] = {x=pos_x_r + (pos_x_add * 3), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['RM23'] = {x=pos_x_r + (pos_x_add * 3), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['RM24'] = {x=pos_x_r + (pos_x_add * 3), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['RM25'] = {x=pos_x_r + (pos_x_add * 3), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['RM26'] = {x=pos_x_r + (pos_x_add * 3), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['RM27'] = {x=pos_x_r + (pos_x_add * 3), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['RB11'] = {x=pos_x_r + (pos_x_add * 4), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['RB12'] = {x=pos_x_r + (pos_x_add * 4), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['RB13'] = {x=pos_x_r + (pos_x_add * 4), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['RB14'] = {x=pos_x_r + (pos_x_add * 4), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['RB15'] = {x=pos_x_r + (pos_x_add * 4), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['RB16'] = {x=pos_x_r + (pos_x_add * 4), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['RB17'] = {x=pos_x_r + (pos_x_add * 4), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['RB21'] = {x=pos_x_r + (pos_x_add * 5), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['RB22'] = {x=pos_x_r + (pos_x_add * 5), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['RB23'] = {x=pos_x_r + (pos_x_add * 5), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['RB24'] = {x=pos_x_r + (pos_x_add * 5), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['RB25'] = {x=pos_x_r + (pos_x_add * 5), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['RB26'] = {x=pos_x_r + (pos_x_add * 5), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['RB27'] = {x=pos_x_r + (pos_x_add * 5), y=pos_y + (pos_y_add * 6)}

-- 알파버전 타일 l

ENEMY_POS['LF11'] = {x=pos_x_l + (pos_x_add * 0), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['LF12'] = {x=pos_x_l + (pos_x_add * 0), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['LF13'] = {x=pos_x_l + (pos_x_add * 0), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['LF14'] = {x=pos_x_l + (pos_x_add * 0), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['LF15'] = {x=pos_x_l + (pos_x_add * 0), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['LF16'] = {x=pos_x_l + (pos_x_add * 0), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['LF17'] = {x=pos_x_l + (pos_x_add * 0), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['LF21'] = {x=pos_x_l + (pos_x_add * 1), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['LF22'] = {x=pos_x_l + (pos_x_add * 1), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['LF23'] = {x=pos_x_l + (pos_x_add * 1), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['LF24'] = {x=pos_x_l + (pos_x_add * 1), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['LF25'] = {x=pos_x_l + (pos_x_add * 1), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['LF26'] = {x=pos_x_l + (pos_x_add * 1), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['LF27'] = {x=pos_x_l + (pos_x_add * 1), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['LM11'] = {x=pos_x_l + (pos_x_add * 2), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['LM12'] = {x=pos_x_l + (pos_x_add * 2), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['LM13'] = {x=pos_x_l + (pos_x_add * 2), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['LM14'] = {x=pos_x_l + (pos_x_add * 2), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['LM15'] = {x=pos_x_l + (pos_x_add * 2), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['LM16'] = {x=pos_x_l + (pos_x_add * 2), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['LM17'] = {x=pos_x_l + (pos_x_add * 2), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['LM21'] = {x=pos_x_l + (pos_x_add * 3), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['LM22'] = {x=pos_x_l + (pos_x_add * 3), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['LM23'] = {x=pos_x_l + (pos_x_add * 3), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['LM24'] = {x=pos_x_l + (pos_x_add * 3), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['LM25'] = {x=pos_x_l + (pos_x_add * 3), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['LM26'] = {x=pos_x_l + (pos_x_add * 3), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['LM27'] = {x=pos_x_l + (pos_x_add * 3), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['LB11'] = {x=pos_x_l + (pos_x_add * 4), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['LB12'] = {x=pos_x_l + (pos_x_add * 4), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['LB13'] = {x=pos_x_l + (pos_x_add * 4), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['LB14'] = {x=pos_x_l + (pos_x_add * 4), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['LB15'] = {x=pos_x_l + (pos_x_add * 4), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['LB16'] = {x=pos_x_l + (pos_x_add * 4), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['LB17'] = {x=pos_x_l + (pos_x_add * 4), y=pos_y + (pos_y_add * 6)}
ENEMY_POS['LB21'] = {x=pos_x_l + (pos_x_add * 5), y=pos_y + (pos_y_add * 0)}
ENEMY_POS['LB22'] = {x=pos_x_l + (pos_x_add * 5), y=pos_y + (pos_y_add * 1)}
ENEMY_POS['LB23'] = {x=pos_x_l + (pos_x_add * 5), y=pos_y + (pos_y_add * 2)}
ENEMY_POS['LB24'] = {x=pos_x_l + (pos_x_add * 5), y=pos_y + (pos_y_add * 3)}
ENEMY_POS['LB25'] = {x=pos_x_l + (pos_x_add * 5), y=pos_y + (pos_y_add * 4)}
ENEMY_POS['LB26'] = {x=pos_x_l + (pos_x_add * 5), y=pos_y + (pos_y_add * 5)}
ENEMY_POS['LB27'] = {x=pos_x_l + (pos_x_add * 5), y=pos_y + (pos_y_add * 6)}



ENEMY_POS['RC01'] = {x=960, y=0}

ENEMY_POS['RO01'] = {x=1380, y=pos_y + (pos_y_add * 0)}
ENEMY_POS['RO02'] = {x=1380, y=pos_y + (pos_y_add * 1)}
ENEMY_POS['RO03'] = {x=1380, y=pos_y + (pos_y_add * 2)}
ENEMY_POS['RO04'] = {x=1380, y=pos_y + (pos_y_add * 3)}
ENEMY_POS['RO05'] = {x=1380, y=pos_y + (pos_y_add * 4)}
ENEMY_POS['RO06'] = {x=1380, y=pos_y + (pos_y_add * 5)}
ENEMY_POS['RO07'] = {x=1380, y=pos_y + (pos_y_add * 6)}

ENEMY_POS['LO01'] = {x=-100, y=pos_y + (pos_y_add * 0)}
ENEMY_POS['LO02'] = {x=-100, y=pos_y + (pos_y_add * 1)}
ENEMY_POS['LO03'] = {x=-100, y=pos_y + (pos_y_add * 2)}
ENEMY_POS['LO04'] = {x=-100, y=pos_y + (pos_y_add * 3)}
ENEMY_POS['LO05'] = {x=-100, y=pos_y + (pos_y_add * 4)}
ENEMY_POS['LO06'] = {x=-100, y=pos_y + (pos_y_add * 5)}
ENEMY_POS['LO07'] = {x=-100, y=pos_y + (pos_y_add * 6)}

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