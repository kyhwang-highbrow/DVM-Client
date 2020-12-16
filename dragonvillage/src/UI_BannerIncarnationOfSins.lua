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

    -- 내 랭킹 표시
    if (vars['rankLabel']) then
        -- 내 랭킹이 0보다 작으면 {-위} 로 노출
        -- 0보다 큰 의미있는 값이면 그대로 노출
        local my_rank = g_eventIncarnationOfSinsData:getMyRank()

        if (my_rank < 0) then
            vars['rankLabel']:setString(Str('순위 없음'))
        else
            local ratio = g_eventIncarnationOfSinsData:getMyRate()
            local percent_text = string.format('%.2f', ratio * 100)
            vars['rankLabel']:setString(Str('{1}위 ({2}%)', comma_value(my_rank), percent_text))
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
    -- 이벤트 활성화중 아님
    if (not g_eventIncarnationOfSinsData:isActive()) then
        return
    
    -- 본 이벤트 기간
    elseif (g_eventIncarnationOfSinsData:canPlay()) then
        g_eventData:openEventPopup('event_incarnation_of_sins')
    
    -- 보상 수령 및 랭킹확인 기간
    else 
        g_eventIncarnationOfSinsData:openRankingPopupForLobby()
    end
end

--@CHECK
UI:checkCompileError(UI_BannerIncarnationOfSins)
