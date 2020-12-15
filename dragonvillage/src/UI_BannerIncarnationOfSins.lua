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

    -- TODO : 구현을 해야한다.
    -- 내 랭킹 표시
    if (vars['rankLabel']) then
        -- 내 랭킹이 0보다 작으면 {-위} 로 노출
        -- 0보다 큰 의미있는 값이면 그대로 노출
        local my_rank = g_eventIncarnationOfSinsData:getMyRank()

        if (my_rank < 0) then
            vars['rankLabel']:setString(Str('{1}위', '-'))
        else
            vars['rankLabel']:setString(Str('{1}위', my_rank))
        end
    end

    -- 남은 이벤트 시간 표시
    if (vars['timeLabel']) then
        vars['timeLabel']:setString(ServerData_EventIncarnationOfSins:getRemainTimeString())
    end
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
