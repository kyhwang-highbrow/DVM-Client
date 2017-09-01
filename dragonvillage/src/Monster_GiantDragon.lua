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
            local attr = owner:getAttribute()
            local res = string.format('res/effect/effect_breath_charge/effect_breath_charge_fire.vrp')
            local animator = MakeAnimator(res)
            if (animator.m_node) then
                animator:changeAni('idle', false)
                animator:setScale(2)
                animator.m_node:setRotation(-90)
                animator:setPosition(-600, 300)
                owner.m_rootNode:addChild(animator.m_node)

                local duration = animator:getDuration()
                local sequence = cc.Sequence:create(
                    cc.DelayTime:create(duration),
                    cc.CallFunc:create(function()
                        --SoundMgr:playEffect('VOICE', 'vo_gdragon_breath')
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
end

-------------------------------------
-- function st_dying
-------------------------------------
function Monster_GiantDragon.st_dying(owner, dt)
    if (owner:isBeginningStep()) then
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

        owner:animatorSpot()

    elseif (owner:isPassedStepTime(1)) then
        owner:runAction_dyingShake()        

    elseif (owner:isPassedStepTime(3)) then
        local action = cc.EaseIn:create(cc.MoveTo:create(3, cc.p(0, -2000)), 2)
        owner.m_animator.m_node:stopActionByTag(CHARACTER_ACTION_TAG__DYING)
        owner.m_animator.m_node:runAction(action)

    elseif (owner:isPassedStepTime(6)) then
        owner:changeState('dead')
        
    end
end

-------------------------------------
-- function animatorSpot
-------------------------------------
function Monster_GiantDragon:animatorSpot()
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    local spotAction = cc.Sequence:create(
        -- 점멸
        cc.CallFunc:create(function(node)
            local shader = ShaderCache:getShader(SHADER_CHARACTER_DAMAGED)
            self.m_animator.m_node:setGLProgram(shader)
        end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function(node)
            local shader = ShaderCache:getShader(cc.SHADER_POSITION_TEXTURE_COLOR)
            self.m_animator.m_node:setGLProgram(shader)
        end),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create(function(node)
            local shader = ShaderCache:getShader(SHADER_CHARACTER_DAMAGED)
            self.m_animator.m_node:setGLProgram(shader)
        end),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function(node)
            local shader = ShaderCache:getShader(cc.SHADER_POSITION_TEXTURE_COLOR)
            self.m_animator.m_node:setGLProgram(shader)
        end)
    )

    cca.runAction(target_node, spotAction, CHARACTER_ACTION_TAG__DYING)
end

-------------------------------------
-- function runAction_dyingShake
-------------------------------------
function Monster_GiantDragon:runAction_dyingShake()
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    local action = cc.Sequence:create(
        -- shake
        cc.MoveTo:create(0.05, cc.p(-20, 0)),
        cc.MoveTo:create(0.05, cc.p(0, 20)),
        cc.MoveTo:create(0.05, cc.p(20, 0)),
        cc.MoveTo:create(0.05, cc.p(0, -20))
    )

    cca.runAction(target_node, cc.RepeatForever:create(action), CHARACTER_ACTION_TAG__DYING)
end