-------------------------------------
-- class ScrollMapLayer
-------------------------------------
ScrollMapLayer = class({
        m_type = 'string',          -- 'horizontal' or 'vertical'
        m_tSprite = 'table',        -- 배경 랜더링에 필요한 스프라이트 테이블
        m_interval = 'number',      -- 배경 랜더링 간격
        m_width = 'number',         -- Sprite의 넓이
        m_height = 'number',        -- Sprite의 높이
        m_speedScale = 'number',    -- 이동 속도 배율
        m_offsetX = 'number',       -- X위치
        m_offsetY = 'number',       -- Y위치
        m_visibleSize = 'table',    -- 화면 사이즈
    })

-------------------------------------
-- class ScrollMapLayer
-------------------------------------
function ScrollMapLayer:init(parent, type, res, animation, interval, offset_x, offset_y, scale, speed_scale)
    self.m_type = type
    self.m_tSprite = {}
    self.m_interval = interval or 960
    self.m_offsetX = offset_x or 0
    self.m_offsetY = offset_y or 0
    self.m_speedScale = speed_scale or 1

    self.m_visibleSize = cc.Director:getInstance():getVisibleSize()
    
    local visible_width = 2048
    local visible_height = 1600

    -- 스프라이트 생성
    local animator = MakeAnimator(res)
    if animation then
        animator:changeAni(animation, true)
    end
    
     local sprite = animator.m_node
    sprite:setDockPoint(cc.p(0, 0.5))
    sprite:setAnchorPoint(cc.p(0, 0.5))
    sprite:setScale(scale)
    parent:addChild(sprite)
    table.insert(self.m_tSprite, sprite)

    if self.m_type == 'horizontal' then
        sprite:setPositionY(self.m_offsetY)
    elseif self.m_type == 'vertical' then
        sprite:setPositionX(self.m_offsetX)
    end

    local sprite_size = sprite:getContentSize()
    self.m_height = sprite_size.height
    self.m_width = sprite_size.width
    
    if self.m_interval > 0 then
        local count

        if self.m_type == 'horizontal' then
            count = math_ceil(visible_width / self.m_interval) + 1
        elseif self.m_type == 'vertical' then
            count = math_ceil(visible_height / self.m_interval) + 1
        end

        if count then
            for i = 2, count do
                local animator = MakeAnimator(res)
                if animation then
                    animator:changeAni(animation, true)
                end

                local sprite = animator.m_node --cc.Sprite:create(res)
                sprite:setDockPoint(cc.p(0, 0.5))
                sprite:setAnchorPoint(cc.p(0, 0.5))
                sprite:setScale(scale)
                parent:addChild(sprite)
                table.insert(self.m_tSprite, sprite)

                if self.m_type == 'horizontal' then
                    sprite:setPositionY(self.m_offsetY)
                elseif self.m_type == 'vertical' then
                    sprite:setPositionX(self.m_offsetX)
                end
            end
        end
    end

    ScrollMapLayer_update(self, 0, 0)
end

-------------------------------------
-- function update
-------------------------------------
function ScrollMapLayer_update(self, totalMove, dt)
    local pos = (totalMove * self.m_speedScale)
    local cameraX, cameraY = 0, 0
    local value

    if g_gameScene then
        cameraX, cameraY = g_gameScene.m_gameWorld.m_gameCamera:getPosition()
    end

    if self.m_type == 'horizontal' then
        pos = pos + self.m_offsetX
        value = cameraX - (CRITERIA_RESOLUTION_X - 2)
    elseif self.m_type == 'vertical' then
        pos = pos + self.m_offsetY
        value = cameraY - (CRITERIA_RESOLUTION_Y - 2)
    end

    local start_pos = pos
    if self.m_interval > 0 then
        start_pos = math_floor(pos % self.m_interval)
    end
    
    if start_pos < value then
        start_pos = start_pos + self.m_interval
    elseif start_pos > value then
        start_pos = start_pos - self.m_interval
    end

    local visibleSize = self.m_visibleSize
    for i, v in ipairs(self.m_tSprite) do
        if self.m_type == 'horizontal' then
            v:setPositionX(start_pos)
        elseif self.m_type == 'vertical' then
            v:setPositionY(start_pos)
        end
        start_pos = start_pos + self.m_interval
    end
end