-------------------------------------
-- class StructEventPopupTab
-------------------------------------
StructEventPopupTab = class({
        m_type = 'string',
        m_sortIdx = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StructEventPopupTab:init(type)
    self.m_type = type
end