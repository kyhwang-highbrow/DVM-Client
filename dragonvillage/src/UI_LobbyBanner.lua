local PARENT = UI

----------------------------------------------------------------------
-- class UI_LobbyBanner
----------------------------------------------------------------------
UI_LobbyBanner = class(PARENT,{
    m_eventData = 'StructEvent',
})

----------------------------------------------------------------------
-- class init
----------------------------------------------------------------------
function UI_LobbyBanner:init(event_data)
    self.m_uiName = 'UI_LobbyBanner'

    local ui_name = event_data['lobby_banner']
    local vars = self:load(ui_name)

    self.m_eventData = event_data

    self:initUI()
    self:initButton()
    self:refresh()
end

--local text_color = TableFriendship:getTextColorWithFlv(flv)

----------------------------------------------------------------------
-- class initUI
----------------------------------------------------------------------
function UI_LobbyBanner:initUI()
end


----------------------------------------------------------------------
-- class initButton
----------------------------------------------------------------------
function UI_LobbyBanner:initButton()
    self.vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end


----------------------------------------------------------------------
-- class refresh
----------------------------------------------------------------------
function UI_LobbyBanner:refresh()
end

----------------------------------------------------------------------
-- class click_bannerBtn
----------------------------------------------------------------------
function UI_LobbyBanner:click_bannerBtn()
    local url = self.m_eventData['url']
    local event_type = self.m_eventData['event_type']

    if (url ~= nil) and (url ~= '') then
        SDKManager:goToWeb(url)
    elseif (event_type == 'event_crosspromotion') then
	    g_fullPopupManager:showFullPopup(event_type)
    end
end

-- @CHECK
UI:checkCompileError(UI_LobbyBanner)