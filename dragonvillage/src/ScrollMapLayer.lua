-------------------------------------
-- class ScrollMapLayer
-------------------------------------
ScrollMapLayer = class({
        m_rootNode = 'cc.Node',
        m_type = 'string',          -- 'horizontal' or 'vertical'
        m_tAnimator = 'table',      -- 배경 랜더링에 필요한 Animator 테이블
        m_interval = 'number',      -- 배경 랜더링 간격
        m_width = 'number',         -- Sprite의 넓이
        m_height = 'number',        -- Sprite의 높이
        m_speedScale = 'number',    -- 이동 속도 배율
        m_offsetX = 'number',       -- X위치
        m_offsetY = 'number',       -- Y위치
        m_visibleSize = 'table',    -- 화면 사이즈
        m_group = 'number',         -- ScrollMapLayer들중 특수하게 연출되어야하는 것들을 구분하기 위한 값(스크립트로 설정)
    })

-------------------------------------
-- class ScrollMapLayer
-------------------------------------
function ScrollMapLayer:init(parent, type, res, animation, interval, offset_x, offset_y, scale, speed_scale, group)
    self.m_type = type
    
    self.m_tAnimator = {}
    self.m_interval = interval or 960
    self.m_offsetX = offset_x or 0
    self.m_offsetY = offset_y or 0
    self.m_speedScale = speed_scale or 1
    self.m_group = group or ''

    self.m_visibleSize = cc.Director:getInstance():getVisibleSize()
    
    local visible_width = 2176
    local visible_height = 1600

    -- 루트 노드 생성
    self.m_rootNode = cc.Node:create()
    parent:addChild(self.m_rootNode)

    -- 스프라이트 생성
    local animator = MakeAnimator(res)
    if animation then
        animator:changeAni(animation, true)
    end
    
    local sprite = animator.m_node
    sprite:setDockPoint(cc.p(0.0, 0.5))
    sprite:setAnchorPoint(cc.p(0.0, 0.5))
    sprite:setScale(scale)
    self.m_rootNode:addChild(sprite)
    table.insert(self.m_tAnimator, animator)
    
    if self.m_type == 'horizontal' then
        sprite:setPositionY(self.m_offsetY)
    elseif self.m_type == 'vertical' then
        sprite:setPositionX(self.m_offsetX)
    end
        
    if self.m_interval > 0 then
        local count

        if self.m_type == 'horizontal' then
            count = math_ceil(visible_width / self.m_interval) + 2
        elseif self.m_type == 'vertical' then
            count = math_ceil(visible_height / self.m_interval) + 2
        end

        if count then
            for i = 2, count do
                local animator = MakeAnimator(res)
                if animation then
                    animator:changeAni(animation, true)
                end

                local sprite = animator.m_node
                sprite:setDockPoint(cc.p(0.0, 0.5))
                sprite:setAnchorPoint(cc.p(0.0, 0.5))
                sprite:setScale(scale)
                self.m_rootNode:addChild(sprite)
                table.insert(self.m_tAnimator, animator)

                if self.m_type == 'horizontal' then
                    sprite:setPositionY(self.m_offsetY)
                elseif self.m_type == 'vertical' then
                    sprite:setPositionX(self.m_offsetX)
                end
            end
        end
    end

    self:update(0, 0)
end

-------------------------------------
-- function update
-------------------------------------
function ScrollMapLayer:update(totalMove, dt, cameraX, cameraY, cameraScale)
    local pos = (totalMove * self.m_speedScale)
    local cameraX = cameraX or 0
    local cameraY = cameraY or 0
    local cameraScale = cameraScale or 1
    local minValue
    local maxValue

    if self.m_type == 'horizontal' then
        pos = pos + self.m_offsetX
        minValue = cameraX - (CRITERIA_RESOLUTION_X / 2)
        maxValue = cameraX + (CRITERIA_RESOLUTION_X / 2)
    elseif self.m_type == 'vertical' then
        pos = pos + self.m_offsetY
        minValue = cameraY - CRITERIA_RESOLUTION_Y
        maxValue = cameraY + CRITERIA_RESOLUTION_Y
    end

    local start_pos = pos
    if self.m_interval > 0 then
        start_pos = math_floor(pos % self.m_interval)
    end
    
    if start_pos < minValue then
        start_pos = start_pos + self.m_interval
    
    elseif start_pos > maxValue then
        start_pos = start_pos - self.m_interval

    end

    local visibleSize = self.m_visibleSize
    for i, v in ipairs(self.m_tAnimator) do
        if self.m_type == 'horizontal' then
            v.m_node:setPositionX(start_pos)
        elseif self.m_type == 'vertical' then
            v.m_node:setPositionY(start_pos)
        end
        start_pos = start_pos + self.m_interval
    end
end

-------------------------------------
-- function doAction
-------------------------------------
function ScrollMapLayer:doAction(action)
    self.m_rootNode:runAction(action)
end