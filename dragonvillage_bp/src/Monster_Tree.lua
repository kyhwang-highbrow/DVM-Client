local PARENT = MonsterLua_Boss

-------------------------------------
-- class Monster_Tree
-------------------------------------
Monster_Tree = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_Tree:init(file_name, body, ...)
end

-------------------------------------
-- function initState
-------------------------------------
function Monster_Tree:initState()
    PARENT.initState(self)

    self:addState('dying', Monster_Tree.st_dying, 'boss_die', false, PRIORITY.DYING)
end


-------------------------------------
-- function st_dying
-------------------------------------
function Monster_Tree.st_dying(owner, dt)
    if (owner:isBeginningStep()) then
        if owner.m_hpNode then
            owner.m_hpNode:setVisible(false)
        end

        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end

        -- 효과음
        if owner.m_tEffectSound['die'] then
            local category = 'EFFECT'
            if startsWith(owner.m_tEffectSound['die'], 'vo_') then
                category = 'VOICE'
            end
            SoundMgr:playEffect(category, owner.m_tEffectSound['die'])
        end

        -- 화면 쉐이킹
        owner.m_world.m_shakeMgr:doShakeUpDown(25, 10)

        owner.m_world:dispatch('nest_tree_die')

        owner.m_animator:addAniHandler(function()
            
            -- 화면 쉐이킹 멈춤
            owner.m_world.m_shakeMgr:stopShake()

            owner:changeState('dead')
        end)
    end
end