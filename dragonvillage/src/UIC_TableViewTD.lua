local PARENT = UIC_Node

-------------------------------------
-- class UIC_TableViewTD
-------------------------------------
UIC_TableViewTD = class(PARENT, {
        m_scrollView = 'cc.ScrollView',
        m_itemList = '',
        m_itemMap = '',

        m_cellSize = '', -- cell하나의 사이즈

        _cellsUsed = 'list',
        _vLinePositions = 'list',

        m_cellUIClass = 'class',
        
        m_lSortInfo = 'table', -- {name = sort_func}
        m_currSortType = 'string',

        m_cellUICreateCB = 'function',
        m_nItemPerCell = 'number',
        m_bFirstLocation = 'boolean',

        m_makeReserveQueue = 'stack',
        m_makeTimer = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_TableViewTD:init(node)

    -- retain된 item들을 release하기 위해
    node:registerScriptHandler(function(event)
        if (event == 'cleanup') then
            self:clearItemList()
        end
    end)

    -- 기본값 설정
    self.m_cellSize = cc.size(100, 100)
    self.m_nItemPerCell = 2
    self.m_bFirstLocation = true

    -- 스크롤 뷰 생성
    local content_size = node:getContentSize()
    self:makeScrollView(content_size)

    do -- 정렬
        self.m_lSortInfo = {}
        self.m_currSortType = nil
    end

    -- UI생성 큐
    self.m_makeReserveQueue = {}
    self.m_makeTimer = 0
end

-------------------------------------
-- function makeScrollView
-------------------------------------
function UIC_TableViewTD:makeScrollView(size)
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

    -- 방향 설정
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.m_node:addChild(scroll_view)

    scroll_view:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UIC_TableViewTD:update(dt)
    self.m_makeTimer = (self.m_makeTimer - dt)
    if (self.m_makeTimer <= 0) then
        
        if self.m_makeReserveQueue[1] then
            local t_item = self.m_makeReserveQueue[1]
            local data = t_item['data']
            t_item['ui'] = self:makeItemUI(data)
            local idx = t_item['idx']
            self:updateCellAtIndex(idx)
            
            table.remove(self.m_makeReserveQueue, 1)
        end

        self.m_makeTimer = 0.03
    end
end

-------------------------------------
-- function _updateLinePositions
-------------------------------------
function UIC_TableViewTD:_updateLinePositions()
    
    for i, v in ipairs(self.m_itemList) do
        self.m_itemList[i]['idx'] = i
    end

    local lineCount = self:getLineCount()

    self._vLinePositions = {}

    if (lineCount > 0) then
        local currentPos = 0
        for i=1, lineCount do
            self._vLinePositions[i] = currentPos;
            local cellSize = self.m_cellSize
            currentPos = currentPos + cellSize['height']
        end
        self._vLinePositions[lineCount + 1] = currentPos;--1 extra value allows us to get right/bottom of the last cell
    end
end

-------------------------------------
-- function _updateContentSize
-------------------------------------
function UIC_TableViewTD:_updateContentSize(skip_update_cells)
    local size = cc.size(0, 0)

    local lineCount = self:getLineCount()

    local viewSize = self.m_scrollView:getViewSize()

    if (lineCount > 0) then
        local maxPosition = self._vLinePositions[lineCount + 1]
        size = cc.size(viewSize['width'], maxPosition)
    end

    self.m_scrollView:setContentSize(size)

    -- cell들의 위치를 업데이트
    local cellsCount = #self.m_itemList
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
function UIC_TableViewTD:scrollViewDidScroll(scroll_view)
    local lineCount = self:getLineCount()

    if (0 == lineCount) then
        return
    end

    local startLine = 1
    local endLine = 1
    local maxIdx = math_max(lineCount, 1)

    -- 현재 컨테이너의 위치를 얻어옴
    local offset = self.m_scrollView:getContentOffset()
    offset['x'] = offset['x'] * -1
    offset['y'] = offset['y'] * -1

    -- 뷰사이즈를 얻어옴
    local viewSize = self.m_scrollView:getViewSize()

    -- 시작 idx 얻어옴
    offset['y'] = offset['y'] + viewSize['height']
    startLine = self:_indexFromOffset(offset)
    if (startLine == -1) then
		startLine = lineCount
	end

    -- 종료 idx 얻어옴
    offset['y'] = offset['y'] - viewSize['height']
    offset['x'] = offset['x'] + viewSize['width']
    endLine = self:_indexFromOffset(offset)

    if (endLine == -1) then
        endLine = lineCount
	end

    local itemCount = self:getItemCount()

    local startIdx = ((startLine - 1) * self.m_nItemPerCell) + 1
    startIdx = math_clamp(startIdx, 1, itemCount)

    local endIdx = endLine * self.m_nItemPerCell
    endIdx = math_clamp(endIdx, 1, itemCount)

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

            -- 최초 생성 시 즉시 생성
            --if self.m_bFirstLocation then
            if false then
                local data = t_item['data']
                t_item['ui'] = self:makeItemUI(data)
                local idx = t_item['idx']
                self:updateCellAtIndex(idx)

            -- 이후 생성 시
            else
                if (not t_item['reserved']) then
                    table.insert(self.m_makeReserveQueue, t_item)
                    t_item['reserved'] = true
                end
            end
        else
            t_item['ui']:setCellVisible(true)
        end

        table.insert(self._cellsUsed, t_item)
    end
end

-------------------------------------
-- function _indexFromOffset
-------------------------------------
function UIC_TableViewTD:_indexFromOffset(offset)
    local index = 1
    local maxIdx = self:getLineCount()

    offset = cc.p(offset['x'], offset['y'])
    offset['y'] = self.m_scrollView:getContainer():getContentSize()['height'] - offset['y'];
    
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
function UIC_TableViewTD:__indexFromOffset(offset)
    local low = 1
    local high = self:getLineCount()
    local search;

    search = offset['y']

    while (high >= low) do
        local index = math_floor(low + (high - low) / 2)
        local cellStart = self._vLinePositions[index];
        local cellEnd = self._vLinePositions[index + 1];

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
function UIC_TableViewTD:maxContainerOffset()
    return 0, 0
end

-------------------------------------
-- function minContainerOffset
-------------------------------------
function UIC_TableViewTD:minContainerOffset()
    local viewSize = self.m_scrollView:getViewSize()

    local _container = self.m_scrollView:getContainer()
    local size = _container:getContentSize()

    local x = viewSize['width'] - size['width']
    local y = viewSize['height'] - size['height']

    return x, y
end

function UIC_TableViewTD:_offsetFromIndex(index)
    local offset = self:__offsetFromIndex(index)

    local cellSize = self.m_cellSize

    local container_size = self.m_scrollView:getContainer():getContentSize()

    offset['y'] = container_size['height'] - offset['y'] - cellSize['height']

    do -- 가운데 정렬을 위해
        offset['x'] = offset['x'] + (cellSize['width'] / 2)
        offset['y'] = offset['y'] + (cellSize['height'] / 2)
    end

    return offset
end

function UIC_TableViewTD:__offsetFromIndex(index)
    local offset = cc.p(0, 0)
    local cellSize = cc.size(0, 0)

    local line = self:calcLineIdx(index)
    offset['y'] = self._vLinePositions[line]

    local idx_x = math_max(0, self:calcXIdx(index) - 1)
    offset['x'] = self.m_cellSize['width'] * idx_x

    return offset
end

function UIC_TableViewTD:updateCellAtIndex(idx)
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
function UIC_TableViewTD:setItemList(list, skip_update, make_item)
    self:clearItemList()

    for key,data in pairs(list) do
        local t_item = {}
        t_item['unique_id'] = key
        t_item['data'] = data

        local idx = #self.m_itemList + 1

        -- UI를 미리 생성
        if make_item then
            t_item['ui'] = self:makeItemUI(data)
        end

        -- 리스트에 추가
        table.insert(self.m_itemList, t_item)

        -- 맵에 등록
        self.m_itemMap[key] = t_item
    end

    if skip_update then
        return
    end

    self:_updateLinePositions()
    self:_updateContentSize()

    --self:relocateContainerDefault()
    --self:scrollViewDidScroll()
end

-------------------------------------
-- function relocateContainer
-- @brief
-------------------------------------
function UIC_TableViewTD:relocateContainer(animated)
    local scroll_view = self.m_scrollView

    local oldPoint = cc.p(0, 0)
    local min, max;
    local newX, newY;

    min = scroll_view:minContainerOffset();
    max = scroll_view:maxContainerOffset();

    oldPoint.x, oldPoint.y = scroll_view:getContainer():getPosition();

    newX     = oldPoint.x;
    newY     = oldPoint.y;

    newY     = math_min(newY, max.y);
    newY     = math_max(newY, min.y);

    if (newY ~= oldPoint.y or newX ~= oldPoint.x) then
        scroll_view:setContentOffset(cc.p(newX, newY), animated);
    end
end

-------------------------------------
-- function relocateContainerDefault
-- @brief 시작 위치로 설정
-------------------------------------
function UIC_TableViewTD:relocateContainerDefault(animated)
    local min_offset_x, min_offset_y = self:minContainerOffset()
    self.m_scrollView:setContentOffset(cc.p(0, min_offset_y), animated)
end

-------------------------------------
-- function clearItemList
-------------------------------------
function UIC_TableViewTD:clearItemList()
    if self.m_itemList then
        for i,v in ipairs(self.m_itemList) do
            if v['ui'] then
                v['ui'].root:removeFromParent()
                --v['ui'].root:release()
            end
        end
    end

    self.m_itemList = {}
    self.m_itemMap = {}
    self._cellsUsed = {}
    self.m_makeReserveQueue = {}
end

-------------------------------------
-- function clearCellsUsed
-------------------------------------
function UIC_TableViewTD:clearCellsUsed()
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
function UIC_TableViewTD:expandTemp(duration)
    local duration = duration or 0.15

    -- 현재 보여지는 애들 리스트
    local l_visible_cells = {}
    for i,v in ipairs(self._cellsUsed) do
        local idx = v['idx']
        l_visible_cells[idx] = v
    end

    self:_updateLinePositions()
    self:_updateContentSize(true)

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
end

-------------------------------------
-- function setCellUIClass
-------------------------------------
function UIC_TableViewTD:setCellUIClass(ui_class, ui_create_cb)
    self.m_cellUIClass = ui_class
    self.m_cellUICreateCB = ui_create_cb
end

-------------------------------------
-- function makeItemUI
-------------------------------------
function UIC_TableViewTD:makeItemUI(data)
    local ui = self.m_cellUIClass(data)
    ui.root:setSwallowTouch(false)
    ui.root:setDockPoint(cc.p(0, 0))
    ui.root:setAnchorPoint(cc.p(0.5, 0.5))
    --ui.root:retain()

    self.m_scrollView:addChild(ui.root)

    if self.m_cellUICreateCB then
        self.m_cellUICreateCB(ui, data)
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
function UIC_TableViewTD:insertSortInfo(sort_type, sort_func)
    self.m_lSortInfo[sort_type] = sort_func
end

-------------------------------------
-- function sortTableView
-- @brief
-------------------------------------
function UIC_TableViewTD:sortTableView(sort_type, b_force)
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
function UIC_TableViewTD:sortImmediately(sort_type)
    self.m_currSortType = sort_type

    local sort_func = self.m_lSortInfo[sort_type]
    table.sort(self.m_itemList, sort_func)

    self:clearCellsUsed()
    self:_updateLinePositions()
    self:_updateContentSize()
    self:scrollViewDidScroll()
end

-------------------------------------
-- function getItem
-- @breif
-------------------------------------
function UIC_TableViewTD:getItem(unique_id)
    return self.m_itemMap[unique_id]
end

-------------------------------------
-- function addItem
-- @breif
-------------------------------------
function UIC_TableViewTD:addItem(unique_id, t_data)
    self:delItem(unique_id)

    local t_item = {}
    t_item['unique_id'] = unique_id
    t_item['data'] = t_data

    self.m_itemMap[unique_id] = t_item
    self.m_itemList[#self.m_lItem + 1] = t_item
end

-------------------------------------
-- function delItem
-- @breif
-------------------------------------
function UIC_TableViewTD:delItem(unique_id)
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
            --ui.root:release()
            t_item['ui'] = nil

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
    end
end

-------------------------------------
-- function getItemCount
-- @breif
-------------------------------------
function UIC_TableViewTD:getItemCount()
    local count = table.count(self.m_itemList)
    return count
end

-------------------------------------
-- function calcLineIdx
-------------------------------------
function UIC_TableViewTD:calcLineIdx(idx)
    local lineIdx = math_floor(idx / self.m_nItemPerCell)
    local rest_of_division = (idx % self.m_nItemPerCell)
    if (rest_of_division > 0) then
        lineIdx = lineIdx + 1
    end
    return lineIdx
end

-------------------------------------
-- function calcXIdx
-------------------------------------
function UIC_TableViewTD:calcXIdx(idx)
    if (idx == 0) then
        return 0
    elseif (idx % self.m_nItemPerCell) == 0 then
        return self.m_nItemPerCell
    else
        return idx % self.m_nItemPerCell
    end
end


-------------------------------------
-- function getLineCount
-------------------------------------
function UIC_TableViewTD:getLineCount()
    local cellsCount = #self.m_itemList
    local lineCount = self:calcLineIdx(cellsCount)
    return lineCount
end

-- _swallowTouch가 false일 경우 CCMenu 클래스의 onTouchBegan함수에서
-- collectSlideNodesInParents()를 수행. 즉, 부모들 중에 SlideNode타입을 수집

-- getItemForTouch() 함수 안에서
-- isIgnoreTouch() 함수 안에서

-- 수집된 SlideNode부모들의 영역안에 포함되어있지 않으면 터치를 하지 않게 처리함