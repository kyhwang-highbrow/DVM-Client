-------------------------------------
-- class FpsMeter
-------------------------------------
FpsMeter = class({
        m_rootNode = 'cc.Node',

        m_startTime = '',
        m_prevTime = '',
        m_frameAverage = '',
        m_frameCnt = '',

        --------------------------------

        m_cumulativeTimeUnder50fps = '',
        m_frameCntUnder50fps = '',

        m_averageLabel = '',
        m_frameDropAverageLabel = '',


        --------------------------------
        -- GL calls
        m_minGLCalls = 'number',
        m_maxGLCalls = 'number',
        m_cumulativeGLCalls = 'number',
        m_glcallsLabel = '',
        --------------------------------

        --------------------------------
        -- PhysicsWorld
        m_physicsWorld = 'PhysicsWolrd',
        m_minPhysObj = 'number',
        m_maxPhysObj = 'number',
        m_cumulativePhysObj = 'number',
        m_physObjLabel = '',
        --------------------------------
    })

-------------------------------------
-- function init
-------------------------------------
function FpsMeter:init()
    local node = cc.Node:create()
    self.m_rootNode = node
    g_currScene.m_scene:addChild(node, 10000)
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))

    node:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    self.m_startTime = socket.gettime()
    self.m_prevTime = self.m_startTime
    self.m_frameCnt = 0

    self.m_cumulativeTimeUnder50fps = 0
    self.m_frameCntUnder50fps = 0






    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 20, 1, cc.size(450, 100), 1, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(0, 10)
    node:addChild(label)
    self.m_averageLabel = label

    --[[
    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 20, 1, cc.size(450, 100), 1, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(0, -10)
    node:addChild(label)
    self.m_frameDropAverageLabel = label
    --]]

    -- GL calls
    self:init_GLCalls()
end

-------------------------------------
-- function update
-------------------------------------
function FpsMeter:update(dt)
    local curr_time = socket.gettime()
    local dt = (curr_time - self.m_prevTime)
    self.m_prevTime = curr_time
    --cclog(dt)
    self.m_frameCnt = (self.m_frameCnt + 1)
    local fps = self.m_frameCnt / (curr_time - self.m_startTime)
    --cclog('fps : ' .. fps)
    local str = string.format('fps : %d, average : %d', math_floor(1/dt), math_floor(fps))
    self.m_averageLabel:setString(str)


    --[[
    -- 45분의 1초
    if (0.02222222222222222222222222222222 <= dt) and (dt <= 0.05) then
        self.m_cumulativeTimeUnder50fps = (self.m_cumulativeTimeUnder50fps + dt)
        self.m_frameCntUnder50fps = self.m_frameCntUnder50fps + 1

        local fps = self.m_frameCntUnder50fps / self.m_cumulativeTimeUnder50fps
        --cclog('fps : ' .. fps)
        self.m_frameDropAverageLabel:setString('프레임 저하 시 fps : ' .. math_floor(fps))
    end
    --]]

    -- GL calls
    self:update_GLCalls(dt)

    -- PhysicsWorld
    self:update_physWolrd(dt)
end

-------------------------------------
-- function init_GLCalls
-------------------------------------
function FpsMeter:init_GLCalls()
    self.m_minGLCalls = nil
    self.m_maxGLCalls = 0
    self.m_cumulativeGLCalls = 0

    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 20, 1, cc.size(450, 100), 1, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(0, -30)
    self.m_rootNode:addChild(label)
    self.m_glcallsLabel = label
end

-------------------------------------
-- function update_GLCalls
-------------------------------------
function FpsMeter:update_GLCalls(dt)
    local drawnBatches = cc.Director:getInstance():getDrawnBatches()

    if (self.m_minGLCalls == nil) then
        self.m_minGLCalls = drawnBatches
    end

    self.m_maxGLCalls = math_max(self.m_maxGLCalls, drawnBatches)

    self.m_cumulativeGLCalls = (self.m_cumulativeGLCalls + drawnBatches)

    local average = math_floor(self.m_cumulativeGLCalls / self.m_frameCnt)

    local str = string.format('GL calls : %d, average : %d, min : %d, max : %d', drawnBatches, average, self.m_minGLCalls, self.m_maxGLCalls)
    self.m_glcallsLabel:setString(str)
end

-------------------------------------
-- function init_physWolrd
-------------------------------------
function FpsMeter:init_physWolrd(physics_world)
    self.m_physicsWorld = physics_world
    self.m_minPhysObj = nil
    self.m_maxPhysObj = 0
    self.m_cumulativePhysObj = 0
    
    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 20, 1, cc.size(450, 100), 1, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(0, -70)
    self.m_rootNode:addChild(label)
    self.m_physObjLabel = label
end

-------------------------------------
-- function update_physWolrd
-------------------------------------
function FpsMeter:update_physWolrd(dt)
    if (not self.m_physicsWorld) then
        return
    end

    local total_obj_cnt = 0
    local group_obj_cnt = 0
    for group_name,l_object in pairs(self.m_physicsWorld.m_group) do
        group_obj_cnt = #l_object
        total_obj_cnt = (total_obj_cnt + group_obj_cnt)
    end

    if (self.m_minPhysObj == nil) then
        self.m_minPhysObj = total_obj_cnt
    end
    
    self.m_maxPhysObj = math_max(self.m_maxPhysObj, total_obj_cnt)

    self.m_cumulativePhysObj = (self.m_cumulativePhysObj + total_obj_cnt)

    local average = math_floor(self.m_cumulativePhysObj / self.m_frameCnt)

    local str = string.format('phys obj cnt : %d, average : %d, min : %d, max : %d', total_obj_cnt, average, self.m_minPhysObj, self.m_maxPhysObj)
    self.m_physObjLabel:setString(str)
end