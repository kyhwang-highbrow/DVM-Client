local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_Panetration
-------------------------------------
SkillIndicator_Panetration = class(SkillIndicator, {
		m_lIndicatorEffect = 'indicator list',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Panetration:init(hero, t_skill)
	PARENT.init(self, hero)
	
	self.m_skillRadius = t_skill['val_1']
	self.m_skillAngle = t_skill['val_2']
	self.m_indicatorScale = t_skill['res_scale']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Panetration:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local pos_x, pos_y = self:getAttackPosition()
    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
	
	-- 1. 각도 제한
    local isChangeDegree = true
	if (dir > 60) and (dir < 180) then 
        dir = 60
        isChangeDegree = false
	elseif (dir < 300) and (dir > 180) then
        dir = 300
        isChangeDegree = false
	end

	if (isChangeDegree) then 
		self.m_targetPosX = x
		self.m_targetPosY = y
	end
	
	-- 이펙트 조정
	self.m_indicatorEffect:setRotation(dir)

	-- 하이라이트 갱신
	local t_collision_obj = self:findTarget(x, y, dir)
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Panetration:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator(RES_INDICATOR['STRAIGHT'])
        root_node:addChild(indicator.m_node)
		indicator:setPosition(self:getAttackPosition())
		indicator:setScale(0.3, self.m_indicatorScale)
		indicator:setTimeScale(5)
        self.m_indicatorEffect = indicator
		return true
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Panetration:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
	if (old_target_count == 0) and (cur_target_count > 0) then
		self.m_indicatorEffect.m_node:setColor(COLOR_RED)

	-- 비활성화
	elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_indicatorEffect.m_node:setColor(COLOR_CYAN)
	end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_Panetration:findTarget(x, y, dir)

    return t_ret
end

-------------------------------------
-- function findTargetEachLine
-------------------------------------
function SkillIndicator_Panetration:findTargetEachLine(x, y, dir)
    local end_pos = getPointFromAngleAndDistance(dir, 2560)    
    local end_x = pos_x + end_pos['x']
    local end_y = pos_y + end_pos['y']

	local phys_group = self.m_hero:getAttackPhysGroup()

    -- 레이저에 충돌된 모든 객체 리턴
    local t_collision_obj = self.m_world.m_physWorld:getLaserCollision(pos_x, pos_y,
        end_x, end_y, self.m_thickness/2, phys_group)

    local t_ret = {}

    for i,v in ipairs(t_collision_obj) do
        table.insert(t_ret, v['obj'])
    end

    return t_ret
end