-------------------------------------
-- class StructEventPopupTab
-- @brief 로비에서 진입 가능한 이벤트 팝업의 탭
--        "출석", "이벤트", "드래곤 생일" 등을 표시
-------------------------------------
StructEventPopupTab = class({
        m_type = 'string',
        m_sortIdx = 'number',

        m_category1 = '',
        m_category2 = '',
        m_category3 = '',

        m_userData = '',

        m_hasNoti = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructEventPopupTab:init(category1, category2, category3)
    self.m_sortIdx = 0

    self:setCategory(category1, category2, category3)
end


-------------------------------------
-- function setCategory
-------------------------------------
function StructEventPopupTab:setCategory(category1, category2, category3)
    self.m_category1 = category1
    self.m_category2 = category2
    self.m_category3 = category3

    self.m_type = tostring(category1)

    if category2 then
        self.m_type = self.m_type .. '_' .. tostring(category2)
    end

    if category3 then
        self.m_type = self.m_type .. '_' .. tostring(category3)
    end
end

-------------------------------------
-- function getTabButtonName
-------------------------------------
function StructEventPopupTab:getTabButtonName()
    if (self.m_category1 == 'attendance') then
        if (self.m_category2 == 'basic') then
            return Str('출석')
        elseif (self.m_category2 == 'event') then
            return Str('이벤트')
        end

    elseif (self.m_category1 == 'birthday_calendar') then
        return Str('드래곤 생일')

    elseif (self.m_category1 == 'exchange') then
        return self.m_category3 .. '\n' .. Str('교환소')

    elseif (self.m_category1 == 'play_time') then
        return Str('접속시간\n이벤트')

    end
end