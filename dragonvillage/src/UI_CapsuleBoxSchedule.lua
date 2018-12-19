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
    
    local capsule_data = g_capsuleBoxData:getCapsuleBoxInfo()
    local capsule_title = capsule_data['first']:getCapsuleTitle()
    vars['rotationTitleLabel']:setString(Str(capsule_title))
   
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBoxSchedule:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBoxSchedule:refresh()
    
end


--@CHECK
UI:checkCompileError(UI_CapsuleBoxSchedule)
