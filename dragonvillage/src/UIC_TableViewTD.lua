local PARENT = UIC_Node

-------------------------------------
-- class UIC_TableViewTD
-------------------------------------
UIC_TableViewTD = class(PARENT, {
        m_scrollView = 'cc.ScrollView',
        m_itemList = '',
        m_itemMap = '',
        m_bDirtyItemList = 'boolean',
        m_refreshDuration = 'number',

        m_cellSize = '', -- cell하나의 사이즈

        _cellsUsed = 'list',
        _vLinePositions = 'list',

        _direction = '',

        m_cellUIClass = 'class',
        
        m_lSortInfo = 'table', -- {name = sort_func}
        m_currSortType = 'string',

        m_cellUICreateCB = 'function',
        m_nItemPerCell = 'number',
        m_bFirstLocation = 'boolean',

		-- cell 생성 관련 변수
        m_makeReserveQueue = 'stack',	-- 생성 큐
        m_makeTimer = 'number',			-- 생성 타이머
		m_makeInterval = 'numnber',		-- 생성 간격
		m_makeCellEachTick = 'number',	-- 한틱에 생성할 셀의 갯수
		m_bMakeAtOnce = 'boolean',		-- 즉시 생성 여부

		-- 리스트 내 개수 부족 시 가운데 정렬
        m_bAlignCenterInInsufficient = 'boolean',

        -- 리스트가 비어있을 때 표시할 노드
        m_emptyDescNode = 'cc.Node',
        m_emptyDescLabel = 'cc.LabelTTF',
        m_emptyUI = '',

		m_visibleStartIdx = 'number',
		m_visibleEndIdx = 'number',

		_cellCreateDirecting = 'CELL_CREATE_DIRECTING',
        m_stability = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_TableViewTD:init(node)
    self.m_node = node
    self.m_refreshDuration = 0.5

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
    self.m_bDirtyItemList = false
	self.m_bAlignCenterInInsufficient = false

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
	self.m_makeInterval = 0.03
	self.m_makeCellEachTick = 1
	self.m_bMakeAtOnce = false

	self.m_visibleStartIdx = 1
	self.m_visibleEndIdx = 1

	self._cellCreateDirecting = CELL_CREATE_DIRECTING['scale']
    self.m_stability = true
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

    -- 방향 설정수평 UI (기본은 세로)
    --self:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.m_node:addChild(scroll_view)

    scroll_view:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UIC_TableViewTD:update(dt)
    -- update함수에서 error가 발생한 후에는 update함수를 콜하지 않도록 하기 위함
    if (not self.m_stability) then
        return 
    end
    self.m_stability = false

	self.m_makeTimer = (self.m_makeTimer - dt)
	if (self.m_makeTimer <= 0) then

		for i = 1, self.m_makeCellEachTick do

			-- 눈에 보이는 셀부터 먼저 생성되도록 큐에 담음
			for i=self.m_visibleStartIdx, self.m_visibleEndIdx do
				local t_item = self.m_itemList[i]
				if (t_item) then
					if t_item['reserved'] and (not t_item['ui']) then
						for i,v in ipairs(self.m_makeReserveQueue) do
							if (t_item == v) then
								table.remove(self.m_makeReserveQueue, i)
								break
							end
						end
						table.insert(self.m_makeReserveQueue, 1, t_item)
						break
					end
				end
			end

			-- 예약된 셀 생성
			if self.m_makeReserveQueue[1] then
				local t_item = self.m_makeReserveQueue[1]
				local data = t_item['data']
				t_item['ui'] = self:makeItemUI(data)
				local ui = t_item['ui']

				-- 셀 생성 연출
				if (self._cellCreateDirecting == CELL_CREATE_DIRECTING['scale']) then
					local scale = ui.root:getScale()
					ui.root:setScale(scale * 0.2)
					local scale_to = cc.ScaleTo:create(0.25, scale)
					local action = cc.EaseInOut:create(scale_to, 2)
					ui.root:runAction(action)

				elseif (self._cellCreateDirecting == CELL_CREATE_DIRECTING['fadein']) then
					doAllChildren(ui.root, function(node) node:setCascadeOpacityEnabled(true) end)
					ui.root:setOpacity(0)
					local scale_to = cc.FadeIn:create(0.5)
					local action = cc.EaseInOut:create(scale_to, 2)
					ui.root:runAction(action)

				end

				local idx = t_item['idx']
				self:updateCellAtIndex(idx)
            
				-- 생성한 셀은 큐에서 삭제
				table.remove(self.m_makeReserveQueue, 1)
			end
		end

		-- 생성 주기
		self.m_makeTimer = self.m_makeInterval
    end

    -- 아이템 리스트가 변경되었을 경우
    if (self.m_bDirtyItemList == true) then
        self.m_bDirtyItemList = false
        local count = self:getItemCount()
        local is_empty = (count <= 0)
        if self.m_emptyDescNode then
            self.m_emptyDescNode:setVisible(is_empty)
            if is_empty then
                cca.uiReactionSlow(self.m_emptyDescNode)
            end
        end
        if self.m_emptyDescLabel then
            self.m_emptyDescLabel:setVisible(is_empty)
            if is_empty then
                cca.uiReactionSlow(self.m_emptyDescLabel)
            end
        end
        if self.m_emptyUI then
            self.m_emptyUI.root:setVisible(is_empty)
            if is_empty then
                cca.pickMePickMe(self.m_emptyUI.root, 20)
            end
        end

        -- 정렬
        local animated = true
        self:expandTemp(self.m_refreshDuration, animated)
    end

    self.m_stability = true
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
            -- 가로
            if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
                currentPos = currentPos + cellSize['width']
            -- 세로
            else
                currentPos = currentPos + cellSize['height']
            end
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

    -- 컨테이너 사이즈 계산
    if (lineCount > 0) then
        local maxPosition = self._vLinePositions[lineCount + 1]
        if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
            size = cc.size(maxPosition, viewSize['height'])
        else
            size = cc.size(viewSize['width'], maxPosition)
        end
    end

    do -- 컨테이너의 사이즈를 다시 지정
        self.m_scrollView:setContentSize(size)
        -- 자식 node들의 transform을 update(dockpoint의 영향이 있을수 있으므로)
        self.m_scrollView:setUpdateChildrenTransform()
    end

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

    -- 현재 컨테이너의 위치를 얻어옴
    local offset = self.m_scrollView:getContentOffset()
    offset['x'] = offset['x'] * -1
    offset['y'] = offset['y'] * -1

    -- 뷰사이즈를 얻어옴
    local viewSize = self.m_scrollView:getViewSize()

    -- 시작 idx 얻어옴
    offset['y'] = offset['y'] + viewSize['height']
    startLine = self:_indexFromOffset(offset)

	-- @mskim tableview 에러를 잡기 위한 우회처리
    if (not startLine) then
        return nil
    end

    if (startLine == -1) then
		startLine = lineCount
	end

    -- 종료 idx 얻어옴
    offset['y'] = offset['y'] - viewSize['height']
    offset['x'] = offset['x'] + viewSize['width']
    endLine = self:_indexFromOffset(offset)
	
	-- @mskim tableview 에러를 잡기 위한 우회처리
    if (not endLine) then
        return nil
    end

    if (endLine == -1) then
        endLine = lineCount
	end

    local itemCount = self:getItemCount()

    local startIdx = ((startLine - 1) * self.m_nItemPerCell) + 1
    startIdx = math_clamp(startIdx, 1, itemCount)

    local endIdx = endLine * self.m_nItemPerCell
    endIdx = math_clamp(endIdx, 1, itemCount)

    -- 현재 보이는 item 앞부분 정리
    if (0 < #self._cellsUsed) then
        local first_used_cell = self._cellsUsed[1]
        local first_used_idx = first_used_cell['idx']
     
		if (first_used_idx ~= nil) then
            -- 앞부분 사용 안되는 셀 개수
            local not_used_front_count = (startIdx - first_used_idx)
            -- 개수 예외처리
            if (not_used_front_count > #self._cellsUsed) then
                not_used_front_count = #self._cellsUsed
            end

            for i = 1, not_used_front_count do
                local cell = table.remove(self._cellsUsed, 1)

                if (cell['ui'] ~= nil) then
					cell['ui']:setCellVisible(false)
				end
            end
		end
    end

    -- 현재 보이는 item 뒷부분 정리
    if (0 < #self._cellsUsed) then
        local last_used_cell = self._cellsUsed[#self._cellsUsed]
        local last_used_idx = last_used_cell['idx']

        if (last_used_idx ~= nil) then
            -- 뒷부분 사용 안되는 셀 개수
            local not_used_back_count = (last_used_idx - endIdx)
            -- 개수 예외처리
            if (not_used_back_count > #self._cellsUsed) then
                not_used_back_count = #self._cellsUsed
            end

            for i = 1, not_used_back_count do
                local cell = table.remove(self._cellsUsed, #self._cellsUsed)

                if (cell['ui'] ~= nil) then
					cell['ui']:setCellVisible(false)
				end
            end
		end
    end


    -- 눈에 보이는 item들 설정
    self._cellsUsed = {}
    for i=startIdx, endIdx do
        local t_item = self.m_itemList[i]

        if (not t_item['ui']) then

            -- 즉시 생성
            if (self.m_bMakeAtOnce) then
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

	-- 눈에 보이는 인덱스 저장
	self.m_visibleStartIdx = startIdx
	self.m_visibleEndIdx = endIdx
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

    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        search = offset['x']
    else
        search = offset['y']
    end

	-- @mskim tableview 에러를 잡기 위한 우회처리
    if (not search) or (not self._vLinePositions) then
        return -1
    end

    while (high >= low) do
        local index = math_floor(low + (high - low) / 2)
        local cellStart = self._vLinePositions[index];
        local cellEnd = self._vLinePositions[index + 1];

		-- @mskim tableview 에러를 잡기 위한 우회처리
		if (not cellStart) or (not cellEnd) then
			return -1
		end

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

    return -1
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

-------------------------------------
-- function _offsetFromIndex
-------------------------------------
function UIC_TableViewTD:_offsetFromIndex(index)
    local offset = self:__offsetFromIndex(index)

    local cellSize = self.m_cellSize

    local container_size = self.m_scrollView:getContainer():getContentSize()

    -- 가로
    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        offset['x'] = container_size['width'] - offset['x'] - cellSize['width']

    -- 세로
    else
        offset['y'] = container_size['height'] - offset['y'] - cellSize['height']
    end

    do -- 가운데 정렬을 위해
        offset['x'] = offset['x'] + (cellSize['width'] / 2)
        offset['y'] = offset['y'] + (cellSize['height'] / 2)
    end
    
	-- 리스트 내 개수 부족 시 가운데 정렬
    if (self.m_bAlignCenterInInsufficient) then
        local viewSize = self.m_scrollView:getViewSize()

        -- 가로 (테스트는 안해봄)
        if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
            if (container_size['width'] < viewSize['width']) then
                offset['x'] = offset['x'] - (viewSize['width'] - container_size['width']) / 2
            end
        -- 세로
        else
            if (container_size['height'] < viewSize['height']) then
                offset['y'] = offset['y'] - (viewSize['height'] - container_size['height']) / 2
            end
        end
    end

    return offset
end

function UIC_TableViewTD:__offsetFromIndex(index)
    local offset = cc.p(0, 0)
    local cellSize = cc.size(0, 0)

    -- 가로
    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        local content_size = self.m_scrollView:getContainer():getContentSize()

        local line = self:calcLineIdx(index)
        offset['x'] = self._vLinePositions[#self._vLinePositions - line]

        local idx_y = math_max(0, self:calcXIdx(index) - 1)
        offset['y'] = self.m_cellSize['height'] * ((self.m_nItemPerCell-1) - idx_y)

    -- 세로
    elseif (self._direction == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
        local line = self:calcLineIdx(index)
        offset['y'] = self._vLinePositions[line]

        local idx_x = math_max(0, self:calcXIdx(index) - 1)
        offset['x'] = self.m_cellSize['width'] * idx_x
    end

    return offset
end

function UIC_TableViewTD:updateCellAtIndex(idx)
    if (not self.m_itemList[idx]) then
        return
    end

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
function UIC_TableViewTD:setDirection(direction)
    self.m_scrollView:setDirection(direction)
    self._direction = direction
end

-------------------------------------
-- function setItemList
-- @brief list는 key값이 고유해야 하며, value로는 UI생성에 필요한 데이터가 있어야 한다
-------------------------------------
function UIC_TableViewTD:setItemList(list, make_item)
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

    if (make_item) then
        self:_updateCellPositions()
        self:_updateContentSize()
    end

    self:setDirtyItemList()
end

-------------------------------------
-- function getCellUI
-- @brief
-------------------------------------
function UIC_TableViewTD:getCellUI(unique_id)
    local t_item = self:getItem(unique_id)

    if (not t_item) then return nil end

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
    if (self._direction == cc.SCROLLVIEW_DIRECTION_BOTH or self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        newX = math_max(newX, min.x);
        newX = math_min(newX, max.x);
    end

    if (self._direction == cc.SCROLLVIEW_DIRECTION_BOTH or self._direction == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
        newY = math_min(newY, max.y);
        newY = math_max(newY, min.y);
    end

    if (newY ~= oldPoint.y or newX ~= oldPoint.x) then
        scroll_view:setContentOffset(cc.p(newX, newY), animated);
    end
end

-------------------------------------
-- function relocateContainerDefault
-- @brief 시작 위치로 설정
-------------------------------------
function UIC_TableViewTD:relocateContainerDefault(animated)
    -- 가로
    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        self.m_scrollView:setContentOffset(cc.p(0, 0), animated)

    -- 세로
    else
        if (self.m_bDirtyItemList == true) then
            self:update(0)
        end
        local min_offset_x, min_offset_y = self:minContainerOffset()
        self.m_scrollView:setContentOffset(cc.p(0, min_offset_y), animated)
    end
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
function UIC_TableViewTD:expandTemp(duration, animated)
    local duration = duration or 0.15

    -- contentSize 변화에 따른 cell들의 위치 조정을 위한 값 캐싱
    local before_content_offset = self.m_scrollView:getContentOffset()

    -- 현재 보여지는 애들 리스트
    for i,v in ipairs(self._cellsUsed) do
        -- scroll view offset 변화로 보이는 위치에서 벗어나더라도 액션 하는 동안 visible 유지
        if v['ui'] then
            v['ui']:cellVisibleRetain(duration)
        end
    end

    self:_updateLinePositions()
    self:_updateContentSize(true)
    self:scrollViewDidScroll()
    
    if (animated == nil) then
        animated = true
    else
        animated = false
    end

    self:relocateContainer(animated)

    -- contentSize 변화에 따른 cell들의 위치 조정을 위한 값
    local after_content_offset = self.m_scrollView:getContentOffset()

     -- cell들 이동
     for i,v in ipairs(self.m_itemList) do
        local ui = self.m_itemList[i]['ui']

        if (ui ~= nil) then
            -- content, offset size 변화에 따른 셀들 위치 조정(자연스럽게 셀들이 이동 액션하도록)
            -- 위의 값들이 변경되어도 UI 상으로 셀은 그대로 있게 만든다.
            local before_pos_x, before_pos_y = ui.root:getPosition()
            local real_pos_x, real_pos_y = before_pos_x + before_content_offset['x'], before_pos_y + before_content_offset['y']
            local after_pos_x, after_pos_y = real_pos_x - after_content_offset['x'] , real_pos_y - after_content_offset['y']
            ui.root:setPosition(cc.p(after_pos_x, after_pos_y))

            -- 올바른 위치로 이동
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
    ui:setTableView(self)
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

    self:setDirtyItemList()
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
    self.m_itemList[#self.m_itemList + 1] = t_item

    self:setDirtyItemList()
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
        end

        -- 생성 예약 리스트에서 삭제
        if t_item['reserved'] then
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
        self:setDirtyItemList()
        return true
    else
        return false
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

-------------------------------------
-- function mergeItemList
-- @breif
-- @param function refresh_func(item, new_data)
-------------------------------------
function UIC_TableViewTD:mergeItemList(list, refresh_func)
    local dirty = false

    -- 새로 생긴 데이터 추가
    for i,v in pairs(list) do
        if (not self.m_itemMap[i]) then
            self:addItem(i, v)
            dirty = true
        else
            if refresh_func then
                local item = self.m_itemMap[i]
                refresh_func(item, v)
            end
        end
    end

    -- 사라진 데이터 삭제
    for i,v in pairs(self.m_itemMap) do
        if (not list[i]) then
            self:delItem(i)
            dirty = false
        end
    end

    if dirty then
        self:setDirtyItemList()
    end
end

-------------------------------------
-- function replaceItemUI
-- @breif
-------------------------------------
function UIC_TableViewTD:replaceItemUI(unique_id, data)
    local item = self:getItem(unique_id)

    if (not item) then
        return
    end

    item['data'] = data

    if (not item['ui']) then
        return
    end
    
    local x, y = item['ui'].root:getPosition()
    item['ui'].root:removeFromParent()
    item['ui'] = self:makeItemUI(data)
    item['ui'].root:setPosition(x, y)
end

-------------------------------------
-- function setEmptyDescNode
-- @breif
-------------------------------------
function UIC_TableViewTD:setEmptyDescNode(node)
    self.m_emptyDescNode = node
end

-------------------------------------
-- function setEmptyDescLabel
-- @breif
-------------------------------------
function UIC_TableViewTD:setEmptyDescLabel(label)
    self.m_emptyDescLabel = label
end

-------------------------------------
-- function setEmptyDesc
-- @breif
-------------------------------------
function UIC_TableViewTD:setEmptyDesc(desc)
    local label = self.m_emptyDescLabel
    label:setString(Str(desc))
end

-------------------------------------
-- function makeDefaultEmptyDescLabel
-- @breif
-------------------------------------
function UIC_TableViewTD:makeDefaultEmptyDescLabel(text)
    local label = UIC_Factory:MakeTableViewDescLabelTTF(self.m_scrollView, text)
    self.m_node:addChild(label.m_node)
    self:setEmptyDescLabel(label)
end

-------------------------------------
-- function makeDefaultEmptyMandragora
-- @breif
-------------------------------------
function UIC_TableViewTD:makeDefaultEmptyMandragora(text, scale)
    local scale = scale or 1
    local ui = UIC_Factory:MakeTableViewEmptyMandragora(text)
    ui.root:setScale(scale)
    self.m_node:addChild(ui.root)

    self.m_emptyUI = ui
end

-------------------------------------
-- function setDirtyItemList
-------------------------------------
function UIC_TableViewTD:setDirtyItemList()
    self.m_bDirtyItemList = true
end

-------------------------------------
-- function setCellCreateDirecting
-- @brief 셀 생성 연출
-------------------------------------
function UIC_TableViewTD:setCellCreateDirecting(n)
    self._cellCreateDirecting = n
end

-------------------------------------
-- function setCellCreateInterval
-- @brief 셀 생성 간격
-------------------------------------
function UIC_TableViewTD:setCellCreateInterval(n)
	if (n < 0) then
		return
	end
    self.m_makeInterval = n
end

-------------------------------------
-- function setCellCreatePerTick
-- @brief 틱 당 셀 생성 갯수
-------------------------------------
function UIC_TableViewTD:setCellCreatePerTick(n)
	if (n < 1) then
		return
	end
    self.m_makeCellEachTick = n
end
-------------------------------------
-- function refreshAllItemUI
-------------------------------------
function UIC_TableViewTD:refreshAllItemUI()
    for i,v in ipairs(self.m_itemList) do
        local ui = v['ui']
        if ui then
            ui:refresh()
        end
    end
end

-------------------------------------
-- function setAlignCenter
-- @brief 갯수 부족시 가운데 정렬
-------------------------------------
function UIC_TableViewTD:setAlignCenter(b)
    self.m_bAlignCenterInInsufficient = b
end

-- _swallowTouch가 false일 경우 CCMenu 클래스의 onTouchBegan함수에서
-- collectSlideNodesInParents()를 수행. 즉, 부모들 중에 SlideNode타입을 수집

-- getItemForTouch() 함수 안에서
-- isIgnoreTouch() 함수 안에서

-- 수집된 SlideNode부모들의 영역안에 포함되어있지 않으면 터치를 하지 않게 처리함


-------------------------------------
-- function relocateContainerFromIndex
-- @brief container 중앙에 해당 idx가 위치하도록 함
-------------------------------------
function UIC_TableViewTD:relocateContainerFromIndex(idx,_show_cnt, _offset, max_pos_)
    if (idx>0) then
        idx = idx - 1
    end
	
    -- 세로 모드일 때만 사용
	if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
		return
	end
	
	-- 각 셸의 높이
	local cell_size = self.m_cellSize
    local top_pos_x, top_pos_y  = self:minContainerOffset()
    
    -- 하드코딩
    if (not _offset) then
        _offset = 0
    end

    local pos_y = top_pos_y + cell_size['height'] * math.floor(idx/self.m_nItemPerCell) + _offset
    self.m_scrollView:setContentOffset(cc.p(0, pos_y), false)
end

