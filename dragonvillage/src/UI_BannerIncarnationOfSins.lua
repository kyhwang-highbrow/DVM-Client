local PARENT = UI

-------------------------------------
-- class UI_BannerIncarnationOfSins
-------------------------------------
UI_BannerIncarnationOfSins = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BannerIncarnationOfSins:init()
    self.m_uiName = 'UI_BannerIncarnationOfSins'
    local vars = self:load('lobby_banner_incarnation_of_sins.ui')

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
function UI_BannerIncarnationOfSins:initUI()
    local vars = self.vars
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BannerIncarnationOfSins:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BannerIncarnationOfSins:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_BannerIncarnationOfSins:update()
	local vars = self.vars

    ---- 남은 시간 표시
    --if vars['timeLabel'] then
        --local str = g_hotTimeData:getEventRemainTimeTextDetail('event_rune_festival') or ''
        --vars['timeLabel']:setString(str)
    --end
end

-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_BannerIncarnationOfSins:click_bannerBtn()
    if (not g_hotTimeData:isActiveEvent('event_incarnation_of_sins')) then
        return
    end
    g_eventData:openEventPopup('event_incarnation_of_sins')
end

--@CHECK
UI:checkCompileError(UI_BannerIncarnationOfSins)
