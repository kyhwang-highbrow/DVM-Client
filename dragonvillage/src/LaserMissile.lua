-------------------------------------
-- class LaserMissile
-------------------------------------
LaserMissile = class(Missile, {
        m_posList = '',
        m_tailList = '',
        m_tailCount = '',
        m_tailActiveIdx = '',
        m_interval = '',

        -- 충돌 바디
        m_physbodyList = '',

        m_temp = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function LaserMissile:init(file_name, body)
    
end

-------------------------------------
-- function initState
-------------------------------------
function LaserMissile:initState()
    Missile.initState(self)

    self:addState('move', LaserMissile.st_move, 'move', true)
    self:addState('move2', LaserMissile.st_move2, 'move', true)
    self:addState('moveOut', LaserMissile.st_moveOut, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function initTail
-------------------------------------
function LaserMissile:initTail(count, interval)
    self.m_posList = {}

    -- 초기화
    if self.m_tailList then
        for i,v in ipairs(self.m_tailList) do
            v.m_mode:removeFromParent()
        end
    end
    self.m_tailList = {}
    self.m_tailCount = count
    self.m_tailActiveIdx = 0
    self.m_interval = interval

    -- 바디들 초기화
    if self.m_physbodyList then
        for i,v in ipairs(self.m_physbodyList) do
            v:release()
        end 
    end

    self.m_physbodyList = {}

    -- 생성
    for i=1, count do
        local animator = MakeAnimator(self.m_animator.m_resName)
        self.m_rootNode:addChild(animator.m_node)
        table.insert(self.m_tailList, animator)

        local pos_x = self.pos.x
        local pos_y = self.pos.y
        animator.m_node:setPosition(self:getLocalPos(pos_x, pos_y))
        animator.m_node:setVisible(false)

        -- 바디 생성
        local phys_obj = PhysObject()
        PhysObject_initPhys(phys_obj, {self.body.x, self.body.y, self.body.size})
        self.m_world.m_physWorld:addObject(PHYS.MISSILE.HERO, phys_obj)

        phys_obj.m_ownerObject = self
        phys_obj:setPosition(pos_x, pos_y)

        table.insert(self.m_physbodyList, phys_obj)
    end
end

-------------------------------------
-- function updateTail
-------------------------------------
function LaserMissile:updateTail(dt)

    local dist = 0
    local missile_idx = 1
    local missile = self.m_tailList[missile_idx]
    local before_value = nil

    local stop_idx = nil

    --cclog('#########################?')
    if missile then
        for i,v in ipairs(self.m_posList) do
            if (i~=1) then
                dist = dist + v['dist']

                if (dist >= self.m_interval) then
                    dist = dist - self.m_interval

                    local degree = getDegree(v['x'], v['y'], before_value['x'], before_value['y'])
                    local pos = getPointFromAngleAndDistance(degree, dist)

                    missile:setRotation(degree)

                    local pos_x = v['x']+pos['x']
                    local pos_y = v['y']+pos['y']


                    missile.m_node:setPosition(self:getLocalPos(pos_x, pos_y))

                    self.m_physbodyList[missile_idx]:setPosition(pos_x, pos_y)

                    if (self.m_tailActiveIdx <= missile_idx) then
                        missile.m_node:setVisible(true)
                        self.m_tailActiveIdx = missile_idx
                    end

                    missile_idx = missile_idx + 1
                    missile = self.m_tailList[missile_idx]

                    if (not missile) then
                        stop_idx = i+1
                        break
                    end
                end
            end
            before_value = v
        end
    end

    while self.m_posList[stop_idx] do
        table.remove(self.m_posList, stop_idx)
    end
end

-------------------------------------
-- function st_move
-------------------------------------
function LaserMissile.st_move(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_temp = 0
    else

        ---[[
        -- 각조 조정
        local dir = owner.movement_theta - (180 * dt)
        local dir = getAdjustDegree(dir)
        owner:setDir(dir)
        owner:setRotation(dir)
        --]]

        owner.m_temp = owner.m_temp + dt
        if owner.m_temp >= 0.1 then
            owner.m_temp = owner.m_temp - 0.1
            owner:clearCollisionObjectList()
        end


        owner:updateTail(dt)

        if (owner.m_stateTimer >= 0.5) then
            owner:changeState('move2')
        end
    end
end

-------------------------------------
-- function st_move2
-------------------------------------
function LaserMissile.st_move2(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_temp = 0
    else

        ---[[
        -- 각조 조정
        local dir = owner.movement_theta + (270 * dt)
        local dir = getAdjustDegree(dir)
        owner:setDir(dir)
        owner:setRotation(dir)
        --]]

        owner.m_temp = owner.m_temp + dt
        if owner.m_temp >= 0.1 then
            owner.m_temp = owner.m_temp - 0.1
            owner:clearCollisionObjectList()
        end


        owner:updateTail(dt)

        if (owner.m_stateTimer >= 0.5) then
            owner:changeState('moveOut')
        end
    end
end

-------------------------------------
-- function st_moveOut
-------------------------------------
function LaserMissile.st_moveOut(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_temp = 0
    else        
        ---[[
        -- 각조 조정

        local dir = owner.movement_theta
        local new_dir = getRotationDegree(dir, 0, (135 * dt))
        owner:setDir(new_dir)
        owner:setRotation(new_dir)
        --]]

        owner.m_temp = owner.m_temp + dt
        if owner.m_temp >= 0.1 then
            owner.m_temp = owner.m_temp - 0.1
            owner:clearCollisionObjectList()
        end

        owner:updateTail(dt)
    end
end


-------------------------------------
-- function getLocalPos
-------------------------------------
function LaserMissile:getLocalPos(x, y)
    return (x-self.pos.x), (y-self.pos.y)
end

-------------------------------------
-- function setPosition
-------------------------------------
function LaserMissile:setPosition(x, y)
    Missile.setPosition(self, x, y)

    -- 꼬리의 위치를 위해 위치 저장
    if self.m_posList then
        local first_pos = self.m_posList[1]

        if first_pos then
            if (first_pos['x'] ~= self.pos.x) or (first_pos['y'] ~= self.pos.y) then
                local dist = math_distance(first_pos['x'], first_pos['y'], self.pos.x, self.pos.y)
                table.insert(self.m_posList, 1, {x=self.pos.x, y=self.pos.y, dist=dist})
            end
        else
            table.insert(self.m_posList, 1, {x=self.pos.x, y=self.pos.y, dist=0})
        end
    end
end

-------------------------------------
-- function release
-------------------------------------
function LaserMissile:release()
    
    -- 바디들 초기화
    if self.m_physbodyList then
        for i,v in ipairs(self.m_physbodyList) do
            v:release()
        end 
    end

    Missile.release(self)
end