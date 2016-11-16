-------------------------------------
-- class SkillIndicator_OppositeTarget
-------------------------------------
SkillIndicator_OppositeTarget = class(SkillIndicator, {
        m_indicatorEffect01 = '',
        m_indicatorLinkEffect = '',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_OppositeTarget:init(hero)
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_OppositeTarget:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local x, y = x, y
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

    self.m_targetChar = self:_findTarget(x, y)

    if self.m_targetChar then
        x = self.m_targetChar.pos.x
        y = self.m_targetChar.pos.y
    end

    -- 이펙트 위치
    LinkEffect_refresh(self.m_indicatorLinkEffect, 0, 0, x - pos_x, y - pos_y)
    
    self.m_targetPosX = x
    self.m_targetPosY = y

    local skill_indicator_mgr = self:getSkillIndicatorMgr()

    local old_target_count = 0

    local old_highlight_list = self.m_highlightList

    if self.m_highlightList then
        old_target_count = #self.m_highlightList
    end

    if (self.m_targetChar) and (not self.m_targetChar.m_targetEffect) then
        skill_indicator_mgr:addHighlightList(self.m_targetChar)
        self:makeTargetEffect(self.m_targetChar)
    end

    if old_highlight_list then
        for i,v in ipairs(old_highlight_list) do
            local find = false
            if (v == self.m_targetChar) then
                find = true
                break
            end
            if (find == false) then
                if (v ~= self.m_hero) then
                    skill_indicator_mgr:removeHighlightList(v)
                else
                    v:removeTargetEffect(v)
                end
            end
        end
    end

    self.m_highlightList = {self.m_targetChar}

    local cur_target_count = #self.m_highlightList
    self:onChangeTargetCount(old_target_count, cur_target_count)
end



-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_OppositeTarget:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator('res/indicator/indicator_effect_cast/indicator_effect_cast.vrp')
        indicator:setTimeScale(5)
        indicator:changeAni('normal', true)

		-- @TODO
		indicator:setVisible(false)

        root_node:addChild(indicator.m_node)
        self.m_indicatorEffect01 = indicator
    end

    do
        local link_effect = LinkEffect('res/indicator/indicator_type_target/indicator_type_target.vrp', 'normal_bar_idle', 'normal_start_idle', 'normal_end_idle', 200, 200)
        root_node:addChild(link_effect.m_node)
        self.m_indicatorLinkEffect = link_effect

		--@TODO
		link_effect.m_startPointNode:setVisible(false)
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_OppositeTarget:onChangeTargetCount(old_target_count, cur_target_count)
    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorLinkEffect.m_startPointNode:changeAni('enemy_start_idle', true)
        self.m_indicatorLinkEffect.m_effectNode:changeAni('enemy_bar_idle', true)
        self.m_indicatorLinkEffect.m_endPointNode:changeAni('enemy_end_idle', true)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorLinkEffect.m_startPointNode:changeAni('normal_start_idle', true)
        self.m_indicatorLinkEffect.m_effectNode:changeAni('normal_bar_idle', true)
        self.m_indicatorLinkEffect.m_endPointNode:changeAni('normal_end_idle', true)
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_OppositeTarget:_findTarget(x, y)
    local world = self:getWorld()
    local target_formation_mgr = nil

    if self.m_hero.m_bLeftFormation then
        target_formation_mgr = world.m_rightFormationMgr
    else
        target_formation_mgr = world.m_leftFormationMgr
    end
     
    local l_target = target_formation_mgr:findNearTarget(x, y, -1, 1, EMPTY_TABLE)
    
    return l_target[1]
end