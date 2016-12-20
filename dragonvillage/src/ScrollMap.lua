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

        m_floatingType = 'number',
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
    eventDispather:addListener('nest_dragon_final_wave', self)
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
            local group = v['group']
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
                
                local map_layer = ScrollMapLayer(self.m_node, type, data['res'], data['animation'], interval, real_offset_x, real_offset_y, scale, speed, group)
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
        v:update(self.m_totalMove, dt, cameraX, cameraY, cameraScale)
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
    -- 이벤트별 특수한 배경 연출 처리
    if (event_name == 'nest_dragon_final_wave') then
        -- 거대용 마지막 웨이브 시작시 연출
        for i,v in ipairs(self.m_tMapLayer) do
            if v.m_group == 'nest_dragon_body' then
                local animator = v.m_tAnimator[1]
                animator:changeAni('end_wave_2', false)
                                
                v:doAction(cc.Sequence:create(
                    cc.EaseOut:create(cc.MoveTo:create(1, cc.p(-700, 0)), 2),
                    cc.EaseIn:create(cc.MoveTo:create(1.5, cc.p(4000, 0)), 2)
                ))
                
            end
        end
    end
end