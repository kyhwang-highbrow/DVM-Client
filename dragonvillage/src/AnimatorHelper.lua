AnimatorHelper = {}

-------------------------------------
-- function makeDragonAnimator
-------------------------------------
function AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
	local res_name = res_name
	
	if evolution then 
		res_name = string.gsub(res_name, '#', '0' .. evolution)
	end
	if attr then 
		res_name = string.gsub(res_name, '@', attr)
	end
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

-------------------------------------
-- function makeMonsterAnimator
-------------------------------------
function AnimatorHelper:makeInstanceHitComboffect(world, count)
	-- 1. 3명 부터 연출 들어간다.
	if (count < 3) then return end 

	local effect = MakeAnimator('res/ui/a2d/ingame_combo_text/ingame_combo_text.vrp')

	-- 2. hit 수에 따라 변경
	local combo_name = nil
	if (count > 5) then 
		combo_name = '40percent_combo'
	else
		combo_name = '20percent_combo'
	end

	effect:changeAni(combo_name, false)
	effect.m_node:setAnchorPoint(cc.p(0.5, 0.5))
	effect.m_node:setDockPoint(cc.p(0.5, 0.5))
	
	effect:setPosition(640, 150)
	world.m_worldNode:addChild(effect.m_node)
end