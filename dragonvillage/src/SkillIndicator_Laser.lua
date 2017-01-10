-------------------------------------
-- class SkillIndicator_Laser
-------------------------------------
SkillIndicator_Laser = class(SkillIndicator, {
        m_thickness = 'number', -- 레이저의 굵기
		m_indicatorAddEffect = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Laser:init(hero, t_skill)
    -- 스킬테이블의 val_1의 값으로 레이저의 굵기를 조정
    local size = t_skill['val_1']
    if (size == 1) then
        self.m_thickness = 30
    elseif (size == 2) then
        self.m_thickness = 60
    elseif (size == 3) then
        self.m_thickness = 120
    else
        error('size : ' .. size)
    end
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Laser:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end
    
    local pos_x, pos_y = self:getAttackPosition()
    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))

	-- 각도 제한
    local isChangeDegree = false
	if (dir > 60) and (dir < 180) then 
        dir = 60
        isChangeDegree = true
	elseif (dir < 300) and (dir > 180) then
        dir = 300
        isChangeDegree = true
	end

    self.m_targetPosX = x
    self.m_targetPosY = y

	-- 이펙트 조정
	self.m_targetDir = dir
    self.m_indicatorEffect:setRotation(dir)
    self.m_indicatorAddEffect:setRotation(dir)

    if isChangeDegree then
        local adjust_pos = getPointFromAngleAndDistance(dir, 500)
        local ap1 = {x=pos_x, y=pos_y}
        local ap2 = {x=pos_x+adjust_pos['x'], y=pos_y+adjust_pos['y']}
        local bp1 = {x=0, y=y}
        local bp2 = {x=3000, y=y}
        local ip_x, ip_y = getIntersectPoint(ap1, ap2, bp1, bp2)
        self.m_indicatorAddEffect:setPosition(ip_x - pos_x + self.m_attackPosOffsetX, ip_y - pos_y + self.m_attackPosOffsetY)

        self.m_targetPosX = (ip_x + self.m_attackPosOffsetX)
        self.m_targetPosY = (ip_y + self.m_attackPosOffsetY)
    else
        self.m_indicatorAddEffect:setPosition(x - pos_x + self.m_attackPosOffsetX, y - pos_y + self.m_attackPosOffsetY)
    end

	-- 하이라이트 갱신
	local t_collision_obj = self:findTarget(pos_x, pos_y, dir)
	self:setHighlightEffect(t_collision_obj)
end



-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Laser:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do
        local indicator = MakeAnimator(RES_INDICATOR['STRAIGHT'])
        indicator:setTimeScale(5)
        indicator:setPosition(self.m_attackPosOffsetX, self.m_attackPosOffsetY)
        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator

        -- a2d상에서 굵기가 120으로 되어있음
        indicator.m_node:setScaleX(self.m_thickness/120)
    end

    do
        local indicator = MakeAnimator(RES_INDICATOR['STRAIGHT'])
        indicator:setTimeScale(5)
		indicator:changeAni('cursor', true)
        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end
end


-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Laser:onChangeTargetCount(old_target_count, cur_target_count)
    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorEffect.m_node:setColor(COLOR_RED)
        self.m_indicatorAddEffect.m_node:setColor(COLOR_RED)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorEffect.m_node:setColor(COLOR_CYAN)
		self.m_indicatorAddEffect.m_node:setColor(COLOR_CYAN)
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_Laser:findTarget(pos_x, pos_y, dir)
    local end_pos = getPointFromAngleAndDistance(dir, 2560)    
    local end_x = pos_x + end_pos['x']
    local end_y = pos_y + end_pos['y']

    -- 레이저에 충돌된 모든 객체 리턴
    local t_collision_obj = self.m_world.m_physWorld:getLaserCollision(pos_x, pos_y,
        end_x, end_y, self.m_thickness/2, 'missile_h')

    local t_ret = {}

    for i,v in ipairs(t_collision_obj) do
        table.insert(t_ret, v['obj'])
    end

    return t_ret
end