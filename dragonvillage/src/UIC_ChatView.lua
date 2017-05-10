local PARENT = UIC_Node

-------------------------------------
-- class UIC_ChatView
-------------------------------------
UIC_ChatView = class(PARENT, {
        m_scrollView = 'cc.ScrollView',

        m_itemList = '',
        m_itemPositions = '',
        m_bDirtyPos = 'boolean',

        m_contentStack = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_ChatView:init(node)

    -- 스크롤 뷰 생성
    local content_size = node:getContentSize()
    self:makeScrollView(content_size)

    self.m_contentStack = {}
    self.m_itemList = {}
end

-------------------------------------
-- function makeScrollView
-------------------------------------
function UIC_ChatView:makeScrollView(size)
    local scroll_view = cc.ScrollView:create()
    self.m_scrollView = scroll_view
    self.m_scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    do -- 컨테이터 비주얼로 보이게
        --local _container = self.m_scrollView:getContainer()
        --UIC_Node(_container):initGLNode()
    end

    do -- 테스트 item
        --local item = UIC_Node:create()
        --item:initGLNode()
        --item:setNormalSize(100, 100)
        --item:setDockPoint(cc.p(0.5, 0))
        --_container:addChild(item.m_node)
    end

    -- 실질적인 테이블 뷰 사이즈 설정
    scroll_view:setViewSize(size)
    scroll_view:setContentSize(size)

    scroll_view:setDockPoint(cc.p(0.5, 0.5))
    scroll_view:setAnchorPoint(cc.p(0.5, 0.5))

    scroll_view:setDelegate()

    -- 스크롤 handler
    local scrollViewDidScroll = function(view)
        self:scrollViewDidScroll(view)
    end
    scroll_view:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)

    self.m_node:addChild(scroll_view)

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.m_node:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.m_node:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
        end
    end)

end

-------------------------------------
-- function update
-------------------------------------
function UIC_ChatView:update(dt)
    if (0 < #self.m_contentStack) then
        for _,chat_content in ipairs(self.m_contentStack) do
            local t_item = {}
            t_item['data'] = chat_content

            local content_type = chat_content:getContentType()

            if (content_type == 'my_msg') then
                t_item['ui'] = UI_ChatListItem_myMsg(chat_content)--UI_ChatListItem(chat_content)

            elseif (content_type == 'msg') then
                t_item['ui'] = UI_ChatListItem_msg(chat_content)

            else
                t_item['ui'] = UI_ChatListItem_systemMsg(chat_content)
            end

            
            t_item['ui'].root:setDockPoint(cc.p(0.5, 0))
            t_item['ui'].root:setAnchorPoint(cc.p(0.5, 0.5))
            t_item['ui'].root:setPositionX(0)

            table.insert(self.m_itemList, t_item)

            local _container = self.m_scrollView:getContainer()
            --ccdump(_container:getNormalSize())
            _container:addChild(t_item['ui'].root)

            self:setDirtyPos()
        end
        self.m_contentStack = {}
    end

    if self.m_bDirtyPos then
        self:updateContentList()
    end
end

-------------------------------------
-- function scrollViewDidScroll
-------------------------------------
function UIC_ChatView:scrollViewDidScroll()
    --local _container = self.m_scrollView:getContainer()
    --local x, y = _container:getPosition()
    --cclog('x, y', x, y)
end

-------------------------------------
-- function relocateContainer
-- @brief
-------------------------------------
function UIC_ChatView:relocateContainer(animated)
--[[
    local scroll_view = self.m_scrollView

    local oldPoint = cc.p(0, 0)
    local min, max;
    local newX, newY;

    min = scroll_view:minContainerOffset();
    max = scroll_view:maxContainerOffset();

    oldPoint.x, oldPoint.y = scroll_view:getContainer():getPosition();

    newX     = oldPoint.x;
    newY     = oldPoint.y;

    --if (self._direction == cc.SCROLLVIEW_DIRECTION_BOTH or self._direction == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
        newY     = math_min(newY, max.y);
        newY     = math_max(newY, min.y);
    --end

    if (newY ~= oldPoint.y or newX ~= oldPoint.x) then
        scroll_view:setContentOffset(cc.p(newX, newY), animated);
    end
    --]]
end

-------------------------------------
-- function relocateContainerDefault
-- @brief 시작 위치로 설정
-------------------------------------
function UIC_ChatView:relocateContainerDefault(animated)
    -- 세로
    --self.m_scrollView:setContentOffset(cc.p(0, 0), animated)
end

-------------------------------------
-- function sample_UIC_ChatView
-------------------------------------
function UIC_ChatView:sample_UIC_ChatView(scene)
    local uic_node = UIC_Node:create()
    uic_node:initGLNode()
    uic_node:setNormalSize(800, 600)
    scene:addChild(uic_node.m_node)

    local function make_cell(data)
        cclog('# ' .. data)

        local t_item_data = {}
        t_item_data['nickname'] = tostring(data)
        t_item_data['uid'] = tostring(data)
        t_item_data['message'] = tostring(data)


        return UI_ChatListItem(t_item_data)
    end

    local function create_func()

    end


    local node = uic_node.m_node

    local chat_view = UIC_ChatView(node)
    --chat_view:setCellUIClass(make_cell, create_func)
    --chat_view:setItemList({1,2,3,4,5,6,7})

    for i=1, 8 do
        local chat_content = ChatContent()
        chat_content['nickname'] = '닉넴'
        chat_content['uid'] = 102893
        chat_content['message'] = '안녕하세요 ' .. i

        chat_view:addChatContent(chat_content)
    end
end

-------------------------------------
-- function addChatContent
-------------------------------------
function UIC_ChatView:addChatContent(chat_content)
    table.insert(self.m_contentStack, chat_content)
end

-------------------------------------
-- function setDirtyPos
-------------------------------------
function UIC_ChatView:setDirtyPos()
    self.m_bDirtyPos = true
end

-------------------------------------
-- function updateContentList
-------------------------------------
function UIC_ChatView:updateContentList()

    -- 시간순으로 정렬
    local function sort_func(a, b)
        return (a['data'].m_timestamp > b['data'].m_timestamp)
    end
    table.sort(self.m_itemList, sort_func)

    -- 첫 아이템의 위치는 0으로 지정 dockPoint(0.5, 0)
    self.m_itemPositions = {}
    self.m_itemPositions[1] = 0

    local _y = 0
    for i,v in ipairs(self.m_itemList) do
        local cell_size = v['ui']:getCellSize()
        v['ui'].root:setPositionY(_y + (cell_size['height'] / 2))
        _y = _y + cell_size['height']
        self.m_itemPositions[i+1] = _y
    end

    -- 컨텐츠 최종 높이
    local total_content_height = self.m_itemPositions[#self.m_itemPositions]

    -- view_size의 height는 보장
    local view_size = self.m_scrollView:getViewSize()
    view_size['height'] = math_max(view_size['height'], total_content_height)
    self.m_scrollView:setContentSize(view_size)

    -- dirty 처리 off
    self.m_bDirtyPos = false
end