-------------------------------------
-- class PhysObject
-------------------------------------
PhysObject = class({
        m_physWorld = '',

        m_ownerObject = '',

        pos = 'cc.p',
        body = 'table',
        body_list = 'table',

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
        
        -- 일시 정지
        m_temporaryPause = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function PhysObject:init()
    self.pos = {x=0, y=0}
    self.rotation = 0
    self.enable_body = false
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

    -- 일시 정지
    self.m_temporaryPause = false

    self.body = nil
    self.body_list = nil
end

-------------------------------------
-- function initPhys
-- @param body
-------------------------------------
function PhysObject:initPhys(body)
    self.enable_body = true

    local body = body or {}

    if (type(body[1]) == 'table') then
        local body_list = body
        local body = body_list[1]

        -- 기본 body
        PhysObject_setBody(self, body[1] or 0, body[2] or 0, body[3] or 0, body[4])

        -- body 리스트
        self.body_list = {}

        for i, v in ipairs(body_list) do
            local data = { key = i, x = v[1], y = v[2], size = v[3], bone = v[4] }

            self:addBody(data)
        end
        
    else
        PhysObject_setBody(self, body[1] or 0, body[2] or 0, body[3] or 0, body[4])

    end
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
    local body_list = self:getBodyList()
    local body = body_list[1]

    return self.pos.x + body.x, self.pos.y + body.y
end

-------------------------------------
-- function getPosition
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
function PhysObject_setBody(self, x, y, size, bone)
    if (not self.body) then
        self.body = { key = 0, x = x, y = y, size = size, bone = bone }
        self.m_dirtyPos = true
    else
        if (self.body.size~=size) or (self.body.x~=x) or (self.body.y~=y) or (self.body.bone~=bone) then
            self.m_dirtyPos = true
        end
        self.body.x = x
        self.body.y = y
        self.body.size = size
        self.body.bone = bone
    end
end

-------------------------------------
-- function getBody
-- @param body
-- @param getPos()
-------------------------------------
function PhysObject:getBody(k)
    local k = k or 1

    if (k and self.body_list) then
        for i, body in ipairs(self.body_list) do
            if (body['key'] == k) then
                return body
            end
        end
    else
        return self.body
    end
end

-------------------------------------
-- function addBody
-- @param body
-------------------------------------
function PhysObject:addBody(data)
    if (not self.body_list) then
        self.body_list = {}
    end

    table.insert(self.body_list, data)
end

-------------------------------------
-- function getBodyList
-- @param body
-------------------------------------
function PhysObject:getBodyList()
    local ret

    if (self.body_list) then
        ret = self.body_list
    else
        ret = { self.body }
    end

    return ret
end

-------------------------------------
-- function setSpeed
-- @param s
-------------------------------------
function PhysObject:setSpeed(s)
    self.speed = s
end

-------------------------------------
-- function getPhysGroup
-------------------------------------
function PhysObject:getPhysGroup()
    return self.phys_key
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
-- @param k body_key
-- @param b no_event
-------------------------------------
function PhysObject:runDefCallback(attacker, i_x, i_y, k, b)
    if self.callback_def then
        for _,v in ipairs(self.callback_def) do
            if v(attacker, self, i_x, i_y, k, b) then break end
        end
    end
end

-------------------------------------
-- function runAtkCallback
-- @param defender
-- @param i_x intersect_pos_x
-- @param i_y intersect_pos_y
-- @param k body_key
-------------------------------------
function PhysObject:runAtkCallback(defender, i_x, i_y, k)
    if self.callback_atk then
        for _,v in ipairs(self.callback_atk) do
            v(self, defender, i_x, i_y, k)
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
    if (self.body.size <= 0) then return false end

    local d = math_pow(self.pos.x + self.body.x - (x + opponentBody.x), 2) + math_pow(self.pos.y + self.body.y - (y + opponentBody.y), 2)
    local dist = math_sqrt(d)    
    if (dist < opponentBody.size + self.body.size) then
        return true, (x + opponentBody.x), (y + opponentBody.y)
        --return true, ((self.pos.x + self.body.x + x + opponentBody.x) / 2), ((self.pos.y + self.body.y + y + opponentBody.y) / 2)
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
-- function setFixedAttack
-------------------------------------
function PhysObject:setFixedAttack(bool)
    self.bFixedAttack = bool
    self.enable_body = not bool
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
-- function updatePhys
-------------------------------------
function PhysObject:updatePhys(dt)
    -- 이동이 허용되고 일시 정지가 아닌 객체만 이동
    if (not self.apply_movement or self.m_temporaryPause) then return end

    local movement_x = self.speed * self.movement_x
    local movement_y = self.speed * self.movement_y

    local pos_x = self.pos.x + (movement_x * dt)
    local pos_y = self.pos.y + (movement_y * dt)

    if (pos_x ~= self.pos.x) or (pos_y ~= self.pos.y) then
        self:setPosition(pos_x, pos_y)
    end
end

-------------------------------------
-- function primitivesDraw
-- @brief body 영역을 그림
-------------------------------------
function PhysObject:primitivesDraw(color)
    local function draw(body)
        local x = self.pos.x + body.x
        local y = self.pos.y + body.y
        local radius = body.size

        cc.DrawPrimitives.drawSolidCircle(cc.p(x, y), radius, 0, 32)
    end

    if (self.body_list) then
        for i, body in ipairs(self.body_list) do
            cc.DrawPrimitives.drawColor4B(color[1], color[2], color[3], color[4])
            draw(body)
        end
    else
        draw(self.body)
    end
end