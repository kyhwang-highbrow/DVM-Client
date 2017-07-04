----------------------------------------------------------------------------
-- 고정된 ENEMY_POS 기준 해상도 : 1280 x 960 (720)
-- 외곽 여유분 + 
-- 기준은 좌측 중간
-- 화면 밖의 적은 삭제되지 않으므로 충분히 멀리서 소환하면 됨
----------------------------------------------------------------------------

local alpha_test_1 = 0
local alpha_test_2 = 300
local pos_x_r = 740
local pos_x_l = 0
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
ENEMY_POS['NEST'] = {x=1300, y=0}
ENEMY_POS['NEST_T'] = {x=1500, y=300}
ENEMY_POS['NEST_B'] = {x=1500, y=-200}







-------------------------------------
-- function getEnemyPos
-- @brief 적군의 절대 위치
-------------------------------------
function getEnemyPos(key)
    local pos = clone(ENEMY_POS[key])

    if (not pos) then
        error('ERROE! 존재하지 않는 key : ' .. tostring(key))
        pos = { x = 0, y = 0 }
    end

    -- 현재 카메라 위치를 기준으로 하는 상대 좌표로 변경
    local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
    pos['x'] = pos['x'] + cameraHomePosX
    pos['y'] = pos['y'] + cameraHomePosY

    return pos
end

-------------------------------------
-- function getWorldEnemyPos
-- @brief 적군의 상대 위치(현재 월드의 scale을 반영)
-------------------------------------
function getWorldEnemyPos(enemy, key)
    if (not ENEMY_POS[key]) then
        error('ERROE! 존재하지 않는 key : ' .. tostring(key))
        return {x=0, y=0}
    end

    -- 현재 월드의 scale을 얻어옴
    local world_scale = enemy.m_world.m_worldScale
    local pos = clone(ENEMY_POS[key])

    -- 절대위치에 scale을 적용
    pos.x = pos.x / world_scale
    pos.y = pos.y / world_scale

    -- 현재 카메라 위치를 기준으로 하는 상대 좌표로 변경
    local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
    pos['x'] = pos['x'] + cameraHomePosX
    pos['y'] = pos['y'] + cameraHomePosY

    return pos
end

-------------------------------------
-- function getRandomEnemyPos
-- @brief 적군의 상대 위치(현재 월드의 scale을 반영)
-------------------------------------
function getRandomWorldEnemyPos(enemy)
    local temp1 = {'R'}
    local temp2 = {'F', 'M', 'B'}
    local temp3 = {'1', '2'}
    local temp4 = {'1', '2', '3', '4', '5', '6', '7'}

    -- 현재 위치가 오른쪽 화면 끝에 가깝다면 무조건 다른 위치로 이동시킴
    if (enemy.pos.x >= ENEMY_POS['RB11'].x) then
        temp2 = {'F', 'M'}
    end


    local temp1 = randomShuffle(temp1)
    local temp2 = randomShuffle(temp2)
    local temp3 = randomShuffle(temp3)
    local temp4 = randomShuffle(temp4)

    local key = temp1[1] ..temp2[1] .. temp3[1] .. temp4[1]
    
    -- 현재 월드의 scale을 얻어옴
    local world_scale = enemy.m_world.m_worldScale
    local pos = clone(ENEMY_POS[key])

    -- 절대위치에 scale을 적용
    pos.x = pos.x / world_scale
    pos.y = pos.y / world_scale

    -- 현재 카메라 위치를 기준으로 하는 상대 좌표로 변경
    local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
    pos['x'] = pos['x'] + cameraHomePosX
    pos['y'] = pos['y'] + cameraHomePosY

    return pos
end

-------------------------------------
-- function getEnemyPosKeyFromPos
-- @brief 좌표값으로 위치 키값을 얻음
-------------------------------------
function getEnemyPosKeyFromPos(x, y)
    local pos_x_add = 95
    local pos_y_add = -68
end