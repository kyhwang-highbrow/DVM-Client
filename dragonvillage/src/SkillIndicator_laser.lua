-------------------------------------
-- class SkillIndicator_laser
-------------------------------------
SkillIndicator_laser = class(SkillIndicator, {
        m_indicatorEffect01 = '',
        m_thickness = 'number', -- 레이저의 굵기
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_laser:init(hero, t_skill)

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
function SkillIndicator_laser:onTouchMoved(x, y)

    if (self.m_siState == SI_STATE_READY) then
        return
    end

    self.m_targetPosX = x
    self.m_targetPosY = y
    
    local pos_x, pos_y = self:getAttackPosition()
    local dir = getAdjustDegree(getDegree(pos_x, pos_y, x, y))

    -- 각도 제한
    local change_degree = false
    if (30 < dir) and (dir <= 180) then
        dir = 30
        change_degree = true
    elseif (180 < dir) and (dir < 330) then
        dir = 330
        change_degree = true
    end

    self.m_indicatorEffect01:setRotation(dir)
    self.m_indicator1:setRotation(dir)
    self.m_indicator2:setRotation(dir)

    if change_degree then
        local adjust_pos = getPointFromAngleAndDistance(dir, 500)
        local ap1 = {x=pos_x, y=pos_y}
        local ap2 = {x=pos_x+adjust_pos['x'], y=pos_y+adjust_pos['y']}
        local bp1 = {x=0, y=y}
        local bp2 = {x=3000, y=y}
        local ip_x, ip_y = getIntersectPoint(ap1, ap2, bp1, bp2)
        self.m_indicator2:setPosition(ip_x - pos_x + self.m_attackPosOffsetX, ip_y - pos_y + self.m_attackPosOffsetY)

        self.m_targetPosX = (ip_x + self.m_attackPosOffsetX)
        self.m_targetPosY = (ip_y + self.m_attackPosOffsetY)
    else
        self.m_indicator2:setPosition(x - pos_x + self.m_attackPosOffsetX, y - pos_y + self.m_attackPosOffsetY)
    end

    do
        local skill_indicator_mgr = self:getSkillIndicatorMgr()

        local old_target_count = 0

        local old_highlight_list = self.m_highlightList

        if self.m_highlightList then
            old_target_count = #self.m_highlightList
        end

        -- 레이저에 충돌된 모든 객체 리턴
        local t_collision_obj = self:findTarget(pos_x, pos_y, dir)

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
                    skill_indicator_mgr:removeHighlightList(v)
                end
            end
        end

        self.m_highlightList = t_collision_obj

        local cur_target_count = #self.m_highlightList
        self:onChangeTargetCount(old_target_count, cur_target_count)
    end


    self.m_targetDir = dir
end



-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_laser:initIndicatorNode()
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
        local indicator = MakeAnimator('res/indicator/indicator_type_straight/indicator_type_straight.vrp')
        indicator:setTimeScale(5)
        indicator:changeAni('bar_normal', true)
        indicator:setPosition(self.m_attackPosOffsetX, self.m_attackPosOffsetY)
        root_node:addChild(indicator.m_node)
        self.m_indicator1 = indicator

        -- a2d상에서 굵기가 120으로 되어있음
        indicator.m_node:setScaleX(self.m_thickness/120)
    end

    do
        local indicator = MakeAnimator('res/indicator/indicator_type_straight/indicator_type_straight.vrp')
        indicator:setTimeScale(5)
        indicator:changeAni('cursor_normal', true)
        root_node:addChild(indicator.m_node)
        self.m_indicator2 = indicator
    end
end


-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_laser:onChangeTargetCount(old_target_count, cur_target_count)

    -- 활성화
    if (old_target_count == 0) and (cur_target_count > 0) then
        self.m_indicatorEffect01:changeAni('enemy', true)
        self.m_indicator1:changeAni('bar_enemy', true)
        self.m_indicator2:changeAni('cursor_enemy', true)

    -- 비활성화
    elseif (old_target_count > 0) and (cur_target_count == 0) then
        self.m_indicatorEffect01:changeAni('normal', true)
        self.m_indicator1:changeAni('bar_normal', true)
        self.m_indicator2:changeAni('cursor_normal', true)

    end

end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_laser:findTarget(pos_x, pos_y, dir)
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