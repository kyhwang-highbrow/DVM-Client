-------------------------------------
-- constant PHYS_COLLISION_INTERVAL
-- @brief 충돌 간격 0.033
--      0.33초마다 충돌 처리 수행 (1초에 약 30번)
--      FPS가 60이라고 가정하였을 때 2프레임에 한번 씩 충돌 처리
--      슈팅 게임을 플레이하기 위한 최소한의 FPS를 30프레임으로 규정
--      30프레임이 나오는 단말과 그 이상의 프레임이 나오는 단말의 결과를 비슷하게 하기 위함
--      불필요한 연산량을 줄여 퍼포먼스 향상과 베터리 소모량을 최소화
-------------------------------------
PHYS_COLLISION_INTERVAL = 0.033

-------------------------------------
-- class physWorld
-- @brief 오브젝트의 이동, 충돌을 연산하는 world
-------------------------------------
PhysWorld = class({

        -- PhysObject들이 add되어있는 Node
        m_worldNode = 'cc.Node',

        -- 디버그 모드
        m_bDebug = 'boolean',

        -- 그룹 리스트
        m_group = 'list',
        -- key는 그룹명, value는 PhysObject들의 리스트
        -- m_group ={
        --         hero = { obj1, obj2, obj3 },
        --         enemy = { obj1, obj2, obj3 },
        --         missile = { obj1, obj2, obj3, obj4 }
        --     }

        m_groupColor = 'list',

        -- 충돌 그룹 리스트
        m_collisionGroup = 'list',
        -- key는 그룹명, value는 충돌 처리를 해야할 상대 그룹들의 리스트
        -- m_collisionGroup = {
        --         hero = { item },
        --         enemy = { hero },
        --         missile = { hero, enemy }
        --     }

        -- PhysObject의 고유 IDX. 1씩 증가
        m_objIdx = 'number',

        -- 충돌처리 스킵 여부
        m_bSkipCollision = 'boolean',

        -- 충돌 타이머 (PHYS_COLLISION_INTERVAL의 간격으로 충돌 처리)
        m_collisionTimer = '',

        -- PhysObject의 충돌 위치 저장 (연산량을 줄이기 위해 위치 변경 시 자동으로 설정)
        m_objPosIndex = '',


        m_gridX = '',
        m_gridY = '',

        -- callback
        m_lDebugChangeCB = '',
    })

-------------------------------------
-- function init
-------------------------------------
function PhysWorld:init(world_node, is_debug_mode)
    self.m_worldNode = world_node
    self.m_bDebug = is_debug_mode

    self.m_group = {}
    self.m_groupColor = {}
    self.m_collisionGroup = {}
    self.m_objIdx = 0
    self.m_bSkipCollision = false
    self.m_collisionTimer = PHYS_COLLISION_INTERVAL
    self.m_objPosIndex = {}

    -- glnode 생성
    do
        -- draw 함수 구현
        local function primitivesDraw(transform, transformUpdated)
            self:primitivesDraw(transform, transformUpdated)
        end

        -- glNode 생성
        local glNode = cc.GLNode:create()
        glNode:registerScriptDrawHandler(primitivesDraw)

        local container = cc.Sprite:create(EMPTY_PNG)
        world_node:addChild(container, 100)

        container:addChild(glNode)
    end

    self:initGrid()

    self.m_lDebugChangeCB = {}
end

-------------------------------------
-- function addGroup
-- @brief 그룹을 만들어 주고, 해당 그룹과 충돌체크 해야하는 대상을 collision_group에 저장해준다
-- @param key
-- @param collision_group
-------------------------------------
function PhysWorld:addGroup(key, collision_group, color)
    self.m_group[key] = {}
    self.m_groupColor[key] = color or {255, 255, 255, 127}
    self.m_collisionGroup[key] = collision_group

    -- 현재 충돌 위치를 저장
    self.m_objPosIndex[key] = {}
    for x=1, (#self.m_gridX + 1) do
        self.m_objPosIndex[key][x] = {}
        for y=1, (#self.m_gridY + 1) do
            self.m_objPosIndex[key][x][y] = {}
        end
    end
end

-------------------------------------
-- function addObject
-- @param key
-- @param object
-------------------------------------
function PhysWorld:addObject(key, object)
    
    object.m_physWorld = self

    if self.m_group[key] then
        table.insert(self.m_group[key], object)
        object.phys_key = key
        object.phys_idx = self.m_objIdx
        self.m_objIdx = self.m_objIdx + 1
    else
        cclog('Phys Group key : ' .. key .. ' is not exist!')
    end
end

-------------------------------------
-- function removeObject
-- @param object
-------------------------------------
function PhysWorld:removeObject(object)
    -- 기존 인덱스 삭제
    if object.phys_key then
        for x=object.m_posIndexMinX, object.m_posIndexMaxX do
            for y=object.m_posIndexMinY, object.m_posIndexMaxY do
                self.m_objPosIndex[object.phys_key][x][y][object.phys_idx] = nil
            end
        end
    end

    local t_data = self.m_group[object.phys_key]
    if t_data then
        for i,v in ipairs(t_data) do
            if (v.phys_idx == object.phys_idx) then
                table.remove(t_data, i)
                break
            end
        end    
    end
end

local unit = 1.0 / 20

-------------------------------------
-- function update
-- @param dt
-------------------------------------
function PhysWorld:update(dt)
    --local work_cnt = 0

    -- 충돌 처리 시간 간격 지정
    local skip = false
    self.m_collisionTimer = self.m_collisionTimer - dt
    if self.m_collisionTimer > 0 then
        skip = true
    else
        self.m_collisionTimer = PHYS_COLLISION_INTERVAL
    end

    -- 물리 객체 포지션 이동
    self:updateObjectPos(dt, (self.m_bSkipCollision or skip))

    -- 충돌 스킵
    if self.m_bSkipCollision or skip then
        return
    end


    -- for문 안에서 변수를 재할당 하지 않도록 미리 선언
    local body = nil
    local object_phys_idx = nil
    local x = 0
    local y = 0
	local target = nil

    local l_enemy_key = nil
    local m_collisionGroup = nil
    local check_phys_idx = nil

    local ret = false
    local intersect_pos_x = 0
    local intersect_pos_y = 0

    local t_collision = nil

    -- 충돌 처리
    for phys_key, l_object in pairs(self.m_group) do
        for _, object in ipairs(l_object) do
		
			-- 단일 타겟만 충돌 체크
			if (object.bFixedAttack) then
				if isInstanceOf(object, Missile) then
					body = object.body
					target = object.m_target
					x = object.pos.x
                    y = object.pos.y
					-- 점과 점의 거리를 이용하여 충돌 여부 확인
					if target then 
						ret = isCollision(x, y, target, 20)
					end
                    -- 충돌 콜백 실행
                    if ret and target then
                        object:runAtkCallback(target, target.pos.x, target.pos.y)
                        target:runDefCallback(object, x, y)

                        -- 지정된 타겟과 한 번 이상 충돌되지 않도록 처리
                        object.bFixedAttack = false
                    end
				end

			-- 다중 충돌 체크
            elseif (object.enable_body) then
                body = object.body

                -- 충돌 idx
                if object.m_ownerObject then
                    object_phys_idx = object.m_ownerObject.phys_idx
                else
                    object_phys_idx = object.phys_idx
                end
                check_phys_idx = {}

				-- 해당 phys group의 충돌체크할 상대의 키 리스트
                l_enemy_key = self.m_collisionGroup[phys_key]
                if l_enemy_key and body.size > 0 then
                    x    = object.pos.x
                    y    = object.pos.y
                    check_phys_idx = {} -- posindex를 여러군데 걸쳤을 경우를 위해

					-- 해당 오브젝트의 body에 해당하는 모든 idx를 순회
                    for x_idx = object.m_posIndexMinX, object.m_posIndexMaxX do
                        for y_idx = object.m_posIndexMinY, object.m_posIndexMaxY do
                    
					        for _, enemy_key in pairs(l_enemy_key) do
                                for _, enemy in pairs(self.m_objPosIndex[enemy_key][x_idx][y_idx]) do
                                    --work_cnt = work_cnt + 1

									-- 충돌리스트를 가져온다.
                                    if enemy.m_ownerObject then
                                        t_collision = enemy.m_ownerObject.t_collision
                                    else
                                        t_collision = enemy.t_collision
                                    end

									-- 이미 충돌했는지 체크
                                    if (not check_phys_idx[enemy.phys_idx]) and enemy.enable_body and (not t_collision[object_phys_idx]) then
                                        
										-- 해당 physobject와 충돌체크 했는지 저장
                                        check_phys_idx[enemy.phys_idx] = true
										
										-- 점과 점의 거리를 이용하여 충돌 여부 확인
                                        ret, intersect_pos_x, intersect_pos_y = enemy:isIntersectBody(body, x, y)
                                        if ret then
											-- 충돌 한 것으로 저장 (해당 오브젝트에 전달)
                                            t_collision[object_phys_idx] = true
											-- 충돌 콜백 실행
                                            enemy:runAtkCallback(object, intersect_pos_x, intersect_pos_y)
                                            object:runDefCallback(enemy, intersect_pos_x, intersect_pos_y)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-------------------------------------
-- function updateObjectPos
-- @brief 물리객체 포지션 이동
-------------------------------------
function PhysWorld:updateObjectPos(dt, skip)
    local pos_x = 0
    local pos_y = 0
    local movement_x = 0
    local movement_y = 0

    -- 위치 이동
    for _, t_list in pairs(self.m_group) do
        for _, _v in ipairs(t_list) do

            -- 이동이 허용되고 일시 정지가 아닌 객체만 이동
            if _v.apply_movement and (not _v.m_temporaryPause) then
                movement_x = _v.speed * _v.movement_x
                movement_y = _v.speed * _v.movement_y

                pos_x = _v.pos.x + (movement_x * dt)
                pos_y = _v.pos.y + (movement_y * dt)

                if (pos_x ~= _v.pos.x) or (pos_y ~= _v.pos.y) then
                    _v:setPosition(pos_x, pos_y)
                end
            end

            if (not skip) and _v.m_dirtyPos then
                self:refreshPosInfo(_v)
            end
        end
    end
end

-------------------------------------
-- function refreshPosInfo
-- @brief 물리객체 포지션 이동
-------------------------------------
function PhysWorld:refreshPosInfo(phys_obj)
    if (not phys_obj.phys_key) or (-1 == phys_obj.phys_idx) then
        return
    end

    -- 기존 인덱스 삭제
    for x=phys_obj.m_posIndexMinX, phys_obj.m_posIndexMaxX do
        for y=phys_obj.m_posIndexMinY, phys_obj.m_posIndexMaxY do
            self.m_objPosIndex[phys_obj.phys_key][x][y][phys_obj.phys_idx] = nil
        end
    end

    local size = phys_obj.body.size

    local body_center_x = phys_obj.pos.x + phys_obj.body.x
    local body_center_y = phys_obj.pos.y + phys_obj.body.y

    local pos_min_x = body_center_x - size
    local pos_max_x = body_center_x + size
    local pos_min_y = body_center_y - size
    local pos_max_y = body_center_y + size

    -- min_x 지정
    phys_obj.m_posIndexMinX = #self.m_gridX + 1
    for i,v in ipairs(self.m_gridX) do
        if pos_min_x < v then
            phys_obj.m_posIndexMinX = i
            break
        end    
    end

    -- max_x 지정
    phys_obj.m_posIndexMaxX = #self.m_gridX + 1
    for i,v in ipairs(self.m_gridX) do
        if pos_max_x < v then
            phys_obj.m_posIndexMaxX = i
            break
        end    
    end

    -- min_y 지정
    phys_obj.m_posIndexMinY = #self.m_gridY + 1
    for i,v in ipairs(self.m_gridY) do
        if pos_min_y < v then
            phys_obj.m_posIndexMinY = i
            break
        end    
    end

    -- max_y 지정
    phys_obj.m_posIndexMaxY = #self.m_gridY + 1
    for i,v in ipairs(self.m_gridY) do
        if pos_max_y < v then
            phys_obj.m_posIndexMaxY = i
            break
        end    
    end

    -- 새로운 인덱스 추가
    for x=phys_obj.m_posIndexMinX, phys_obj.m_posIndexMaxX do
        for y=phys_obj.m_posIndexMinY, phys_obj.m_posIndexMaxY do
            self.m_objPosIndex[phys_obj.phys_key][x][y][phys_obj.phys_idx] = phys_obj
        end
    end

    phys_obj.m_dirtyPos = false
end

-------------------------------------
-- function initGrid
-------------------------------------
function PhysWorld:initGrid()
    self.m_gridX = {}
    local x_interval = 100
    local x_count = 19
    local start_x = x_interval/2

    for i=1, x_count do        
        table.insert(self.m_gridX, start_x)
        start_x = start_x + x_interval
    end

    --[[
    table.insert(self.m_gridX, 30)
    table.insert(self.m_gridX, 115)
    table.insert(self.m_gridX, 195)
    table.insert(self.m_gridX, 275)
    table.insert(self.m_gridX, 355)
    table.insert(self.m_gridX, 435)
    table.insert(self.m_gridX, 515)
    table.insert(self.m_gridX, 595)
    table.insert(self.m_gridX, 675)
    table.insert(self.m_gridX, 755)
    table.insert(self.m_gridX, 835)
    table.insert(self.m_gridX, 915)
    table.insert(self.m_gridX, 995)
    table.insert(self.m_gridX, 1075)
    table.insert(self.m_gridX, 1155)
    --]]
    
    self.m_gridY = {}
    local y_interval = 100
    local y_count = 14
    local start_y = (-(y_count - 0.5) / 2) * y_interval

    for i=1, y_count do        
        table.insert(self.m_gridY, start_y)
        start_y = start_y + y_interval
    end

    --[[
    table.insert(self.m_gridY, 100)
    table.insert(self.m_gridY, 50)
    table.insert(self.m_gridY, -50)
    table.insert(self.m_gridY, -100)
    --]]

    for i,v in pairs(self.m_objPosIndex) do
        self.m_objPosIndex[i] = {}
        for x=1, (#self.m_gridX + 1) do
            self.m_objPosIndex[i][x] = {}
            for y=1, (#self.m_gridY + 1) do
                self.m_objPosIndex[i][x][y] = {}
            end
        end
    end
end

-------------------------------------
-- function initGroup
-------------------------------------
function PhysWorld:initGroup()
    -- 왼쪽이 방어자, 오른쪽이 공격자
    self:addGroup(PHYS.HERO, {PHYS.MISSILE.ENEMY}, {0, 255, 0, 127})
    self:addGroup(PHYS.ENEMY, {PHYS.MISSILE.HERO}, {0, 255, 200, 127})
    
    self:addGroup(PHYS.MISSILE.HERO, {}, {255, 0, 0, 127})
    self:addGroup(PHYS.MISSILE.ENEMY, {}, {255, 0, 200, 127})    

    self:addGroup(PHYS.EFFECT, {}, {0, 0, 255, 127})
end


-------------------------------------
-- function primitivesDraw
-------------------------------------
function PhysWorld:primitivesDraw(transform, transformUpdated)

    if (not self.m_bDebug) then
        return
    end

    kmGLPushMatrix()
    kmGLLoadMatrix(transform)

    gl.lineWidth(1)

    --self:drawResolution()
    self:drawGrid()
    
    for phys_key, l_object in pairs(self.m_group) do

        -- 색상 지정
        local color = self.m_groupColor[phys_key]
        cc.DrawPrimitives.drawColor4B(color[1], color[2], color[3], color[4])

        for _, object in ipairs(l_object) do
            if (object.enable_body) or (object.bFixedAttack) then
                local x = object.pos.x + object.body.x
                local y = object.pos.y + object.body.y
                local radius = object.body.size
                cc.DrawPrimitives.drawSolidCircle(cc.p(x, y), radius, 0, 32)
            end
        end
    end

    kmGLPopMatrix()
end

-------------------------------------
-- function drawResolution
-------------------------------------
function PhysWorld:drawResolution()
    cc.DrawPrimitives.drawColor4B(255, 255, 255, 255)

    if false then
        -- 1080 * 720
        local vertices =   
        {
            cc.p(0, MIN_RESOLUTION_Y/2),
            cc.p(0, -MIN_RESOLUTION_Y/2),
            cc.p(MIN_RESOLUTION_X, -MIN_RESOLUTION_Y/2),
            cc.p(MIN_RESOLUTION_X, MIN_RESOLUTION_Y/2),
        }  
        cc.DrawPrimitives.drawPoly(vertices, 4, true) 

        -- 1280 * 810
        local vertices =   
        {
            cc.p(0, MAX_RESOLUTION_Y/2),  
            cc.p(0, -MAX_RESOLUTION_Y/2),  
            cc.p(MAX_RESOLUTION_X, -MAX_RESOLUTION_Y/2),  
            cc.p(MAX_RESOLUTION_X, MAX_RESOLUTION_Y/2),  
        }  
        cc.DrawPrimitives.drawPoly(vertices, 4, true) 
    end
end

-------------------------------------
-- function drawGrid
-------------------------------------
function PhysWorld:drawGrid()
    cc.DrawPrimitives.drawColor4B(255, 255, 0, 127)
    
    -- 라인 생성
    for i, v in ipairs(self.m_gridX) do
        cc.DrawPrimitives.drawLine(cc.p(v, -1024), cc.p(v, 1024))
    end

    -- 라인 생성
    for i, v in ipairs(self.m_gridY) do
        cc.DrawPrimitives.drawLine(cc.p(0, v), cc.p(2048, v))
    end
end

-------------------------------------
-- 레이저 관련
-------------------------------------

-------------------------------------
-- function getRectangularCoordinates
-- @brief 선분과 임의의 점의 직교 좌표
-- @param x1, y1, x2, y2 선분의 시작과 끝
-- @param px, py 임의의 점
-- @return ax, ay 직교 좌표
-------------------------------------
function PhysWorld:getRectangularCoordinates(x1, y1, x2, y2, px, py)
    local ax, ay;   -- 교점
    local ml;       -- 기울기
    local kl;       -- 방정식 y = mx + k1의 상수 k1

    local m2; -- 수직인 직선의 기울기
    local k2; -- 수직인 직선의 방정식 y = mx + k2의 상수 k2

    -- 먼저 직선의 방정식부터 구한다
    -- 구하는 방법은 두 점 p1, p2 를 지나는 직선의 방정식
    -- y - yp1 = (yp1-yp2)/(xp1-xp2) * (x-xp1) 이 됨

    -- 기울기를 구할 건데 예외 상황부터 먼저 처리

    -- 선분이 수직일 경우
    if ( x1 == x2 ) then
        ax = x1;
        ay = py;
    -- 선분이 수평일 경우
    elseif ( y1 == y2 ) then
        ax = px;
        ay = y1;
    -- 그 외의 경우
    else
        -- 기울기 m1
        m1 = (y1 - y2) / (x1 - x2);
        -- 상수 k1
        k1 = -m1 * x1 + y1;

        -- 선분 l 을 포함하는 직선의 방정식은 y = m1x + k1
        -- 남은 것은 점 p 를 지나고 위의 직선과 직교하는 직선의 방정식을 구한다
        -- 두 직선은 직교하기 때문에 m1 * m2 = -1

        -- 기울기 m2
        m2 = -1.0 / m1;
        -- p 를 지나기 때문에 yp = m2 * xp + k2 => k2 = yp - m2 * xp
        k2 = py - m2 * px;

        -- 두 직선 y = m1x + k1, y = m2x + k2 의 교점을 구한다
        ax = (k2 - k1) / (m1 - m2);
        ay = m1 * ax + k1;
    end

    return ax, ay
end


-------------------------------------
-- function getLaserCollision
-------------------------------------
function PhysWorld:getLaserCollision(x1, y1, x2, y2, thickness, phys_key)

    -- phys_key가 충돌처리를 해야하는 phys_key의 리스트를 얻어옴
    local t_target_key = self:getTargetPhysKey(phys_key)

    local t_collision_obj = {}
    
    -- 충돌 처리 범위 확인
    local min_x, max_x
    if (x1 < x2) then
        min_x = x1 - thickness
        max_x = x2 + thickness
    else
        min_x = x2 - thickness
        max_x = x1 + thickness
    end
    local min_y, max_y
    if (y1 < y2) then
        min_y = y1 - thickness
        max_y = y2 + thickness
    else
        min_y = y2 - thickness
        max_y = y1 + thickness
    end


    for _, key in ipairs (t_target_key) do
        for _, object in pairs(self.m_group[key]) do
            
            local obj_x = object.pos.x + object.body.x
            local obj_y = object.pos.y + object.body.y
            local obj_size = object.body.size

            local not_finish = true
            local x3, y3 = self:getRectangularCoordinates(x1, y1, x2, y2, obj_x, obj_y)
            

            -- 직교 좌표가 범위를 넘어갔을 경우
            if (x3 < min_x) or (max_x < x3) or (y3 < min_y) or (max_y < y3) then

                -- 시작 좌표와 충돌 확인
                if not_finish then
                    local dist = math_distance(obj_x, obj_y, x1, y1)
                    if dist <= (obj_size + thickness) then
                        not_finish = false
                    end
                end

                -- 종료 좌표와 충돌 확인
                if not_finish then
                    local dist = math_distance(obj_x, obj_y, x2, y2)
                    if dist <= (obj_size + thickness) then
                        not_finish = false
                    end
                end
            else
                -- 직교 좌표가 범위안에 존재할 경우
                local dist = math_distance(obj_x, obj_y, x3, y3)
                if dist <= (obj_size + thickness) then
                    not_finish = false
                end
            end

            -- 충돌된 객체라면 리스트에 저장 (죽지 않은 대상)
            --if (not_finish == false) and (object.m_bDead == false) then
            if (not_finish == false) then
                local distance = math_distance(x1, y1, x3, y3)
                table.insert(t_collision_obj, {obj=object, dist = distance, x=x3, y=y3})
            end

        end
    end

    -- dist가 짧은 순으로 정렬
    table.sort(t_collision_obj, function(a, b)
        return a['dist'] < b['dist']
    end)

    return t_collision_obj
end

-------------------------------------
-- function getTargetPhysKey
-- @brief phys_key와 충돌처리가 되는 key의 리스트를 리턴
-------------------------------------
function PhysWorld:getTargetPhysKey(phys_key)
    -- ex) self:addGroup(PHYS.HERO, {PHYS.MISSILE.ENEMY}, {0, 255, 0, 127})

    local t_target_key = {}
    for key, l_group in pairs(self.m_collisionGroup) do
        if table.find(l_group, phys_key) then
            table.insert(t_target_key, key)
        end
    end

    return t_target_key
end

-------------------------------------
-- function setDebug
-------------------------------------
function PhysWorld:setDebug(debug)
    self.m_bDebug = debug

    for i,v in pairs(self.m_lDebugChangeCB) do
        v(self.m_bDebug)
    end
end

-------------------------------------
-- function addDebugChangeCB
-------------------------------------
function PhysWorld:addDebugChangeCB(owner, cb)
    self.m_lDebugChangeCB[owner] = cb
    if cb then
        cb(self.m_bDebug)
    end
end