-------------------------------------
-- class Buff_Protection
-- @breif 파워드래곤 전용 스킬
-------------------------------------
Buff_Protection = class(Buff, {
        m_defUp = 'number',
        m_target = 'Character',

		m_res = 'string',

        m_shieldEffect = 'Animator',
        m_barEffect = 'EffectLink',
        m_barrierEffect1 = 'Animator',
        m_barrierEffect2 = 'Animator',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Buff_Protection:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_buff
-------------------------------------
function Buff_Protection:init_buff(owner, duration, def_up, target, res)
    Buff.init_buff(self, owner, duration)

    self.m_defUp = (def_up / 100)
    self.m_target = target
	self.m_res = res

    -- 연결 이펙트 -- @TODO groundnode..? 여기서만 사용중
    self.m_barEffect = EffectLink(res, 'bar_appear', '', '', 512, 256)
    self.m_world.m_groundNode:addChild(self.m_barEffect.m_node)
    self.m_barEffect.m_startPointNode:setVisible(false)
    self.m_barEffect.m_endPointNode:setVisible(false)
    self.m_barEffect.m_effectNode:addAniHandler(function() self.m_barEffect.m_effectNode:changeAni('bar_idle', true) end)

    -- 베리어 이펙트
    self.m_barrierEffect1 = MakeAnimator(res)
    self.m_barrierEffect1:changeAni('barrier_appear', false)
    self.m_barrierEffect1:addAniHandler(function() self.m_barrierEffect1:changeAni('barrier_idle', true) end)
    self.m_rootNode:addChild(self.m_barrierEffect1.m_node)

    -- 베리어 이펙트
    self.m_barrierEffect2 = MakeAnimator(res)
    self.m_barrierEffect2:changeAni('barrier_appear', false)
    self.m_barrierEffect2:addAniHandler(function() self.m_barrierEffect2:changeAni('barrier_idle', true) end)
    self.m_rootNode:addChild(self.m_barrierEffect2.m_node)

    -- 방패 이펙트
    self.m_shieldEffect = MakeAnimator(res)
    self.m_shieldEffect:changeAni('shield_appear', false)
    self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
    self.m_rootNode:addChild(self.m_shieldEffect.m_node)
end

-------------------------------------
-- function initState
-------------------------------------
function Buff_Protection:initState()
    Buff.initState(self)

    self:addState('end', Buff_Protection.st_end, nil, false)
end

-------------------------------------
-- function st_end
-------------------------------------
function Buff_Protection.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:endBuff()

        -- 방패 이팩트
        owner.m_shieldEffect:changeAni('shield_disappear', false)
        
        -- 연결 이팩트
        owner.m_barEffect.m_effectNode:changeAni('bar_disappear', false)

        -- 베리어 이팩트
        owner.m_barrierEffect1:changeAni('barrier_disappear', false)
        owner.m_barrierEffect2:changeAni('barrier_disappear', false)

    elseif (owner.m_stateTimer >= 3) then
        owner:changeState('dying')
    end
end

-------------------------------------
-- function checkDead
-------------------------------------
function Buff_Protection:checkDead()
    if (self.m_owner.m_bDead or self.m_target.m_bDead) then
        self:changeState('end')
        return true
    end

    return false
end

-------------------------------------
-- function onStart
-------------------------------------
function Buff_Protection:onStart()

    if (self.m_owner.m_buffProtection) then
        self.m_owner.m_buffProtection:changeState('dying')
    end
    
    self.m_owner.m_buffProtection = self

    if (not self.m_target.m_lProtectionList) then
        self.m_target.m_lProtectionList = {}
    end

    table.insert(self.m_target.m_lProtectionList, self)
end


-------------------------------------
-- function onHit
-------------------------------------
function Buff_Protection:onHit()
    -- 방패 이팩트
    self.m_shieldEffect:changeAni('shield_hit', false)
    self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
        
    -- 연결 이팩트
    self.m_barEffect.m_effectNode:changeAni('bar_hit', false)
    self.m_barEffect.m_effectNode:addAniHandler(function() self.m_barEffect.m_effectNode:changeAni('bar_idle', true) end)

    -- 베리어 이팩트
    self.m_barrierEffect1:changeAni('barrier_hit', false)
    self.m_barrierEffect1:addAniHandler(function() self.m_barrierEffect1:changeAni('barrier_idle', true) end)

    self.m_barrierEffect2:changeAni('barrier_hit', false)
    self.m_barrierEffect2:addAniHandler(function() self.m_barrierEffect2:changeAni('barrier_idle', true) end)
end

-------------------------------------
-- function onEnd
-------------------------------------
function Buff_Protection:onEnd()

    if (self.m_owner.m_buffProtection == self) then
        self.m_owner.m_buffProtection = nil
    end

    if self.m_target.m_lProtectionList then
        local idx = table.find(self.m_target.m_lProtectionList, self)
        if self.m_target.m_lProtectionList[idx] then
            self.m_target.m_lProtectionList[idx] = nil
        end
    end
end

-------------------------------------
-- function checkBuffPosDirty
-------------------------------------
function Buff_Protection:checkBuffPosDirty()
    -- 본체 변경 확인
    if (self.pos.x ~= self.m_owner.pos.x) or (self.pos.y ~= self.m_owner.pos.y) then
        self.m_bDirtyPos = true
        return
    end

    -- 베리어 대상자 변경 확인
    local x = self.m_target.pos.x - self.pos.x
    local y = self.m_target.pos.y - self.pos.y
    if (self.m_barrierEffect2.m_posX ~= x) or (self.m_barrierEffect2.m_posY ~= y) then
        self.m_bDirtyPos = true
        return
    end
end

-------------------------------------
-- function updateBuffPos
-------------------------------------
function Buff_Protection:updateBuffPos()
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

    local x = self.m_target.pos.x - self.pos.x
    local y = self.m_target.pos.y - self.pos.y
    self.m_barrierEffect2:setPosition(x, y)
    self.m_shieldEffect:setPosition(x, y)

    EffectLink_refresh(self.m_barEffect, self.pos.x, self.pos.y, self.m_target.pos.x, self.m_target.pos.y)

    self.m_bDirtyPos = false
end


-------------------------------------
-- function release
-------------------------------------
function Buff_Protection:release()
    Buff.release(self)

    if self.m_barEffect then
        self.m_barEffect:release()
        self.m_barEffect = nil
    end
end