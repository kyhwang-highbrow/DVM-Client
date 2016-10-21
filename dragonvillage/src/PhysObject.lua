-------------------------------------
-- class PhysObject
-------------------------------------
PhysObject = class({
        m_physWorld = '',

        m_ownerObject = '',

        pos = 'cc.p',
        body = 'table',
        rotation = 'number',
        enable_body = 'boolean',
		
		bFixedAttack = 'boolean',	-- 충돌체크에서 제외되고 충돌체크 대신 목표한 위치로 이동 여부만 체크

        speed = 'number',
        speed_backup = 'number',
        movement_theta = 'number',
        movement_x = 'number',
        movement_y = 'number',
        callback_def = 'table',
        callback_atk = 'table',
        apply_movement = 'boolean',
        phys_idx = 'number',
        phys_key = 'number',
        t_collision = 'table',

        m_dirtyPos = 'boolean', -- 위치 정보가 갱신되었는지에 대한 플래그

        m_posIndexMinX = '',
        m_posIndexMaxX = '',
        m_posIndexMinY = '',
        m_posIndexMaxY = '',

        m_activityCarrier = 'AttackDamage',

        -- 추가된 바디
        m_lAdditionalPhysObject = 'list(PhysObject)',
        m_bInitAdditionalPhysObject = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function PhysObject:init()
end

-------------------------------------
-- function initPhys
-- @param body
-------------------------------------
function PhysObject_initPhys(self, body)
    local body = body or {}

    self.pos = {x=0, y=0}
    self.rotation = 0
    self.enable_body = true
	self.bFixedAttack = false
    self.speed = 0
    self.movement_theta = 0
    self.movement_x = 0
    self.movement_y = 0
    self.apply_movement = true
    self.phys_idx = -1
    self.phys_key = nil
    self.t_collision = {}

    self.m_dirtyPos = false

    self.m_posIndexMinX = 1
    self.m_posIndexMaxX = 1
    self.m_posIndexMinY = 1
    self.m_posIndexMaxY = 1

    --self.body = {x=body[1] or 0, y=body[2] or 0, size=body[3] or 0}
    PhysObject_setBody(self, body[1] or 0, body[2] or 0, body[3] or 0)
end

-------------------------------------
-- function setPosition
-- @brief PhysObject를 상속한 객체에서는 오버라이딩해서 사용할 것!
-- @param x
-- @param y
-------------------------------------
function PhysObject:setPosition(x, y)
    if self.pos.x ~= x or self.pos.y ~= y then
        self.m_dirtyPos = true
    end

    self.pos.x = x
    self.pos.y = y

    if self.m_bInitAdditionalPhysObject then
        self:posUpdateAdditionalPhysObject(x, y)
    end
end

-------------------------------------
-- function getPos
-- @return x, y
-------------------------------------
function PhysObject:getPos()
    return self.pos.x, self.pos.y
end

-------------------------------------
-- function getCenterPos
-- @return x, y
-------------------------------------
function PhysObject:getCenterPos()
    return self.pos.x + self.body.x, self.pos.y + self.body.y
end

-------------------------------------
-- function getPossition
-- @return x, y
-------------------------------------
function PhysObject:getPosition()
    return self.pos.x, self.pos.y
end

-------------------------------------
-- function setDir
-- @param theta 0~360
-------------------------------------
function PhysObject:setDir(theta)
    self.movement_theta = theta
    self.movement_x = math_cos(math_rad(theta))
    self.movement_y = math_sin(math_rad(theta))
end

-------------------------------------
-- function setRotation
-- @param rad 0~360
-------------------------------------
function PhysObject:setRotation(rad)
    self.rotation = rad
end

-------------------------------------
-- function getRotation
-- @return rotation
-------------------------------------
function PhysObject:getRotation()
    return self.rotation
end

-------------------------------------
-- function PhysObject_setBody
-------------------------------------
function PhysObject_setBody(self, x, y, size)
    if (not self.body) then
        self.body = {x=x, y=y, size=size}
        self.m_dirtyPos = true
    else
        if (self.body.size~=size) or (self.body.x~=x) or (self.body.y~=y) then
            self.m_dirtyPos = true
        end
        self.body.x = x
        self.body.y = y
        self.body.size = size
    end
end

-------------------------------------
-- function getBody
-- @param body
-- @param getPos()
-------------------------------------
function PhysObject:getBody()
    return self.body, self:getPos()
end

-------------------------------------
-- function setSpeed
-- @param s
-------------------------------------
function PhysObject:setSpeed(s)
    self.speed = s
end

-------------------------------------
-- function addAtkCallback
-- @param callback_atk : function
-------------------------------------
function PhysObject:addAtkCallback(callback_atk)
    if self.callback_atk == nil then
        self.callback_atk = {}
    end
    table.insert(self.callback_atk, callback_atk)
end

-------------------------------------
-- function addDefCallback
-- @param callback_def : function
-------------------------------------
function PhysObject:addDefCallback(callback_def)
    if self.callback_def == nil then
        self.callback_def = {}
    end
    table.insert(self.callback_def, callback_def)
end

-------------------------------------
-- function runDefCallback
-- @param attacker
-- @param i_x intersect_pos_x
-- @param i_y intersect_pos_y
-------------------------------------
function PhysObject:runDefCallback(attacker, i_x, i_y)
    if self.callback_def then
        for _,v in ipairs(self.callback_def) do
            if v(attacker, self, i_x, i_y) then break end
        end
    end
end

-------------------------------------
-- function runAtkCallback
-- @param defender
-- @param i_x intersect_pos_x
-- @param i_y intersect_pos_y
-------------------------------------
function PhysObject:runAtkCallback(defender, i_x, i_y)
    if self.callback_atk then
        for _,v in ipairs(self.callback_atk) do
            v(self, defender, i_x, i_y)
        end
    end
end

-------------------------------------
-- function isIntersectBody
-- @param opponentBody
-- @param x
-- @param y
-------------------------------------
function PhysObject:isIntersectBody(opponentBody, x, y)
    if self.body.size <= 0 then return false end

    local d = math_pow(self.pos.x + self.body.x - (x + opponentBody.x), 2) + math_pow(self.pos.y + self.body.y - (y + opponentBody.y), 2)
    local dist = math_sqrt(d)    
    if dist < (opponentBody.size + self.body.size) then
        return true, ((self.pos.x + self.body.x + x) / 2), ((self.pos.y + self.body.y + y) / 2)
    else 
        return false, 0, 0
    end
end

-------------------------------------
-- function addCollisionObjectList
-- @param id
-------------------------------------
function PhysObject:addCollisionObjectList(id)
    self.t_collision[id] = true
end

-------------------------------------
-- function clearCollisionObjectList
-------------------------------------
function PhysObject:clearCollisionObjectList()
    self.t_collision = {}
end

-------------------------------------
-- function isAlreadyCollision
-- @param id
-------------------------------------
function PhysObject:isAlreadyCollision(id)
    return self.t_collision[id]
end

-------------------------------------
-- function setEnableBody
-- @param enabled
-- @param release_appended
-------------------------------------
function PhysObject:setEnableBody(enabled)
    self.enable_body = enabled
end

-------------------------------------
-- function setEnableBody
-- @param enabled
-- @param release_appended
-------------------------------------
function PhysObject:setFixedAttack(bool)
    self.bFixedAttack = bool
end

-------------------------------------
-- function release
-------------------------------------
function PhysObject:release()
    if self.m_physWorld then
        self.m_physWorld:removeObject(self)
    end
end



-------------------------------------
-- function init_AdditionalPhysObject
-- @breif 추가 PhysObject 초기화
-------------------------------------
function PhysObject:init_AdditionalPhysObject()
    if self.m_bInitAdditionalPhysObject then
        return
    end

    self.m_lAdditionalPhysObject = {}
    self.m_bInitAdditionalPhysObject = true
end

-------------------------------------
-- function addPhysObject
-- @breif PhysObject 추가
-------------------------------------
function PhysObject:addPhysObject(object_key, t_body)
    if (not self.m_bInitAdditionalPhysObject) then
        self:init_AdditionalPhysObject()
    end

    -- PhysObject 생성
    local phys_obj = PhysObject()
    PhysObject_initPhys(phys_obj, t_body)
    --phys_obj.m_ownerObject = self
    
    -- 최초 위치 지정
    local pos_x = self.pos.x
    local pos_y = self.pos.y
    phys_obj:setPosition(pos_x, pos_y)

    -- PhysWorld에 추가
    self.m_physWorld:addObject(object_key, phys_obj)

    -- 리스트에 추가
    table.insert(self.m_lAdditionalPhysObject, phys_obj)

    return phys_obj
end

-------------------------------------
-- function removePhysObject
-- @breif PhysObject 제거
-------------------------------------
function PhysObject:removePhysObject(phys_obj)
    for i,v in pairs(self.m_lAdditionalPhysObject) do
        if (phys_obj == v) then
            self.m_physWorld:removeObject(phys_obj)
            table.remove(self.m_lAdditionalPhysObject, i)
            break
        end
    end
end

-------------------------------------
-- function posUpdateAdditionalPhysObject
-- @breif PhysObject 추가
-------------------------------------
function PhysObject:posUpdateAdditionalPhysObject(x, y)
    if (not self.m_bInitAdditionalPhysObject) then
        return
    end
    
    for _,phys_obj in pairs(self.m_lAdditionalPhysObject) do
        phys_obj:setPosition(x, y)
    end
end