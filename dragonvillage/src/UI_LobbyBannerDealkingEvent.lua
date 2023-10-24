local PARENT = UI

----------------------------------------------------------------------
-- class UI_LobbyBannerDealkingEvent
----------------------------------------------------------------------
UI_LobbyBannerDealkingEvent = class(PARENT,{
    m_eventData = 'StructEvent',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:init(event_data)
    self.m_uiName = 'UI_LobbyBannerDealkingEvent'
    self.m_resName = event_data['lobby_banner']
    self.m_eventData = event_data
end

----------------------------------------------------------------------
-- function init_after
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:init_after()
    self:load(self.m_resName)
    
    self:initUI()
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update() end, 0)
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:initUI()
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:initButton()
    local vars = self.vars
    if vars['bannerBtn'] then
        vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
    end
end

----------------------------------------------------------------------
-- function update
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:update()
    self:updateTime()
    self:updateNoti()
end

----------------------------------------------------------------------
-- function updateTime
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:updateTime()
    local vars = self.vars
--[[     if vars['timeLabel'] == nil then
        return
    end

    local event_type = self.m_eventData['event_type']
    --local event_id = self.m_eventData['event_id']

    if event_type == 'event_popularity' then
        vars['timeLabel']:setString(g_eventPopularityGacha:getStatusText(true))
    elseif event_type == 'story_dungeon_gacha' then
        vars['timeLabel']:setString(g_eventDragonStoryDungeon:getRemainTimeText())
    end ]]
end

----------------------------------------------------------------------
-- function updateNoti
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:updateNoti()
--[[     local vars = self.vars
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
    end ]]
end

----------------------------------------------------------------------
-- class refresh
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:refresh()
end


----------------------------------------------------------------------
-- class click_bannerBtn
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:click_bannerBtn()

end

-- @CHECK
UI:checkCompileError(UI_LobbyBannerDealkingEvent)