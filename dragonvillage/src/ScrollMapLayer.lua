-------------------------------------
-- class IScrollMapLayer
-------------------------------------
IScrollMapLayer = class({
    m_rootNode = 'cc.NodeGrid',
    m_animator = 'Animator',    -- 배경 랜더링에 필요한 Animator
    m_offsetX = 'number',       -- X위치
    m_offsetY = 'number',       -- Y위치
    m_visibleSize = 'table',    -- 화면 사이즈
    m_group = 'string',         -- ScrollMapLayer들중 특수하게 연출되어야하는 것들을 구분하기 위한 값(스크립트로 설정)
})

    -------------------------------------
    -- function init
    -------------------------------------
    function IScrollMapLayer:init(parent, tParam)
        local tParam = tParam or {}
        local res = tParam['res']
        local animation = tParam['animation']
        local scale = tParam['scale']

        self.m_offsetX = tParam['offset_x'] or 0
        self.m_offsetY = tParam['offset_y'] or 0
        self.m_cameraRate = tParam['camera_rate'] or 0
        self.m_group = tParam['group'] or ''

        self.m_visibleSize = cc.Director:getInstance():getVisibleSize()
    
        -- 루트 노드 생성     
        self.m_rootNode = cc.NodeGrid:create()
        parent:addChild(self.m_rootNode)

        -- 스프라이트 생성
        self.m_animator = MakeAnimator(res)
        self.m_animator.m_node:setDockPoint(cc.p(0.0, 0.5))
        self.m_animator.m_node:setAnchorPoint(cc.p(0.0, 0.5))
        self.m_animator.m_node:setPosition(self.m_offsetX, self.m_offsetY)
        self.m_animator.m_node:setScale(scale)
        self.m_rootNode:addChild(self.m_animator.m_node)

        if animation then
            self.m_animator:changeAni(animation, true)
        end
    end


    -------------------------------------
    -- function update
    -------------------------------------
    function IScrollMapLayer:update(dt, tParam)
    end

    -------------------------------------
    -- function doAction
    -------------------------------------
    function IScrollMapLayer:doAction(action)
        self.m_rootNode:runAction(action)
    end

    -------------------------------------
    -- function setDirecting
    -- @breif 배경 백판 연출 설정
    -------------------------------------
    function IScrollMapLayer:setDirecting(type)
    end


-------------------------------------
-- class ScrollMapLayer
-------------------------------------
ScrollMapLayer = class(IScrollMapLayer, {
        m_type = 'string',          -- 'horizontal' or 'vertical'
        m_tAnimator = 'table',      -- 배경 랜더링에 필요한 Animator 테이블
        m_interval = 'number',      -- 배경 랜더링 간격
        m_speedScale = 'number',    -- 이동 속도 배율
        m_cameraRate = 'number',
    })

    -------------------------------------
    -- function init
    -------------------------------------
    function ScrollMapLayer:init(parent, tParam)
        self.m_tAnimator = {}
        self.m_type = tParam['type']
        self.m_interval = tParam['interval'] or 960
        self.m_group = tParam['group'] or ''
        self.m_cameraRate = tParam['camera_rate'] or 0
        self.m_speedScale = tParam['speed_scale'] or 1

        local res = tParam['res']
        local animation = tParam['animation']
        local scale = tParam['scale']
    
        table.insert(self.m_tAnimator, self.m_animator)

        if self.m_type == 'horizontal' then
            self.m_animator.m_node:setPositionY(self.m_offsetY)
        elseif self.m_type == 'vertical' then
            self.m_animator.m_node:setPositionX(self.m_offsetX)
        end
        
        if self.m_interval > 0 then
            local visible_width = 2176
            local visible_height = 1600
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

        self:update(0)
    end

    -------------------------------------
    -- function update
    -------------------------------------
    function ScrollMapLayer:update(dt, tParam)
        local tParam = tParam or {}
        local totalMove = tParam['totalMove'] or 0
        local cameraX = tParam['cameraX'] or 0
        local cameraY = tParam['cameraY'] or 0
        local cameraScale = tParam['cameraScale'] or 1

        local pos = (totalMove * self.m_speedScale)
        local minValue
        local maxValue

        if self.m_type == 'horizontal' then
            pos = pos + self.m_offsetX - (self.m_cameraRate * cameraX / cameraScale)
            minValue = cameraX - (CRITERIA_RESOLUTION_X / 2)
            maxValue = cameraX + (CRITERIA_RESOLUTION_X / 2)
        elseif self.m_type == 'vertical' then
            pos = pos + self.m_offsetY - (self.m_cameraRate * cameraY / cameraScale)
            minValue = cameraY - (CRITERIA_RESOLUTION_Y / 2)
            maxValue = cameraY + (CRITERIA_RESOLUTION_Y / 2)
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
    -- function setDirecting
    -- @breif 배경 백판 연출 설정
    -------------------------------------
    function ScrollMapLayer:setDirecting(type)
        local sequence
	
	    if (type == 'nightmare') then 
		    local duration = 0.001
		    sequence = cc.Sequence:create(
			    cca.getShaky3D(3, duration),
			    cc.DelayTime:create(duration*100000)
            )
		
		    -- 별도로 암전 및 그레이스케일 효과 적용
		    for _, animator in pairs(self.m_tAnimator) do
			    animator.m_node:runAction(cca.repeatTintToMoreDark(5, 100, 100, 100))
			    animator.m_node:setCustomShader(6,0)
		    end
	    elseif (type == 'burning') then
		    local duration = 0.001
		    sequence = cc.Sequence:create(
			    cca.getShaky3D(2, duration),
			    cc.DelayTime:create(duration*100000)
            )
        end

        if sequence then
            self.m_rootNode:runAction(cc.RepeatForever:create(sequence))
	    else
		    cclog('잘못된 배경 연출 타입입니다. ' .. type)
        end
    end

-------------------------------------
-- class ScrollMapLayerFixed
-------------------------------------
ScrollMapLayerFixed = class(IScrollMapLayer, {
    m_cameraRate = 'number',
})

    -------------------------------------
    -- function init
    -------------------------------------
    function ScrollMapLayerFixed:init(parent, tParam)
        self.m_cameraRate = tParam['camera_rate'] or 0

        local is_flip = tParam['is_flip'] or false

        if is_flip then
            cclog('ScrollMapLayerFixed flip')
        end

        self.m_animator:setFlip(is_flip)
        self:update(0)
    end

    -------------------------------------
    -- function update
    -------------------------------------
    function ScrollMapLayerFixed:update(dt, tParam)
        local tParam = tParam or {}
        local cameraX = tParam['cameraX'] or 0
        local cameraY = tParam['cameraY'] or 0
        local cameraScale = tParam['cameraScale'] or 1

        local posX = self.m_offsetX - (self.m_cameraRate * cameraX / cameraScale)
        local posY = self.m_offsetY - (self.m_cameraRate * cameraY / cameraScale)
    
        self.m_animator.m_node:setPositionX(posX)
        self.m_animator.m_node:setPositionY(posY)
    end