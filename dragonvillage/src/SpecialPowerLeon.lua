-------------------------------------
-- class SpecialPowerLeon
-------------------------------------
SpecialPowerLeon = class(Entity, {
        m_owner = '',

        m_hitTimer = '',
        m_hitCount = '',

        m_activityCarrier = '',

        m_hitNumCount = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SpecialPowerLeon:init(file_name, body, ...)
    self:initState()
    self.m_hitNumCount = 0

    self.m_animator:setScale(0.5)
end

-------------------------------------
-- function initState
-------------------------------------
function SpecialPowerLeon:initState()
    self:addState('idle', SpecialPowerLeon.st_idle, 'skill_special', false)
    self:addState('end', SpecialPowerLeon.st_end, nil, false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    
    self:changeState('idle')
end

-------------------------------------
-- function st_idle
-------------------------------------
function SpecialPowerLeon.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 배경 어둡게
        owner.m_world.m_mapManager:tintTo(100, 100, 100, 0.25)

        owner.m_hitTimer = 0
        owner:addAniHandler(function() owner:changeState('end') end)

        local function attack_cb(event)
            SpecialPowerLeon.attack(owner)
        end

        owner.m_animator:setEventHandler(attack_cb)
    else
        --[[
        owner.m_hitTimer = owner.m_hitTimer + dt

        if (owner.m_hitTimer >= 0.1) then
            owner.m_hitTimer = owner.m_hitTimer - 0.1
            SpecialPowerLeon.attack(owner)
        end
        --]]
    end
end

-------------------------------------
-- function st_end
-------------------------------------
function SpecialPowerLeon.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 배경 밝게
        owner.m_world.m_mapManager:tintTo(255, 255, 255, 0.5)

        local world = owner.m_world
        world:setWaitAllCharacter(false)

        world.m_mapManager:tintTo(255, 255, 255, 0.5)

        owner:changeState('dying')

        local effect = MakeAnimator('res/effect/tamer_magic_1/tamer_magic_1.vrp')
        effect:setPosition(owner.m_owner.pos.x, owner.m_owner.pos.y)
        effect:changeAni('bomb', false)
        effect:setScale(0.8)
        local duration = effect:getDuration()
        effect:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function() effect:release() end)))
        world.m_missiledNode:addChild(effect.m_node)

        owner.m_owner:setActive(true)
    end
end

-------------------------------------
-- function attack
-------------------------------------
function SpecialPowerLeon.attack(self)

    ShakeDir2(math_random(335-20, 335+20), math_random(500, 1500))
    --SoundMgr:playEffect('EFFECT', 'option_thunderbolt_3')

    for i,v in pairs(self.m_world.m_tEnemyList) do
        if (not v.m_bDead) and (v.enable_body) then
            self:runAtkCallback(v, v.pos.x, v.pos.y)
            v:runDefCallback(self, v.pos.x, v.pos.y)

            self.m_hitNumCount = self.m_hitNumCount + 1
        end
    end

    g_gameScene.m_inGameUI.vars['hitLabel']:setString(self.m_hitNumCount)
    g_gameScene.m_inGameUI.vars['hitNode']:setVisible(true)
    g_gameScene.m_inGameUI.vars['hitNode']:stopAllActions()

    g_gameScene.m_inGameUI.vars['hitNode']:setScale(1.4)
    g_gameScene.m_inGameUI.vars['hitNode']:setOpacity(255)
    g_gameScene.m_inGameUI.vars['hitNode']:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1), cc.FadeOut:create(0.5), cc.Hide:create()))
end