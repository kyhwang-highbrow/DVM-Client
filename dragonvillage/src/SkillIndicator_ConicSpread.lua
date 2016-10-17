local PARENT = SkillIndicator_Conic

-------------------------------------
-- class SkillIndicator_ConicSpread
-------------------------------------
SkillIndicator_ConicSpread = class(SkillIndicator_Conic, {
		m_lSpreadEffect = '',
		m_skillType = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_ConicSpread:init(hero, t_skill)
	PARENT.init(self, hero, t_skill)

	self.m_skillRadius = t_skill['val_1']
	self.m_lSpreadEffect = {}
	self.m_skillType = t_skill['type']
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_ConicSpread:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator('res/indicator/indicator_breath_gust/indicator_breath_gust.vrp')
		indicator:setTimeScale(5)
		indicator:changeAni('20_normal', false)
		indicator:setPosition(self:getAttackPosition())
        root_node:addChild(indicator.m_node)

		-- @하드코딩
		if (self.m_skillType == 'skill_breath_gust') then 
			indicator:setScale(self.m_skillRadius / 800)
		end

        self.m_indicator1 = indicator

		return true
    end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_ConicSpread:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local tar_x, tar_y = x, y
    local pos_x, pos_y = self:getAttackPosition()

	-- 1. 각도 제한
	local dir = getAdjustDegree(getDegree(pos_x, pos_y, tar_x, tar_y))
    local isChangeDegree = false
	if (dir > 30) and (dir < 180) then 
        dir = 30
        isChangeDegree = true
	elseif (dir < 330) and (dir > 180) then
        dir = 330
        isChangeDegree = true
	end

	self.m_indicator1:setRotation(dir)

    self.m_targetPosX = tar_x
    self.m_targetPosY = tar_y
    
	local t_collision_obj = self:findTargetList(tar_x, tar_y, dir)

	-- 전이 이펙트
	self:spreadStatusEffect(t_collision_obj, 'burn', 225)

	-- 공격 대상 하이라이트 이펙트 관리
    local skill_indicator_mgr = self:getSkillIndicatorMgr()

    local old_target_count = 0

    local old_highlight_list = self.m_highlightList

    if self.m_highlightList then
        old_target_count = #self.m_highlightList
    end

    for i,target in ipairs(t_collision_obj) do            
        if (not target.m_targetEffect) then
            skill_indicator_mgr:addHighlightList(target)
            self:makeTargetEffect(target)
        end
    end

    if old_highlight_list then
        for i,v in ipairs(old_highlight_list) do
            local find = false
            for _,v2 in ipairs(t_collision_obj) do
                if (v == v2) then
                    find = true
                    break
                end
            end
            if (find == false) then
                if (v ~= self.m_hero) then
                    skill_indicator_mgr:removeHighlightList(v)
                else
                    v:removeTargetEffect(v)
                end
            end
        end
    end

    self.m_highlightList = t_collision_obj

    local cur_target_count = #self.m_highlightList
    self:onChangeTargetCount(old_target_count, cur_target_count)
end

-------------------------------------
-- function spreadStatusEffect
-- @brief 특정 상태이상을 전이... 시킨다
-------------------------------------
function SkillIndicator_ConicSpread:spreadStatusEffect(l_target, status_effect_type)
	local count = 1

	for i, v in pairs(self.m_lSpreadEffect) do 
		v:setVisible(false)
	end

	for i, target in pairs(l_target) do 
		-- 1. 공격 대상의 상태 효과 검색
		if (target:getStatusEffectList()[status_effect_type]) then 
			if (self.m_lSpreadEffect[count]) then 
				local effect = self.m_lSpreadEffect[count]
				effect:setPosition(target.pos.x - self.m_hero.pos.x, target.pos.y - self.m_hero.pos.y)
				effect:setVisible(true)
				count = count + 1
			else
				-- 2. 범위 지정 연출
				local effect1 = MakeAnimator('res/indicator/indicator_breath_gust/indicator_breath_gust.vrp')
				effect1:changeAni('cicle', true)
				effect1:setAlpha(0.6)
				effect1:setScale(225/150)
				self.m_indicatorRootNode:addChild(effect1.m_node, 0)
				effect1:setPosition(target.pos.x - self.m_hero.pos.x, target.pos.y - self.m_hero.pos.y)
				table.insert(self.m_lSpreadEffect, effect1)
			end
		end
	end

end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_ConicSpread:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
	if (old_target_count == 0) and (cur_target_count > 0) then
		self.m_indicator1:changeAni('20', false)

	-- 비활성화
	elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_indicator1:changeAni('20_normal', false)
	end
end