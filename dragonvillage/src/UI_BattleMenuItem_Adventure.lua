local PARENT = UI_BattleMenuItem

-------------------------------------
-- class UI_BattleMenuItem_Adventure
-------------------------------------
UI_BattleMenuItem_Adventure = class(PARENT, {})

local THIS = UI_BattleMenuItem_Adventure

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem_Adventure:init(content_type)
    local vars = self:load('battle_menu_adventure_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()

    if (content_type == 'adventure') then
        self:initUI_advent()
    end
end

-------------------------------------
-- function initUI_advent
-------------------------------------
function UI_BattleMenuItem_Adventure:initUI_advent()
    if (g_hotTimeData:isActiveEvent('event_advent')) then
        local vars = self.vars

        -- 깜짝 출현 남은 시간
        vars['timeSprite']:setVisible(true)
        vars['timeLabel']:setString('')

        -- 깜짝 출현 타이틀
        local title = g_eventAdventData:getAdventTitle()
        
        local frame_guard = 1
        local function update(dt)
            frame_guard = frame_guard + dt
            if (frame_guard < 1) then
                return
            end
            frame_guard = frame_guard - 1
            
            local remain_time = g_hotTimeData:getEventRemainTime('event_advent')
            if remain_time > 0 then
                local time_str = ServerTime:getInstance():makeTimeDescToSec(remain_time, true)
                vars['timeLabel']:setString(title .. '\n' .. Str('{1} 남음', time_str))
            end
        end
        vars['timeSprite']:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
    end
end