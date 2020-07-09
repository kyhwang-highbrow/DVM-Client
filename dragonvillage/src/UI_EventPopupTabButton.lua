local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EventPopupTabButton
-------------------------------------
UI_EventPopupTabButton = class(PARENT, {
        m_structEventPopupTab = 'StructEventPopupTab',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTabButton:init(struct_event_popup_tab)
    self.m_structEventPopupTab = struct_event_popup_tab

    local vars = self:load('event_item.ui')

    self:initUI()
    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTabButton:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTabButton:initButton()
    local vars = self.vars
    vars['listBtn']:registerScriptTapHandler(function() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTabButton:refresh()
    local vars = self.vars

    local struct_event_popup_tab = self.m_structEventPopupTab
    local type = struct_event_popup_tab.m_type
    local tab_btn_name = struct_event_popup_tab:getTabButtonName()
    tab_btn_name = self:labelForGoogleFeatured(tab_btn_name)
    vars['eventLabel']:setString(tab_btn_name)
end

-------------------------------------
-- function labelForGoogleFeatured
-------------------------------------
function UI_EventPopupTabButton:labelForGoogleFeatured(tab_btn_name)
    
    if (not string.find(tostring(tab_btn_name), '구글 피처드')) then
        return tab_btn_name
    end

    local market, os = GetMarketAndOS()

    if(market == 'google' or market == 'windows') then
        return tab_btn_name
    else
        return Str('피처드 선정\n기념 출석 이벤트') -- 번역 텍스트 필요
    end
end