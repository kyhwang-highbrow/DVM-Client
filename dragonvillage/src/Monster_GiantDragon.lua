local PARENT = MonsterLua_Boss

local CHARACTER_ACTION_TAG__DYING = 99

-------------------------------------
-- class Monster_GiantDragon
-------------------------------------
Monster_GiantDragon = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_GiantDragon:init(file_name, body, ...)
end

-------------------------------------
-- function initState
-------------------------------------
function Monster_GiantDragon:initState()
    PARENT.initState(self)

    self:addState('attack', Monster_GiantDragon.st_attack, 'attack', false)
    self:addState('dying', Monster_GiantDragon.st_dying, 'dying', false, PRIORITY.DYING)
end

-------------------------------------
-- function st_attack
-------------------------------------
function Monster_GiantDragon.st_attack(owner, dt)
    PARENT.st_attack(owner)

    if (owner.m_stateTimer == 0) then
        -- 브레스 스킬 사용시 차지 이펙트
        if (owner.m_animator.m_currAnimation == 'skill_3') then
            local attr = owner.m_charTable['attr']
            --local res = string.format('res/effect/effect_breath_charge/effect_breath_charge_%s.vrp', attr)
            local res = string.format('res/effect/effect_breath_charge/effect_breath_charge_fire.vrp')
            local animator = MakeAnimator(res)
            animator:changeAni('idle', false)
            animator:setScale(2)
            animator.m_node:setRotation(-90)
            animator:setPosition(-600, 300)
            owner.m_rootNode:addChild(animator.m_node)

            local duration = animator:getDuration()
            local sequence = cc.Sequence:create(
                cc.DelayTime:create(duration),
                cc.CallFunc:create(function()
                    SoundMgr:playEffect('EFFECT', 'gdragon_breath')
                end),
                cc.RemoveSelf:create()
            )

            local sequence2 = cc.Sequence:create(
                cc.MoveBy:create(1, cc.p(150, 250))
            )

            local spawn = cc.Spawn:create(sequence, sequence2)
            animator:runAction(spawn)
        end
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function Monster_GiantDragon.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        if owner.m_hpNode then
            owner.m_hpNode:setVisible(false)
        end

        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end

        -- 효과음
        if owner.m_tEffectSound['die'] then
            SoundMgr:playEffect('VOICE', owner.m_tEffectSound['die'])
        end

        -- 화면 점멸 2회
        g_gameScene:flashInOut({cbEnd = function()
            g_gameScene:flashInOut({time = 1, cbEnd = function()
                owner:setMove(owner.pos.x, owner.pos.y - 1000, 600)
                owner:animatorDying()
            end})
        end})

        --
        owner:addAniHandler(function()
            owner:changeState('dead')
        end)
    end
end

-------------------------------------
-- function animatorDying
-------------------------------------
function Monster_GiantDragon:animatorDying()
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    local shake_action = cc.Sequence:create(
        cc.MoveTo:create(0.05, cc.p(-20, 0)),
        cc.MoveTo:create(0.05, cc.p(0, 20)),
        cc.MoveTo:create(0.05, cc.p(20, 0)),
        cc.MoveTo:create(0.05, cc.p(0, -20))
    )

    cca.runAction(target_node, cc.RepeatForever:create(shake_action), CHARACTER_ACTION_TAG__DYING)
end