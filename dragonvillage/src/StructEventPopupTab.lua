-------------------------------------
-- class StructEventPopupTab
-------------------------------------
StructEventPopupTab = class({
        m_type = 'string',
        m_sortIdx = 'number',

        m_category = '',
        m_categorySub = '',

        m_userData = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructEventPopupTab:init(category, category_sub)
    self:setCategory(category, category_sub)
end


-------------------------------------
-- function setCategory
-------------------------------------
function StructEventPopupTab:setCategory(category, category_sub)
    self.m_category = category
    self.m_categorySub = category_sub

    self.m_type = tostring(category)

    if category_sub then
        self.m_type = self.m_type .. '_' .. tostring(category_sub)
    end
end