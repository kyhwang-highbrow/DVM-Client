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
    menu:setSwallowTouch(false)
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
    if (self.m_eventType == 'event_dice' or self.m_eventType == 'event_mandraquest') then
        inner_ui:setContainerAndPosY(container_node, self.m_originPosY)
        inner_ui:refresh()
    end

    if (self.m_eventType == 'event_bingo') then
        inner_ui:setContainerAndPosY(container_node, self.m_originPosY)
        inner_ui:moveContainer(self.m_originPosY)
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

    local function repos_func(has_reward)
        -- 받을 누적 보상이 있다면 누적 보상쪽 스크롤
        if (has_reward) then
            container_node:setPositionY(-80)
        else
            container_node:setPositionY(self.m_originPosY)
        end
    end

    if (event_type == 'event_exchange') then
        repos_func(g_exchangeEventData:hasReward())
    
    elseif (event_type == 'event_gold_dungeon') then
        repos_func(g_eventGoldDungeonData:hasReward())

    elseif (event_type == 'event_match_card') then
        -- 카드 쌓아놓고 하위 보상은 교환하지 않는 경우가 생기므로 보상쪽 스크롤 하지 않음
        repos_func(false)

    -- 알파벳 이벤트
    elseif (event_type == 'event_alphabet') then
        repos_func(false)

    -- 별도로 처리하지 않으면 최상위로 스크롤 하도록 처리 
    else
        repos_func(false)
    end
end