-------------------------------------
-- class MissileEffecter
-------------------------------------
MissileEffecter = class(Entity, {

     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileEffecter:init(file_name, body, ...)

end

-------------------------------------
-- function initState
-------------------------------------
function MissileEffecter:initState()
    self:addState('start', MissileEffecter.st_start, 'start', false)
    self:addState('idle', MissileEffecter.st_idle, 'idle', true)
    self:addState('end', MissileEffecter.st_end, 'end', false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('start')
end


-------------------------------------
-- function st_start
-------------------------------------
function MissileEffecter.st_start(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
            owner:changeState('idle')
        end)
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function MissileEffecter.st_idle(owner, dt)
    if (owner.m_stateTimer >= 5) then
        owner:changeState('end')
    end
end

-------------------------------------
-- function st_end
-------------------------------------
function MissileEffecter.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
            owner:changeState('dying')
        end)
    end
end

-------------------------------------
-- function release
-------------------------------------
function MissileEffecter:release()
    Entity.release(self)
end