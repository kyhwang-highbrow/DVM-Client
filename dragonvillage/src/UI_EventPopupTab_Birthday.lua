local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Birthday
-------------------------------------
UI_EventPopupTab_Birthday = class(PARENT,{
        m_year = 'number',
        m_currMonth = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Birthday:init(owner)
    local vars = self:load('event_birthday.ui')

    vars['titleLabel'] = owner.vars['titleLabel']

    local year_month, t_time = Timer:getGameServerDate(true, true, false)
    self.m_year = t_time['year']
    
    self:initUI()
    self:initButton()
    --self:refresh()

    self:changeMonth(t_time['month'])
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_Birthday:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_Birthday:initButton()
    local vars = self.vars

    vars['prevBtn']:registerScriptTapHandler(function() self:changeMonth(self.m_currMonth - 1) end)
    vars['nextBtn']:registerScriptTapHandler(function() self:changeMonth(self.m_currMonth + 1) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_Birthday:refresh()
    local vars = self.vars

    local table_calendar = TableCalendar()
    local day_list = table_calendar:getCalendarDayList(self.m_year, self.m_currMonth)

    for i=1, 35 do
        vars['dayNode' .. i]:removeAllChildren()
    end

    for _,struct_calendar_day in ipairs(day_list) do
        local ui = UI_BirthdayCalendarDayElement(struct_calendar_day)

        local idx_on_calendar = struct_calendar_day.m_idxOnCalendar
        if vars['dayNode' .. idx_on_calendar] then
            vars['dayNode' .. idx_on_calendar]:addChild(ui.root)
        end

        cca.uiReactionSlow(ui.root)
    end
end

-------------------------------------
-- function changeMonth
-------------------------------------
function UI_EventPopupTab_Birthday:changeMonth(month)
    if (self.m_currMonth == month) then
        return
    end

    local vars = self.vars
    self.m_currMonth = month
    self:refresh()

    vars['titleLabel']:setString(Str('{1}월 드래곤 생일', month))

    if (self.m_currMonth <= 1) then
        vars['prevBtn']:setVisible(false)
    else
        vars['prevBtn']:setVisible(true)
    end

    if (self.m_currMonth >= 12) then
        vars['nextBtn']:setVisible(false)
    else
        vars['nextBtn']:setVisible(true)
    end
end