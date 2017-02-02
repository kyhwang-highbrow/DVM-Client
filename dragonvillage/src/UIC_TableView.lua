local PARENT = UIC_Node

VerticalFillOrder = {}
VerticalFillOrder['TOP_DOWN'] = 0
VerticalFillOrder['BOTTOM_UP'] = 1

-------------------------------------
-- class UIC_TableView
-------------------------------------
UIC_TableView = class(PARENT, {
        m_scrollView = 'cc.ScrollView',
        m_itemList = '',
        m_itemMap = '',

        m_bUseEachSize = 'boolean', -- 셀별 개별 크기 적용 여부(사용시 _size세팅 필수!!)
        m_defaultCellSize = '', -- cell이 생성되기 전이라면 기본 사이즈를 지정

        _cellsUsed = 'list',
        _vCellsPositions = 'list',

        _direction = '',
        _vordering = 'VerticalFillOrder',

        m_makeReserveQueue = 'stack',
        m_makeTimer = 'number',

        m_cellUIClass = 'class',
        
        m_lSortInfo = 'table', -- {name = sort_func}
        m_currSortType = 'string',

        m_cellUICreateCB = 'function',
        m_cellUIAppearCB = 'function',

        -- 리스트 내 개수 부족 시 가운데 정렬
        m_bAlignCenterInInsufficient = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_TableView:init(node)
    -- 기본값 설정
    self.m_bUseEachSize = false
    self.m_defaultCellSize = cc.size(100, 100)
    self._vordering = VerticalFillOrder['TOP_DOWN']

    -- 스크롤 뷰 생성
    local content_size = node:getContentSize()
    self:makeScrollView(content_size)

    -- UI생성 큐
    self.m_makeReserveQueue = {}
    self.m_makeTimer = 0

    do -- 정렬
        self.m_lSortInfo = {}
        self.m_currSortType = nil
    end
end

-------------------------------------
-- function makeScrollView
-------------------------------------
function UIC_TableView:makeScrollView(size)
    local scroll_view = cc.ScrollView:create()
    self.m_scrollView = scroll_view

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

    -- 방향 설정수평 UI
    self:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    --self:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.m_node:addChild(scroll_view)

    scroll_view:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UIC_TableView:update(dt)
    self.m_makeTimer = (self.m_makeTimer - dt)
    if (self.m_makeTimer <= 0) then
        
        if self.m_makeReserveQueue[1] then
            local t_item = self.m_makeReserveQueue[1]
            local data = t_item['data']
            t_item['ui'] = self:makeItemUI(data, t_item['unique_id'])
            local idx = t_item['idx']
            self:updateCellAtIndex(idx)
            
            table.remove(self.m_makeReserveQueue, 1)

            if self.m_cellUIAppearCB then
                self.m_cellUIAppearCB(t_item['ui'])
            end
        end

        self.m_makeTimer = 0.03
    end
end

-------------------------------------
-- function _updateCellPositions
-------------------------------------
function UIC_TableView:_updateCellPositions()
    local cellsCount = #self.m_itemList

    self._vCellsPositions = {}

    if (cellsCount > 0) then
        local currentPos = 0
        for i=1, cellsCount do
            self._vCellsPositions[i] = currentPos;
            local cellSize = self:tableCellSizeForIndex(i)

            -- 가로
            if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
                currentPos = currentPos + cellSize['width']
            -- 세로
            else
                currentPos = currentPos + cellSize['height']
            end

            self.m_itemList[i]['idx'] = i
        end
        self._vCellsPositions[cellsCount + 1] = currentPos;--1 extra value allows us to get right/bottom of the last cell
    end
end

-------------------------------------
-- function _updateContentSize
-------------------------------------
function UIC_TableView:_updateContentSize(skip_update_cells)
    local size = cc.size(0, 0)

    local cellsCount = #self.m_itemList

    local viewSize = self.m_scrollView:getViewSize()

    if (cellsCount > 0) then
        local maxPosition = self._vCellsPositions[cellsCount + 1]

        if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
            size = cc.size(maxPosition, viewSize['height'])
        else
            size = cc.size(viewSize['width'], maxPosition)
        end
    end

    self.m_scrollView:setContentSize(size)

    -- cell들의 위치를 업데이트
    if (not skip_update_cells) then
        for i=1, cellsCount do
            self:updateCellAtIndex(i)
        end
    end
end

-------------------------------------
-- function scrollViewDidScroll
-------------------------------------
function UIC_TableView:scrollViewDidScroll()
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
    if (self._vordering == VerticalFillOrder['TOP_DOWN']) then
        offset['y'] = offset['y'] + viewSize['height']
    end
    startIdx = self:_indexFromOffset(offset)
    if (startIdx == -1) then
		startIdx = cellsCount
	end

    -- 종료 idx 얻어옴
    if (self._vordering == VerticalFillOrder['TOP_DOWN']) then
        offset['y'] = offset['y'] - viewSize['height']
    else
        offset['y'] = offset['y'] + viewSize['height']
    end
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

        if (not t_item['ui']) then

            if (not t_item['reserved']) then
                table.insert(self.m_makeReserveQueue, t_item)
                t_item['reserved'] = true
            end

            --[[
            local data = t_item['data']
            t_item['ui'] = self:makeItemUI(data)
            local idx = t_item['idx']
            self:updateCellAtIndex(idx)
            --]]
        else
            t_item['ui']:setCellVisible(true)
        end

        table.insert(self._cellsUsed, t_item)
    end
end


-------------------------------------
-- function tableCellSizeForIndex
-------------------------------------
function UIC_TableView:tableCellSizeForIndex(idx)
    if (not self.m_bUseEachSize) then
        return self.m_defaultCellSize
    end

    local t_item = self.m_itemList[idx]
    local ui = t_item['ui']

    if (not ui) then
        return self.m_defaultCellSize    
    end

    local size = ui:getCellSize()
    return size
end

-------------------------------------
-- function _indexFromOffset
-------------------------------------
function UIC_TableView:_indexFromOffset(offset)
    local index = 1
    local  maxIdx = #self.m_itemList

    if (self._vordering == VerticalFillOrder['TOP_DOWN']) then
        offset = cc.p(offset['x'], offset['y'])
        offset['y'] = self.m_scrollView:getContainer():getContentSize()['height'] - offset['y'];
    end
    
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
function UIC_TableView:__indexFromOffset(offset)
    local low = 1
    local high = #self.m_itemList
    local search;

    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        search = offset['x']
    else
        search = offset['y']
    end

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
function UIC_TableView:maxContainerOffset()
    return 0, 0
end

-------------------------------------
-- function minContainerOffset
-------------------------------------
function UIC_TableView:minContainerOffset()
    local viewSize = self.m_scrollView:getViewSize()

    local _container = self.m_scrollView:getContainer()
    local size = _container:getContentSize()

    local x = viewSize['width'] - size['width']
    local y = viewSize['height'] - size['height']

    return x, y
end

function UIC_TableView:_offsetFromIndex(index)
    local offset = self:__offsetFromIndex(index)

    local cellSize = self:tableCellSizeForIndex(index)

    if (self._vordering == VerticalFillOrder['TOP_DOWN']) then
        offset['y'] = self.m_scrollView:getContainer():getContentSize()['height'] - offset['y'] - cellSize['height']
    end

    do -- 가운데 정렬을 위해
        offset['x'] = offset['x'] + (cellSize['width'] / 2)
        offset['y'] = offset['y'] + (cellSize['height'] / 2)
    end

    
    -- 리스트 내 개수 부족 시 가운데 정렬
    if self.m_bAlignCenterInInsufficient then
        local viewSize = self.m_scrollView:getViewSize()
        local container_size = self._vCellsPositions[#self._vCellsPositions]

        -- 가로
        if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
            if (container_size < viewSize['width']) then
                offset['x'] = offset['x'] + (viewSize['width'] - container_size) / 2
            end
        -- 세로
        else
            if (container_size < viewSize['height']) then
                offset['y'] = offset['y'] + (viewSize['height'] - container_size) / 2
            end
        end
    end

    return offset
end

function UIC_TableView:__offsetFromIndex(index)
    local offset = cc.p(0, 0)
    local cellSize = cc.size(0, 0)

    -- 가로
    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        offset['x'] = self._vCellsPositions[index]
    -- 세로
    else
        offset['y'] = self._vCellsPositions[index]
    end

    return offset
end

function UIC_TableView:updateCellAtIndex(idx)
    local offset = self:_offsetFromIndex(idx)

    local ui = self.m_itemList[idx]['ui']

    if ui then
        ui.root:setPosition(offset['x'], offset['y'])
    end
end












-------------------------------------
-- function setDirection
-- @param direction
-- cc.SCROLLVIEW_DIRECTION_NONE = -1
-- cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0
-- cc.SCROLLVIEW_DIRECTION_VERTICAL = 1
-- cc.SCROLLVIEW_DIRECTION_BOTH  = 2
-------------------------------------
function UIC_TableView:setDirection(direction)
    self.m_scrollView:setDirection(direction)
    self._direction = direction
end

-------------------------------------
-- function setItemList
-- @brief list는 key값이 고유해야 하며, value로는 UI생성에 필요한 데이터가 있어야 한다
-------------------------------------
function UIC_TableView:setItemList(list, skip_update, make_item)
    self:clearItemList()

    for key,data in pairs(list) do
        local t_item = {}
        t_item['unique_id'] = key
        t_item['data'] = data

        local idx = #self.m_itemList + 1

        -- UI를 미리 생성
        if make_item then
            t_item['ui'] = self:makeItemUI(data, key)
        end

        -- 리스트에 추가
        table.insert(self.m_itemList, t_item)

        -- 맵에 등록
        self.m_itemMap[key] = t_item
    end

    if skip_update then
        return
    end

    self:_updateCellPositions()
    self:_updateContentSize()

    self:relocateContainerDefault()

    self:scrollViewDidScroll()
end

-------------------------------------
-- function getCellUI
-- @brief
-------------------------------------
function UIC_TableView:getCellUI(unique_id)
    local t_item = self:getItem(unique_id)

    if (not t_item['ui']) then
        t_item['ui'] = self:makeItemUI(t_item['data'], t_item['unique_id'])
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
function UIC_TableView:relocateContainer(animated)
    local scroll_view = self.m_scrollView

    local oldPoint = cc.p(0, 0)
    local min, max;
    local newX, newY;

    min = scroll_view:minContainerOffset();
    max = scroll_view:maxContainerOffset();

    oldPoint.x, oldPoint.y = scroll_view:getContainer():getPosition();

    newX     = oldPoint.x;
    newY     = oldPoint.y;
    if (self._direction == cc.SCROLLVIEW_DIRECTION_BOTH or self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        newX     = math_max(newX, min.x);
        newX     = math_min(newX, max.x);
    end

    if (self._direction == cc.SCROLLVIEW_DIRECTION_BOTH or self._direction == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
        newY     = math_min(newY, max.y);
        newY     = math_max(newY, min.y);
    end

    if (newY ~= oldPoint.y or newX ~= oldPoint.x) then
        scroll_view:setContentOffset(cc.p(newX, newY), animated);
    end
end

-------------------------------------
-- function relocateContainerDefault
-- @brief 시작 위치로 설정
-------------------------------------
function UIC_TableView:relocateContainerDefault(animated)
    -- 가로
    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        self.m_scrollView:setContentOffset(cc.p(0, 0), animated)

    -- 세로
    else
        if (self._vordering == VerticalFillOrder['TOP_DOWN']) then
            local min_offset_x, min_offset_y = self:minContainerOffset()
            self.m_scrollView:setContentOffset(cc.p(0, min_offset_y), animated)
        else
            self.m_scrollView:setContentOffset(cc.p(0, 0), animated)
        end
    end
end

-------------------------------------
-- function clearItemList
-------------------------------------
function UIC_TableView:clearItemList()
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
function UIC_TableView:clearCellsUsed()
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
function UIC_TableView:expandTemp(duration, animated)
    local duration = duration or 0.15

    -- 현재 보여지는 애들 리스트
    local l_visible_cells = {}
    for i,v in ipairs(self._cellsUsed) do
        local idx = v['idx']
        l_visible_cells[idx] = v
    end

    self:_updateCellPositions()
    self:_updateContentSize(true)
    self:scrollViewDidScroll(true)

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
    else
        animated = false
    end
    self:relocateContainer(animated)
end

-------------------------------------
-- function setCellUIClass
-------------------------------------
function UIC_TableView:setCellUIClass(ui_class, ui_create_cb)
    self.m_cellUIClass = ui_class
    self.m_cellUICreateCB = ui_create_cb
end

-------------------------------------
-- function makeItemUI
-------------------------------------
function UIC_TableView:makeItemUI(data, key)
    local ui = self.m_cellUIClass(data)
    ui.root:setSwallowTouch(false)
    if ui.vars['swallowTouchMenu'] then
        ui.vars['swallowTouchMenu']:setSwallowTouch(false)
    end
    ui.root:setDockPoint(cc.p(0, 0))
    ui.root:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_scrollView:addChild(ui.root)

    if self.m_cellUICreateCB then
        -- true를 리턴했을 경우 연출을 사용하지 않겠다는 뜻으로 즉시 리턴
        if self.m_cellUICreateCB(ui, data, key) then
            return ui
        end
    end

    local scale = ui.root:getScale()
    ui.root:setScale(scale * 0.2)
    local scale_to = cc.ScaleTo:create(0.25, scale)
    local action = cc.EaseInOut:create(scale_to, 2)
    ui.root:runAction(action)

    return ui
end

-------------------------------------
-- function insertSortInfo
-------------------------------------
function UIC_TableView:insertSortInfo(sort_type, sort_func)
    self.m_lSortInfo[sort_type] = sort_func
end

-------------------------------------
-- function sortTableView
-- @brief
-------------------------------------
function UIC_TableView:sortTableView(sort_type, b_force)
    if (not b_force) and (self.m_currSortType == sort_type) then
        return
    end

    self.m_currSortType = sort_type

    local sort_func = self.m_lSortInfo[sort_type]
    table.sort(self.m_itemList, sort_func)

    --
    self:expandTemp(0.5)
end

-------------------------------------
-- function sortImmediately
-- @brief
-------------------------------------
function UIC_TableView:sortImmediately(sort_type)
    self.m_currSortType = sort_type

    local sort_func = self.m_lSortInfo[sort_type]
    table.sort(self.m_itemList, sort_func)

    self:clearCellsUsed()
    self:_updateCellPositions()
    self:_updateContentSize()
    self:scrollViewDidScroll()
end

-------------------------------------
-- function getItem
-- @breif
-------------------------------------
function UIC_TableView:getItem(unique_id)
    return self.m_itemMap[unique_id]
end

-------------------------------------
-- function addItem
-- @breif
-------------------------------------
function UIC_TableView:addItem(unique_id, t_data)
    self:delItem(unique_id)

    local t_item = {}
    t_item['unique_id'] = unique_id
    t_item['data'] = t_data

    self.m_itemMap[unique_id] = t_item
    self.m_itemList[#self.m_itemList + 1] = t_item
end

-------------------------------------
-- function delItem
-- @breif
-------------------------------------
function UIC_TableView:delItem(unique_id)
    -- map리스트에서 삭제
    self.m_itemMap[unique_id] = nil

    local idx = nil
    local t_item = nil

    for i,item in pairs(self.m_itemList) do
        if (item['unique_id'] == unique_id) then
            t_item = item
            idx = i
            break
        end
    end

    if t_item then
        local ui = t_item['ui']
        if ui then
            ui.root:removeFromParent()
            t_item['ui'] = nil

            for i, v in ipairs(self._cellsUsed) do
                if v['idx'] == t_item['idx'] then
                    table.remove(self._cellsUsed, i)
                    break
                end
            end

            -- _cellsUsed에서 삭제
            for i, v in ipairs(self._cellsUsed) do
                if v['idx'] == t_item['idx'] then
                    table.remove(self._cellsUsed, i)
                    break
                end
            end

            -- 생성 예약 리스트에서 삭제
            for i, v in ipairs(self.m_makeReserveQueue) do
                if (t_item == v) then
                    table.remove(self.m_makeReserveQueue, i)
                    break
                end
            end
        end
    end

    if idx then
        table.remove(self.m_itemList, idx)
        return true
    else
        return false
    end
end

-------------------------------------
-- function getItemCount
-- @breif
-------------------------------------
function UIC_TableView:getItemCount()
    local count = table.count(self.m_itemList)
    return count
end

-------------------------------------
-- function mergeItemList
-- @breif
-------------------------------------
function UIC_TableView:mergeItemList(list)
    local dirty = false

    -- 새로 생긴 데이터 추가
    for i,v in pairs(list) do
        if (not self.m_itemMap[i]) then
            self:addItem(i, v)
            dirty = true
        end
    end

    -- 사라진 데이터 삭제
    for i,v in pairs(self.m_itemMap) do
        if (not list[i]) then
            self:delItem(i)
            dirty = false
        end
    end

    -- 갱신
    if dirty then
        self:expandTemp(0.5)
        self:relocateContainer(animated)
    end
end