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
    local vars = self:load('lobby_banner_event_dealking.ui')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:scheduleUpdate(function(dt) self:update(dt) end, 1, true)
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
    if vars['timeLabel'] == nil then
        return
    end
    vars['timeLabel']:setString(g_eventDealkingData:getRemainTimeString())
end

----------------------------------------------------------------------
-- function updateNoti
----------------------------------------------------------------------
function UI_LobbyBannerDealkingEvent:updateNoti()
    local vars = self.vars
    local my_rank = g_eventDealkingData:getMyRank()
    -- 이벤트 종료 후 보상 획득 가능
    if (g_eventDealkingData:canReward() and my_rank > 0) then
        vars['timeLabel']:setString('')
        vars['rankLabel']:setString(Str('보상'))
        vars['notiSprite']:setVisible(true)
    -- 이벤트 종료 및 보상 받을 것도 없는 상황
    else
        -- 내 랭킹이 0보다 작으면 {-위} 로 노출
        -- 0보다 큰 의미있는 값이면 그대로 노출
        vars['notiSprite']:setVisible(false)
        if (my_rank < 0) then
            vars['rankLabel']:setString(Str('순위 없음'))
        else
            local ratio = g_eventDealkingData:getMyRate()
            local percent_text = string.format('%.2f', ratio * 100)
            vars['rankLabel']:setString(Str('{1}위 ({2}%)', comma_value(my_rank), percent_text))
        end

        if (g_eventDealkingData:canPlay()) then
            local time_str = g_eventDealkingData:getRemainTimeString()
            if (time_str ~= nil) then
                -- 남은 이벤트 시간 표시
                vars['timeLabel']:setString(time_str)
            else
                vars['timeLabel']:setString('')
            end
        else
            vars['timeLabel']:setString('')
        end
    end
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
    -- 이벤트 활성화중 아님
    if (not g_eventDealkingData:isActive()) then
        return
    
    -- 본 이벤트 기간
    elseif (g_eventDealkingData:canPlay()) then
        g_eventData:openEventPopup('event_dealking')

    -- 보상 수령 및 랭킹확인 기간
    else
        local function finish_cb(ret)
            UI_EventDealkingRankingPopup() -- 랭킹 팝업
            local last_info = g_eventDealkingData:getMyRankInfoTotal()
            cclog('rank', last_info['rank'])
            local reward_info = ret['reward_info']

            -- 보상을 받을 수 있는 상태라면
            if (last_info and reward_info) then
                -- 랭킹 보상 팝업
                UI_EventIncarnationOfSinsRewardPopup(last_info, reward_info)
                g_highlightData:setHighlightMail()
            end
        end
        
        -- 보상이 있을 경우 보상 요청
        if (g_eventDealkingData:canReward() == true) then
            g_eventDealkingData:request_eventDealkingReward(finish_cb, nil)
        else -- 보상이 없을 경우
            finish_cb({})
        end 
    end
end

-- @CHECK
UI:checkCompileError(UI_LobbyBannerDealkingEvent)