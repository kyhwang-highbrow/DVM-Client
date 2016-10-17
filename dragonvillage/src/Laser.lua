-------------------------------------
-- class Laser
-------------------------------------
Laser = class(Entity, {
        m_bDirty = '',

        m_startDir = '',
        m_endPos = '',
        m_interval = '',
        m_count = '',

        m_effectRes = '',
        m_effectList = '',

        m_endEffect = '',

        m_syncPosObj = '',


        m_temp = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Laser:init(file_name, body, ...)
    self:initState()

    self.m_bDirty = true

    self.m_startDir = 0
    self.m_endPos = {x=0, y=0}
    self.m_interval = 50
    self.m_count = 100
end

-------------------------------------
-- function initLaser
-------------------------------------
function Laser:initLaser(file_name)
    self.m_effectRes = file_name
    self.m_effectList = {}
end

-------------------------------------
-- function initState
-------------------------------------
function Laser:initState()
    self:addState('idle', Laser.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('idle')
end

-------------------------------------
-- function st_idle
-------------------------------------
function Laser.st_idle(owner, dt)

    --[[
    local tar_dir = 20
    if owner.m_temp then
        tar_dir = tar_dir * (-1)
    end

    local dir, gap = getRotationDegree(owner.m_startDir, tar_dir, 720 * dt)
    owner:setStartDir(dir)

    if (gap == 0) then
        owner.m_temp = (not owner.m_temp) 
    end 
    --]]
    

    if owner.m_syncPosObj then
        local x = owner.m_syncPosObj.pos.x
        local y = owner.m_syncPosObj.pos.y
        owner:setPosition(x, y)
    end

    if owner.m_bDirty then
        owner:updateLaser()
    end
end

-------------------------------------
-- function setStartDir
-------------------------------------
function Laser:setStartDir(dir)
    if (self.m_startDir == dir) then
        return
    end

    self.m_startDir = dir

    self.m_bDirty = true
end

-------------------------------------
-- function setEndPos
-------------------------------------
function Laser:setEndPos(x, y)
    if (self.m_endPos.x == x) or (self.m_endPos.y == y) then
        return
    end

    self.m_endPos.x = x
    self.m_endPos.y = y

    self.m_bDirty = true
end

-------------------------------------
-- function setInterval
-------------------------------------
function Laser:setInterval(interval)
    if (self.m_interval == interval) then
        return
    end

    self.m_interval = interval

    self.m_bDirty = true
end

-------------------------------------
-- function setCount
-------------------------------------
function Laser:setCount(count)
    if (self.m_count == count) then
        return
    end

    self.m_count = count

    self.m_bDirty = true
end

-------------------------------------
-- function updateLaser
-------------------------------------
function Laser:updateLaser()
    if (not self.m_bDirty) then
        return
    end

    -- 모든 effect visible off
    for i,v in pairs(self.m_effectList) do
        v.m_node:setVisible(false)
    end

    -- 일단 직선만 해보자...
    local x, y = 0, 0
    --local dir = getDegree(self.pos.x, self.pos.y, self.m_endPos.x, self.m_endPos.y)
    local dir = self.m_startDir
    local gap = 0
    local delta = getPointFromAngleAndDistance(dir, self.m_interval)
    local endpos = {x=self.m_endPos.x-self.pos.x, y=self.m_endPos.y-self.pos.y}

    --cclog('dir ' .. dir)
    --cclog('delta ' .. luadump(delta))

    local add_dir = 0

    for i=1, self.m_count do
        local effect = self:getEffect(i)
        effect.m_node:setVisible(true)
        

        local mid_x, mid_y = self:getMiddlePos(x, y, x + delta['x'], y + delta['y'])
        effect.m_node:setPosition(mid_x, mid_y)
        effect:setRotation(dir)

        x = x + delta['x']
        y = y + delta['y']

        local dest_dir = getDegree(x, y, endpos.x, endpos.y)
        --cclog('x, y, endpos.x, endpos.y ', x, y, endpos.x, endpos.y)
        --cclog('dest_dir ' .. dest_dir)
        dir, gap = getRotationDegree(dir, dest_dir, add_dir)

        add_dir = add_dir + 1
        add_dir = math_min(add_dir, 45)

        delta = getPointFromAngleAndDistance(dir, self.m_interval)
        
        --if gap == 0 then
            local dist = getDistance(x, y, endpos.x, endpos.y)
            --cclog('dist ' .. dist)
            --cclog('self.m_interval ' .. self.m_interval)
            if (dist <= (self.m_interval/2)) then
                break
            end
        --end
    end    

    self:getEndEffect().m_node:setPosition(self.m_endPos.x - self.pos.x, self.m_endPos.y - self.pos.y)

    self.m_bDirty = false
end

-------------------------------------
-- function release
-------------------------------------
function Laser:release()
    Entity.release(self)
end

-------------------------------------
-- function getEffect
-------------------------------------
function Laser:getEffect(idx)
    if (not self.m_effectList[idx]) then
        -- 생성
        local animator = MakeAnimator(self.m_effectRes)
        animator:changeAni('test', true)
        self.m_effectList[idx] = animator
        self.m_rootNode:addChild(animator.m_node)
    end

    return self.m_effectList[idx]
end

-------------------------------------
-- function getEndEffect
-------------------------------------
function Laser:getEndEffect()
    if (not self.m_endEffect) then
        -- 생성
        local animator = MakeAnimator('res/effect/shot_white_02.png')
        animator:changeAni('test', true)
        self.m_endEffect = animator
        self.m_rootNode:addChild(animator.m_node, 1)
    end

    return self.m_endEffect
end


-------------------------------------
-- function getMiddlePos
-------------------------------------
function Laser:getMiddlePos(x1, y1, x2, y2)
    return (x1 + x2)/2, (y1 + y2)/2
end

-------------------------------------
-- function setPosition
-------------------------------------
function Laser:setPosition(x, y)
    if (self.pos.x ~= x) or (self.pos.y ~= y) then
        self.m_bDirty = true
    end

    Entity.setPosition(self, x, y)
end

-- 시작위치, 종료위치(target or 직선)
-- 시작각, 레이저 간격, 회전각, 최대 갯수
-- 1. 시각적으로 후전 만들어보자
-- 2. 실제 충돌은 나중에 생각하자




-------------------------------------
-- function testCode
-------------------------------------
function Laser:testCode()
    local laser = Laser()
    laser:initLaser('res/test/effect_laser_water_idle/effect_laser_water_idle.vrp')
    laser:setPosition(100, 0)
    laser:setEndPos(900, 1)
    laser:setStartDir(45)

    self.m_missiledNode:addChild(laser.m_rootNode)
    self:addToUnitList(laser)

    laser:updateLaser()

    laser.m_syncPosObj = hero
end