local PARENT = class(UI, IEventDispatcher:getCloneTable())

-------------------------------------
-- class UI_ArenaNewAutoPlayPopup
-------------------------------------
UI_ArenaNewAutoPlayPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewAutoPlayPopup:init()
    self.m_uiName = 'UI_ArenaNewAutoPlayPopup'
    local vars = self:load('arena_new_scene_ready_auto_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewAutoPlayPopup')

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
function UI_ArenaNewAutoPlayPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewAutoPlayPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

	-- main
    vars['autoStartOnBtn'] = UIC_CheckBox(vars['autoStartOnBtn'].m_node, vars['autoStartOnSprite'], false)
    vars['autoStartOnBtn']:registerScriptTapHandler(function() self:click_autoStartOnBtn() end)

    vars['autoStartBtn1']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['autoStartBtn1'] = UIC_CheckBox(vars['autoStartBtn1'].m_node, vars['autoStartSprite1'], true)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_ArenaNewAutoPlayPopup:refresh()
    local vars = self.vars

end


-------------------------------------
-- function click_autoStartOnBtn
-------------------------------------
function UI_ArenaNewAutoPlayPopup:click_autoStartOnBtn()
    local vars = self.vars

    g_autoPlaySetting:setAutoPlay(true)
    g_autoPlaySetting:set('stop_condition_lose', vars['autoStartBtn1']:isChecked())

    -- 활성 상태일 경우 창을 닫음
    self:close()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ArenaNewAutoPlayPopup:click_exitBtn()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_ArenaNewAutoPlayPopup)
