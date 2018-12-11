local PARENT = UI

-------------------------------------
-- class UI_UserDeckInfo_GrandArena_Popup
-------------------------------------
UI_UserDeckInfo_GrandArena_Popup = class(PARENT, {
        m_structUserInfoColosseum  = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:init(struct_user_info)
    self.m_uiName = 'UI_UserDeckInfo_GrandArena_Popup'
    self.m_structUserInfoColosseum = struct_user_info

    local vars = self:load('grand_arena_user_deck_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_UserDeckInfo_GrandArena_Popup')

    -- @UI_ACTION
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:refresh()
   
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:click_closeBtn()
    self:close()
end
