local PARENT = UI

-------------------------------------
-- class UI_BirthdayCalendarDayElement
-------------------------------------
UI_BirthdayCalendarDayElement = class(PARENT, {
        m_structCalendarDay = 'StructCalendarDay',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_BirthdayCalendarDayElement:init(struct_calendar_day)
    self.m_structCalendarDay = struct_calendar_day

    local vars = self:load('event_birthday_list.ui')

    self:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BirthdayCalendarDayElement:refresh()
    local vars = self.vars

    local struct_calendar_day = self.m_structCalendarDay

    local month = struct_calendar_day.m_month
    local day = struct_calendar_day.m_day

    vars['dayLabel']:setString(tostring(day))

    local l_birthday_list = g_birthdayData:getBirthdayInfo(month, day)
    local table_dragon = TableDragon()
    for i,v in ipairs(l_birthday_list) do
        local dragon_type = v['type']

        local t_dragon = table_dragon:getRepresentativeDragonByType(dragon_type)
        local did = t_dragon['did']

        if vars['dragonNode' .. i] then
            local card = MakeSimpleDragonCard(did)
            vars['dragonNode' .. i]:addChild(card.root)
        end
    end

    if struct_calendar_day:isToday() then
        vars['todaySprite']:setVisible(true)
    else
        vars['todaySprite']:setVisible(false)
    end
end