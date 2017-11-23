--local PARENT = MonsterLua_Boss
local PARENT = Monster

-------------------------------------
-- class Monster_GoldDragon
-------------------------------------
Monster_GoldDragon = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_GoldDragon:init(file_name, body, ...)
end

-------------------------------------
-- function releaseAnimator
-------------------------------------
function Monster_GoldDragon:releaseAnimator()
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:retain()

            local x, y = self.m_rootNode:getPosition()
            self.m_animator.m_node:setPosition(x, y)
            self.m_animator.m_node:removeFromParent(true)
            
            self.m_world.m_bgNode:addChild(self.m_animator.m_node)
        end
        self.m_animator = nil
    end
end

-------------------------------------
-- function initState
-------------------------------------
function Monster_GoldDragon:initState()
    PARENT.initState(self)

    self:addState('dying', Monster_GoldDragon.st_dying, 'boss_die', false, PRIORITY.DYING)
end


-------------------------------------
-- function st_dying
-------------------------------------
function Monster_GoldDragon.st_dying(owner, dt)
    if (owner:isBeginningStep()) then
        if owner.m_hpNode then
            owner.m_hpNode:setVisible(false)
        end

        if owner.m_castingNode then
            owner.m_castingNode:setVisible(false)
        end

        -- 효과음
        --[[
        if owner.m_tEffectSound['die'] then
            local category = 'EFFECT'
            if startsWith(owner.m_tEffectSound['die'], 'vo_') then
                category = 'VOICE'
            end
            SoundMgr:playEffect(category, owner.m_tEffectSound['die'])
        end
        ]]--

        -- 화면 쉐이킹
        owner.m_world.m_shakeMgr:doShakeUpDown(25, 10)

        owner.m_animator:addAniHandler(function()
            
            -- 화면 쉐이킹 멈춤
            owner.m_world.m_shakeMgr:stopShake()

            owner:changeState('dead')
        end)

        -- 금화 떨어지는 연출
        do
            local res = 'res/effect/effect_gold_dying/effect_gold_dying.vrp'
            owner.m_world:addInstantEffect(res, 'idle', owner.pos.x - 200, owner.pos.y + 380)
        end
    end
end
