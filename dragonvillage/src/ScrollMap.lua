-------------------------------------
-- class ScrollMap
-------------------------------------
ScrollMap = class(MapManager, IEventListener:getCloneTable(), {
        m_node = '',
        m_cameraNode = '',

        m_speed = '',
        m_totalMove = '',
        m_tMapLayer = '',

        m_colorR = 'number',
        m_colorG = 'number',
        m_colorB = 'number',

        m_colorScale = '',

        m_bgDirectingType = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ScrollMap:init(node)
    self.m_node = cc.NodeGrid:create()
    self.m_parentNode:addChild(self.m_node)
    self.m_speed = 0
    self.m_totalMove = 0
    self.m_tMapLayer = {}

    self.m_colorR = 255
    self.m_colorG = 255
    self.m_colorB = 255

    self.m_colorScale = 100

    self.m_bgDirectingType = 'floating_1'
end

-------------------------------------
-- function bindCameraNode
-- @breif 배경 백판 연출 설정
-------------------------------------
function ScrollMap:bindCameraNode(node)
    self.m_cameraNode = node
end

-------------------------------------
-- function bindEventDispatcher
-------------------------------------
function ScrollMap:bindEventDispatcher(eventDispather)
    -- 맵 연출 이벤트 등록
    eventDispather:addListener('nest_dragon_start', self)
    eventDispather:addListener('nest_dragon_final_wave', self)
    eventDispather:addListener('nest_tree_appear', self)
    eventDispather:addListener('nest_tree_die', self)
end

-------------------------------------
-- function setDirecting
-- @breif 배경 백판 연출 설정
-------------------------------------
function ScrollMap:setDirecting(directing_type)
    self.m_bgDirectingType = directing_type

    local time = getInGameConstant(MAP_FLOATING_TIME) / 4
    local yScope = getInGameConstant(MAP_FLOATING_Y_SCOPE)
    local sequence
	
    if (self.m_bgDirectingType == 'floating_1') then
        -- 위아래 흔들림
        sequence = cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(time, cc.p(0, yScope)), 2),
            cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 0)), 2),
            cc.EaseOut:create(cc.MoveTo:create(time, cc.p(0, -yScope)), 2),
            cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 0)), 2)
        )

    elseif (self.m_bgDirectingType == 'floating_2') then
        -- 회전 쏠림
        local rotateTime = getInGameConstant(MAP_FLOATING_ROTATE_TIME) / 2
        local rotateScope = getInGameConstant(MAP_FLOATING_ROTATE_SCOPE)

        local move_action = cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(time, cc.p(0, yScope)), 2),
            cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 0)), 2),
            cc.EaseOut:create(cc.MoveTo:create(time, cc.p(0, -yScope)), 2),
            cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 0)), 2)
        )

        local rotate_action = cc.Sequence:create(
            cc.RotateTo:create(rotateTime, rotateScope),
            cc.RotateTo:create(rotateTime, -rotateScope)
        )
        
        sequence = cc.Spawn:create(move_action, rotate_action)

    elseif (string.find(self.m_bgDirectingType, 'darknix')) then
        cclog('darknix')
        local effect_type = string.match(self.m_bgDirectingType, '%d')
		local is_low_mode = isLowEndMode()

        if (string.find(self.m_bgDirectingType, 'shakyripple')) then 
            sequence = cc.Spawn:create(
                cc.Sequence:create(
					cca.getShaky3D(effect_type, 0.1),
					cc.DelayTime:create(0.1)
				),
                cc.Sequence:create(
					cca.getRipple3D(effect_type, 10)
				)
            )

        elseif (string.find(self.m_bgDirectingType, 'shaky')) then
            cclog('darknix shaky')
			-- shaky3d + tintto + gray shader 
			-- 저사양 모드에선 gray shader 만 사용
			local duration = 0.001
			if (not is_low_mode) then 
				sequence = cc.Sequence:create(
					cca.getShaky3D(effect_type, duration),
					cc.DelayTime:create(duration*100)
				)
			end

			-- 별도로 배경 색 전환
			for _, map_layer in pairs(self.m_tMapLayer) do
				for _, animator in pairs(map_layer.m_tAnimator) do
					local value = (3 - effect_type) * 80
                    animator.m_node:setColor(cc.c3b(255, value, value))
					
				end
			end
        end
        

	elseif (string.find(self.m_bgDirectingType, 'nightmare')) then 
		local effect_type = string.match(self.m_bgDirectingType, '%d')
		local is_low_mode = isLowEndMode()

        if (string.find(self.m_bgDirectingType, 'shaky')) then 
			-- shaky3d + tintto + gray shader 
			-- 저사양 모드에선 gray shader 만 사용
			local duration = 0.001
			if (not is_low_mode) then 
				sequence = cc.Sequence:create(
					cca.getShaky3D(effect_type, duration),
					cc.DelayTime:create(duration*100)
				)
			end

			-- 별도로 암전 효과 및 그레이스케일 적용
			for _, map_layer in pairs(self.m_tMapLayer) do
				for _, animator in pairs(map_layer.m_tAnimator) do
					if (not is_low_mode) then 
						animator.m_node:runAction(cca.repeatTintToMoreDark(5, 100, 100, 100))
					end
					animator.m_node:setCustomShader(6,0)
				end
			end

		elseif (string.find(self.m_bgDirectingType, 'ripple')) then 
			-- ripple3d + tintto + gray shader 
			-- 저사양 모드에선 gray shader 만 사용
			local duration = 10
			if (not is_low_mode) then 
				sequence = cc.Sequence:create(
					cca.getRipple3D(effect_type , duration)
				)
			end

			-- 별도로 암전 효과 및 그레이스케일 적용
			for _, map_layer in pairs(self.m_tMapLayer) do
				for _, animator in pairs(map_layer.m_tAnimator) do
					if (not is_low_mode) then 
						animator.m_node:runAction(cca.repeatTintToMoreDark(5, 100, 100, 100))
					end
					animator.m_node:setCustomShader(6,0)
				end
			end
		end
	elseif (string.find(self.m_bgDirectingType, 'shaky')) then
		local effect_type = string.match(self.m_bgDirectingType, '%d')
		local duration = 0.001
		sequence = cc.Sequence:create(
			cca.getShaky3D(effect_type, duration),
			cc.DelayTime:create(duration*100000)
        )


	elseif (string.find(self.m_bgDirectingType , 'ripple')) then
		local effect_type = string.match(self.m_bgDirectingType, '%d')
		local duration = 10
		sequence = cc.Sequence:create(
			cca.getRipple3D(effect_type, duration)
        )

    end

    if sequence then
        self.m_node:runAction(cc.RepeatForever:create(sequence))
	else
		cclog('잘못된 배경 연출 타입입니다. ' .. self.m_bgDirectingType)
    end
end

-------------------------------------
-- function setBg
-------------------------------------
function ScrollMap:setBg(res)

    -- 초기화
    self.m_node:removeAllChildren();
    self.m_tMapLayer = {}

    -- 스크립트로 맵 생성
    local script = TABLE:loadJsonTable(res)
    if not script then return end
    
    for _, v in ipairs(script['layer']) do
        local type = v['type'] or 'horizontal'
        local speed = v['speed'] or 0                   -- 이동 속도 배율
        local camera_app_rate_x = v['camera_app_rate_x'] or 1 -- 카메라 적용 배율
        local camera_app_rate_y = v['camera_app_rate_y'] or 1
        local camera_app_rate_scale = v['camera_app_rate_scale'] or 1
        local group = v['group']

        local bFixedLayer = (speed == 0) -- 속도값이 0일 경우 반복되지 않는 맵으로 간주

        if (bFixedLayer) then
            for i, data in ipairs(v['list']) do
                local real_offset_x = (data['pos_x'] or 0)
                local real_offset_y = (data['pos_y'] or 0)
                local scale = (data['scale'] or 1)
                local bFlip = (data['flip'] or false)
                local bPause = (data['pause'] or false)

                self:makeLayer({
                    res = data['res'],
                    animation = data['animation'],
                    offset_x = real_offset_x,
                    offset_y = real_offset_y,
                    scale = scale,
                    group = group,
                    camera_app_rate_x = camera_app_rate_x,
                    camera_app_rate_y = camera_app_rate_y,
                    camera_app_rate_scale = camera_app_rate_scale,
                    is_flip = bFlip,
                    is_pause = bPause
                }, true)
            end

        else
            local offset_x = 0
            local offset_y = 0
            local interval = 0

            -- 반복되서 나오는 맵의 경우 반복 주기 크기를 계산
            for i, data in ipairs(v['list']) do
                if (type == 'horizontal') then
                    interval = interval + (data['width'] or 0)
                elseif (type == 'vertical') then
                    interval = interval + (data['height'] or 0)
                end
            end
            
            for i, data in ipairs(v['list']) do
                local real_offset_x = (data['pos_x'] or 0)
                local real_offset_y = (data['pos_y'] or 0)
                local scale = (data['scale'] or 1)
                
                if type == 'horizontal' then
                    real_offset_x = real_offset_x + offset_x
                elseif type == 'vertical' then
                    real_offset_y = real_offset_y + offset_y
                end

                self:makeLayer({
                    type = type,
                    res = data['res'],
                    animation = data['animation'],
                    interval = interval,
                    offset_x = real_offset_x,
                    offset_y = real_offset_y,
                    scale = scale,
                    group = group,
                    speed_scale = speed,
                    directing = v['directing']
                }, false)
                    
                if type == 'horizontal' then
                    offset_x = offset_x + (data['width'] or 0)
                elseif type == 'vertical' then
                    offset_y = offset_y + (data['height'] or 0)
                end
            end
        end
    end

	-- 연출 처리
	if (script['directing']) then 
		self:setDirecting(script['directing'])
	end
end

-------------------------------------
-- function setBg
-------------------------------------
function ScrollMap:makeLayer(tParam, bFixedLayer)
    local map_layer

    if bFixedLayer then
        map_layer = ScrollMapLayerFixed(self.m_node, tParam)

    else
        map_layer = ScrollMapLayer(self.m_node, tParam)
    end

    table.insert(self.m_tMapLayer, map_layer)

	return map_layer
end

-------------------------------------
-- function update
-- @param dt
-------------------------------------
function ScrollMap:update(dt)
    local distance = 0
    distance = self.m_speed * dt

    self.m_totalMove = self.m_totalMove + distance

    -- 각 레이어들이 현재의 카메라 위치를 기준으로 루핑되도록 함.
    local cameraX, cameraY = 0, 0
    local cameraScale = 1
    if self.m_cameraNode then
        cameraX, cameraY = self.m_cameraNode:getPosition()
        cameraScale = self.m_cameraNode:getScale()
    end
    
    for i,v in ipairs(self.m_tMapLayer) do
        v:update(dt, {
            totalMove = self.m_totalMove,
            cameraX = cameraX,
            cameraY = cameraY,
            cameraScale = cameraScale
        })
    end

    return self.m_totalMove
end

-------------------------------------
-- function setSpeed
-------------------------------------
function ScrollMap:setSpeed(speed)
    self.m_speed = speed
end

-------------------------------------
-- function onEvent
-------------------------------------
function ScrollMap:onEvent(event_name, ...)
    local arg = {...}
    local cbFunction = arg[1] or function() end

    -- 이벤트별 특수한 배경 연출 처리
    if (event_name == 'nest_dragon_start') then
        -- 거대용 던전 시작시 연출
        for i, v in ipairs(self.m_tMapLayer) do
            if v.m_group == 'nest_dragon_body' then
                v.m_rootNode:setPosition(-7000, 0)
                
                v:doAction(cc.Sequence:create(
                    cc.EaseIn:create(cc.MoveTo:create(1.5, cc.p(0, 0)), 2),
                    cc.CallFunc:create(cbFunction)
                ))
                
            end
        end

    elseif (event_name == 'nest_dragon_final_wave') then
        -- 거대용 마지막 웨이브 시작시 연출
        for i, v in ipairs(self.m_tMapLayer) do
            if v.m_group == 'nest_dragon_body' then
                local animator = v.m_animator
                animator:changeAni('endwave_2', false)
                                                
                v:doAction(cc.Sequence:create(
                    cc.EaseOut:create(cc.MoveTo:create(1, cc.p(-700, 0)), 2),
                    cc.EaseIn:create(cc.MoveTo:create(1.5, cc.p(4000, 0)), 2),
                    cc.CallFunc:create(cbFunction)
                ))
                
            end
        end

    elseif (event_name == 'nest_tree_appear') then
        -- 거목 마지막 웨이브 시작시 연출
        for i, v in ipairs(self.m_tMapLayer) do
            if v.m_group == 'nest_tree' then
                local animator = v.m_animator
                animator:setVisible(false)
            end
        end

    elseif (event_name == 'nest_tree_die') then
        -- 거목 마지막 웨이브 시작시 연출
        for i, v in ipairs(self.m_tMapLayer) do
            if v.m_group == 'nest_tree_bg' then
                local xPos = v.m_rootNode:getPositionX()

                v:doAction(cc.Sequence:create(
                    cc.DelayTime:create(1),
                    cc.MoveTo:create(3, cc.p(xPos, -1500))
                ))
            end
        end

    end
end