-------------------------------------
-- class ScrollMap
-------------------------------------
ScrollMap = class(MapManager, {
        m_node = '',
        m_speed = '',
        m_totalMove = '',
        m_tMapLayer = '',

        m_colorR = 'number',
        m_colorG = 'number',
        m_colorB = 'number',

        m_colorScale = '',

        m_floatingType = 'number',

        m_fGetCameraPosition = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function ScrollMap:init(node)
    self.m_node = cc.Node:create()
    self.m_parentNode:addChild(self.m_node)
    self.m_speed = 0
    self.m_totalMove = 0
    self.m_tMapLayer = {}

    self.m_colorR = 255
    self.m_colorG = 255
    self.m_colorB = 255

    self.m_colorScale = 100

    self.m_floatingType = 0

    self.m_fGetCameraPosition = nil
end

-------------------------------------
-- function setFloating
-- @breif 배경 백판 연출 설정
-------------------------------------
function ScrollMap:setFloating(type)
    self.m_floatingType = type

    local time = MAP_FLOATING_TIME / 4
    local sequence

    if self.m_floatingType == 1 then
        -- 위아래 흔들림
        sequence = cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(time, cc.p(0, MAP_FLOATING_Y_SCOPE)), 2),
            cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 0)), 2),
            cc.EaseOut:create(cc.MoveTo:create(time, cc.p(0, -MAP_FLOATING_Y_SCOPE)), 2),
            cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 0)), 2)
        )
        

    elseif self.m_floatingType == 2 then
        -- 회전 쏠림
        local move_action = cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(time, cc.p(0, MAP_FLOATING_Y_SCOPE)), 2),
            cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 0)), 2),
            cc.EaseOut:create(cc.MoveTo:create(time, cc.p(0, -MAP_FLOATING_Y_SCOPE)), 2),
            cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 0)), 2)
        )

        local rotate_time = MAP_FLOATING_ROTATE_TIME / 2
        local rotate_action = cc.Sequence:create(
            cc.RotateTo:create(rotate_time, MAP_FLOATING_ROTATE_SCOPE),
            cc.RotateTo:create(rotate_time, -MAP_FLOATING_ROTATE_SCOPE)
        )
        
        sequence = cc.Spawn:create(move_action, rotate_action)
    end

    if sequence then
        self.m_node:runAction(cc.RepeatForever:create(sequence))
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
    if script then        
        for _, v in ipairs(script['layer']) do
            local type = v['type'] or 'horizontal'
            local speed = v['speed']
            local option = v['option']
            local offset_x = 0
            local offset_y = 0
            local interval = 0

            -- 속도값이 0일 경우 반복되지 않는 맵으로 간주
            if speed ~= 0 then
                for i, data in ipairs(v['list']) do
                    if type == 'horizontal' then
                        interval = interval + (data['width'] or 0)
                    elseif type == 'vertical' then
                        interval = interval + (data['height'] or 0)
                    end
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
                
                local map_layer = ScrollMapLayer(self.m_node, type, data['res'], data['animation'], interval, real_offset_x, real_offset_y, scale, speed, option)
                table.insert(self.m_tMapLayer, map_layer)

                if type == 'horizontal' then
                    offset_x = offset_x + (data['width'] or 0)
                elseif type == 'vertical' then
                    offset_y = offset_y + (data['height'] or 0)
                end
            end
        end
    end
end

-------------------------------------
-- function setFuncGetCameraPosition
-------------------------------------
function ScrollMap:setFuncGetCameraPosition(func)
    self.m_fGetCameraPosition = func
end

-------------------------------------
-- function update
-- @param dt
-------------------------------------
function ScrollMap:update(dt)
    local distance = 0
    distance = self.m_speed * dt

    self.m_totalMove = self.m_totalMove + distance

    local cameraX, cameraY = 0, 0
    if self.m_fGetCameraPosition then
        cameraX, cameraY = self.m_fGetCameraPosition()
    end

    for i,v in ipairs(self.m_tMapLayer) do
        ScrollMapLayer_update(v, self.m_totalMove, dt, cameraX, cameraY)
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
-- function doOption
-------------------------------------
function ScrollMap:doOption(option)
    for i,v in ipairs(self.m_tMapLayer) do
        if v.m_option == option then
            local cameraX, cameraY = 0, 0
            if self.m_fGetCameraPosition then
                cameraX, cameraY = self.m_fGetCameraPosition()
            end

            --local distance = CRITERIA_RESOLUTION_X - cameraX
            local distance = 3600
            local action = cc.MoveTo:create(1.5, cc.p(distance, 0))
            
            ScrollMapLayer_doAction(v, action)
        end
    end
end