local PARENT = UI

-------------------------------------
-- class UI_CapsuleBoxSchedule
-------------------------------------
UI_CapsuleBoxSchedule = class(PARENT,{
      
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBoxSchedule:init()
    self.m_uiName = 'UI_CapsuleBoxSchedule'
    local vars = self:load('event_capsule_box_schedule.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CapsuleBoxSchedule')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBoxSchedule:initUI()
    local vars = self.vars

   
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBoxSchedule:initButton()
    local vars = self.vars
   
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBoxSchedule:refresh()
    
end


--@CHECK
UI:checkCompileError(UI_CapsuleBoxSchedule)
