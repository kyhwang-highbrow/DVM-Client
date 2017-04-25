-------------------------------------
-- class FpsMeter
-------------------------------------
FpsMeter = class({
        m_startTime = '',
        m_prevTime = '',
        m_frameAverage = '',
        m_frameCnt = '',

        --------------------------------

        m_cumulativeTimeUnder50fps = '',
        m_frameCntUnder50fps = '',

        m_averageLabel = '',
        m_frameDropAverageLabel = '',
    })

-------------------------------------
-- function init
-------------------------------------
function FpsMeter:init()
    local node = cc.Node:create()
    g_currScene.m_scene:addChild(node, 10000)
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))

    node:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    self.m_startTime = socket.gettime()
    self.m_prevTime = self.m_startTime
    self.m_frameCnt = 0

    self.m_cumulativeTimeUnder50fps = 0
    self.m_frameCntUnder50fps = 0






    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 20, 1, cc.size(250, 100), 0, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(0, 10)
    node:addChild(label)
    self.m_averageLabel = label

    local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 20, 1, cc.size(250, 100), 0, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(0, -10)
    node:addChild(label)
    self.m_frameDropAverageLabel = label

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
    self.m_averageLabel:setString('평균 fps : ' .. math_floor(fps))


    -- 45분의 1초
    if (0.02222222222222222222222222222222 <= dt) and (dt <= 0.05) then
        self.m_cumulativeTimeUnder50fps = (self.m_cumulativeTimeUnder50fps + dt)
        self.m_frameCntUnder50fps = self.m_frameCntUnder50fps + 1

        local fps = self.m_frameCntUnder50fps / self.m_cumulativeTimeUnder50fps
        --cclog('fps : ' .. fps)
        self.m_frameDropAverageLabel:setString('프레임 저하 시 fps : ' .. math_floor(fps))
    end
end