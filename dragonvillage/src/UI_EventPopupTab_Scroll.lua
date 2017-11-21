local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Scroll
-------------------------------------
UI_EventPopupTab_Scroll = class(PARENT,{
        m_eventType = 'string',
        m_scrollView = 'cc.ScrollView',

        m_originPosY = 'cc.p',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Scroll:init(owner, struct_event_popup_tab, inner_ui)
    if (not inner_ui) then
        return
    end

    local vars = self:load('event_scroll.ui')

    local event_data = struct_event_popup_tab.m_eventData
    self.m_eventType = event_data['event_type']
    
    local menu = inner_ui.vars['scrollMenu']
    local target_size = menu:getContentSize()

    -- 스크롤 뷰 위에 해당 이벤트 UI 올려줌
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
    scroll_view:addChild(inner_ui.root)
    self.m_scrollView = scroll_view

    local container_node = scroll_view:getContainer()
    self.m_originPosY = size.height - target_size.height

    -- inner_ui에서 컨테이너 컨트롤 가능하도록
    if (self.m_eventType == 'event_dice') then
        inner_ui:setContainer(container_node)
    end

    self:onEnterTab()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Scroll:onEnterTab()
    local event_type = self.m_eventType
    local scroll_view = self.m_scrollView
    local container_node = scroll_view:getContainer()

    if (event_type == 'event_exchange') then

        -- 받을 누적 보상이 있다면 누적 보상쪽 스크롤
        if (g_exchangeEventData:hasReward()) then
            container_node:setPositionY(-80)
        else
            container_node:setPositionY(self.m_originPosY)
        end

    elseif (event_type == 'event_dice') then
        container_node:setPositionY(self.m_originPosY)
    end
end