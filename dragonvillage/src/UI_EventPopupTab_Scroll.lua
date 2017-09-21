local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Scroll
-------------------------------------
UI_EventPopupTab_Scroll = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Scroll:init(owner, struct_event_popup_tab)
    local vars = self:load('event_scroll.ui')

    local event_data = struct_event_popup_tab.m_eventData
    local event_type = event_data['event_type']
    

    local ui
    local target_size 
    if (event_type == 'event_chuseok') then
        ui = UI_ChuseokEvent()
        target_size = cc.size(930, 1200)
    end

    -- 스크롤 뷰 위에 해당 이벤트 UI 올려줌
    if (ui) then
        local scroll_node = vars['scrollNode']
        local size = scroll_node:getContentSize()

        local scroll_view = cc.ScrollView:create()
        scroll_view:setNormalSize(size)
        scroll_view:setContentSize(target_size)
        scroll_view:setDockPoint(CENTER_POINT)
        scroll_view:setAnchorPoint(CENTER_POINT)
        scroll_view:setPosition(ZERO_POINT)
        scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scroll_view:setTouchEnabled(true)
        scroll_node:addChild(scroll_view)
        scroll_view:addChild(ui.root)

        local container_node = scroll_view:getContainer()
        container_node:setPositionY(size.height - target_size.height)
    end
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Scroll:onEnterTab()
end