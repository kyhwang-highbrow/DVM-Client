local PARENT = UIC_Node

-------------------------------------
-- class UIC_ChatView
-------------------------------------
UIC_ChatView = class(PARENT, {
        m_scrollView = 'cc.ScrollView',

        m_itemList = '',
        m_itemPositions = '',

        
        --[[
        m_itemList = '',
        m_itemMap = '',
        m_bDirtyItemList = 'boolean',
        m_refreshDuration = 'number',

        _cellsUsed = 'list',
        _vCellsPositions = 'list',

        m_makeReserveQueue = 'stack',
        m_makeTimer = 'number',

        m_cellUIClass = 'class',

        m_cellUICreateCB = 'function',
        m_cellUIAppearCB = 'function',

        m_bFirstLocation = 'boolean',
        --]]
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_ChatView:init(node)

    -- 스크롤 뷰 생성
    local content_size = node:getContentSize()
    self:makeScrollView(content_size)

    self.m_itemList = {}

    --[[
    self.m_refreshDuration = 0.5

    -- 기본값 설정
    self.m_bFirstLocation = true
    self.m_bDirtyItemList = false

    -- 스크롤 뷰 생성
    local content_size = node:getContentSize()
    self:makeScrollView(content_size)

    -- UI생성 큐
    self.m_makeReserveQueue = {}
    self.m_makeTimer = 0
    --]]
end

-------------------------------------
-- function makeScrollView
-------------------------------------
function UIC_ChatView:makeScrollView(size)
    local scroll_view = cc.ScrollView:create()
    self.m_scrollView = scroll_view
    self.m_scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 컨테이터 비주얼로 보이게
    local _container = self.m_scrollView:getContainer()
    UIC_Node(_container):initGLNode()

    do -- 테스트 item
        local item = UIC_Node:create()
        item:initGLNode()
        item:setNormalSize(100, 100)
        item:setDockPoint(cc.p(0.5, 0))
        _container:addChild(item.m_node)
    end

    -- 실질적인 테이블 뷰 사이즈 설정
    scroll_view:setViewSize(size)

    scroll_view:setDockPoint(cc.p(0.5, 0.5))
    scroll_view:setAnchorPoint(cc.p(0.5, 0.5))

    scroll_view:setDelegate()

    -- 스크롤 handler
    local scrollViewDidScroll = function(view)
        self:scrollViewDidScroll(view)
    end
    scroll_view:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)

    self.m_node:addChild(scroll_view)

    --scroll_view:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UIC_ChatView:update(dt)
    --[[
    self.m_makeTimer = (self.m_makeTimer - dt)
    if (self.m_makeTimer <= 0) then
        
        if self.m_makeReserveQueue[1] then
            local t_item = self.m_makeReserveQueue[1]
            local data = t_item['data']

            if t_item['generated_ui'] then
                t_item['ui'] = t_item['generated_ui']
                t_item['generated_ui'] = nil
                t_item['ui'].root:setVisible(true)
            else
                t_item['ui'] = self:makeItemUI(data)
            end

            do -- 액션 수행 위치 수정
                local ui = t_item['ui']
                local scale = ui.root:getScale()
                ui.root:setScale(scale * 0.2)
                local scale_to = cc.ScaleTo:create(0.25, scale)
                local action = cc.EaseInOut:create(scale_to, 2)
                ui.root:runAction(action)
            end

            local idx = t_item['idx']
            self:updateCellAtIndex(idx)
            
            table.remove(self.m_makeReserveQueue, 1)

            if self.m_cellUIAppearCB then
                self.m_cellUIAppearCB(t_item['ui'])
            end
        end

        self.m_makeTimer = 0.03
    end
    --]]

    -- 아이템 리스트가 변경되었을 경우
    if (self.m_bDirtyItemList == true) then
        self.m_bDirtyItemList = false

        -- 정렬
        local animated = true
        self:expandTemp(self.m_refreshDuration, animated)
    end
end

-------------------------------------
-- function _updateCellPositions
-------------------------------------
function UIC_ChatView:_updateCellPositions()
    local cellsCount = #self.m_itemList

    self._vCellsPositions = {}

    if (cellsCount > 0) then
        local currentPos = 0
        for i=1, cellsCount do
            self._vCellsPositions[i] = currentPos;
            local cellSize = self:tableCellSizeForIndex(i)

            -- 세로
            currentPos = currentPos + cellSize['height']

            self.m_itemList[i]['idx'] = i
        end
        self._vCellsPositions[cellsCount + 1] = currentPos;--1 extra value allows us to get right/bottom of the last cell
    end
end

-------------------------------------
-- function _updateContentSize
-------------------------------------
function UIC_ChatView:_updateContentSize(skip_update_cells)
    local size = cc.size(0, 0)

    local cellsCount = #self.m_itemList

    local viewSize = self.m_scrollView:getViewSize()

    if (cellsCount > 0) then
        local maxPosition = self._vCellsPositions[cellsCount + 1]

        local height = math_max(viewSize['height'], maxPosition)
        size = cc.size(viewSize['width'], height)
    end

    do -- 컨테이너의 사이즈를 다시 지정
        self.m_scrollView:setContentSize(size)
        -- 자식 node들의 transform을 update(dockpoint의 영향이 있을수 있으므로)
        self.m_scrollView:setUpdateChildrenTransform()
    end

    -- cell들의 위치를 업데이트
    if (not skip_update_cells) then
        for i=1, cellsCount do
            self:updateCellAtIndex(i)
        end
    end

    if self.m_bFirstLocation then
        self:relocateContainerDefault()
        self.m_bFirstLocation = false
    end
end

-------------------------------------
-- function scrollViewDidScroll
-------------------------------------
function UIC_ChatView:scrollViewDidScroll()
    --[[
    local cellsCount = #self.m_itemList

    if (0 == cellsCount) then
        return
    end

    local startIdx = 1
    local endIdx = 1
    local maxIdx = math_max(cellsCount, 1)

    -- 현재 컨테이너의 위치를 얻어옴
    local offset = self.m_scrollView:getContentOffset()
    offset['x'] = offset['x'] * -1
    offset['y'] = offset['y'] * -1

    -- 뷰사이즈를 얻어옴
    local viewSize = self.m_scrollView:getViewSize()

    -- 시작 idx 얻어옴
    startIdx = self:_indexFromOffset(offset)
    if (startIdx == -1) then
		startIdx = cellsCount
	end

    -- 종료 idx 얻어옴
    offset['y'] = offset['y'] + viewSize['height']
    offset['x'] = offset['x'] + viewSize['width']
    endIdx = self:_indexFromOffset(offset)

    if (endIdx == -1) then
        endIdx = cellsCount
	end
    
    -- 현재 보이는 item의 앞쪽 정리
    if (0 < #self._cellsUsed) then
        local cell = self._cellsUsed[1]
        local idx = cell['idx']

        while (idx < startIdx) do
            table.remove(self._cellsUsed, 1)

            if cell['ui'] then
                cell['ui']:setCellVisible(false)
            end

            if (#self._cellsUsed <= 0) then
                break
            end

            cell = self._cellsUsed[1]
            idx = cell['idx']
        end
    end

    -- 현재 보이는 item의 뒷쪽 정리
    if (0 < #self._cellsUsed) then
        local cell = self._cellsUsed[#self._cellsUsed]
        local idx = cell['idx']

        while (idx < maxIdx) and (idx > endIdx) do
            table.remove(self._cellsUsed, #self._cellsUsed)

            if cell['ui'] then
                cell['ui']:setCellVisible(false)
            end

            if (#self._cellsUsed <= 0) then
                break
            end

            cell = self._cellsUsed[#self._cellsUsed]
            idx = cell['idx']
        end
    end

    -- 눈에 보이는 item들 설정
    self._cellsUsed = {}
    for i=startIdx, endIdx do
        local t_item = self.m_itemList[i]

        if (t_item['ui']) then
            t_item['ui']:setCellVisible(true)
        end

        table.insert(self._cellsUsed, t_item)
    end
    --]]

    local _container = self.m_scrollView:getContainer()
    local x, y = _container:getPosition()
    cclog('x, y', x, y)
end


-------------------------------------
-- function tableCellSizeForIndex
-------------------------------------
function UIC_ChatView:tableCellSizeForIndex(idx)
    local t_item = self.m_itemList[idx]
    local ui = t_item['ui']

    local size = ui:getCellSize()
    return size
end

-------------------------------------
-- function _indexFromOffset
-------------------------------------
function UIC_ChatView:_indexFromOffset(offset)
    local index = 1
    local  maxIdx = #self.m_itemList
    
    index = self:__indexFromOffset(offset);
    if (index ~= -1) then
        index = math_max(1, index)
        if (index > maxIdx) then
            index = -1
        end
    end

    return index;
end

-------------------------------------
-- function __indexFromOffset
-------------------------------------
function UIC_ChatView:__indexFromOffset(offset)
    local low = 1
    local high = #self.m_itemList
    local search;

    search = offset['y']

    while (high >= low) do
        local index = math_floor(low + (high - low) / 2)
        local cellStart = self._vCellsPositions[index];
        local cellEnd = self._vCellsPositions[index + 1];

        if (search >= cellStart and search <= cellEnd) then
            return index
        elseif (search < cellStart) then
            high = index - 1
        else
            low = index + 1
        end
    end

    if (low <= 1) then
        return 1
    end

    return -1;
end

-------------------------------------
-- function maxContainerOffset
-------------------------------------
function UIC_ChatView:maxContainerOffset()
    return 0, 0
end

-------------------------------------
-- function minContainerOffset
-------------------------------------
function UIC_ChatView:minContainerOffset()
    local viewSize = self.m_scrollView:getViewSize()

    local _container = self.m_scrollView:getContainer()
    local size = _container:getContentSize()

    local x = viewSize['width'] - size['width']
    local y = viewSize['height'] - size['height']

    return x, y
end

function UIC_ChatView:_offsetFromIndex(index)
    local offset = self:__offsetFromIndex(index)

    local cellSize = self:tableCellSizeForIndex(index)

    do -- 가운데 정렬을 위해
        offset['x'] = offset['x'] + (cellSize['width'] / 2)
        offset['y'] = offset['y'] + (cellSize['height'] / 2)
    end

    return offset
end

function UIC_ChatView:__offsetFromIndex(index)
    local offset = cc.p(0, 0)
    local cellSize = cc.size(0, 0)

    offset['y'] = self._vCellsPositions[index]

    return offset
end

function UIC_ChatView:updateCellAtIndex(idx)
    local offset = self:_offsetFromIndex(idx)

    local ui = self.m_itemList[idx]['ui']

    if ui then
        ui.root:setPosition(offset['x'], offset['y'])
    end
end

-------------------------------------
-- function setItemList
-- @brief list는 key값이 고유해야 하며, value로는 UI생성에 필요한 데이터가 있어야 한다
-------------------------------------
function UIC_ChatView:setItemList(list, make_item)
    self:clearItemList()

    for key,data in pairs(list) do
        local t_item = {}
        t_item['unique_id'] = key
        t_item['data'] = data

        local idx = #self.m_itemList + 1

        -- UI를 미리 생성
        if make_item then
            t_item['generated_ui'] = self:makeItemUI(data)
            t_item['generated_ui'].root:setVisible(false)
        end

        -- 리스트에 추가
        table.insert(self.m_itemList, t_item)

        -- 맵에 등록
        self.m_itemMap[key] = t_item
    end

    if (make_item) then
        self:_updateCellPositions()
        self:_updateContentSize()
    end

    self:setDirtyItemList()
end

-------------------------------------
-- function makeAllItemUI
-- @brief
-------------------------------------
function UIC_ChatView:makeAllItemUI()
    self:_updateCellPositions()
    self:_updateContentSize()

    for i,item in ipairs(self.m_itemList) do
        if (not item['ui']) then
            item['ui'] = self:makeItemUI(item['data'])
            local ui = item['ui']
            local idx = item['idx']
            self:updateCellAtIndex(idx)

            do -- UI 생성 연출
                local scale = ui.root:getScale()
                ui.root:setScale(scale * 0.2)
                local scale_to = cc.ScaleTo:create(0.25, scale)
                local action = cc.EaseInOut:create(scale_to, 2)
                ui.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.03), action))
            end

            -- 생성 예약 리스트에서 삭제
            for i, v in ipairs(self.m_makeReserveQueue) do
                if (item == v) then
                    table.remove(self.m_makeReserveQueue, i)
                    break
                end
            end
        end
    end
end

-------------------------------------
-- function getCellUI
-- @brief
-------------------------------------
function UIC_ChatView:getCellUI(unique_id)
    local t_item = self:getItem(unique_id)

    if (not t_item['ui']) then
        t_item['ui'] = self:makeItemUI(t_item['data'])
        local idx = t_item['idx']
        self:updateCellAtIndex(idx)

        -- 생성 예약 리스트에서 삭제
        for i, v in ipairs(self.m_makeReserveQueue) do
            if (t_item == v) then
                table.remove(self.m_makeReserveQueue, i)
                break
            end
        end
    end

    return t_item['ui']
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
-- function clearItemList
-------------------------------------
function UIC_ChatView:clearItemList()
    if self.m_itemList then
        for i,v in ipairs(self.m_itemList) do
            if v['ui'] then
                v['ui'].root:removeFromParent()
            end
        end
    end

    self.m_itemList = {}
    self.m_itemMap = {}
    self._cellsUsed = {}
end

-------------------------------------
-- function clearCellsUsed
-------------------------------------
function UIC_ChatView:clearCellsUsed()
    for i,v in ipairs(self._cellsUsed) do
        if v['ui'] then
            v['ui']:setCellVisible(false)
        end
    end

    self._cellsUsed = {}
end

-------------------------------------
-- function expandTemp
-------------------------------------
function UIC_ChatView:expandTemp(duration, animated)
    local duration = duration or 0.15

    -- 현재 보여지는 애들 리스트
    local l_visible_cells = {}
    for i,v in ipairs(self._cellsUsed) do
        local idx = v['idx']
        if idx then
            l_visible_cells[idx] = v
        end
    end

    self:_updateCellPositions()
    self:_updateContentSize(true)
    self:scrollViewDidScroll(true)

    -- Item UI를 즉시 생성하기 위해  m_bFirstLocation를 true로 설정
    self.m_bFirstLocation = true
    self:scrollViewDidScroll()
    self.m_bFirstLocation = false

    -- 변경 후 보여질 애들 리스트
    for i,v in ipairs(self._cellsUsed) do
        local idx = v['idx']
        l_visible_cells[idx] = v
    end

    -- 눈에 보여지도록 추가
    for i,v in pairs(l_visible_cells) do
        if v['ui'] then
            v['ui']:cellVisibleRetain(duration)
        end
    end

    -- cell들 이동
    for i,v in ipairs(self.m_itemList) do
        local ui = self.m_itemList[i]['ui']

        if ui then
            local offset = self:_offsetFromIndex(i)
            ui:cellMoveTo(duration, offset)
        end
    end

    if (animated == nil) then
        animated = true
    end
    self:relocateContainer(animated)
end

-------------------------------------
-- function setCellUIClass
-------------------------------------
function UIC_ChatView:setCellUIClass(ui_class, ui_create_cb)
    self.m_cellUIClass = ui_class
    self.m_cellUICreateCB = ui_create_cb
end

-------------------------------------
-- function makeItemUI
-------------------------------------
function UIC_ChatView:makeItemUI(data)
    local ui = self.m_cellUIClass(data)
    ui.root:setSwallowTouch(false)
    if ui.vars['swallowTouchMenu'] then
        ui.vars['swallowTouchMenu']:setSwallowTouch(false)
    end
    ui.root:setDockPoint(cc.p(0, 0))
    ui.root:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_scrollView:addChild(ui.root)

    if self.m_cellUICreateCB then
        self.m_cellUICreateCB(ui, data)
    end

    return ui
end

-------------------------------------
-- function getItem
-- @breif
-------------------------------------
function UIC_ChatView:getItem(unique_id)
    return self.m_itemMap[unique_id]
end

-------------------------------------
-- function setDirtyItemList
-------------------------------------
function UIC_ChatView:setDirtyItemList()
    self.m_bDirtyItemList = true
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

    for i=1, 5 do
        local chat_content = ChatContent()
        chat_content['nickname'] = '닉넴'
        chat_content['uid'] = 102893
        chat_content['message'] = '안녕하세요 ' .. i

        chat_view:addChatContent(chat_content)
    end
    
    chat_view:updateContentList()
end

-------------------------------------
-- function addChatContent
-------------------------------------
function UIC_ChatView:addChatContent(chat_content)
    ccdump(chat_content)

    local t_item = {}
    t_item['data'] = chat_content
    t_item['ui'] = UI_ChatListItem(chat_content)


    table.insert(self.m_itemList, t_item)

    

    local _container = self.m_scrollView:getContainer()
    ccdump(_container:getNormalSize())
    _container:addChild(t_item['ui'].root)
end


-------------------------------------
-- function updateContentList
-------------------------------------
function UIC_ChatView:updateContentList()

    local function sort_func(a, b)
        return (a['data'].m_timestamp >= b['data'].m_timestamp)
    end

    table.sort(self.m_itemList, sort_func)

    self.m_itemPositions = {0}

    local _y = 0
    for i,v in ipairs(self.m_itemList) do
        local cell_size = v['ui']:getCellSize()
        v['ui'].root:setPositionY(_y + (cell_size['height'] / 2))
        v['ui'].root:setDockPoint(cc.p(0.5, 0))
        v['ui'].root:setAnchorPoint(cc.p(0.5, 0.5))
        _y = _y + cell_size['height']
        self.m_itemPositions[i+1] = _y
    end

    local total_content_height = self.m_itemPositions[#self.m_itemPositions]

    local view_size = self.m_scrollView:getViewSize()
    view_size['height'] = math_max(view_size['height'], total_content_height)
    self.m_scrollView:setContentSize(view_size)
    ccdump(self.m_itemPositions)
end