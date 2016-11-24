local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_LeafBlade
-------------------------------------
SkillIndicator_LeafBlade = class(SkillIndicator, {
		-- 베지어 곡선 이펙트
        m_indicatorBezierEffect1 = '',
        m_indicatorBezierEffect2 = '',

		-- 직선 이펙트
        m_indicatorLinearEffect1 = '',
        m_indicatorLinearEffect2 = '',

		-- 리프블레이드 무관통 관련 변수
		m_isPass = 'bool',
		m_isCollision = 'bool', 
		m_target_1 = '',
		m_target_2 = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_LeafBlade:init(hero, t_skill)
	PARENT.init(self, hero)

	self.m_isPass = (t_skill['val_1'] == 1)
	self.m_isCollision = false
	self.m_target_1 = nil
	self.m_target_2 = nil
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_LeafBlade:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local tar_x, tar_y = x, y
    local pos_x = self.m_hero.pos.x
    local pos_y = self.m_hero.pos.y

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

	-- 2. 최소 거리 제한
	local distance = getDistance(tar_x, tar_y, pos_x, pos_y)
	local isChangeDistance = false
	if (distance < 400) then
        distance = 400
		isChangeDistance = true
	end

	-- 3. 각도와 거리 체크하여 타겟 좌표 수정
	if isChangeDegree or isChangeDistance then
        local adj_pos = getPointFromAngleAndDistance(dir, distance)
        tar_x, tar_y = adj_pos.x + pos_x, adj_pos.y + pos_y
    end

    local t_collision_obj = self:findTargetList(tar_x, tar_y)
    self.m_targetChar = t_collision_obj[1]
	
    -- 4-1. 베지어 곡선 이펙트 위치 갱신
    EffectBezierLink_refresh(self.m_indicatorBezierEffect1, tar_x, tar_y, pos_x, pos_y, 1)
    EffectBezierLink_refresh(self.m_indicatorBezierEffect2, tar_x, tar_y, pos_x, pos_y, -1)

	-- 4-2. 직선 이펙트 위치 갱신
    EffectLinearDot_refresh(self.m_indicatorLinearEffect1, tar_x, tar_y, pos_x, pos_y, 1)
    EffectLinearDot_refresh(self.m_indicatorLinearEffect2, tar_x, tar_y, pos_x, pos_y, -1)

	-- 4-3. 타겟에 찍히는 이펙트 위치 갱신
    self.m_indicatorEffect:setPosition(tar_x - pos_x, tar_y - pos_y)

	-- 5. 메인 타겟 좌표 멤버 변수에 저장
    self.m_targetPosX = tar_x
    self.m_targetPosY = tar_y

	-- 6. 공격 대상 하이라이트 이펙트 관리
    self:setHighlightEffect(t_collision_obj)
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
        local indicator = MakeAnimator('res/indicator/indicator_type_target/indicator_type_target.vrp')
        indicator:setTimeScale(5)
        indicator:changeAni('enemy_start_idle', true)
        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator
    end
    
    -- 베지어 곡선 이펙트 (상)
    do
        local link_effect = EffectBezierLink('res/indicator/indicator_bezier/indicator_bezier.vrp', 'circle')
        root_node:addChild(link_effect.m_node)
        self.m_indicatorBezierEffect1 = link_effect
    end

    -- 베지어 곡선 이펙트 (하)
    do
        local link_effect = EffectBezierLink('res/indicator/indicator_bezier/indicator_bezier.vrp', 'circle')
        root_node:addChild(link_effect.m_node)
        self.m_indicatorBezierEffect2 = link_effect
    end

    -- 직선 이펙트 (상)
    do
        local link_effect = EffectLinearDot('res/indicator/indicator_bezier/indicator_bezier.vrp', 'circle')
        root_node:addChild(link_effect.m_node)
        self.m_indicatorLinearEffect1 = link_effect
    end

    -- 직선 이펙트 (하)
    do
        local link_effect = EffectLinearDot('res/indicator/indicator_bezier/indicator_bezier.vrp', 'circle')
        root_node:addChild(link_effect.m_node)
        self.m_indicatorLinearEffect2 = link_effect
    end
end

-------------------------------------
-- function setHighlight
-------------------------------------
function SkillIndicator_LeafBlade:setHighlightEffect(t_collision_obj)
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
                skill_indicator_mgr:removeHighlightList(v)
            end
        end
    end

    self.m_highlightList = t_collision_obj

    local cur_target_count = #self.m_highlightList

	if (not self.m_isPass) then
		self:changeEffectNonePass()
	else
		local cur_target_count = #self.m_highlightList
		self:onChangeTargetCount(old_target_count, cur_target_count)
	end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_LeafBlade:findTargetList(x, y)
    local target_formation_mgr = self.m_hero:getFormationMgr()
	
	self.m_target_1 = nil 
	self.m_target_2 = nil

    local pos_x = self.m_hero.pos.x
    local pos_y = self.m_hero.pos.y

	local l_target = {}

    -- 베지어 곡선에 의한 충돌 리스트
    local l_target1 = target_formation_mgr:findBezierTarget(x, y, pos_x, pos_y, 1)
    local l_target2 = target_formation_mgr:findBezierTarget(x, y, pos_x, pos_y, -1)

	-- 00. 무관통 탄일 경우 베지어 곡선에서 충돌 리스트가 있다면 탈출
	if (not self.m_isPass) then 
		if (#l_target1 > 0) then 
			table.insert(l_target, l_target1[1])
			self.m_target_1 = l_target1[1]
		end
		if (#l_target2 > 0) then 
			table.insert(l_target, l_target2[1])
			self.m_target_2 = l_target2[1]
		end
	end

    local std_dist = 1000
	local degree = getDegree(pos_x, pos_y, x, y)

    -- 직선에 의한 충돌 리스트 (상)
    local rad = math_rad(degree + LEAF_STRAIGHT_ANGLE)
    local factor_y = math.tan(rad)
    local t_target_line_1 = self.m_world.m_physWorld:getLaserCollision(x, y,
        x + std_dist, y + std_dist * factor_y, LEAF_COLLISION_SIZE, 'missile_h')

    -- 직선에 의한 충돌 리스트 (하)
    rad = math_rad(degree - LEAF_STRAIGHT_ANGLE)
    factor_y = math.tan(rad)
    local t_target_line_2 = self.m_world.m_physWorld:getLaserCollision(x, y,
        x + std_dist, y + std_dist * factor_y, LEAF_COLLISION_SIZE, 'missile_h')
    
    -- getLaserCollision는 반환값이 특정 테이블이기때문에 Character 클래스만 꺼내와서 정리한다.
	-- 00. 무관통 탄의 경우 첫번째 오브젝트만 가져간다.
    local l_target_line = {}
    for i, col in pairs(t_target_line_1) do
        table.insert(l_target_line, col['obj'])
		if (not self.m_isPass) and (not self.m_target_2) then 
			self.m_target_2 = col['obj']
			break
		end
    end
    for i, col in pairs(t_target_line_2) do
        table.insert(l_target_line, col['obj'])
		if (not self.m_isPass) and (not self.m_target_1) then 
			self.m_target_1 = col['obj']
			break
		end
    end
	
	-- 하나의 테이블로 합침
	if (not self.m_isPass) then 
		if (#l_target > 0) then 
			return l_target
		else
			return l_target_line
		end
	else
		l_target = table.merge(l_target1, l_target2)
		l_target = table.merge(l_target, l_target_line)
		return l_target
	end 
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_LeafBlade:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
	if (old_target_count == 0) and (cur_target_count > 0) then
		self.m_indicatorEffect:changeAni('enemy_start_idle', true)
		self.m_indicatorBezierEffect1:changeAni('circle', true)
		self.m_indicatorBezierEffect2:changeAni('circle', true)
		self.m_indicatorLinearEffect1:changeAni('circle', true)
		self.m_indicatorLinearEffect2:changeAni('circle', true)

	-- 비활성화
	elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_indicatorEffect:changeAni('normal_start_idle', true)
		self.m_indicatorBezierEffect1:changeAni('circle_normal', true)
		self.m_indicatorBezierEffect2:changeAni('circle_normal', true)
		self.m_indicatorLinearEffect1:changeAni('circle_normal', true)
		self.m_indicatorLinearEffect2:changeAni('circle_normal', true)
	end
end

-------------------------------------
-- function checkNonePass
-------------------------------------
function SkillIndicator_LeafBlade:changeEffectNonePass()
	-- 교차점 표시 부분
	if (not self.m_target_1) and (not self.m_target_2) then
		self.m_indicatorEffect:changeAni('normal_start_idle', true)
	else
		self.m_indicatorEffect:changeAni('enemy_start_idle', true)
	end
	
	-- 탄1
	if self.m_target_1 then
		self:checkPosX(self.m_indicatorBezierEffect1.m_lEffectNode, self.m_target_1)
		self:checkPosX(self.m_indicatorLinearEffect2.m_lEffectNode, self.m_target_1)
	else
		self.m_indicatorBezierEffect1:changeAni('circle', true)
		self.m_indicatorLinearEffect2:changeAni('circle', true)
	end
	
	-- 탄2
	if self.m_target_2 then
		self:checkPosX(self.m_indicatorBezierEffect2.m_lEffectNode, self.m_target_2)
		self:checkPosX(self.m_indicatorLinearEffect1.m_lEffectNode, self.m_target_2)
	else
		self.m_indicatorBezierEffect2:changeAni('circle', true)
		self.m_indicatorLinearEffect1:changeAni('circle', true)
	end
end

-------------------------------------
-- function checkPosX
-------------------------------------
function SkillIndicator_LeafBlade:checkPosX(l_effect, target)
	local pos_x = nil
	
	-- 위아래 나누어 타겟을 저장하기 때문에 x 좌표만 검사 한다 
	for _, effect in pairs(l_effect) do
		pos_x = effect.m_node:getPositionX() + self.m_hero.pos.x
		if (pos_x > target.pos.x) then
			effect:changeAni('circle_normal', true)
		else
			effect:changeAni('circle', true)
		end
	end
end