-------------------------------------
-- class LinearLaser2
-------------------------------------
LinearLaser2 = class(Entity, {

        m_linkEffect = '',  -- 레이저의 그래픽 리소스
        m_laserDir = '',

        m_limitTime = '',

        m_multiHitTime = '',
        m_multiHitTimer = '',

        m_clearCount = '',
        m_maxClearCount = '',

        m_offsetX = '',
        m_offsetY = '',

        -- basic ray
        m_ownerChar = '',

        m_startPosX = '',
        m_startPosY = '',
        m_endPosX = '',
        m_endPosY = '',

        m_laserEndPosX = '',
        m_laserEndPosY = '',

        m_physGroup = '',

        m_activityCarrier = '',

        m_laserThickness = 'number', -- 레이저 굵기
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function LinearLaser2:init(file_name, body, ...)
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
-- function initLinearLaser2
-------------------------------------
function LinearLaser2:initLinearLaser(file_name, x, y, type)

    -- 레이저 링크 이펙트 생성
    self:makeLaserLinkEffect(file_name, type)

    self.m_laserDir = 180

    self.m_startPosX = x or 0
    self.m_startPosY = y or 0
    self.m_endPosX = x or 0
    self.m_endPosY = y or 0

    do
        -- 스케일 지정
        if (type == 1) then     self.m_laserThickness = 30
        elseif (type == 2) then self.m_laserThickness = 60
        elseif (type == 3) then self.m_laserThickness = 120
        else                    error('type : ' .. type)
        end
    end
end

-------------------------------------
-- function makeLaserLinkEffect
-------------------------------------
function LinearLaser2:makeLaserLinkEffect(file_name, type)
    local link_effect = LinkEffect(file_name)

    link_effect.m_bRotateEndEffect = false

    -- 저사양모드 ignore
    link_effect:setIgnoreLowEndMode(true)

    -- 'appear' -> 'idle' 에니메이션으로 자동 변경
    link_effect:registCommonAppearAniHandler()

    do -- 이펙트 스케일 지정
        local scale = 1

        -- 스케일 지정
        if (type == 1) then     scale = 0.5
        elseif (type == 2) then scale = 1
        elseif (type == 3) then scale = 2
        else                    error('type : ' .. type)
        end

        link_effect.m_startPointNode:setScale(scale)
        link_effect.m_effectNode:setScale(scale, 1)
        link_effect.m_endPointNode:setScale(scale)
    end

    self.m_rootNode:addChild(link_effect.m_node)

    self.m_linkEffect = link_effect
end

-------------------------------------
-- function initState
-------------------------------------
function LinearLaser2:initState()
    self:addState('idle', LinearLaser2.st_idle, 'idle', true)
    self:addState('disappear', LinearLaser2.st_disappear, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('idle')
end

-------------------------------------
-- function st_idle
-------------------------------------
function LinearLaser2.st_idle(owner, dt)
    
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt
    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_clearCount < owner.m_maxClearCount) then

        owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime

        owner.m_clearCount = owner.m_clearCount + 1
    end

    owner:refresh()

    if ((not owner.m_ownerChar) or owner.m_ownerChar.m_bDead) or (owner.m_stateTimer >= owner.m_limitTime) then
        owner:changeState('disappear')
        return
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function LinearLaser2.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
        local function ani_handler()
            owner:changeState('dying')
        end
        owner.m_linkEffect:changeCommonAni('disappear', false, ani_handler)
    end
end


-------------------------------------
-- function refresh
-------------------------------------
function LinearLaser2:refresh(force)
    local change_start = false
    if self.m_ownerChar then
        if (self.m_ownerChar.pos.x ~= self.m_startPosX) or (self.m_ownerChar.pos.y ~= self.m_startPosY) then
            change_start = true
            self.m_startPosX = self.m_ownerChar.pos.x + self.m_offsetX
            self.m_startPosY = self.m_ownerChar.pos.y + self.m_offsetY
            self:setPosition(self.m_startPosX, self.m_startPosY)
        end
    end

    if force or change_start then
        local dir = getDegree(self.m_startPosX, self.m_startPosY, self.m_endPosX, self.m_endPosY)

        if (self.m_laserDir ~= dir) then
            self.m_laserDir = dir
            local pos = getPointFromAngleAndDistance(dir, 2560)    
            LinkEffect_refresh(self.m_linkEffect, 0, 0, pos['x'], pos['y'])

            self.m_laserEndPosX = self.m_startPosX + pos['x']
            self.m_laserEndPosY = self.m_startPosY + pos['y']
        end
    end

    if (not force) then
        self:checkCollision()
    end
end

-------------------------------------
-- function checkCollision
-------------------------------------
function LinearLaser2:checkCollision()

    local radius = (self.m_laserThickness / 2)

    -- 레이저에 충돌된 모든 객체 리턴
    local t_collision_obj = self.m_world.m_physWorld:getLaserCollision(self.m_startPosX, self.m_startPosY,
        self.m_laserEndPosX, self.m_laserEndPosY, radius, self.m_physGroup)

    -- 모든 객체에 공격
    for i,v in ipairs(t_collision_obj) do
        self:collisionAttack(v['obj'])
    end
end

-------------------------------------
-- function collisionAttack
-------------------------------------
function LinearLaser2:collisionAttack(target_char)
    if (not self.t_collision) then
        return
    end

    -- 이미 충돌된 객체라면 리턴
    if (self.t_collision[target_char.phys_idx]) then
        return
    end

    -- 충돌, 공격 처리
    self.t_collision[target_char.phys_idx] = true
    self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
    target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
end


