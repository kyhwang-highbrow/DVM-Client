local PARENT = EnemyLua_Boss

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
-- function initAnimatorMonster
-------------------------------------
function Monster_GiantDragon:initAnimatorMonster(file_name, attr)
    PARENT.initAnimatorMonster(self, file_name, attr)

    local animator = self.m_animator

    do
        local horn_animator = AnimatorHelper:makeMonsterAnimator(file_name, attr)
        horn_animator:changeAni('tail_idle')
        animator.m_node:bindSpine('tail', horn_animator.m_node)
    end

    do
        local horn_animator = AnimatorHelper:makeMonsterAnimator(file_name, attr)
        horn_animator:changeAni('horn_idle')
        animator.m_node:bindSpine('horn', horn_animator.m_node)
    end
end