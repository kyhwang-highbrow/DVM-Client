-------------------------------------
-- class ScrollMapLayer
-------------------------------------
ScrollMapLayer = class({
        m_tSprite = 'table',     -- 배경 랜더링에 필요한 스프라이트 테이블
        m_interval = 'number',   -- 배경 랜더링 간격
        m_width = 'number',      -- Sprite의 넓이
        m_height = 'number',     -- Sprite의 높이
        m_speedScale = 'number', -- 이동 속도 배율
        m_offsetX = 'number',    -- Y위치
        m_offsetY = 'number',     -- 가로 이동 속도
        m_visibleSize = 'table', -- 화면 사이즈
    })

-------------------------------------
-- class ScrollMapLayer
-------------------------------------
function ScrollMapLayer:init(parent, res, animation, interval, offset_x, offset_y, speed_y, speed_scale)
    self.m_tSprite = {}
    self.m_interval = interval or 960
    self.m_offsetX = offset_x or 0
    self.m_offsetY = speed_y or 0
    self.m_speedScale = speed_scale or 1

    self.m_visibleSize = cc.Director:getInstance():getVisibleSize()
    local visible_width = self.m_visibleSize.width
    visible_width = 2048

    -- 스프라이트 생성
    local animator = MakeAnimator(res)
    animator:changeAni(animation, true)
    local sprite = animator.m_node --cc.Sprite:create(res)
    sprite:setDockPoint(cc.p(0, 0.5))
    sprite:setAnchorPoint(cc.p(0, 0.5))
    sprite:setPositionY(offset_y)
    parent:addChild(sprite)
    table.insert(self.m_tSprite, sprite)

    local sprite_size = sprite:getContentSize()
    self.m_height = sprite_size.height
    self.m_width = sprite_size.width
    
    local count = math_ceil(visible_width / self.m_interval) + 1

    for i=2, count do
        local animator = MakeAnimator(res)
        animator:changeAni(animation, true)
        local sprite = animator.m_node --cc.Sprite:create(res)
        sprite:setDockPoint(cc.p(0, 0.5))
        sprite:setAnchorPoint(cc.p(0, 0.5))
        sprite:setPositionY(offset_y)
        parent:addChild(sprite)
        table.insert(self.m_tSprite, sprite)
    end

    ScrollMapLayer_update(self, 0, 0)
end

-------------------------------------
-- function update
-------------------------------------
function ScrollMapLayer_update(self, pos_x, dt)
    local pos_x = (pos_x * self.m_speedScale) + self.m_offsetX

    local remain = math_floor(pos_x % self.m_interval)
    local start_pos = remain

    if start_pos < 0 then
        --if (start_pos + (self.m_width/2)) < 0 then
        if start_pos < 0 then
            start_pos = start_pos + self.m_interval
        end
    else
        --if (start_pos - (self.m_width/2)) > 0 then
        if start_pos > 0 then
            start_pos = start_pos - self.m_interval
        end
    end

    local visibleSize = self.m_visibleSize
    for i,v in ipairs(self.m_tSprite) do
        v:setPositionX(start_pos)
        start_pos = start_pos + self.m_interval


        -- Y로 이동
        if self.m_offsetY ~= 0 then
            local pos_y = v:getPositionY()
            pos_y = pos_y + (self.m_offsetY * dt)

            if self.m_offsetY > 0 then
                if pos_y > ((visibleSize.height/2) + (self.m_height/2)) then
                    pos_y = -((visibleSize.height/2) + (self.m_height/2))
                end
            else
                if pos_y < -((visibleSize.height/2)+(self.m_height/2)) then
                    pos_y = ((visibleSize.height/2) + (self.m_height/2))
                end
            end
            v:setPositionY(pos_y)
        end
    end
end