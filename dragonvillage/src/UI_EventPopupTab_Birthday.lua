local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Birthday
-------------------------------------
UI_EventPopupTab_Birthday = class(PARENT,{
        m_titleText = 'string',
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

    self:checkBirthdayReward()
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

    vars['dayItemsMenu']:removeAllChildren()

    for _,struct_calendar_day in ipairs(day_list) do
        local ui = UI_BirthdayCalendarDayElement(struct_calendar_day)
        ui.root:setDockPoint(cc.p(0.5, 0.5))
        ui.root:setAnchorPoint(cc.p(0.5, 0.5))

        local idx_on_calendar = struct_calendar_day.m_idxOnCalendar
        vars['dayItemsMenu']:addChild(ui.root)


        local x, y = self:getDayElementPos(idx_on_calendar)
        ui.root:setPosition(x, y)

        cca.uiReactionSlow(ui.root)
    end
end

-------------------------------------
-- function getDayElementPos
-------------------------------------
function UI_EventPopupTab_Birthday:getDayElementPos(idx)
    local x = -390
    local y = 178

    local interval_x = 130
    local interval_y = 87

    local idx_x, idx_y = self:getMatrixIdx(idx, 7)

    local pos_x = x + ((idx_x-1) * interval_x)
    local pos_y = y - ((idx_y-1) * interval_y)

    return pos_x, pos_y
end

-------------------------------------
-- function getMatrixIdx
-------------------------------------
function UI_EventPopupTab_Birthday:getMatrixIdx(idx, num_of_line)
    if (idx == 0) then
        return 0, 0
    end
    
    local idx_x = ((idx % num_of_line) == 0) and num_of_line or (idx % num_of_line)

    local idx_y = ((idx % num_of_line) == 0) and math_floor(idx / num_of_line) or math_floor((idx / num_of_line) + 1)

    return idx_x, idx_y
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

    self.m_titleText = Str('{1}월 드래곤 생일', month)
    vars['titleLabel']:setString(self.m_titleText)

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

-------------------------------------
-- function checkBirthdayReward
-------------------------------------
function UI_EventPopupTab_Birthday:checkBirthdayReward()
    local vars = self.vars

    local has_reward, birth_list = g_birthdayData:hasBirthdayReward()

    if (not has_reward) then
        return
    end

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        co:waitTime(0.8)

        for i,birth_id in ipairs(birth_list) do
            co:work()
            local ui = UI_BirthdayRewardSelectPopup(birth_id)
            ui:setCloseCB(co.NEXT)
            if co:waitWork() then return end
        end

        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Birthday:onEnterTab()
    local vars = self.vars
    vars['titleLabel']:setString(self.m_titleText)
end