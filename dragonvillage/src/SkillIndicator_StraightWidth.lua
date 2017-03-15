local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_StraightWidth
-------------------------------------
SkillIndicator_StraightWidth = class(PARENT, {
		m_indicatorAddEffect = 'a2d',
        m_skillHeight = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_StraightWidth:init(hero, t_skill)
    self.m_skillHeight = t_skill['val_1']
	self.m_indicatorScale = t_skill['res_scale']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_StraightWidth:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()
    
	local t_collision_obj = self:findTarget(x, y)

    self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 조정
    local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
    self.m_indicatorEffect:setPosition(cameraHomePosX - pos_x, y - pos_y)
    self.m_indicatorAddEffect:setPosition(x - pos_x, y - pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_StraightWidth:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator(RES_INDICATOR['STRAIGHT_WIDTH'])
        indicator:setRotation(0)
        root_node:addChild(indicator.m_node)
		indicator.m_node:setColor(COLOR_CYAN)
        self.m_indicatorEffect = indicator

		--@TODO 스킬 인디케이터 스케일 전면 수정 해야함
        local scale_y = (self.m_skillHeight / 300)
        indicator.m_node:setScaleY(scale_y)
    end

	do -- 커서 이펙트
		local indicator = MakeAnimator(RES_INDICATOR['STRAIGHT_WIDTH'])
		indicator:setRotation(0)
		indicator:changeAni('cursor', true)
		root_node:addChild(indicator.m_node)
		self.m_indicatorAddEffect = indicator
	end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_StraightWidth:findTarget(x, y)
    local world = self:getWorld()

    local l_target = world:getTargetList(self.m_hero, x, y, 'enemy', 'x', 'distance_y')
    
    local l_ret = {}

    local half_skill_height = (self.m_skillHeight / 2)

    for i,v in ipairs(l_target) do
        local distance = math_abs(v.pos.y - y)
        if (distance <= half_skill_height) then
            table.insert(l_ret, v)
        else
            break
        end
    end

    return l_ret
end
