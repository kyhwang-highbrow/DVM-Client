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

    -- 임시 처리
    local difficulty, chapter, stage = parseAdventureID(g_gameScene.m_stageID)
    if chapter == 2 then
        self:setFloating(2)
    else
        self:setFloating(1)
    end
end

-------------------------------------
-- function setFloating
-- @breif 배경 백판 연출 설정
-------------------------------------
function ScrollMap:setFloating(type)
    self.m_floatingType = type

    local sequence

    if self.m_floatingType == 1 then
        -- 위아래 흔들림
        sequence = cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(0.75, cc.p(0, MAP_FLOATING_Y_SCOPE)), 2),
            cc.EaseIn:create(cc.MoveTo:create(0.75, cc.p(0, 0)), 2),
            cc.EaseOut:create(cc.MoveTo:create(0.75, cc.p(0, -MAP_FLOATING_Y_SCOPE)), 2),
            cc.EaseIn:create(cc.MoveTo:create(0.75, cc.p(0, 0)), 2)
        )
        

    elseif self.m_floatingType == 2 then
        -- 회전 쏠림
        local move_action = cc.Sequence:create(
            cc.EaseOut:create(cc.MoveTo:create(0.75, cc.p(0, MAP_FLOATING_Y_SCOPE)), 2),
            cc.EaseIn:create(cc.MoveTo:create(0.75, cc.p(0, 0)), 2),
            cc.EaseOut:create(cc.MoveTo:create(0.75, cc.p(0, -MAP_FLOATING_Y_SCOPE)), 2),
            cc.EaseIn:create(cc.MoveTo:create(0.75, cc.p(0, 0)), 2)
        )

        local rotate_action = cc.Sequence:create(
            cc.RotateTo:create(2.5, MAP_FLOATING_ROTATE_SCOPE),
            cc.RotateTo:create(2.5, -MAP_FLOATING_ROTATE_SCOPE)
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
        for _,v in ipairs(script['layer']) do

            local total_width = 0
            for i,data in ipairs(v['list']) do
                total_width = total_width + data['width']
            end

            local speed = v['speed']
            local offset_x = 0
            for i,data in ipairs(v['list']) do
                local map_layer = ScrollMapLayer(self.m_node, data['res'], data['animation'], total_width, offset_x, 0, 0, speed)
                table.insert(self.m_tMapLayer, map_layer)
                offset_x = offset_x + data['width']
            end
        end
        return
    end

    -- 일반적인 룰로 생성
    if res then
        -- 원경
        local map_layer = ScrollMapLayer(self.m_node, 'res/test/bg/' .. res .. '_1_a.png', 1280*2, 0, 0, 0, 0.2)
        table.insert(self.m_tMapLayer, map_layer)

        local map_layer = ScrollMapLayer(self.m_node, 'res/test/bg/' .. res .. '_1_b.png', 1280*2, 1280, 0, 0, 0.2)
        table.insert(self.m_tMapLayer, map_layer)


        -- 원경2
        local map_layer2 = ScrollMapLayer(self.m_node, 'res/test/bg/' .. res .. '_2_a.png', 1280*2, 0, 0, 0, 0.5)
        table.insert(self.m_tMapLayer, map_layer2)

        local map_layer2 = ScrollMapLayer(self.m_node, 'res/test/bg/' .. res .. '_2_b.png', 1280*2, 1280, 0, 0, 0.51)
        table.insert(self.m_tMapLayer, map_layer2)

        -- 원경3
        local map_layer3 = ScrollMapLayer(self.m_node, 'res/test/bg/' .. res .. '_3_a.png', 1280*2, 0, 0, 0, 0.8)
        table.insert(self.m_tMapLayer, map_layer3)

        local map_layer3 = ScrollMapLayer(self.m_node, 'res/test/bg/' .. res .. '_3_b.png', 1280*2, 1280, 0, 0, 0.8)
        table.insert(self.m_tMapLayer, map_layer3)
        return
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

    for i,v in ipairs(self.m_tMapLayer) do
        ScrollMapLayer_update(v, self.m_totalMove, dt)
    end

    return self.m_totalMove
end

-------------------------------------
-- function setSpeed
-------------------------------------
function ScrollMap:setSpeed(speed)
    self.m_speed = speed
end