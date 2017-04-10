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
function SkillIndicator_LeafBlade:onTouchMoved(x, y)
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

    local t_collision_obj, t_collision_bodys = self:findTarget(tar_x, tar_y)
    self.m_targetChar = t_collision_obj[1]
	
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
	self:setHighlightEffect(t_collision_obj, t_collision_bodys)
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
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'target')
        local indicator = MakeAnimator(indicator_res)
        indicator:changeAni('enemy_start_idle', true)
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
-- function findTarget
-------------------------------------
function SkillIndicator_LeafBlade:findTarget(x, y)
    local l_target = self.m_hero:getTargetListByType(self.m_targetType, self.m_targetFormation)
    	
	local target_1 = nil 
	local target_2 = nil

    local pos_x = self.m_hero.pos.x
    local pos_y = self.m_hero.pos.y

   	-- 베지어 곡선에 의한 충돌 리스트
    local l_ret_bezier1, l_ret_bezier_bodys1 = SkillTargetFinder:findTarget_Bezier(l_target, x, y, pos_x, pos_y, 1)
    local l_ret_bezier2, l_ret_bezier_bodys2 = SkillTargetFinder:findTarget_Bezier(l_target, x, y, pos_x, pos_y, -1)
    
    -- 충돌체크에 필요한 변수 생성
    local std_dist = 1000
	local degree = getDegree(pos_x, pos_y, x, y)
	local leaf_body_size = g_constant:get('SKILL', 'LEAF_COLLISION_SIZE')
	local straight_angle = g_constant:get('SKILL', 'LEAF_STRAIGHT_ANGLE')
	
    -- 직선에 의한 충돌 리스트 (상)
    local rad = math_rad(degree + straight_angle)
    local factor_y = math.tan(rad)
    local t_ret_line1, t_ret_line_bodys1 = SkillTargetFinder:findTarget_Bar(l_target, x, y, x + std_dist, y + std_dist * factor_y, leaf_body_size)

    -- 직선에 의한 충돌 리스트 (하)
    rad = math_rad(degree - straight_angle)
    factor_y = math.tan(rad)
    local t_ret_line2, t_ret_line_bodys2 = SkillTargetFinder:findTarget_Bar(l_target, x, y, x + std_dist, y + std_dist * factor_y, leaf_body_size)

	-- 하나의 테이블로 합침
    -- 맵형태로 변경해서 중복값을 없앰
    local m_temp = {}
    local m_temp_bodys = {}
    local l_temp = {
        { l_ret_bezier1, l_ret_bezier_bodys1 },
        { l_ret_bezier2, l_ret_bezier_bodys2 },
        { t_ret_line1, t_ret_line_bodys1 },
        { t_ret_line2, t_ret_line_bodys2 },
    }

    for _, list in ipairs(l_temp) do
        local l_objs = list[1]
        local l_bodys = list[2]

        for i, v in ipairs(l_objs) do
            m_temp[v] = v
            if (not m_temp_bodys[v]) then
                m_temp_bodys[v] = {}
            end

            local body_keys = l_bodys[i]
            for _, k in ipairs(body_keys) do
                m_temp_bodys[v][k] = true
            end
        end
    end
    
    -- 다시 리스트 형태로 변환
    local l_ret = {}
    local l_ret_bodys = {}

    for k, _ in pairs(m_temp) do
        table.insert(l_ret, k)

        local body_keys = {}
        for k2, _ in pairs(m_temp_bodys[k]) do
            table.insert(body_keys, k2)
        end

        table.insert(l_ret_bodys, body_keys)
    end
    
    return l_ret, l_ret_bodys
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_LeafBlade:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
	if (cur_target_count > 0) then
		if (old_target_count == 0) then
			self.m_indicatorEffect:changeAni('enemy_start_idle', true)
		end
		self.m_indicatorBezierEffect1:setColor(COLOR_RED)
		self.m_indicatorBezierEffect2:setColor(COLOR_RED)
		self.m_indicatorLinearEffect1:setColor(COLOR_RED)
		self.m_indicatorLinearEffect2:setColor(COLOR_RED)

	-- 비활성화
	elseif (cur_target_count == 0) then
		if (old_target_count > 0) then
			self.m_indicatorEffect:changeAni('normal_start_idle', true)
		end
		self.m_indicatorBezierEffect1:setColor(COLOR_CYAN)
		self.m_indicatorBezierEffect2:setColor(COLOR_CYAN)
		self.m_indicatorLinearEffect1:setColor(COLOR_CYAN)
		self.m_indicatorLinearEffect2:setColor(COLOR_CYAN)
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