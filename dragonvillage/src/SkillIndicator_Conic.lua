local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_Conic
-------------------------------------
SkillIndicator_Conic = class(SkillIndicator, {
		m_indicatorAddEffectList = '',
		m_skillRadius = 'num',
		m_skillAngle = 'num',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Conic:init(hero, t_skill)
	PARENT.init(self, hero)
	
	self.m_skillRadius = t_skill['val_1']
	self.m_skillAngle = t_skill['val_2']
	self.m_indicatorScale = t_skill['res_scale']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Conic:onTouchMoved(x, y)
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
	local t_collision_obj = self:findTargetList(x, y, dir)
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Conic:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator(RES_INDICATOR['CONE'..self.m_skillAngle])
        root_node:addChild(indicator.m_node)
		indicator:setPosition(self:getAttackPosition())
		indicator:setScale(self.m_indicatorScale)
		indicator:setTimeScale(5)
        self.m_indicatorEffect = indicator
		return true
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Conic:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
	if (old_target_count == 0) and (cur_target_count > 0) then
		self.m_indicatorEffect.m_node:setColor(COLOR_RED)

	-- 비활성화
	elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_indicatorEffect.m_node:setColor(COLOR_CYAN)
	end
end


-------------------------------------
-- function findTargetList
-------------------------------------
function SkillIndicator_Conic:findTargetList(x, y, dir)
    local world = self:getWorld()

    local t_data = {}
    t_data['x'] = self.m_hero.pos.x
    t_data['y'] = self.m_hero.pos.y
    t_data['dir'] = dir
    t_data['angle_range'] = 20 
    t_data['radius'] = self.m_skillRadius

    return world:getTargetList(self.m_hero, self.m_hero.pos.x, self.m_hero.pos.y, 'enemy', 'x', 'fan_shape', t_data)
end