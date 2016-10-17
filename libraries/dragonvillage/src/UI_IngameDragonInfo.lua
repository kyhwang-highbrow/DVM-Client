-------------------------------------
-- class UI_IngameDragonInfo
-------------------------------------
UI_IngameDragonInfo = class(UI, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonInfo:init(hero)
    local vars = self:load('ingame_dragon_info.ui')

    if (hero.m_tDragonInfo) then
        vars['levelLabel']:setString(hero.m_tDragonInfo['lv'])
    else
        vars['levelLabel']:setString('')
    end

    if (hero.m_charType == 'tamer') then
        vars['levelLabel']:setString(g_userData.m_userData['lv'])
    end

    local attr_str = hero.m_charTable['attr']
    local res = 'res/ui/icon/attr/attr_' .. attr_str .. '.png'
    local icon = cc.Sprite:create(res)
    if icon then
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['attrNode']:addChild(icon)
    end

    vars['skillGauge']:setPercentage(0)
end


-------------------------------------
-- function click_backkey
-------------------------------------
function UI_IngameDragonInfo:click_button()
    if self.m_buttonHandler then
        self.m_buttonHandler()
    end
end

-------------------------------------
-- function onEnter_activated
-------------------------------------
function UI_IngameDragonInfo:onEnter_activated()
    local vars = self.vars
    vars['active_gauge']:setVisible(true)
    vars['active_effect']:setVisible(true)
    vars['time_label']:setVisible(true)
end

-------------------------------------
-- function onExit_activated
-------------------------------------
function UI_IngameDragonInfo:onExit_activated()
    local vars = self.vars
    vars['active_gauge']:setVisible(false)
    vars['active_effect']:setVisible(false)
    vars['time_label']:setVisible(false)
end

-------------------------------------
-- function onEnter_charged
-------------------------------------
function UI_IngameDragonInfo:onEnter_charged()
    local vars = self.vars
end

-------------------------------------
-- function onExit_charged
-------------------------------------
function UI_IngameDragonInfo:onExit_charged()
    local vars = self.vars
end

-------------------------------------
-- function onEnter_cool
-------------------------------------
function UI_IngameDragonInfo:onEnter_cool()
    local vars = self.vars
    vars['time_gauge']:setVisible(true)
    vars['time_label']:setVisible(true)
end

-------------------------------------
-- function onExit_cool
-------------------------------------
function UI_IngameDragonInfo:onExit_cool()
    local vars = self.vars
    vars['time_gauge']:setVisible(false)
    vars['time_label']:setVisible(false)
end


-------------------------------------
-- function update_activated
-------------------------------------
function UI_IngameDragonInfo:update_activated(time, max_time)
    local vars = self.vars
    local percent = (time / max_time) * 100
    local time_str = math_floor(time + 0.5)

    vars['active_gauge']:setPercentage(percent)
    vars['time_label']:setString(time_str)
end

-------------------------------------
-- function update_cool
-------------------------------------
function UI_IngameDragonInfo:update_cool(time, max_time)
    local vars = self.vars
    local percent = (time / max_time) * 100
    local time_str = math_floor(time + 0.5)

   vars['time_gauge']:setPercentage(percent)
   vars['time_label']:setString(time_str)
end

-------------------------------------
-- function setGlobalCoolUI
-------------------------------------
function UI_IngameDragonInfo:setGlobalCoolUI(on_off)
    local vars = self.vars
    vars['normal_node']:setVisible(not on_off)
    vars['global_cool_node']:setVisible(on_off)
end

-------------------------------------
-- function update_globalCool
-------------------------------------
function UI_IngameDragonInfo:update_globalCool(time, max_time)
    local vars = self.vars
    local percent = (time / max_time) * 100
    local time_str = math_floor(time + 0.5)

   vars['global_time_gauge']:setPercentage(percent)
   vars['global_time_label']:setString(time_str)
end