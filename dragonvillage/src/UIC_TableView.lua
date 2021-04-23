local PARENT = UIC_Node

-- cell 생성 연출
CELL_CREATE_DIRECTING = {}
CELL_CREATE_DIRECTING['scale'] = 0
CELL_CREATE_DIRECTING['fadein'] = 1
CELL_CREATE_DIRECTING['fadein_fast'] = 2

-------------------------------------
-- class UIC_TableView
-------------------------------------
UIC_TableView = class(PARENT, {
        m_scrollView = 'cc.ScrollView',
        m_itemList = '',
        m_itemMap = '',
        m_bDirtyItemList = 'boolean',
        m_refreshDuration = 'number',

        m_bVariableCellSize = 'boolean', -- 셀별 개별 크기 적용 여부(사용시 _size세팅 필수!!)
        m_defaultCellSize = '', -- cell이 생성되기 전이라면 기본 사이즈를 지정
        m_bFixedCellSize = 'boolean', -- 셀별 크기 노드 사이즈와 동일하게 적용 여부
        m_gapBtwCellsSize = 'number', -- cell 사이의 갭 크기 지정


        _cellsUsed = 'list',
        _vCellsPositions = 'list',

        _direction = 'cc.SCROLLVIEW_DIRECTION_HORIZONTAL',
        _vordering = 'cc.TABLEVIEW_FILL_TOPDOWN',

        m_makeReserveQueue = 'stack',
        m_makeTimer = 'number',

        m_cellUIClass = 'class',
        
        m_lSortInfo = 'table', -- {name = sort_func}
        m_currSortType = 'string',

        m_cellUICreateCB = 'function',
        m_cellUIAppearCB = 'function',

        -- 리스트 내 개수 부족 시 가운데 정렬
        m_bAlignCenterInInsufficient = 'boolean',

        m_bFirstLocation = 'boolean',

        -- 리스트가 비어있을 때 표시할 노드
        m_emptyDescNode = 'cc.Node',
        m_emptyDescLabel = 'cc.LabelTTF',
        m_emptyUI = '',

		-- 보이는 셀 미리 생성
		m_isMakeLookingCellFirst = 'bool', -- 사용 여부
		m_visibleStartIdx = 'number',
		m_visibleEndIdx = 'number',
		
		_cellCreateDirecting = 'enum',
        
		m_stability = 'bool',

		-- scroll end event
		m_scrollEndStd = 'number',
		m_scrollEndSprite = 'cc.Sprite',
		m_scrollEndCB = 'function',
		m_scrollEndIdx = 'number',

		m_scrollLock = 'bool',
        m_isScrollEnd = 'bool', -- 스크롤 상태가 limit에 근접할 시 초기화
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_TableView:init(node)
    self.m_refreshDuration = 0.5

    -- 기본값 설정
    self.m_bVariableCellSize = false
    self.m_defaultCellSize = cc.size(100, 100)
    self.m_bFixedCellSize = false
    self.m_gapBtwCellsSize = 0


    self._vordering = cc.TABLEVIEW_FILL_TOPDOWN
    self.m_bFirstLocation = true
    self.m_bDirtyItemList = false

	self.m_scrollLock = false
    self.m_isScrollEnd = false
	self.m_bAlignCenterInInsufficient = false

    -- 스크롤 뷰 생성
    local content_size = node:getContentSize()
    self:makeScrollView(content_size)

    -- UI생성 큐
    self.m_makeReserveQueue = {}
    self.m_makeTimer = 0
	
	-- 보이는 셀 미리 생성
	self.m_isMakeLookingCellFirst = true
	self.m_visibleStartIdx = 1
	self.m_visibleEndIdx = 1

	self._cellCreateDirecting = CELL_CREATE_DIRECTING['scale']
    self.m_stability = true

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
    local scrollViewDidScroll = function()
        self:scrollViewDidScroll()
    end
    scroll_view:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)

    -- 방향 설정수평 UI
    self:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    self.m_node:addChild(scroll_view)

    scroll_view:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UIC_TableView:update(dt)

    -- update함수에서 error가 발생한 후에는 update함수를 콜하지 않도록 하기 위함
    if (not self.m_stability) then
        return 
    end
    self.m_stability = false

    self.m_makeTimer = (self.m_makeTimer - dt)
    if (self.m_makeTimer <= 0) then
        
		-- 눈에 보이는 셀부터 먼저 생성되도록 큐에 담음
		if (self.m_isMakeLookingCellFirst) then
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
		end

		-- 예약된 셀 생성
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

            elseif (self._cellCreateDirecting == CELL_CREATE_DIRECTING['fadein_fast']) then
				doAllChildren(ui.root, function(node) node:setCascadeOpacityEnabled(true) end)
				ui.root:setOpacity(0)
				local fade_in = cc.FadeIn:create(0.1)
				local action = cc.EaseInOut:create(fade_in, 2)
				ui.root:runAction(action)

            end

            local idx = t_item['idx']
            self:updateCellAtIndex(idx)
            
            table.remove(self.m_makeReserveQueue, 1)

            if self.m_cellUIAppearCB then
                self.m_cellUIAppearCB(t_item['ui'], t_item['data'])
            end
        end

        self.m_makeTimer = 0.03
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
        self:refreshCellsAndContainer(self.m_refreshDuration, animated)

		--dirty후에 풀리도록 고정
        
        if(not self.m_scrollLock) then
            self.m_isScrollEnd = false

		    -- 정렬된 cell들을 처리하는 의미
		    self:scrollViewDidScroll()
        end
    end

    self.m_stability = true
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
    local content_size = cc.size(0, 0)

    local cell_cnt = #self.m_itemList

    local view_size = self.m_scrollView:getViewSize()

	-- 컨테이너 사이즈 계산
    if (cell_cnt > 0) then
        local max_pos = self._vCellsPositions[cell_cnt + 1]
		local width, height

		-- 최소 view_size 크기는 유지하기 위해 math_max사용
        if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
			width = math_max(view_size['width'], max_pos)
			height = view_size['height']
        else
		 	width = view_size['width']
			height = math_max(view_size['height'], max_pos)
        end

		content_size = cc.size(width, height)
    end

	-- 컨테이너의 사이즈 적용
    do
        self.m_scrollView:setContentSize(content_size)
        -- 자식 node들의 transform을 update(dockpoint의 영향이 있을수 있으므로)
        self.m_scrollView:setUpdateChildrenTransform()
    end

    -- cell들의 위치를 업데이트
    if (not skip_update_cells) then
        for i=1, cell_cnt do
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
function UIC_TableView:scrollViewDidScroll()
    local cellsCount = #self.m_itemList

    if (0 == cellsCount) then
        return
    end
	if (self.m_isScrollEnd) then
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

    -- 리스트 아이템 갯수가 부족할 때 가운데 정렬을 하는 경우
    -- 가운데로 맞추기 위해 offset을 조정하는 부분이 있다.
    -- 이를 역으로 다시 계산하여 정상적으로 startIdx가 구해지도록 함
    if (self.m_bAlignCenterInInsufficient) then
        if (self._vCellsPositions) then
            local container_size = self._vCellsPositions[#self._vCellsPositions]

            if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
                if (container_size < viewSize['width']) then
                    offset['x'] = offset['x'] - ((viewSize['width'] - container_size) / 2)
                end

            else
                if (container_size < viewSize['height']) then
                    offset['y'] = offset['y'] + ((viewSize['height'] - container_size) / 2)
                end
            end
        end
    end
    
    -- 시작 idx 얻어옴
    if (self._vordering == cc.TABLEVIEW_FILL_TOPDOWN) then
        offset['y'] = offset['y'] + viewSize['height']
    end
    startIdx = self:_indexFromOffset(offset)

    -- @mskim tableview 에러를 잡기 위한 우회처리
    if (not startIdx) then
        return nil
    end

    if (startIdx == -1) then
		startIdx = cellsCount
	end

    -- 종료 idx 얻어옴
    if (self._vordering == cc.TABLEVIEW_FILL_TOPDOWN) then
        offset['y'] = offset['y'] - viewSize['height']
    else
        offset['y'] = offset['y'] + viewSize['height']
    end
    offset['x'] = offset['x'] + viewSize['width']
    endIdx = self:_indexFromOffset(offset)

    if (endIdx == -1) then
        endIdx = cellsCount
	end
	
	-- scroll end event
	self:scrollEndEventHandler(offset, endIdx)

    -- 현재 보이는 item의 앞쪽 정리
    if (0 < #self._cellsUsed) then
        local cell = self._cellsUsed[1]
        local idx = cell['idx']

        -- @mskim tableview 에러를 잡기 위한 우회처리
        if (idx) then
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
    end

    -- 현재 보이는 item의 뒷쪽 정리
    if (0 < #self._cellsUsed) then
        local cell = self._cellsUsed[#self._cellsUsed]
        local idx = cell['idx']

        -- @mskim tableview 에러를 잡기 위한 우회처리
        if (idx) then
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
-- function scrollEndEventHandler
-- @brief 스크롤을 끝까지 했을때의 이벤트 처리
-------------------------------------
function UIC_TableView:scrollEndEventHandler(offset, end_idx)
	-- scroll end callback 있을 경우에만 동작
	if (not self.m_scrollEndCB) then
		self:releaseScrollEndSprite()
		return
	end

	-- 스크롤 방향에 따라 offset 구함
	local curr_pos
	if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
		curr_pos = offset['x']
	elseif (self._direction == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
		curr_pos = offset['y']
	else
		return
	end

	-- 기준치 이상 스크롤 되었을 시
	if (curr_pos < -self.m_scrollEndStd) then
		-- 더불러오기 아이콘 생성
		if (not self.m_scrollEndSprite) then
			self:makeScrollEndSprite()

		-- 더불러오기 아이콘 연출
		else
			local gap_percent = (- curr_pos - self.m_scrollEndStd)/(self.m_scrollEndStd)

			-- 위치 조정
			self.m_scrollEndSprite:setPositionY(- curr_pos - self.m_scrollEndStd)
			-- percent 계산
			self.m_scrollEndSprite:setPercentage(gap_percent * 100)
			-- 크기 살짝 조정
			self.m_scrollEndSprite:setScale(1 + gap_percent * 0.2)

			-- 기준치의 2배 이상 스크롤 되었을 시 콜백 실행
			if (curr_pos < - (self.m_scrollEndStd * 2)) then
				self.m_scrollEndIdx = end_idx
				--[[
					scroll end callback 을 사용하다면 대체로 리스트를 추가적으로 불러오고 갱신할것으로 가정함
					따라서 현재 마지막idx를 갱신한 후에 화면에 계속 출력할 수 있도록 idx를 저장한다.
					다른 사용용도가 생긴다면 그때 추가 개발 할 예정
				]]
                self.m_isScrollEnd = true
				self.m_scrollEndCB()
			end
		end

	-- 기준치 이내라면 더불러오기 아이콘 삭제
	else
		self:releaseScrollEndSprite()

	end
end

-------------------------------------
-- function makeScrollEndSprite
-------------------------------------
function UIC_TableView:makeScrollEndSprite()
	local spr = cc.Sprite:create('res/ui/buttons/refresh_tableview.png')
	self.m_scrollEndSprite = cc.ProgressTimer:create(spr)

	self.m_scrollEndSprite:setDockPoint(cc.p(0.5, 0))
	self.m_scrollEndSprite:setAnchorPoint(CENTER_POINT)
	self.m_scrollEndSprite:setPercentage(0)
	self.m_node:addChild(self.m_scrollEndSprite)
end

-------------------------------------
-- function releaseScrollEndSprite
-------------------------------------
function UIC_TableView:releaseScrollEndSprite()
	if (self.m_scrollEndSprite) then
		self.m_scrollEndSprite:stopAllActions()
		self.m_scrollEndSprite:removeFromParent(true)
		self.m_scrollEndSprite = nil
	end
end

-------------------------------------
-- function tableCellSizeForIndex
-------------------------------------
function UIC_TableView:tableCellSizeForIndex(idx)
    if (not self.m_bVariableCellSize) then
        return self.m_defaultCellSize
    end

    local t_item = self.m_itemList[idx] or {}
    local ui = t_item['ui'] or t_item['generated_ui']

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

    if (self._vordering == cc.TABLEVIEW_FILL_TOPDOWN) then
        offset = cc.p(offset['x'], offset['y'])
        offset['y'] = self.m_scrollView:getContainer():getContentSize()['height'] - offset['y'];
    end
    
    index = self:__indexFromOffset(offset);
    
    -- @mskim tableview 에러를 잡기 위한 우회처리
    if (not index) then
         return nil
    end

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

    -- @mskim tableview 에러를 잡기 위한 우회처리
    if (not self._vCellsPositions) then
        return nil
    end

    while (high >= low) do
        local index = math_floor(low + (high - low) / 2)
        local cellStart = self._vCellsPositions[index];
        local cellEnd = self._vCellsPositions[index + 1];
        
        -- @mskim tableview 에러를 잡기 위한 우회처리
        if (not cellStart or not cellEnd) then
            break
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

-------------------------------------
-- function _offsetFromIndex
-------------------------------------
function UIC_TableView:_offsetFromIndex(index)
    local viewSize = self.m_scrollView:getViewSize()
    local offset = self:_makeIndexOffset(index)

    local cellSize = self:tableCellSizeForIndex(index)

    if (self._vordering == cc.TABLEVIEW_FILL_TOPDOWN) then
        offset['y'] = self.m_scrollView:getContainer():getContentSize()['height'] - offset['y'] - cellSize['height']
    end

    do -- 가운데 정렬을 위해
        offset['x'] = offset['x'] + (cellSize['width'] / 2)
        offset['y'] = offset['y'] + (cellSize['height'] / 2)

        -- 가로
        if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
            -- 아이템이 가지는 상하 빈공간 높이
            -- y + 위 / - 아래
            local blank_gap = ((viewSize['height'] - cellSize['height']) / 2)
            offset['y'] = offset['y'] - blank_gap

        -- 세로
        else
            offset['x'] = offset['x'] + ((viewSize['width'] - cellSize['width']) / 2)

        end
    end

    
    -- 리스트 내 개수 부족 시 가운데 정렬
    if self.m_bAlignCenterInInsufficient then
        local viewSize = self.m_scrollView:getViewSize()
        local container_size = self._vCellsPositions[#self._vCellsPositions]

        -- 비어 있는 공간의 절반만큼 더하여 가운데로 정렬되도록 함
        -- 가로
        if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
            if (container_size < viewSize['width']) then
                offset['x'] = offset['x'] + ((viewSize['width'] - container_size) / 2)
            end
        -- 세로
        else
            if (container_size < viewSize['height']) then
                offset['y'] = offset['y'] - ((viewSize['height'] - container_size) / 2)
            end
        end
    end

    return offset
end

-------------------------------------
-- function _makeIndexOffset
-------------------------------------
function UIC_TableView:_makeIndexOffset(index)
    local offset = cc.p(0, 0)

    -- 가로
    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        offset['x'] = self._vCellsPositions[index] or 0
    -- 세로
    else
        offset['y'] = self._vCellsPositions[index] or 0
    end

    return offset
end

-------------------------------------
-- function updateCellAtIndex
-------------------------------------
function UIC_TableView:updateCellAtIndex(idx)
    -- @mskim tableview 에러를 잡기 위한 우회처리
    if (not idx) then
        return
    end
    if (not self.m_itemList) then
        return
    end
    if (not self.m_itemList[idx]) then
        return
    end

    local offset = self:_offsetFromIndex(idx)
    local ui = self.m_itemList[idx]['ui']
    if ui and offset then
        ui.root:setPosition(offset['x'], offset['y'])
    end
end










-------------------------------------
-- function setItemList
-- @brief list는 key값이 고유해야 하며, value로는 UI생성에 필요한 데이터가 있어야 한다
-------------------------------------
function UIC_TableView:setItemList(list, make_item)
    self:clearItemList()

    local make_item = make_item or self.m_bVariableCellSize
    for key,data in pairs(list) do
        local t_item = {}
        t_item['unique_id'] = key
        t_item['data'] = data

        local idx = #self.m_itemList + 1

        -- UI를 미리 생성
        if make_item then
            t_item['generated_ui'] = self:makeItemUI(data, key)
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
-- function setItemList3
-- @brief
-------------------------------------
function UIC_TableView:setItemList3(list, sort_func)
    self:clearItemList()

    for key,data in pairs(list) do
        local t_item = {}
        t_item['unique_id'] = key
        t_item['data'] = data

        local idx = #self.m_itemList + 1

        -- UI를 미리 생성
        t_item['ui'] = self:makeItemUI(data, key)

        -- 리스트에 추가
        table.insert(self.m_itemList, t_item)

        -- 맵에 등록
        self.m_itemMap[key] = t_item

        --[[
        do -- 액션 수행 위치 수정
            local ui = t_item['ui']
            local scale = ui.root:getScale()
            ui.root:setScale(scale * 0.2)
            local scale_to = cc.ScaleTo:create(0.25, scale)
            local action = cc.EaseInOut:create(scale_to, 2)
            ui.root:runAction(action)
        end
        --]]
    end

    if (sort_func) then
        sort_func()
    end

    self:_updateCellPositions()
    self:_updateContentSize()
    self:scrollViewDidScroll()

    self:setDirtyItemList()
end


function UIC_TableView:CreateCellUIClass(id, num, isPreload)
    self:clearItemList()

    for i = 1, num do
        local t_item = {}
        local data = {}
        data['parent_key'] = id
        data['id'] = i
        
        t_item['unique_id'] = i
        t_item['data'] = data

        if (isPreload) then
            t_item['ui'] = self:makeItemUI(data, i)
        end
        
        table.insert(self.m_itemList, t_item)

        self.m_itemMap[i] = t_item
    end

    if (isPreload) then
        self:_updateCellPositions()
        self:_updateContentSize()
    end

    self:scrollViewDidScroll()

    self:setDirtyItemList()
end

-------------------------------------
-- function makeAllItemUI
-- @brief
-------------------------------------
function UIC_TableView:makeAllItemUI()
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
-- function makeAllItemUINoAction
-- @brief
-------------------------------------
function UIC_TableView:makeAllItemUINoAction()
    for i,item in ipairs(self.m_itemList) do
        if (not item['ui']) then
            item['ui'] = self:makeItemUI(item['data'], i)
            
            -- 생성 예약 리스트에서 삭제
            for i, v in ipairs(self.m_makeReserveQueue) do
                if (item == v) then
                    table.remove(self.m_makeReserveQueue, i)
                    break
                end
            end
        end
    end

    self:_updateCellPositions()
    self:_updateContentSize()
end

-------------------------------------
-- function getCellUI
-- @brief
-------------------------------------
function UIC_TableView:getCellUI(unique_id)
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
function UIC_TableView:relocateContainer(animated)
    local scroll_view = self.m_scrollView

    local oldPoint = cc.p(0, 0)
    local min, max;
    local newX, newY;

    min = scroll_view:minContainerOffset();
    max = scroll_view:maxContainerOffset();

    oldPoint.x, oldPoint.y = scroll_view:getContainer():getPosition();

    newX = oldPoint.x;
    newY = oldPoint.y;
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
function UIC_TableView:relocateContainerDefault(animated)
    -- 가로
    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        self.m_scrollView:setContentOffset(cc.p(0, 0), animated)

    -- 세로
    else
        if (self._vordering == cc.TABLEVIEW_FILL_TOPDOWN) then
            local min_offset_x, min_offset_y = self:minContainerOffset()
            self.m_scrollView:setContentOffset(cc.p(0, min_offset_y), animated)
        else
            self.m_scrollView:setContentOffset(cc.p(0, 0), animated)
        end
    end
end

-------------------------------------
-- function relocateContainerFromIndex
-- @brief container 중앙에 해당 idx가 위치하도록 함
-------------------------------------
function UIC_TableView:relocateContainerFromIndex(idx, animated)
	local view_size = self.m_scrollView:getViewSize()
	local offset = self:_offsetFromIndex(idx)
	local min_x, min_y = self:minContainerOffset()
	local max_x, max_y = self:maxContainerOffset()

	local pos_x, pos_y = 0, 0

    -- 가로
    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        pos_x = -(offset['x'] - (view_size['width'] / 2))
		pos_x = math_max(pos_x, min_x)
		pos_x = math_min(pos_x, max_x)

    -- 세로
    elseif (self._direction == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
		pos_y = -(offset['y'] - (view_size['height'] / 2))
		pos_y = math_max(pos_y, min_y)
		pos_y = math_min(pos_y, max_y)

    end

    self.m_scrollView:setContentOffset(cc.p(pos_x, pos_y), animated)
end

-------------------------------------
-- function relocateContainerFirstFromIndex
-- @brief container 첫번째에 해당 idx가 위치하도록 함, move_pos로 위치 커스텀 가능
-------------------------------------
function UIC_TableView:relocateContainerFirstFromIndex(idx, animated, move_pos_x, move_pos_y)
	local view_size = self.m_scrollView:getViewSize()
	local offset = self:_offsetFromIndex(idx)
	local min_x, min_y = self:minContainerOffset()
	local max_x, max_y = self:maxContainerOffset()
    local move_pos_x = move_pos_x or 0
    local move_pos_y = move_pos_y or 0

	local pos_x, pos_y = 0, 0

    -- 가로
    if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        pos_x = -(offset['x'])
		pos_x = math_max(pos_x, min_x)
		pos_x = math_min(pos_x, max_x)

    -- 세로
    elseif (self._direction == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
		pos_y = -(offset['y'])
		pos_y = math_max(pos_y, min_y)
		pos_y = math_min(pos_y, max_y)

    end

    self.m_scrollView:setContentOffset(cc.p(pos_x + move_pos_x, pos_y + move_pos_y), animated)
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
-- function refreshCellsAndContainer
-------------------------------------
function UIC_TableView:refreshCellsAndContainer(duration, animated)
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

	-- 외부에서 dirty가 들어오기 전에 scrollEndIdx 를 설정한다면 0,0이 아닌 해당 idx로 이동한다.
	if (self.m_scrollEndIdx) then
		self:relocateContainerFromIndex(self.m_scrollEndIdx, false)
		self.m_scrollEndIdx = nil
	else
		self:relocateContainer(animated)
	end
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
    local ui = self.m_cellUIClass(data, key)
    ui:setTableView(self)
    ui.root:setSwallowTouch(false)
    if ui.vars['swallowTouchMenu'] then
        ui.vars['swallowTouchMenu']:setSwallowTouch(false)
    end

	-- cell size를 정의 하지 않는다면 디폴트 사이즈를 넣는다.
    -- UI 에서 한국어아 아니면 ui의 루트에 새로운 노드를 생성하여
    -- 딜레이타임을 가지고 하위 라벨 체크를 하는 액션을 취한다.
    -- 그 말인 즉 ui.root:getChildrenCount() 이 1, 2 두개의 값을 가질 수 있다는것
    if (self.m_bFixedCellSize) and (ui.root:getChildrenCount() <= 2) then
        local size = ui.root:getChildren()[1]:getContentSize()
        local width = size['width']
        local height = size['height']
        if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL or self._direction == cc.SCROLLVIEW_DIRECTION_BOTH) then
            width = width + self.m_gapBtwCellsSize
        end  
        if (self._direction == cc.SCROLLVIEW_DIRECTION_VERTICAL or self._direction == cc.SCROLLVIEW_DIRECTION_BOTH) then
            height = height + self.m_gapBtwCellsSize
        end
        self.m_defaultCellSize = cc.size(width, height)
        ui:setCellSize(self.m_defaultCellSize)
	elseif (ui:getCellSize() == nil) then
		ui:setCellSize(self.m_defaultCellSize)
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

    self:setDirtyItemList()
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

    self:setDirtyItemList()
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
function UIC_TableView:getItemCount()
    local count = table.count(self.m_itemList)
    return count
end

-------------------------------------
-- function addItemList
-- @breif
-------------------------------------
function UIC_TableView:addItemList(list)
    local dirty = false

    -- 새로 생긴 데이터 추가
    for i, v in pairs(list) do
        if (not self.m_itemMap[i]) then
            self:addItem(i, v)
            dirty = true
        end
    end

    if dirty then
        self:setDirtyItemList()
    end
end

-------------------------------------
-- function mergeItemList
-- @breif
-------------------------------------
function UIC_TableView:mergeItemList(list, refresh_func)
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
function UIC_TableView:replaceItemUI(unique_id, data)
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
function UIC_TableView:setEmptyDescNode(node)
    self.m_emptyDescNode = node
end

-------------------------------------
-- function setEmptyDescLabel
-- @breif
-------------------------------------
function UIC_TableView:setEmptyDescLabel(label)
    self.m_emptyDescLabel = label
end

-------------------------------------
-- function setEmptyDesc
-- @breif
-------------------------------------
function UIC_TableView:setEmptyDesc(desc)
    local label = self.m_emptyDescLabel
    label:setString(Str(desc))
end

-------------------------------------
-- function makeDefaultEmptyDescLabel
-- @breif
-------------------------------------
function UIC_TableView:makeDefaultEmptyDescLabel(text)
    local label = UIC_Factory:MakeTableViewDescLabelTTF(self.m_scrollView, text)
    self.m_node:addChild(label.m_node)
    self:setEmptyDescLabel(label)
end

-------------------------------------
-- function makeDefaultEmptyMandragora
-- @breif
-------------------------------------
function UIC_TableView:makeDefaultEmptyMandragora(text, scale)
    local scale = scale or 1
    local ui = UIC_Factory:MakeTableViewEmptyMandragora(text)
    ui.root:setScale(scale)
    self.m_node:addChild(ui.root)

    self.m_emptyUI = ui
end

-------------------------------------
-- function setDirtyItemList
-------------------------------------
function UIC_TableView:setDirtyItemList()
    self.m_bDirtyItemList = true
end

-------------------------------------
-- function refreshAllItemUI
-------------------------------------
function UIC_TableView:refreshAllItemUI()
    for i,v in ipairs(self.m_itemList) do
        local ui = v['ui']
        if ui then
            ui:refresh()
        end
    end
end

-------------------------------------
-- function setScrollEndCB
-------------------------------------
function UIC_TableView:setScrollEndCB(cb_func)
	-- SCROLLVIEW_DIRECTION_NONE 또는 SCROLLVIEW_DIRECTION_BOTH은 지원하지 않음
	if (self._direction == cc.SCROLLVIEW_DIRECTION_NONE) or (self._direction == cc.SCROLLVIEW_DIRECTION_BOTH) then
		error('해당 스크롤 타입은 scroll end call back을 지원하지 않습니다')
	end

    self.m_scrollEndCB = cb_func

	-- scrollEnd 기준 계산
	if (not self.m_scrollEndStd) then
		local visible_size = cc.Director:getInstance():getVisibleSize()
		local sensitivity = 0.1

		if (self._direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
			self.m_scrollEndStd = visible_size['width'] * sensitivity
		elseif (self._direction == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
			self.m_scrollEndStd = visible_size['height'] * sensitivity
		end
	end
end














-------------------------------------
-- public
-------------------------------------

-------------------------------------
-- function setUseVariableSize
-------------------------------------
function UIC_TableView:setUseVariableSize(b)
    self.m_bVariableCellSize = b
end

-------------------------------------
-- function setVerticalFillOrder
-- @param order
-- cc.TABLEVIEW_FILL_TOPDOWN = 0
-- cc.TABLEVIEW_FILL_BOTTOMUP = 1
-------------------------------------
function UIC_TableView:setVerticalFillOrder(order)
    self._vordering = order
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
-- function setScrollLock
-------------------------------------
function UIC_TableView:setScrollLock(b)
	self.m_scrollView:setTouchEnabled(not b)
    self.m_scrollLock = b
end

-------------------------------------
-- function setCellCreateDirecting
-- @brief 셀 생성 연출
-------------------------------------
function UIC_TableView:setCellCreateDirecting(n)
    self._cellCreateDirecting = n
end

-------------------------------------
-- function setMakeLookingCellFirst
-- @brief 눈에 보이는 셀 먼저 생성할지 여부
-------------------------------------
function UIC_TableView:setMakeLookingCellFirst(b)
	self.m_isMakeLookingCellFirst = b
end

-------------------------------------
-- function setAlignCenter
-- @brief 갯수 부족시 가운데 정렬
-------------------------------------
function UIC_TableView:setAlignCenter(b)
    self.m_bAlignCenterInInsufficient = b
end

-------------------------------------
-- function destroy
-- @brief 갯수 부족시 가운데 정렬
-------------------------------------
function UIC_TableView:destroy()
    for i, v in pairs(self.m_itemList) do
        self:delItem(i)
    end
    self.m_itemList = nil
end

-------------------------------------
-- function getIndexFromId
-- @param unique_id
-- @return idx number, nil을 리턴할 수 있다.
-------------------------------------
function UIC_TableView:getIndexFromId(unique_id)
    local idx = nil

    if (self.m_itemMap[unique_id]) then
        idx = self.m_itemMap[unique_id]['idx']
    end

    -- nil이 리턴될 수 있음
    return idx
end

-------------------------------------
-- function getIdFromIndex
-- @param idx number
-- @return unique_id, nil을 리턴할 수 있다.
-------------------------------------
function UIC_TableView:getIdFromIndex(idx)
    local unique_id = nil

    if (self.m_itemList[idx]) then
        unique_id = self.m_itemList[idx]['unique_id']
    end

    -- nil이 리턴될 수 있음
    return unique_id
end

-------------------------------------
-- function getItemFromIndex
-- @param idx number
-- @return 해당 idx번째 아이템, nil을 리턴할 수 있다.
-------------------------------------
function UIC_TableView:getItemFromIndex(idx)
    local item = self.m_itemList[idx]

    -- nil이 리턴될 수 있음
    return item
end




function UIC_TableView:setCellSizeToNodeSize(isFixedSize)
    self.m_bFixedCellSize = isFixedSize
end

function UIC_TableView:setGapBtwCells(gap)
    self.m_gapBtwCellsSize = gap
end

function UIC_TableView:setVisible(isVisible)

    -- for i,item in ipairs(self.m_itemList) do
    --     local ui = item['ui'] or item['generated_ui']
    --     ui.root:setVisible(isVisible)
    --     ui.root:setEnabled(isVisible)
    -- end
    self.m_scrollView:setVisible(isVisible)
    --self.m_scrollView:setEnabled(false)
end

function UIC_TableView:isVisible()
    return self.m_scrollView:isVisible()
end