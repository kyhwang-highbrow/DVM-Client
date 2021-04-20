local PARENT = UI

----------------------------------------------------------------------
-- class UI_EventRoulette
-- @brief 
----------------------------------------------------------------------
UI_EventRoulette = class(PARENT, {

    m_startBtn = 'UIC_Button',
    m_stopBtn = 'UIC_Button',
    m_rouletteSprite = 'Animator',


    -- TEMP
    m_angular_vel = 'number',
    m_angular_accel = 'number',

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette:init()
    self.m_uiName = 'UI_EventRoulette'
    local vars = self:load('event_roulette.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRoulette')
    self:doActionReset()
    self:doAction(nil, false)

    self.m_startBtn = vars['startBtn']
    self.m_stopBtn = vars['stopBtn']
    self.m_rouletteSprite = vars['rouletteSprite']

    self.m_angular_vel = 500
    self.m_angular_accel = 5

    self:initUI()
    self:initButton()
    self:refresh()
end


----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_EventRoulette:initUI()
end


----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_EventRoulette:initButton()
    self.m_startBtn:registerScriptTapHandler(function() self:click_startBtn() end)
    self.m_stopBtn:registerScriptTapHandler(function() self:click_stopBtn() end)
end

-- 1. Start를 누름 (일정한 속도로 계속 돌아감) 

-- 2. Stop을 누름 (360 - 현재 각도) + 일정한 바퀴수 + rand()


----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRoulette:refresh()

end

function UI_EventRoulette:keepSpinningRoulette(dt)
    if self.m_rouletteSprite:getNumberOfRunningActions() == 0 then
    self.m_rouletteSprite:runAction(cc.RotateBy:create(0.7, 360))
    end
end

function UI_EventRoulette:Test1(dt)
    self.m_angular_vel = 500
    local rot = self.m_rouletteSprite:getRotation()
    self.m_rouletteSprite:setRotation(rot + self.m_angular_vel * dt)
end

function UI_EventRoulette:Test2(dt) 
    self.m_angular_vel = self.m_angular_vel - self.m_angular_accel

    local rot = self.m_rouletteSprite:getRotation()
    self.m_rouletteSprite:setRotation(rot + self.m_angular_vel * dt)

    if (self.m_angular_vel <= 0) then
        self.root:unscheduleUpdate()
    end
end

function UI_EventRoulette:stopSpinningRoulette(dt)
    --local cycle = 360 * 3

    self.m_rouletteSprite:stopAllActions()
    ccdump(self.m_rouletteSprite:getRotation())

end


-- local rot1 = cc.RotateBy:create(2, -2880)
-- local rot2 = cc.RotateBy:create(3, -1800)
-- local rot3 = cc.RotateBy:create(3, -720)
-- local rot4 = cc.RotateBy:create(3, -270)
-- local test = cc.Sequence:create(cc.Sequence:create(cc.Sequence:create(rot1, rot2), rot3), rot4)
-- if vars['quickBtn'] ~= nil then
--     vars['quickBtn']:runAction(test)
-- end
----------------------------------------------------------------------
-- function click_startBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_startBtn()
    self.m_startBtn:setVisible(false)
    self.m_stopBtn:setVisible(true)

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:Test1(dt) end, 0)

    -- self.m_rouletteSprite:stopAllActions()
    -- self.m_rouletteSprite:setRotation(self.m_rouletteSprite:getRotation() % 360)
    -- ccdump(self.m_rouletteSprite:getRotation())
    -- local rand_angle = math.random(0, 360)
    -- local rot1 = cc.RotateBy:create(2, 2880 + rand_angle)
    -- self.m_rouletteSprite:runAction(rot1)
    --ccdump(self.m_rouletteSprite:getRotation())
end


function UI_EventRoulette:click_stopBtn()
    self.m_stopBtn:setVisible(false)
    self.m_startBtn:setVisible(true)

    self.root:unscheduleUpdate()
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:Test2(dt) end, 0)
end