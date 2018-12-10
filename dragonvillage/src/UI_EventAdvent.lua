local PARENT = UI

-------------------------------------
-- class UI_EventAdvent
-------------------------------------
UI_EventAdvent = class(PARENT,{
        m_eventDataUI = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventAdvent:init()
    local vars = self:load('event_advent.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventAdvent:initUI()
    local vars = self.vars

    -- 깜짝 출현 남은 시간
    do
        vars['timeLabel']:setString('')

        local frame_guard = 1
        local function update(dt)
            frame_guard = frame_guard + dt
            if (frame_guard < 1) then
                return
            end
            frame_guard = frame_guard - 1
            
            local remain_time = g_hotTimeData:getEventRemainTime('event_advent')
            if remain_time > 0 then
                local time_str = datetime.makeTimeDesc(remain_time, true)
                vars['timeLabel']:setString(Str('{1} 남음', time_str))
            end
        end
        self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventAdvent:initButton()
    local vars = self.vars
    vars['stageMoveBtn']:registerScriptTapHandler(function() self:click_stageMoveBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventAdvent:refresh()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventAdvent:onEnterTab()
    self:refresh()
end

-------------------------------------
-- function click_stageMoveBtn
-- @brief 깜짝 출현 챕터 보통 난이도 1스테이지로 보냄
-------------------------------------
function UI_EventAdvent:click_stageMoveBtn()
    local advent_default_stage_id = 1119901
    UINavigator:goTo('adventure', advent_default_stage_id)
end
