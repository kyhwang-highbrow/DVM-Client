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

        m_bPause = 'boolean',

        -- 추가 이동 처리를 위한 것들(설정되어있을 경우 speed가 0일때 이동시킴)
        m_bUseAddMove = 'boolean',
        m_addMoveDestTime = 'number',
        m_addMoveDestDistance = 'number',
        m_addMoveCurTime = 'number',
        m_addMoveCurDistance = 'number',
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
    self.m_bPause = false

    self.m_bUseAddMove = false
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
    if (not g_constant) then return end

    self.m_bgDirectingType = directing_type

    local time = getInGameConstant("MAP_FLOATING_TIME") / 4
    local yScope = getInGameConstant("MAP_FLOATING_Y_SCOPE")
    local sequence
	
	-- [FLOATING]
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
        local rotateTime = getInGameConstant("MAP_FLOATING_ROTATE_TIME") / 2
        local rotateScope = getInGameConstant("MAP_FLOATING_ROTATE_SCOPE")

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

    elseif (self.m_bgDirectingType == 'floating_colosseum') then
        -- 위아래 흔들림
        sequence = cc.Sequence:create(
            cc.EaseInOut:create(cc.MoveTo:create(time * 2, cc.p(0, yScope * 2)), 2),
            cc.EaseInOut:create(cc.MoveTo:create(time * 2, cc.p(0, 0)), 2)
        )

    -- [콜로세움 광폭화 연출용]
    elseif (string.find(self.m_bgDirectingType, 'colosseum_fury')) then
        local level = tonumber(string.match(self.m_bgDirectingType, '%d'))
        
        if (level > 0) then
            local map_layer = self.m_tMapLayer[1]
		    map_layer.m_animator:changeAni('appear_' .. level, false)
            map_layer.m_animator:addAniHandler(function()
                map_layer.m_animator:changeAni('idle_' .. level, true)
            end)
		end

        sequence = cc.Sequence:create(
            cc.MoveTo:create(0.1, cc.p(-5, 0)),
            cc.MoveTo:create(0.2, cc.p(5, 0)),
            cc.MoveTo:create(0.1, cc.p(0, 0))
        )

        self.m_parentNode:setPosition(0, 0)
        self.m_parentNode:runAction(cc.Repeat:create(sequence, 5))

        return

	-- [DARKNIX 보스용]
    elseif (string.find(self.m_bgDirectingType, 'darknix')) then
        local effect_type = string.match(self.m_bgDirectingType, '%d')
		local is_low_mode = isLowEndMode()

		-- [SHAKY + RIPPLE]
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

		-- [SHAKY]
        elseif (string.find(self.m_bgDirectingType, 'shaky')) then
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
                local value = (3 - effect_type) * 80
                map_layer:setColor(cc.c3b(255, value, value))
			end
        end
        
	-- [GRAY SCALE]
	elseif (string.find(self.m_bgDirectingType, 'nightmare')) then 
		local effect_type = string.match(self.m_bgDirectingType, '%d')
		local is_low_mode = isLowEndMode()

		-- 추가 효과
		-- [SHAKY]
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

		-- [RIPPLE]
		elseif (string.find(self.m_bgDirectingType, 'ripple')) then 
			-- ripple3d + tintto + gray shader 
			-- 저사양 모드에선 gray shader 만 사용
			local duration = 10
			if (not is_low_mode) then 
				sequence = cc.Sequence:create(
					cca.getRipple3D(effect_type , duration)
				)
			end
		end

		-- 별도로 암전 효과 및 그레이스케일 적용
		for _, map_layer in pairs(self.m_tMapLayer) do
            if (not is_low_mode) then 
                map_layer:doActionFromAnimator(cca.repeatTintToMoreDark(5, 100, 100, 100))
            end
            map_layer:setCustomShader(6,0)
		end

	-- [SHAKY]
	elseif (string.find(self.m_bgDirectingType, 'shaky')) then
		local effect_type = string.match(self.m_bgDirectingType, '%d')
		local duration = 0.001
		sequence = cc.Sequence:create(
			cca.getShaky3D(effect_type, duration),
			cc.DelayTime:create(duration*100000)
        )

	-- [RIPPLE]
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
function ScrollMap:setBg(res, attr)
    -- 초기화
    self.m_node:removeAllChildren();
    self.m_tMapLayer = {}

    -- 스크립트로 맵 생성
    local script = TABLE:loadMapScript(res)
    if not script then return end
    
    for _, v in ipairs(script['layer']) do
        local type = v['type'] or 'horizontal'
        local speed = v['speed'] or 0                   -- 이동 속도 배율
        local camera_app_rate_x = v['camera_app_rate_x'] or 1 -- 카메라 적용 배율
        local camera_app_rate_y = v['camera_app_rate_y'] or 1
        local camera_app_rate_scale = v['camera_app_rate_scale'] or 1
        local group = v['group']
        local visible = v['visible']

        local bFixedLayer = (speed == 0) -- 속도값이 0일 경우 반복되지 않는 맵으로 간주

        if (bFixedLayer) then
            for i, data in ipairs(v['list']) do
                local res = data['res']
                -- 아래 정규표현식은 기존 리소스명에 저사양모드인 경우는 low_를 붙여주는 코드
                -- ex) res/bg/sky_temple/sky_temple.vrp -> res/bg/low_sky_temple/low_sky_temple.vrp
                local res_low = string.gsub(data['res'], 'res/bg/([%w|_]+)/([%w|_]+).vrp', 'res/bg/low_%1/low_%2.vrp')

                local real_offset_x = (data['pos_x'] or 0)
                local real_offset_y = (data['pos_y'] or 0)
                local animation = data['animation'] or 'idle'
                local scale = (data['scale'] or 1)
                local bFlip = (data['flip'] or false)
                local bPause = (data['pause'] or false)

                if (attr) then
                    res = string.gsub(res, '@', attr)
                    res_low = string.gsub(res_low, '@', attr)
                    animation = string.gsub(animation, '@', attr)
                end
                if (isLowEndMode()) then
                    res = res_low
                end
                self:makeLayer({
                    res = res,
                    animation = animation,
                    offset_x = real_offset_x,
                    offset_y = real_offset_y,
                    scale = scale,
                    group = group,
                    camera_app_rate_x = camera_app_rate_x,
                    camera_app_rate_y = camera_app_rate_y,
                    camera_app_rate_scale = camera_app_rate_scale,
                    is_flip = bFlip,
                    is_pause = bPause,
                    is_visible = visible
                }, true)
            end

        else
            local offset_x = 0
            local offset_y = 0
            local interval = 0

            -- 반복되서 나오는 맵의 경우 반복 주기 크기를 계산
            for i, data in ipairs(v['list']) do
                local width = data['width'] or 0
                local height = data['height'] or 0

                if (type == 'horizontal') then
                    interval = interval + width
                elseif (type == 'vertical') then
                    interval = interval + height
                end
            end
            
            for i, data in ipairs(v['list']) do
                local res = data['res']
                -- 아래 정규표현식은 기존 리소스명에 저사양모드인 경우는 low_를 붙여주는 코드
                -- ex) res/bg/sky_temple/sky_temple.vrp -> res/bg/low_sky_temple/low_sky_temple.vrp
                local res_low = string.gsub(data['res'], 'res/bg/([%w|_]+)/([%w|_]+).vrp', 'res/bg/low_%1/low_%2.vrp')
                local animation = data['animation'] or 'idle'
                
                if (attr) then
                    res = string.gsub(res, '@', attr)
                    res_low = string.gsub(res_low, '@', attr)
                    animation = string.gsub(animation, '@', attr)
                end
                if (isLowEndMode() and not string.find(res, 'low_')) then
                    res = res_low
                end
                local real_offset_x = (data['pos_x'] or 0)
                local real_offset_y = (data['pos_y'] or 0)
                local scale = (data['scale'] or 1)
                local width = data['width'] or 0
                local height = data['height'] or 0
                
                if type == 'horizontal' then
                    real_offset_x = real_offset_x + offset_x
                elseif type == 'vertical' then
                    real_offset_y = real_offset_y + offset_y
                end

                self:makeLayer({
                    type = type,
                    res = res,
                    animation = animation,
                    interval = interval,
                    offset_x = real_offset_x,
                    offset_y = real_offset_y,
                    scale = scale,
                    group = group,
                    speed_scale = speed,
                    directing = v['directing'],
                    is_visible = visible
                }, false)
                    
                if type == 'horizontal' then
                    offset_x = offset_x + width
                elseif type == 'vertical' then
                    offset_y = offset_y + height
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
-- function makeLayer
-------------------------------------
function ScrollMap:makeLayer(tParam, bFixedLayer)
    local map_layer

    if bFixedLayer then
        map_layer = ScrollMapLayerNoRepeat(self.m_node, tParam)
    else
        map_layer = ScrollMapLayer(self.m_node, tParam)
    end

    if (tParam['is_visible'] ~= nil) then
        map_layer:setVisible(tParam['is_visible'])
    end
    

    table.insert(self.m_tMapLayer, map_layer)

	return map_layer
end

-------------------------------------
-- function update
-- @param dt
-------------------------------------
function ScrollMap:update(dt)
    if (self.m_bPause) then return self.m_totalMove end

    local distance = 0

    if (self.m_speed ~= 0) then
        distance = self.m_speed * dt
    elseif (self.m_bUseAddMove) then
        distance = self:getAddMoveDistance(dt)
    end

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
-- function setDecel
-------------------------------------
function ScrollMap:setDecel(decel)
    self.m_decel = decel
end

-------------------------------------
-- function pause
-------------------------------------
function ScrollMap:pause()
    self.m_bPause = true
    
    local function f_pause(node)
        node:pause()
    end
	
    doAllChildren(self.m_parentNode, f_pause)
end

-------------------------------------
-- function resume
-------------------------------------
function ScrollMap:resume()
    self.m_bPause = false

    local function f_resume(node)
        node:resume()
    end

    doAllChildren(self.m_parentNode, f_resume)
end

-------------------------------------
-- function onEvent
-------------------------------------
function ScrollMap:onEvent(event_name, t_event, ...)
    local arg = {...}
    local cbFunction = arg[1] or function() end

    -- 이벤트별 특수한 배경 연출 처리
    if (event_name == 'nest_dragon_start') then
        -- 거대용 던전 시작시 연출
        for i, v in ipairs(self.m_tMapLayer) do
            if (v.m_group == 'nest_dragon_body') then
                v.m_rootNode:setPosition(-7000, 0)

                local animator = v.m_animator
                animator:changeAni('endwave_2', false)
                
                v:doAction(cc.Sequence:create(
                    cc.EaseIn:create(cc.MoveTo:create(1.5, cc.p(0, 0)), 2),
                    cc.CallFunc:create(function()
                        animator:changeAni('idle', true)
                        cbFunction()
                    end)
                ))
                
            end
        end

    elseif (event_name == 'nest_dragon_final_wave') then
        -- 거대용 마지막 웨이브 시작시 연출
        for i, v in ipairs(self.m_tMapLayer) do
            if (v.m_group == 'nest_dragon_body') then
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
            if (v.m_group == 'nest_tree') then
                --local animator = v.m_animator
                --animator:setVisible(false)
                v:setVisible(false)
            end
        end

    elseif (event_name == 'nest_tree_die') then
        -- 거목 마지막 웨이브 클리어시 연출
        for i, v in ipairs(self.m_tMapLayer) do
            if (v.m_group == 'nest_tree_bg') then
                local xPos = v.m_rootNode:getPositionX()

                v:doAction(cc.Sequence:create(
                    cc.DelayTime:create(1),
                    cc.MoveTo:create(3, cc.p(xPos, -1500))
                ))
            end
        end
    end
end

-------------------------------------
-- function setAddMove
-------------------------------------
function ScrollMap:setAddMove(distance, time)
    self.m_bUseAddMove = true

    self.m_addMoveDestTime = time
    self.m_addMoveDestDistance = distance
    self.m_addMoveCurTime = 0
    self.m_addMoveCurDistance = 0
end

-------------------------------------
-- function getAddMoveDistance
-------------------------------------
function ScrollMap:getAddMoveDistance(dt)
    self.m_addMoveCurTime = self.m_addMoveCurTime + dt

    local distance = 0

    if (self.m_addMoveCurTime > self.m_addMoveDestTime) then
        self.m_bUseAddMove = false

        local prev_distance = self.m_addMoveCurDistance

        self.m_addMoveCurDistance = self.m_addMoveDestDistance
        distance = self.m_addMoveDestDistance - prev_distance
        
    else
        local prev_distance = self.m_addMoveCurDistance

        self.m_addMoveCurDistance = (self.m_addMoveCurTime / self.m_addMoveDestTime) * self.m_addMoveDestDistance
        distance = self.m_addMoveCurDistance - prev_distance
    end

    return distance
end