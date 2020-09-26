local PARENT = UI

-------------------------------------
-- class UI_EventLFBag
-------------------------------------
UI_EventLFBag = class(PARENT,{
        m_structLFBag = 'structEventLFBag'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBag:init()
    local vars = self:load('event_lucky_fortune_bag.ui')

    self.m_structLFBag = g_eventLFBagData:getLFBag()

    self:initUI()
    self:initButton()
    self:refresh()

    -- touch 먹히도록 함
    self:setSwallowTouch()
    self:startUpdate(function(dt) self:update(dt) end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventLFBag:initUI()
    local vars = self.vars

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventLFBag:initButton()
    local vars = self.vars

    vars['openBtn']:registerScriptTapHandler(function() self:click_openBtn() end)
    vars['stopBtn']:registerScriptTapHandler(function() self:click_stopBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
    vars['packageBtn']:registerScriptTapHandler(function() self:click_packageBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBag:refresh()
    local vars = self.vars
    
    -- 보유 수
    local count_str = Str('{1}개', self.m_structLFBag:getCount())
    vars['numberLabel']:setString(count_str)

    -- 확률
    local prob_str = Str('성공 확률 {1}%', self.m_structLFBag:getProb() * 100)
    vars['percentageLabel']:setString(prob_str)

    -- 레벨
    local lv_str = Str('복주머니') .. ' ' .. string.format('Lv.%d', self.m_structLFBag:getLv())
    vars['levelLabel']:setString(lv_str)

    -- 최고레벨 여부 
    vars['completeSprite']:setVisible(self.m_structLFBag:isMax())
end

-------------------------------------
-- function update
-------------------------------------
function UI_EventLFBag:update(dt)
    if (self.m_structLFBag == nil) then
        time_label:setString('')
    end
    
    local time_label = self.vars['timeLabel']
    if time_label then
        local curr_time = Timer:getServerTime()
        local end_time = self.m_structLFBag:getEndTime()
        if (0 < end_time) and (curr_time < end_time) then
            local remain_time = (end_time - curr_time) * 1000
            local str = datetime.makeTimeDesc_timer(remain_time)
            time_label:setString(str)
        else
            time_label:setString('')
        end
    end
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventLFBag:onEnterTab()
    self:refresh()
end

-------------------------------------
-- function click_openBtn
-------------------------------------
function UI_EventLFBag:click_openBtn()
    if (self.m_structLFBag:getCount() == 0) then
        UIManager:toastNotificationRed(Str('복주머니가 부족합니다.'))
        return
    end

    local function finish_cb()
        self:refresh()
    end    
    g_eventLFBagData:request_eventLFBagNext(finish_cb)
end

-------------------------------------
-- function click_stopBtn
-------------------------------------
function UI_EventLFBag:click_stopBtn()
    if (self.m_structLFBag:getLv() == 0) then
        UIManager:toastNotificationRed(Str('수령할 누적 보상이 없습니다.'))
        return
    end

    local msg = Str('복주머니를 포기하고 현재까지의 누적 보상을 수령하시겠습니까?')
    local function ok_btn_cb()
        local function finish_cb()
            self:refresh()
        end
        g_eventLFBagData:request_eventLFBagStop(finish_cb)
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventLFBag:click_infoBtn()
    MakePopup('event_lucky_fortune_bag_info_popup.ui')
end

-------------------------------------
-- function click_packageBtn
-------------------------------------
function UI_EventLFBag:click_packageBtn()
    UI_Package_Bundle('package_lucky_fortune_bag', true)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventLFBag:click_rankBtn()
    require('UI_EventLFBagRankingPopup')
    UI_EventLFBagRankingPopup()
end