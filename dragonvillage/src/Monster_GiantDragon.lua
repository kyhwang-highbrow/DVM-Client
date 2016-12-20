local PARENT = MonsterLua_Boss

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
            local res = string.format('res/effect/effect_breath_charge/effect_breath_charge_%s.vrp', attr)
            local animator = MakeAnimator(res)
            animator:changeAni('idle', false)
            animator:setScale(2)
            animator.m_node:setRotation(-90)
            animator:setPosition(-600, 300)
            owner.m_rootNode:addChild(animator.m_node)

            local duration = animator:getDuration()
            local sequence = cc.Sequence:create(
                cc.DelayTime:create(duration),
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