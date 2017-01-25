local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_Penetration
-------------------------------------
SkillIndicator_Penetration = class(SkillIndicator, {
		m_lIndicatorEffectList = 'indicator list',
		m_indicatorAddEffect = 'Indicator',
		
		m_skillLineNum = 'num',		-- 공격 하는 직선 갯수
		m_skillLineSize = 'num',	-- 직선의 두께
		
		m_skillLineGap = 'num',		-- 직선 간의 간격

		m_lAttackPosList = 'pos list',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Penetration:init(hero, t_skill)
	PARENT.init(self, hero)
	
	self.m_skillLineNum = t_skill['hit']
	self.m_skillLineSize = t_skill['val_1']
	
	self.m_skillLineGap = nil

	self.m_indicatorScale = t_skill['res_scale']

	self.m_lIndicatorEffectList = {}
	self.m_lAttackPosList = self:getAttackPositionList()
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Penetration:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

	local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
	
	-- root node 상에서 터치된 좌표 위치 환산
	local touch_x, touch_y = (x - pos_x), (y - pos_y)
	
	self.m_targetPosX = x
	self.m_targetPosY = y

	-- 이펙트 조정
	local l_dir = {}
	do
		local pos, dir
		for i, indicator in pairs(self.m_lIndicatorEffectList) do
			pos = self.m_lAttackPosList[i]
			dir = getAdjustDegree(getDegree(pos.x, pos.y, touch_x, touch_y))
			indicator:setRotation(dir)
			table.insert(l_dir, dir)
		end
		self.m_indicatorAddEffect:setPosition(touch_x, touch_y)
	end

	-- 하이라이트 갱신
	local t_collision_obj = self:findTarget(l_dir)
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Penetration:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode
	local pos

	-- 인디케이터 다발
    for i = 1, self.m_skillLineNum do
        local indicator = MakeAnimator(RES_INDICATOR['STRAIGHT'])
        root_node:addChild(indicator.m_node)
		indicator.m_node:setScale(0.1, 2.5)
		indicator.m_node:setColor(COLOR_CYAN)
		indicator:setTimeScale(5)
		
		pos =  self.m_lAttackPosList[i]
		indicator:setPosition(pos.x, pos.y)
		
		table.insert(self.m_lIndicatorEffectList, indicator)
    end

	-- 겹치는 부분 가리는 추가 인디케이터
	do
        local indicator = MakeAnimator(RES_INDICATOR['RANGE'])
        indicator:setTimeScale(5)
        indicator:setScale(0.1)
        indicator:changeAni('skill_range_normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end

	return true
end

-------------------------------------
-- function onEnterAppear
-------------------------------------
function SkillIndicator_Penetration:onEnterAppear()
    self.m_hero.m_animator:setTimeScale(5)
	for _, indicator in pairs(self.m_lIndicatorEffectList) do
		indicator:changeAni('appear')
		indicator:addAniHandler(function()
			indicator:changeAni('idle', true)
		end)
	end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Penetration:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
	if (old_target_count == 0) and (cur_target_count > 0) then
		for _, indicator in pairs(self.m_lIndicatorEffectList) do
			indicator.m_node:setColor(COLOR_RED)
		end

	-- 비활성화
	elseif (old_target_count > 0) and (cur_target_count == 0) then
		for _, indicator in pairs(self.m_lIndicatorEffectList) do
			indicator.m_node:setColor(COLOR_CYAN)
		end
	end
end

-------------------------------------
-- function getAttackPositionList
-- 로지컬 하게 짜야함!
-------------------------------------
function SkillIndicator_Penetration:getAttackPositionList()
	local t_ret = {}
	
	local pos_x, pos_y = self:getAttackPosition()

	for i = 1, self.m_skillLineNum do
		table.insert(t_ret, {x = 100, y = -300 + (i * 100)})
	end

    return t_ret
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_Penetration:findTarget(l_dir)
	local t_ret = {}
	
	local t_each
	for i = 1, self.m_skillLineNum do
		t_collision_obj = self:findTargetEachLine(self.m_lAttackPosList[i], l_dir[i])
		for i,v in ipairs(t_collision_obj) do
			table.insert(t_ret, v['obj'])
		end
	end

	return t_ret
end

-------------------------------------
-- function findTargetEachLine
-------------------------------------
function SkillIndicator_Penetration:findTargetEachLine(start_pos, dir)
    local end_pos = getPointFromAngleAndDistance(dir, 2560)    
	local start_x = start_pos.x
	local start_y = start_pos.y
    local end_x = start_x + end_pos['x']
    local end_y = start_y + end_pos['y']

	local phys_group = self.m_hero:getAttackPhysGroup()

    -- 레이저에 충돌된 모든 객체 리턴
    local t_collision_obj = self.m_world.m_physWorld:getLaserCollision(start_x, start_y,
        end_x, end_y, self.m_skillLineSize/2, phys_group)

    return t_collision_obj
end