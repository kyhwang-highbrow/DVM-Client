local PARENT = UIC_Node

-------------------------------------
-- class UIC_TableView
-------------------------------------
UIC_TableView = class(PARENT, {
        m_scrollView = 'cc.ScrollView',
        m_itemList = '',
        m_itemMap = '',


        m_defaultCellSize = '',

        _cellsUsed = 'list',
        _vCellsPositions = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_TableView:init(node)
    node:registerScriptHandler(function(event)
        if (event == 'cleanup') then
            self:clearItemList()
        end
    end)

    local content_size = node:getContentSize()

    self.m_defaultCellSize = cc.size(400, 460)

    self:makeScrollView(content_size)
end

-------------------------------------
-- function makeScrollView
-------------------------------------
function UIC_TableView:makeScrollView(size)
    local scroll_view = cc.ScrollView:create()
    self.m_scrollView = scroll_view

    scroll_view:setDockPoint(cc.p(0.5, 0.5))
    scroll_view:setAnchorPoint(cc.p(0.5, 0.5))

    scroll_view:setDelegate()


    local scrollViewDidScroll = function(view)
        self:scrollViewDidScroll(view)
    end
    scroll_view:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)


    scroll_view:setViewSize(size)


    -- 수평 UI
    self:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    --self:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local _container = scroll_view:getContainer()



    local size1 = clone(size)
    size1['width'] = size1['width'] * 2
    size1['height'] = size1['height']
    --scroll_view:setContentSize(size1);

    --relocateContainer()

    --cclog(tostring(_container))
    --scroll_view:setDirection()

    self.m_node:addChild(scroll_view)
end

-------------------------------------
-- function _updateCellPoitions
-------------------------------------
function UIC_TableView:_updateCellPoitions()
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
                if self.m_itemList[i]['ui'] then
                    --self.m_itemList[i]['ui'].root:setPositionX(currentPos)
                    self.m_itemList[i]['ui'].root:runAction(cc.MoveTo:create(0.15, cc.p(currentPos, 0)))
                end
                currentPos = currentPos + cellSize['width']
            -- 세로
            else
                if self.m_itemList[i]['ui'] then
                    self.m_itemList[i]['ui'].root:setPositionY(currentPos)
                end
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
function UIC_TableView:_updateContentSize()
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
end

-------------------------------------
-- function scrollViewDidScroll
-------------------------------------
function UIC_TableView:scrollViewDidScroll(view)
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

    -- 종료 idx 얻어옴
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
                cell['ui'].root:setVisible(false)
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
                cell['ui'].root:setVisible(false)
            end

            if (#self._cellsUsed <= 0) then
                break
            end

            cell = self._cellsUsed[#self._cellsUsed]
            idx = cell['idx']
        end
    end

    -- 눈에 보이는 item들 설정
    --local 
    --local start_end_idx = self._cellsUsed[1] and 
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
                --local maxPosition = self._vCellsPositions[cellsCount + 1]
                --t_item['ui'].root:setPositionX(maxPosition)
                --t_item['ui'].root:setPositionX(pos + self.m_defaultCellSize['width'])
                t_item['ui'].root:setPositionX(pos + viewSize['width'])
                t_item['ui'].root:runAction(cc.MoveTo:create(0.15, cc.p(pos, 0)))
            -- 세로
            else
                t_item['ui'].root:setPositionY(pos)
            end
        else
            t_item['ui'].root:setVisible(true)
        end

        table.insert(self._cellsUsed, t_item)
    end
end


-------------------------------------
-- function tableCellSizeForIndex
-------------------------------------
function UIC_TableView:tableCellSizeForIndex(idx)
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

    --if (_vordering == VerticalFillOrder::TOP_DOWN)
    --{
    --    offset.y = this->getContainer()->getContentSize().height - offset.y;
    --}
    
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
-- function setDirection
-- @param direction
-- cc.SCROLLVIEW_DIRECTION_NONE = -1
-- cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0
-- cc.SCROLLVIEW_DIRECTION_VERTICAL = 1
-- cc.SCROLLVIEW_DIRECTION_BOTH  = 2
-------------------------------------
function UIC_TableView:setDirection(direction)
    self.m_scrollView:setDirection(direction)
end

-------------------------------------
-- function setItemList
-- @brief list는 key값이 고유해야 하며, value로는 UI생성에 필요한 데이터가 있어야 한다
-------------------------------------
function UIC_TableView:setItemList(list)
    self:clearItemList()

    for key,data in pairs(list) do
        local t_item = {}
        t_item['unique_id'] = key
        t_item['data'] = data

        -- UI를 미리 생성
        --t_item['ui'] = self:makeItemUI(data)

        -- 리스트에 추가
        table.insert(self.m_itemList, t_item)

        -- 맵에 등록
        self.m_itemMap[key] = t_item
    end

    self:_updateCellPoitions()
    self:_updateContentSize()
    self:scrollViewDidScroll()
end

-------------------------------------
-- function clearItemList
-------------------------------------
function UIC_TableView:clearItemList()
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
function UIC_TableView:makeItemUI(data)
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

        self:_updateCellPoitions()
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

        self:_updateCellPoitions()
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