AnimatorHelper = {}

-------------------------------------
-- function makeDragonAnimator
-------------------------------------
function AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)

	local res_name = self:getDragonResName(res_name, evolution, attr)
	local animator = MakeAnimator(res_name)

    if (not animator.m_node) then
        animator = MakeAnimator('res/character/dragon/godaeshinryong_light_03/godaeshinryong_light_03.spine')
        animator:setColor(cc.c3b(0, 0, 0))
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
-- function makeDragonAnimator_usingDid
-------------------------------------
function AnimatorHelper:makeDragonAnimator_usingDid(did, evolution)
    local t_dragon = TableDragon():get(did)
    local evolution = evolution or 3
    return AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
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

    local res_name = self:getMonsterResName(res_name, attr)
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
function AnimatorHelper:makeInstanceHitComboffect(combo_name, cbFunction)
	local animator = MakeAnimator('res/ui/a2d/ingame_combo_text/ingame_combo_text.vrp')
	
	-- 1. 생성 실패시 탈출
	if (not animator) then return nil end

	-- 2. 기본 중앙 정렬
	animator:setAnchorPoint(0.5, 0.5)
	animator:setDockPoint(0.5, 0.5)
	
	-- 3. ani 이름 있을 시 change 
	if combo_name then
		animator:changeAni(combo_name, false)
	end

	-- 4. 콜백 있을 시 등록
	if cbFunction then
		animator:addAniHandler(cbFunction)
	end

	return animator
end

-------------------------------------
-- function getDragonResName
-------------------------------------
function AnimatorHelper:getDragonResName(res_name, evolution, attr)
	local res_name = res_name
	
	if evolution then 
		res_name = string.gsub(res_name, '#', '0' .. evolution)
	end
	if attr then 
		res_name = string.gsub(res_name, '@', attr)
	end
    
    return res_name
end

-------------------------------------
-- function getMonsterResName
-------------------------------------
function AnimatorHelper:getMonsterResName(res_name, attr)
    local res_name = string.gsub(res_name, '@', attr)
    return res_name
end