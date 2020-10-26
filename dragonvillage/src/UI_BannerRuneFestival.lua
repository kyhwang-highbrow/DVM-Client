local PARENT = UI

-------------------------------------
-- class UI_BannerRuneFestival
-------------------------------------
UI_BannerRuneFestival = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BannerRuneFestival:init()
    self.m_uiName = 'UI_BannerRuneFestival'
    local vars = self:load('lobby_banner_rune_festival.ui')

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
function UI_BannerRuneFestival:initUI()
    local vars = self.vars
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BannerRuneFestival:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BannerRuneFestival:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_BannerRuneFestival:update()
	local vars = self.vars

    -- 남은 시간 표시
    if vars['timeLabel'] then
        local str = g_hotTimeData:getEventRemainTimeTextDetail('event_rune_festival') or ''
        vars['timeLabel']:setString(str)
    end
end

-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_BannerRuneFestival:click_bannerBtn()
    if (not g_hotTimeData:isActiveEvent('event_rune_festival')) then
        return
    end
    g_eventData:openEventPopup('event_rune_festival')
end

--@CHECK
UI:checkCompileError(UI_BannerRuneFestival)
