local PARENT = UIC_Node

VerticalFillOrder = {}
VerticalFillOrder['TOP_DOWN'] = 0
VerticalFillOrder['BOTTOM_UP'] = 1

-------------------------------------
-- class UIC_TableViewCore
-------------------------------------
UIC_TableViewCore = class(PARENT, {
        m_scrollView = 'cc.ScrollView',
        m_itemList = '',
        m_itemMap = '',


        m_defaultCellSize = '', -- cell이 생성되기 전이라면 기본 사이즈를 지정

        _cellsUsed = 'list',
        _vCellsPositions = 'list',

        _vordering = 'VerticalFillOrder',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_TableViewCore:init(node)

    -- retain된 item들을 release하기 위해
    node:registerScriptHandler(function(event)
        if (event == 'cleanup') then
            self:clearItemList()
        end
    end)

    -- 기본값 설정
    self.m_defaultCellSize = cc.size(100, 100)
    self._vordering = VerticalFillOrder['BOTTOM_UP']

    -- 스크롤 뷰 생성
    local content_size = node:getContentSize()
    self:makeScrollView(content_size)
end

-------------------------------------
-- function makeScrollView
-------------------------------------
function UIC_TableViewCore:makeScrollView(size)
    local scroll_view = cc.ScrollView:create()
    self.m_scrollView = scroll_view

    scroll_view:setDockPoint(cc.p(0.5, 0.5))
    scroll_view:setAnchorPoint(cc.p(0.5, 0.5))

    scroll_view:setDelegate()

    -- 스크롤 handler
    local scrollViewDidScroll = function(view)
        self:scrollViewDidScroll(view)
    end
    scroll_view:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)

    -- 실질적인 테이블 뷰 사이즈 설정
    scroll_view:setViewSize(size)

    -- 방향 설정수평 UI
    self:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    --self:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.m_node:addChild(scroll_view)
end

-------------------------------------
-- function _updateCellPositions
-------------------------------------
function UIC_TableViewCore:_updateCellPositions()
    local cellsCount = #self.m_itemList

    self._vCellsPositions = {}

    local direction = self.m_scrollView:getDirection()

    if (cellsCount > 0) then
        local currentPos = 0
        for i=1, cellsCount do
            self._vCellsPositions[i] = currentPos;
            local cellSize = self:tableCellSizeForIndex(i)

            -- 가로
            if (direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
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
function UIC_TableViewCore:_updateContentSize(skip_update_cells)
    local size = cc.size(0, 0)

    local cellsCount = #self.m_itemList

    local viewSize = self.m_scrollView:getViewSize()

    if (cellsCount > 0) then
        local direction = self.m_scrollView:getDirection()
        local maxPosition = self._vCellsPositions[cellsCount + 1]

        if (direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
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
function UIC_TableViewCore:scrollViewDidScroll(view)
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
                cell['ui']:setVisible(false)
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
                cell['ui']:setVisible(false)
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
    local direction = self.m_scrollView:getDirection()
    for i=startIdx, endIdx do
        local t_item = self.m_itemList[i]

        if (not t_item['ui']) then
            local data = t_item['data']
            t_item['ui'] = self:makeItemUI(data)

            local pos = self._vCellsPositions[i]
            -- 가로
            if (direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
                t_item['ui'].root:setPositionX(pos)
            -- 세로
            else
                t_item['ui'].root:setPositionY(pos)
            end
        else
            t_item['ui']:setVisible(true)
        end

        table.insert(self._cellsUsed, t_item)
    end
end


-------------------------------------
-- function tableCellSizeForIndex
-------------------------------------
function UIC_TableViewCore:tableCellSizeForIndex(idx)
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
function UIC_TableViewCore:_indexFromOffset(offset)
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
function UIC_TableViewCore:__indexFromOffset(offset)
    local low = 1
    local high = #self.m_itemList
    local search;

    local direction = self.m_scrollView:getDirection()

    if (direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
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
function UIC_TableViewCore:maxContainerOffset()
    return 0, 0
end

-------------------------------------
-- function minContainerOffset
-------------------------------------
function UIC_TableViewCore:minContainerOffset()
    local viewSize = self.m_scrollView:getViewSize()

    local _container = self.m_scrollView:getContainer()
    local size = _container:getContentSize()

    local x = viewSize['width'] - size['width']
    local y = viewSize['height'] - size['height']

    return x, y
end

function UIC_TableViewCore:_offsetFromIndex(index)
    local offset = self:__offsetFromIndex(index)

    local cellSize = self:tableCellSizeForIndex(index)

    if (self._vordering == VerticalFillOrder['TOP_DOWN']) then
        offset['y'] = self.m_scrollView:getContainer():getContentSize()['height'] - offset['y'] - cellSize['height']
    end
    return offset
end

function UIC_TableViewCore:__offsetFromIndex(index)
    local offset = cc.p(0, 0)
    local cellSize = cc.size(0, 0)

    local direction = self.m_scrollView:getDirection()

    -- 가로
    if (direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        offset['x'] = self._vCellsPositions[index]
    -- 세로
    else
        offset['y'] = self._vCellsPositions[index]
    end

    return offset
end

function UIC_TableViewCore:updateCellAtIndex(idx)
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
function UIC_TableViewCore:setDirection(direction)
    self.m_scrollView:setDirection(direction)
end

-------------------------------------
-- function setItemList
-- @brief list는 key값이 고유해야 하며, value로는 UI생성에 필요한 데이터가 있어야 한다
-------------------------------------
function UIC_TableViewCore:setItemList(list)
    self:clearItemList()

    for key,data in pairs(list) do
        local t_item = {}
        t_item['unique_id'] = key
        t_item['data'] = data

        -- UI를 미리 생성
        t_item['ui'] = self:makeItemUI(data)

        -- 리스트에 추가
        table.insert(self.m_itemList, t_item)

        -- 맵에 등록
        self.m_itemMap[key] = t_item
    end

    self:_updateCellPositions()
    self:_updateContentSize()

    self:relocateContainerDefault()

    self:scrollViewDidScroll()
end

-------------------------------------
-- function relocateContainerDefault
-- @brief 시작 위치로 설정
-------------------------------------
function UIC_TableViewCore:relocateContainerDefault(animated)
    local direction = self.m_scrollView:getDirection()
    -- 가로
    if (direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
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
function UIC_TableViewCore:clearItemList()
    if self.m_itemList then
        for i,v in ipairs(self.m_itemList) do
            if v['ui'] then
                v['ui'].root:release()
            end
        end
    end

    self.m_itemList = {}
    self.m_itemMap = {}
    self._cellsUsed = {}
end




-------------------------------------
-- function makeItemUI
-------------------------------------
function UIC_TableViewCore:makeItemUI(data)
    local ui = UI_DragonTrainSlot_ListItem(data)
    ui.root:retain()
    ui.root:setDockPoint(cc.p(0, 0))
    ui.root:setAnchorPoint(cc.p(0, 0))

    ui.vars['trainButtonA']:getParent():setSwallowTouch(false)
    ui.vars['trainButtonA']:registerScriptTapHandler(function()
        local width, height = ui.root:getNormalSize()
        local func = function(value)
            ui.root:setNormalSize(value, height)
        end
        local tween = cc.ActionTweenForLua:create(0.15, width, 400, func)
        ui.root:stopAllActions()
        ui.root:runAction(tween)

        ui.m_cellSize['width'] = 400

        self:_updateCellPositions()
        self:_updateContentSize()
        self:scrollViewDidScroll()
    end)

    ui.vars['trainButtonB']:getParent():setSwallowTouch(false)
    ui.vars['trainButtonB']:registerScriptTapHandler(function()
        local width, height = ui.root:getNormalSize()
        local func = function(value)
            ui.root:setNormalSize(value, height)
        end
        local tween = cc.ActionTweenForLua:create(0.15, width, 180, func)
        ui.root:stopAllActions()
        ui.root:runAction(tween)

        ui.m_cellSize['width'] = 180

        self:_updateCellPositions()
        self:_updateContentSize()
        self:scrollViewDidScroll()
    end)

    self.m_scrollView:addChild(ui.root)

    return ui
end


-- _swallowTouch가 false일 경우 CCMenu 클래스의 onTouchBegan함수에서
-- collectSlideNodesInParents()를 수행. 즉, 부모들 중에 SlideNode타입을 수집

-- getItemForTouch() 함수 안에서
-- isIgnoreTouch() 함수 안에서

-- 수집된 SlideNode부모들의 영역안에 포함되어있지 않으면 터치를 하지 않게 처리함