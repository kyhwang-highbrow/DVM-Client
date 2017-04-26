local PARENT = UI

-------------------------------------
-- class UI_BirthdayCalendarDayElement
-- @brief 드래곤 생일 달력에서 하루를 표현하는 UI
-------------------------------------
UI_BirthdayCalendarDayElement = class(PARENT, {
        m_structCalendarDay = 'StructCalendarDay',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_BirthdayCalendarDayElement:init(struct_calendar_day)
    self.m_structCalendarDay = struct_calendar_day

    local vars = self:load('event_birthday_item.ui')

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

    self:makeDragonIcons(month, day)

    if struct_calendar_day:isToday() then
        vars['dayBtn']:setAutoShake(true)
        vars['todaySprite']:setVisible(true)
    else
        vars['dayBtn']:setAutoShake(false)
        vars['todaySprite']:setVisible(false)
    end
end

-------------------------------------
-- function makeDragonIcons
-- @brief 오늘 생일인 드래곤들의 아이콘을 생성
-------------------------------------
function UI_BirthdayCalendarDayElement:makeDragonIcons(month, day)
    local vars = self.vars

    local l_birthday_list = g_birthdayData:getBirthdayInfo(month, day)
    local table_dragon = TableDragon()
    for i,v in ipairs(l_birthday_list) do
        local dragon_type = v['type']

        local did = TableDragonType:getBaseDid(dragon_type)

        if vars['dragonNode' .. i] then
            local card = MakeSimpleDragonCard(did)
            card.vars['clickBtn']:setEnabled(false)
            vars['dragonNode' .. i]:addChild(card.root)

            -- 드래곤 원종 도감에 포함된 애들만 활성화
            if (not g_collectionData:isExistDragonType(dragon_type)) then
                card:setShadowSpriteVisible(true)
            end
        end
    end
end