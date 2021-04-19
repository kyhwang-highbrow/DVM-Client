local PARENT = UI

----------------------------------------------------------------------
-- class UI_EventRoulette
-- @brief 
----------------------------------------------------------------------
UI_EventRoulette = class(PARENT, {

    m_startBtn = 'UIC_Button',
    m_rouletteSprite = 'Animator',

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
    self.m_rouletteSprite = vars['rouletteSprite']

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
end


----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRoulette:refresh()

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
    self.m_rouletteSprite:stopAllActions()
    self.m_rouletteSprite:setRotation(self.m_rouletteSprite:getRotation() % 360)
    ccdump(self.m_rouletteSprite:getRotation())
    local rand_angle = math.random(0, 360)
    local rot1 = cc.RotateBy:create(2, 2880 + rand_angle)
    self.m_rouletteSprite:runAction(rot1)
    --ccdump(self.m_rouletteSprite:getRotation())
end
