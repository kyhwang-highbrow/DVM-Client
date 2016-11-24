local PARENT = SkillIndicator
-------------------------------------
-- class SkillIndicator_Crash
-- @brief 가루다의 액티스 스킬 (skill_crash)
-- t_skill
-- ['res_1']        충격파 이펙트
-- ['res_2']        돌진 이펙트 (드래곤에 붙어서 출력)
-- ['power_rate']   충격 데미지 (%)
-- ['val_1']        충격파 데미지 (%)
-- ['val_2']        충격파 반지름
-------------------------------------
SkillIndicator_Crash = class(PARENT, {
        m_indicatorAddEffect = '',
        m_skillRadius = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Crash:init(hero, t_skill)
    -- 충격파 반지름
    self.m_skillRadius = t_skill['val_2']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Crash:onTouchMoved(x, y)

    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local x, y = x, y
    local pos_x, pos_y = self.m_indicatorRootNode:getPosition()

    self.m_targetPosX = x
    self.m_targetPosY = y
    local t_collision_obj = self:findShockwaveTarget(x, y)

    -- 이펙트 위치
    LinkEffect_refresh(self.m_indicatorEffect, 0, 0, x - pos_x, y - pos_y)

    self.m_indicatorAddEffect:setPosition(x - pos_x, y - pos_y)

    local skill_indicator_mgr = self:getSkillIndicatorMgr()

    local old_target_count = 0

    local old_highlight_list = self.m_highlightList

    if self.m_highlightList then
        old_target_count = #self.m_highlightList
    end

    for i,target in ipairs(t_collision_obj) do            
        if (not target.m_targetEffect) then
            skill_indicator_mgr:addHighlightList(target)
            self:makeTargetEffect(target, 'appear_enemy', 'idle_enemy')
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
                if (v ~= self.m_hero) then
                    skill_indicator_mgr:removeHighlightList(v)
                else
                    v:removeTargetEffect(v)
                end
            end
        end
    end

    self.m_highlightList = t_collision_obj

    local cur_target_count = #self.m_highlightList
    self:onChangeTargetCount(old_target_count, cur_target_count)
end



-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_Crash:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do
        local indicator = MakeAnimator('res/indicator/indicator_common/indicator_common.vrp')
        indicator:changeAni('fan_shape_enemy', true)
        indicator:setRotation(0)
        root_node:addChild(indicator.m_node)
        self.m_indicatorAddEffect = indicator
    end

    do
        local link_effect = LinkEffect('res/indicator/indicator_type_target/indicator_type_target.vrp', 'normal_bar_idle', 'normal_start_idle', 'normal_end_idle', 200, 200)
        root_node:addChild(link_effect.m_node)
		self.m_indicatorEffect = link_effect
		
		--@TODO
		link_effect.m_startPointNode:setVisible(false)
    end

    
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Crash:onChangeTargetCount(old_target_count, cur_target_count)

    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorEffect.m_startPointNode:changeAni('enemy_start_idle', true)
        self.m_indicatorEffect.m_effectNode:changeAni('enemy_bar_idle', true)
        self.m_indicatorEffect.m_endPointNode:changeAni('enemy_end_idle', true)

        self.m_indicatorAddEffect:changeAni('fan_shape_enemy')

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorEffect.m_startPointNode:changeAni('normal_start_idle', true)
        self.m_indicatorEffect.m_effectNode:changeAni('normal_bar_idle', true)
        self.m_indicatorEffect.m_endPointNode:changeAni('normal_end_idle', true)

        self.m_indicatorAddEffect:changeAni('fan_shape_normal')

    end
end

-------------------------------------
-- function findShockwaveTarget
-------------------------------------
function SkillIndicator_Crash:findShockwaveTarget(x, y)
    local world = self:getWorld()

    local t_data = {}
    t_data['x'] = x
    t_data['y'] = y
    t_data['dir'] = 0
    t_data['angle_range'] = 60 -- 변경되지 않는 값
    t_data['radius'] = self.m_skillRadius

    if self.m_hero.m_bLeftFormation then
        t_data['dir'] = 0
    else
        t_data['dir'] = 180
    end

    return world:getTargetList(self.m_hero, self.m_hero.pos.x, self.m_hero.pos.y, 'enemy', 'x', 'fan_shape', t_data)
end