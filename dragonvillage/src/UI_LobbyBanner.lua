local PARENT = UI

----------------------------------------------------------------------
-- class UI_LobbyBanner
----------------------------------------------------------------------
UI_LobbyBanner = class(PARENT,{
    m_eventData = 'StructEvent',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_LobbyBanner:init(event_data)
    self.m_uiName = 'UI_LobbyBanner'
    self.m_resName = event_data['lobby_banner']
    self.m_eventData = event_data
end

----------------------------------------------------------------------
-- function init_after
----------------------------------------------------------------------
function UI_LobbyBanner:init_after()
    self:load(self.m_resName)
    
    self:initUI()
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update() end, 0)
end

--local text_color = TableFriendship:getTextColorWithFlv(flv)

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_LobbyBanner:initUI()
end


----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_LobbyBanner:initButton()
    local vars = self.vars
    if vars['bannerBtn'] then
        vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
    end
end

----------------------------------------------------------------------
-- function update
----------------------------------------------------------------------
function UI_LobbyBanner:update()
    self:updateTime()
    self:updateNoti()
end

----------------------------------------------------------------------
-- function updateTime
----------------------------------------------------------------------
function UI_LobbyBanner:updateTime()
    local vars = self.vars
    if vars['timeLabel'] == nil then
        return
    end

    local event_type = self.m_eventData['event_type']
    --local event_id = self.m_eventData['event_id']

    if event_type == 'event_popularity' then
        vars['timeLabel']:setString(g_eventPopularityGacha:getStatusText(true))
    end
end

----------------------------------------------------------------------
-- function updateNoti
----------------------------------------------------------------------
function UI_LobbyBanner:updateNoti()
    local vars = self.vars
    if vars['notiSprite'] == nil then
        return
    end
    
    local event_type = self.m_eventData['event_type']
    local event_id = self.m_eventData['event_id']

    if event_type == 'event_crosspromotion' then        
        local is_available = g_userData:isAvailablePreReservation(event_id)
        vars['notiSprite']:setVisible(is_available)
    elseif event_type == 'event_popularity' then
        local is_available = g_eventPopularityGacha:isAvailableMileagePoint()
        vars['notiSprite']:setVisible(is_available)
    end
end

----------------------------------------------------------------------
-- class refresh
----------------------------------------------------------------------
function UI_LobbyBanner:refresh()
end

-------------------------------------
-- function update_reservation_timer
-------------------------------------
function UI_LobbyBanner:update_reservation_timer(dt)
    local vars = self.vars

end

----------------------------------------------------------------------
-- class click_bannerBtn
----------------------------------------------------------------------
function UI_LobbyBanner:click_bannerBtn()
    local url = self.m_eventData['url']
    local event_type = self.m_eventData['event_type']

    if (url ~= nil) and (url ~= '') then
        if (event_type == 'event_crosspromotion') then
            g_fullPopupManager:showFullPopup(event_type)
        else
            SDKManager:goToWeb(url)
        end
    elseif (event_type == 'event_crosspromotion') then
	    g_fullPopupManager:showFullPopup(event_type)

    elseif (event_type == 'story_dungeon_gacha') then
        local ui = g_fullPopupManager:showFullPopup(event_type)
        if ui.m_innerUI.vars['story_dungeonBtn'] ~= nil then
            ui.m_innerUI.vars['story_dungeonBtn']:setVisible(true)
        end

    elseif (event_type == 'event_popularity') then
        g_fullPopupManager:showFullPopup(event_type)

    end
end

-- @CHECK
UI:checkCompileError(UI_LobbyBanner)