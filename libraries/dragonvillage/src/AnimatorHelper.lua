AnimatorHelper = {}

-------------------------------------
-- function makeDragonAnimator
-------------------------------------
function AnimatorHelper:makeDragonAnimator(res_name, evolution)

    local res_name = string.gsub(res_name, '#', '0' .. evolution)
    local animator = MakeAnimator(res_name)

    if (not animator.m_node) then
        animator = MakeAnimator('res/character/dragon/developing_dragon/developing_dragon.spine')
    end

    if animator then
        animator.m_node:setMix('idle', 'attack', 0.1)
        animator.m_node:setMix('idle', 'idle', 0.1)
        animator.m_node:setMix('idle', 'skill_appear', 0.5)
        animator.m_node:setMix('attack', 'skill_appear', 0.5)

        animator.m_node:setMix('skill_appear', 'skill_idle', 0.2)
        animator.m_node:setMix('idle', 'skill_idle', 0.2)
        animator.m_node:setMix('attack', 'skill_idle', 0.2)

        animator.m_node:setMix('pose_1', 'idle', 0.2)
        animator.m_node:setMix('idle', 'pose_1', 0.2)
    end

    return animator
end

-------------------------------------
-- function makeTamerAnimator
-------------------------------------
function AnimatorHelper:makeTamerAnimator(res_name)
    local animator = MakeAnimator(res_name)

    if (not animator.m_node) then
        animator = MakeAnimator('res/character/dragon/developing_dragon/developing_dragon.spine')
    end

    if animator then
        animator.m_node:setMix('idle', 'attack', 0.1)
        animator.m_node:setMix('idle', 'idle', 0.1)
        animator.m_node:setMix('idle', 'skill_appear', 0.5)
        animator.m_node:setMix('attack', 'skill_appear', 0.5)

        animator.m_node:setMix('skill_appear', 'skill_idle', 0.2)
        animator.m_node:setMix('idle', 'skill_idle', 0.2)
        animator.m_node:setMix('attack', 'skill_idle', 0.2)

        -- 테이머가 사용함
        animator.m_node:setMix('idle', 'summon', 0.2)
        animator.m_node:setMix('summon', 'idle', 0.2)
    end

    return animator
end

-------------------------------------
-- function makeMonsterAnimator
-------------------------------------
function AnimatorHelper:makeMonsterAnimator(res_name, attr)

    local res_name = string.gsub(res_name, '@', attr)
    local animator = MakeAnimator(res_name)

    if (not animator.m_node) then
        animator = MakeAnimator('res/character/dragon/developing_dragon/developing_dragon.spine')
    end

    if animator then
        animator.m_node:setMix('idle', 'attack', 0.1)
        animator.m_node:setMix('idle', 'idle', 0.1)
        animator.m_node:setMix('attack', 'idle', 0.1)
    end

    return animator
end