-------------------------------------
-- class SkillIndicator_HealingWind
-------------------------------------
SkillIndicator_HealingWind = class(SkillIndicator, {
		m_indicatorAddEffect = 'a2d',
        m_skillWidth = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_HealingWind:init(hero, t_skill)
    self.m_skillWidth = t_skill['val_2']
	self.m_indicatorScale = t_skill['res_scale']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_HealingWind:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local t_collision_obj = self:findTarget(x, y)

    self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 조정
    self.m_indicatorEffect:setPosition(x - pos_x, 0)
    self.m_indicatorAddEffect:setPosition(x - pos_x, y - pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_HealingWind:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator(RES_INDICATOR['STRAIGHT'])
        indicator:setTimeScale(5)
        indicator:changeAni('healing_wind_normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect = indicator

		--@TODO 스킬 인디케이터 스케일 전면 수정 해야함
        local scale_x = (self.m_skillWidth / 360)
        indicator.m_node:setScaleX(scale_x)
    end

    do
        local indicator = MakeAnimator(RES_INDICATOR['STRAIGHT'])
        indicator:setTimeScale(5)
        indicator:changeAni('cursor_normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_HealingWind:findTarget(x, y)
    local world = self:getWorld()

    local l_target = world:getTargetList(nil, x, y, 'all', 'x', 'distance_x')
    
    local l_ret = {}

    local half_skill_width = (self.m_skillWidth / 2)

    for i,v in ipairs(l_target) do
        local distance = math_abs(v.pos.x - x)
        if (distance <= half_skill_width) then
            table.insert(l_ret, v)
        else
            break
        end
    end

    return l_ret
end
