-------------------------------------
-- class SpecialPower
-------------------------------------
SpecialPower = class(Entity, {
        m_owner = '',
        m_effect = 'Animator',

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
function SpecialPower:init(file_name, body, ...)
    self:initState()
    self.m_hitNumCount = 0
end

-------------------------------------
-- function initState
-------------------------------------
function SpecialPower:initState()
    self:addState('idle', SpecialPower.st_idle, nil, false)
    self:addState('end', SpecialPower.st_end, nil, false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    
    self:changeState('idle')
end

-------------------------------------
-- function st_idle
-------------------------------------
function SpecialPower.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        local res = 'res/effect/special_power_laser/special_power_laser.spine'
        local animator = MakeAnimator(res)
        animator:changeAni('bar_idle', true)
        owner.m_world:addChild2(animator.m_node)
        animator.m_node:setPosition(960, 0)
        animator:setRotation(335)
        owner.m_effect = animator

        owner.m_hitTimer = 0

    elseif (owner.m_stateTimer > 2) then
        owner:changeState('end')
        owner.m_effect:release()
    else
        owner.m_hitTimer = owner.m_hitTimer + dt

        if (owner.m_hitTimer >= 0.1) then
            owner.m_hitTimer = owner.m_hitTimer - 0.1
            SpecialPower.attack(owner)
        end
    end
end

-------------------------------------
-- function st_end
-------------------------------------
function SpecialPower.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        local world = owner.m_world
        world.m_bDoingTamerSkill = false
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
function SpecialPower.attack(self)

    ShakeDir2(math_random(335-20, 335+20), math_random(500, 1500))
    SoundMgr:playEffect('EFFECT', 'option_thunderbolt_3')

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