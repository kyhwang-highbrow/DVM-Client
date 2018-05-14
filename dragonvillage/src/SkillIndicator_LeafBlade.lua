local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_LeafBlade
-------------------------------------
SkillIndicator_LeafBlade = class(PARENT, {
		-- 베지어 곡선 이펙트
        m_indicatorBezierEffect1 = '',
        m_indicatorBezierEffect2 = '',

		-- 직선 이펙트
        m_indicatorLinearEffect1 = '',
        m_indicatorLinearEffect2 = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_LeafBlade:init(hero, t_skill)
	self.m_indicatorAngleLimit = g_constant:get('SKILL', 'LEAF_ANGLE_LIMIT')
	self.m_indicatorDistanceLimit = g_constant:get('SKILL', 'LEAF_DIST_LIMIT')
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_LeafBlade:onTouchMoved(x, y, is_virtual_test)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local tar_x, tar_y = x, y
    local pos_x = self.m_hero.pos.x
    local pos_y = self.m_hero.pos.y

    -- 1. 각도 및 거리 제한
	local dir = getAdjustDegree(getDegree(pos_x, pos_y, tar_x, tar_y))
	local distance = getDistance(tar_x, tar_y, pos_x, pos_y)
	local t_ret = self:checkIndicatorLimit(dir, distance)
    dir = t_ret['angle']
	distance = t_ret['distance']

	-- 3. 각도와 거리 체크하여 타겟 좌표 수정
	if (not t_ret['is_change']) then
        local adj_pos = getPointFromAngleAndDistance(dir, distance)
        tar_x, tar_y = adj_pos.x + pos_x, adj_pos.y + pos_y
    end

    local l_collision = self:findCollision(tar_x, tar_y)

    if (is_virtual_test) then
        self.m_collisionListByVirtualTest = l_collision
        
    else
        if (l_collision[1]) then
            self.m_targetChar = l_collision[1]:getTarget()
        end
	
        -- 4-1. 베지어 곡선 이펙트 위치 갱신
        self.m_indicatorBezierEffect1:refreshEffect(tar_x, tar_y, pos_x, pos_y, 1)
	    self.m_indicatorBezierEffect2:refreshEffect(tar_x, tar_y, pos_x, pos_y, -1)

	    -- 4-2. 직선 이펙트 위치 갱신
        self.m_indicatorLinearEffect1:refreshEffect(tar_x, tar_y, pos_x, pos_y, 1)
	    self.m_indicatorLinearEffect2:refreshEffect(tar_x, tar_y, pos_x, pos_y, -1)

	    -- 4-3. 타겟에 찍히는 이펙트 위치 갱신
        self.m_indicatorEffect:setPosition(tar_x - pos_x, tar_y - pos_y)

	    -- 5. 메인 타겟 좌표 멤버 변수에 저장
        self.m_targetPosX = tar_x
        self.m_targetPosY = tar_y

	    -- 6. 공격 대상 하이라이트 이펙트 관리
	    self:setHighlightEffect(l_collision)
    end
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_LeafBlade:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 교차점 이펙트
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'round')
        local indicator = MakeAnimator(indicator_res)
        
		indicator:setScale(0.3)
        self:initIndicatorEffect(indicator)

		root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end
    
	local indicator_res = g_constant:get('INDICATOR', 'RES', 'leaf')
    
	-- 베지어 곡선 이펙트 (상)
    do
        local link_effect = EffectBezierLink(indicator_res)
        root_node:addChild(link_effect.m_node)
        self.m_indicatorBezierEffect1 = link_effect
    end

    -- 베지어 곡선 이펙트 (하)
    do
        local link_effect = EffectBezierLink(indicator_res)
        root_node:addChild(link_effect.m_node)
        self.m_indicatorBezierEffect2 = link_effect
    end

    -- 직선 이펙트 (상)
    do
        local link_effect = EffectLinearDot(indicator_res)
        root_node:addChild(link_effect.m_node)
        self.m_indicatorLinearEffect1 = link_effect
    end

    -- 직선 이펙트 (하)
    do
        local link_effect = EffectLinearDot(indicator_res)
        root_node:addChild(link_effect.m_node)
        self.m_indicatorLinearEffect2 = link_effect
    end

end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillIndicator_LeafBlade:findCollision(x, y)
    -- 하나의 리스트로 merge
    local l_ret = mergeCollisionLists({
        self:findCollisionEachLine(x, y, 1),
        self:findCollisionEachLine(x, y, -1)
    })
    
    return l_ret
end

-------------------------------------
-- function findCollisionEachLine
-------------------------------------
function SkillIndicator_LeafBlade:findCollisionEachLine(x, y, course)
    local l_target = self:getProperTargetList()
    local pos_x = self.m_hero.pos.x
    local pos_y = self.m_hero.pos.y

    -- 베지어 곡선에 의한 충돌 리스트
    local collisions_bezier = SkillTargetFinder:findCollision_Bezier(l_target, x, y, pos_x, pos_y, course)

    -- 타겟 수 만큼만 얻어옴
    collisions_bezier = table.getPartList(collisions_bezier, self.m_targetLimit)

    -- 충돌체크에 필요한 변수 생성
    local std_dist = 1000
	local degree = getDegree(pos_x, pos_y, x, y)
	local leaf_body_size = g_constant:get('SKILL', 'LEAF_COLLISION_SIZE')
	local straight_angle = g_constant:get('SKILL', 'LEAF_STRAIGHT_ANGLE')
	
    -- 직선에 의한 충돌 리스트 (상)
    local rad = math_rad(degree + straight_angle)
    local factor_y = math.tan(rad)
    local collisions_bar = SkillTargetFinder:findCollision_Bar(l_target, x, y, x + std_dist, y + std_dist * factor_y, leaf_body_size)

    -- 타겟 수 만큼만 얻어옴 (상)
    local remain_count = math_max(self.m_targetLimit - #collisions_bezier, 0)
    collisions_bar = table.getPartList(collisions_bar, remain_count)

    -- 하나의 리스트로 merge
    local l_ret = mergeCollisionLists({
        collisions_bezier,
        collisions_bar
    })

    -- 거리순으로 정렬(필요할 경우)
    table.sort(l_ret, function(a, b)
        return (a:getDistance() < b:getDistance())
    end)

    return l_ret
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_LeafBlade:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
	if (cur_target_count > 0) then
		-- 타겟수에 따른 보너스 등급 저장
		self.m_bonus = DragonSkillBonusHelper:getBonusLevel(self.m_hero, cur_target_count)

		self:onChangeIndicatorEffect(self.m_indicatorBezierEffect1, self.m_bonus, self.m_preBonusLevel)
		self:onChangeIndicatorEffect(self.m_indicatorBezierEffect2, self.m_bonus, self.m_preBonusLevel)
		self:onChangeIndicatorEffect(self.m_indicatorLinearEffect1, self.m_bonus, self.m_preBonusLevel)
		self:onChangeIndicatorEffect(self.m_indicatorLinearEffect2, self.m_bonus, self.m_preBonusLevel)
		self:onChangeIndicatorEffect(self.m_indicatorEffect, self.m_bonus, self.m_preBonusLevel)

	-- 비활성화
	elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_bonus = -1
		self:initIndicatorEffect(self.m_indicatorEffect)
		self:initIndicatorEffect(self.m_indicatorBezierEffect1)
		self:initIndicatorEffect(self.m_indicatorBezierEffect2)
		self:initIndicatorEffect(self.m_indicatorLinearEffect1)
		self:initIndicatorEffect(self.m_indicatorLinearEffect2)
	end

	self.m_preBonusLevel = self.m_bonus
end

-------------------------------------
-- function onChangeIndicatorEffect
-- @brief 인디케이터 보너스 단계별로 다른 연출을 한다.
-------------------------------------
function SkillIndicator_LeafBlade:onChangeIndicatorEffect(indicator, bonus_lv, pre_bonus_lv)
	-- 인디케이터 색상 변경
	local l_color_lv = g_constant:get('INDICATOR', 'COLOR_LEVEL')
	local color_key = l_color_lv[tostring(bonus_lv)]
	local color = COLOR[color_key]
	indicator:setColor(color)

	-- 인디케이터 애니메이션 변경
	if (pre_bonus_lv < 2) and (bonus_lv >= 2) then
		indicator:changeAni('idle_2', true)
	elseif (bonus_lv ~= pre_bonus_lv) then
		-- @TODO 왜 이 리소스만 changeAni를 해야 setColor가 보일까
		indicator:changeAni('idle', true)
	end
end

-------------------------------------
-- function onEnterAppear
-------------------------------------
function SkillIndicator_LeafBlade:onEnterAppear()
	PARENT.onEnterAppear(self)

	self.m_indicatorBezierEffect1:changeAni('appear', false, function(node)
		node:changeAni('idle', true)
	end)

	self.m_indicatorBezierEffect2:changeAni('appear', false, function(node)
		node:changeAni('idle', true)
	end)

	self.m_indicatorLinearEffect1:changeAni('appear', false, function(node)
		node:changeAni('idle', true)
	end)

	self.m_indicatorLinearEffect2:changeAni('appear', false, function(node)
		node:changeAni('idle', true)
	end)
end