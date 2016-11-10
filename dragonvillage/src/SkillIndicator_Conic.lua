local PARENT = SkillIndicator

-------------------------------------
-- class SkillIndicator_Conic
-------------------------------------
SkillIndicator_Conic = class(SkillIndicator, {
		m_indicatorAddEffectList = '',

		m_skillRadius = 'num',
		
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_Conic:init(hero, t_skill)
	PARENT.init(self, hero)
	
	self.m_skillRadius = t_skill['val_1']
	self.m_indicatorScale = t_skill['res_scale']
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicator_Conic:onTouchMoved(x, y)
    if (self.m_siState == SI_STATE_READY) then
        return
    end

    local x, y = x, y
    local pos_x, pos_y = self:getAttackPosition()
    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))
	self.m_indicator1:setRotation(dir)

    self.m_targetPosX = x
    self.m_targetPosY = y
    
	local t_collision_obj = self:findTargetList(x, y, dir)

    local skill_indicator_mgr = self:getSkillIndicatorMgr()

    local old_target_count = 0

    local old_highlight_list = self.m_highlightList

    if self.m_highlightList then
        old_target_count = #self.m_highlightList
    end

    --local t_collision_obj = self:findTarget(x, y)

    for i,target in ipairs(t_collision_obj) do            
        if (not target.m_targetEffect) then
            skill_indicator_mgr:addHighlightList(target)
            self:makeTargetEffect(target)
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
function SkillIndicator_Conic:initIndicatorNode()
    if (not PARENT.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    do -- 캐스팅 이펙트
        local indicator = MakeAnimator('res/indicator/indicator_breath_gust/indicator_breath_gust.vrp')
		indicator:setTimeScale(5)
        root_node:addChild(indicator.m_node)
		indicator:setPosition(self:getAttackPosition())
		indicator:setScale(self.m_indicatorScale)
        self.m_indicator1 = indicator
		return true
    end
end

-------------------------------------
-- function onEnterAppear
-------------------------------------
function SkillIndicator_Conic:onEnterAppear()
    self.m_indicator1:changeAni('20', false)
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_Conic:onChangeTargetCount(old_target_count, cur_target_count)
    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        --self.m_indicatorEffect:changeAni('skill_range_enemy', true)

    -- 비활성화 
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        --self.m_indicatorEffect:changeAni('skill_range_normal', true)
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