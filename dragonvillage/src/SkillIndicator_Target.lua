local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_Target
-------------------------------------
SkillIndicator_Target = class(PARENT, {
		m_isOpposite = 'bool', --formationMgr 가져올때 사용'
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Target:init(hero, t_skill, is_opposite)
	self.m_isOpposite = is_opposite
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Target:onTouchMoved(x, y)
    if (not self.m_bDirty) then return end
    self.m_bDirty = false

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

    local l_collision = self:findCollision(x, y)

    if (l_collision[1]) then
        self.m_targetChar = l_collision[1]:getTarget()

        x = self.m_targetChar.pos.x
        y = self.m_targetChar.pos.y
    end

	-- 타겟이 변경되었다면 인디케이터 액션 다시 실행
	if (self.m_targetPosX ~= x) or (self.m_targetPosY ~= y) then
		self.m_indicatorEffect:refreshAction()
	end

	self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 위치
    EffectLink_refresh(self.m_indicatorEffect, 0, 0, x - pos_x, y - pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(l_collision)
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Target:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'target')
        local link_effect = EffectLink(indicator_res, 'bar_idle', 'start_idle', 'end_idle', 200, 200)
        
		link_effect:doNotUseHead()
		self:initIndicatorEffect(link_effect)

		root_node:addChild(link_effect.m_node)
        self.m_indicatorEffect = link_effect
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillIndicator_Target:findCollision(x, y)
    local l_target = self.m_hero:getTargetListByType(self.m_targetType, self.m_targetLimit, self.m_targetFormation)
    local l_ret = SkillTargetFinder:findCollision_AoERound(l_target, x, y, -1)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end
