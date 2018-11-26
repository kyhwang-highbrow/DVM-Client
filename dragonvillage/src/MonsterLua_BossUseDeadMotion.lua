local PARENT = MonsterLua_Boss

-------------------------------------
-- class MonsterLua_BossUseDeadMotion
-------------------------------------
MonsterLua_BossUseDeadMotion = class(PARENT, {
     })
-------------------------------------
-- function initState
-------------------------------------
function MonsterLua_BossUseDeadMotion:initState()
    PARENT.initState(self)
    self:addState('dying', MonsterLua_BossUseDeadMotion.st_dying, 'boss_die', false, PRIORITY.DYING)
end

-------------------------------------
-- function st_dying
-------------------------------------
function MonsterLua_BossUseDeadMotion.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 사망 처리 시 StateDelegate Kill!
        owner:killStateDelegate()

        -- 효과음
        if owner.m_tEffectSound['die'] then
            SoundMgr:playEffect('VOICE', owner.m_tEffectSound['die'])
        end

        --owner:dispatch('character_dying', {}, owner)

        --local duration = owner.m_animator:getDuration()
        --owner.m_animator:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.FadeTo:create(duration, 0)))

        -- 에니메이션 종료 시
        owner:addAniHandler(function()
            owner:changeState('dead')
        end)

        if (owner.m_hpNode) then
            owner.m_hpNode:setVisible(false)
        end

        if (owner.m_castingNode) then
            owner.m_castingNode:setVisible(false)
        end
    end
end