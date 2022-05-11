local PARENT = UI

-------------------------------------
-- class UI_HbrwLoungePopup
-------------------------------------
UI_HbrwLoungePopup = class(PARENT,{

})


-------------------------------------
-- function init
-------------------------------------
function UI_HbrwLoungePopup:init()
    local vars = self:load('hbrw_lounge_popup.ui')

    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CommunityPopup')
    
    self:initUI()
    self:initButton()
    self:refresh()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_HbrwLoungePopup:initUI()
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HbrwLoungePopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_HbrwLoungePopup:click_okBtn()
    local date_format = pl.Date.Format('yyyy-mm-dd')
    local curr_timestamp = Timer:getServerTime()

    local curr_date_str = date_format:tostring(curr_timestamp)

    g_settingData:setHbrwLoungeSetting(curr_date_str)

    self:setCloseCB(function() SDKManager:goToWeb('https://discord.gg/mtM3xnE4nh') end)
    
    self:close()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HbrwLoungePopup:click_cancelBtn()
    self:close()
end