-------------------------------------
-- class LinearLaser
-------------------------------------
LinearLaser = class(Entity, {

        m_linkEffect = '',  -- 레이저의 그래픽 리소스
        m_laserLength = '',
        m_laserDir = '',

        m_laserTimer = '',
        m_limitTime = '',

        m_multiHitTime = '',
        m_multiHitTimer = '',

        m_clearCount = '',
        m_maxClearCount = '',

        m_offsetX = '',
        m_offsetY = '',

        -- basic ray
        m_ownerChar = '',
        m_targetChar = '',

        m_startPosX = '',
        m_startPosY = '',
        m_endPosX = '',
        m_endPosY = '',

        m_physGroup = '',

        m_activityCarrier = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function LinearLaser:init(file_name, body, ...)
    self.m_limitTime = 3

    self.m_multiHitTime = 1
    self.m_multiHitTimer = 0

    self.m_clearCount = 0
    self.m_maxClearCount = 0

    self.m_offsetX = 0
    self.m_offsetY = 0

    self:initState()
end

-------------------------------------
-- function initLinearLaser
-------------------------------------
function LinearLaser:initLinearLaser(file_name, x, y)
    local file_name = file_name
    local start_ani = 'start_appear'
    local link_ani = 'bar_appear'
    local end_ani = 'end_appear'
    self.m_linkEffect = LinkEffect(file_name, link_ani, start_ani, end_ani, 200, 200)
    self.m_linkEffect.m_bRotateEndEffect = false

    self.m_laserLength = 800
    self.m_laserDir = 180

    self.m_startPosX = x or 0
    self.m_startPosY = y or 0
    self.m_endPosX = x or 0
    self.m_endPosY = y or 0

    -- 저사양모드 ignore
    self.m_linkEffect:setIgnoreLowEndMode(true)

    -- 에니메이션 변경
    do
        self.m_linkEffect.m_effectNode:addAniHandler(function()
            self.m_linkEffect.m_startPointNode:changeAni('start_idle', true)
            self.m_linkEffect.m_effectNode:changeAni('bar_idle', true)
            self.m_linkEffect.m_endPointNode:changeAni('end_idle', true)
        end)
    end

    self.m_rootNode:addChild(self.m_linkEffect.m_node)
end

-------------------------------------
-- function initState
-------------------------------------
function LinearLaser:initState()
    self:addState('idle', LinearLaser.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('idle')
end

-------------------------------------
-- function st_idle
-------------------------------------
function LinearLaser.st_idle(owner, dt)
    
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt
    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_clearCount < owner.m_maxClearCount ) then

        owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime

        owner.m_clearCount = owner.m_clearCount + 1
    end

    owner:refresh()

    if ((not owner.m_ownerChar) or owner.m_ownerChar.m_bDead) or (owner.m_stateTimer >= owner.m_limitTime) then
        owner:changeState('dying')
        return
    end


    if ((not owner.m_targetChar) or owner.m_targetChar.m_bDead) then
        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function LinearLaser:refresh()
    local change_start = false
    if self.m_ownerChar then
        if (self.m_ownerChar.pos.x ~= self.m_startPosX) or (self.m_ownerChar.pos.y ~= self.m_startPosY) then
            change_start = true
            self.m_startPosX = self.m_ownerChar.pos.x + self.m_offsetX
            self.m_startPosY = self.m_ownerChar.pos.y + self.m_offsetY
            self:setPosition(self.m_startPosX, self.m_startPosY)
        end
    end

    local change_end = false
    if self.m_targetChar then
        if (self.m_targetChar.pos.x ~= self.m_endPosX) or (self.m_targetChar.pos.y ~= self.m_endPosY) then
            change_end = true
            self.m_endPosX = self.m_targetChar.pos.x
            self.m_endPosY = self.m_targetChar.pos.y
        end
    end

    if change_start or change_end then
        local dir = getDegree(self.m_startPosX, self.m_startPosY, self.m_endPosX, self.m_endPosY)
        local dist = getDistance(self.m_startPosX, self.m_startPosY, self.m_endPosX, self.m_endPosY)
        local pos = getPointFromAngleAndDistance(dir, dist)


        -- 레이저에 충돌된 모든 객체 리턴
        local t_collision_obj = self.m_world.m_physWorld:getLaserCollision(self.m_startPosX, self.m_startPosY,
            self.m_endPosX, self.m_endPosY, 25, self.m_physGroup)

        -- 가장 가까이 위치한 충돌체의 거리까지만 레이저 출력
        if (not self:checkCollision()) then
            LinkEffect_refresh(self.m_linkEffect, 0, 0, pos['x'], pos['y'])
        end
    else
        self:checkCollision()
    end
end

-------------------------------------
-- function checkCollision
-------------------------------------
function LinearLaser:checkCollision()
    -- 레이저에 충돌된 모든 객체 리턴
    local t_collision_obj = self.m_world.m_physWorld:getLaserCollision(self.m_startPosX, self.m_startPosY,
        self.m_endPosX, self.m_endPosY, 10, self.m_physGroup)

    -- 가장 가까이 위치한 충돌체의 거리까지만 레이저 출력
    if t_collision_obj[1] then
        local first_obj = t_collision_obj[1]
        local x = math_clamp2(first_obj['x'], self.m_startPosX, self.m_endPosX)
        local y = math_clamp2(first_obj['y'], self.m_startPosY, self.m_endPosY)

        x = x - self.pos.x
        y = y - self.pos.y

        LinkEffect_refresh(self.m_linkEffect, 0, 0, x, y)

        self:collisionAttack(first_obj['obj'])

        return true
    end
    return false
end

-------------------------------------
-- function collisionAttack
-------------------------------------
function LinearLaser:collisionAttack(target_char)
    if (not self.t_collision) then
        return
    end

    if (not self.t_collision[target_char.phys_idx]) then
        self.t_collision[target_char.phys_idx] = true

        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
    end
    
end




-- link_effect를 사용
-- 1. 충돌된 가장 첫번째 객체까지만 표시 (무조건 1명만 맞음?!)

-- 레이저의 문제점
-- 1. 레이저의 길이를 벗어나지 않도록 체크



