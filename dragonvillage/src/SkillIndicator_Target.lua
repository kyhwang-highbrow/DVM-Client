-------------------------------------
-- class SkillIndicator_Target
-------------------------------------
SkillIndicator_Target = class(SkillIndicator, {
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
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

    local t_collision_obj = self:findTarget(x, y)
    self.m_targetChar = t_collision_obj[1]

    if self.m_targetChar then
        x = self.m_targetChar.pos.x
        y = self.m_targetChar.pos.y
    end

	self.m_targetPosX = x
    self.m_targetPosY = y

    -- 이펙트 위치
    EffectLink_refresh(self.m_indicatorEffect, 0, 0, x - pos_x, y - pos_y)

	-- 하이라이트 갱신
    self:setHighlightEffect(t_collision_obj)
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
        local link_effect = EffectLink(RES_INDICATOR['TARGET'], 'normal_bar_idle', 'normal_start_idle', 'normal_end_idle', 200, 200)
        link_effect:doNotUseHead()
		root_node:addChild(link_effect.m_node)
        self.m_indicatorEffect = link_effect
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Target:onChangeTargetCount(old_target_count, cur_target_count)
	local type = 'ally'
	if self.m_isOpposite then
		type = 'enemy'
	end

    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorEffect.m_startPointNode:changeAni(type .. '_start_idle', true)
        self.m_indicatorEffect.m_effectNode:changeAni(type .. '_bar_idle', true)
        self.m_indicatorEffect.m_endPointNode:changeAni(type .. '_end_idle', true)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorEffect.m_startPointNode:changeAni('normal_start_idle', true)
        self.m_indicatorEffect.m_effectNode:changeAni('normal_bar_idle', true)
        self.m_indicatorEffect.m_endPointNode:changeAni('normal_end_idle', true)
    end
end


-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_Target:findTarget(x, y)
    local target_formation_mgr = self.m_hero:getFormationMgr(self.m_isOpposite)
    local l_target = target_formation_mgr:findNearTarget(x, y, -1, 1, EMPTY_TABLE)
    
    return {l_target[1]}
end
