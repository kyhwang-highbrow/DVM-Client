require 'uilib/TableView'

ROOT_CACHE_SIZE = 5

-------------------------------------
-- class TableViewTD
-------------------------------------
TableViewTD = class(TableView,{
    m_items = 'table' -- 2차원배열 형태로 구성될 item테이블
,    m_createUIFunc = 'function'
,    m_touchCellFunc = 'function'

,    m_nItemPerCell = 'number'
,    m_cellSize = 'cc.Size'
,    m_gapSize = 'cc.Size'

,    m_bReuseable = 'boolean' -- 셀에 자식으로 붙게될 ui(menu)의 재사용 여부
,    m_tRootCache = 'table' -- 셀에 자식으로 붙게될 ui(menu)를 재사용하기 위한 캐쉬 테이블
,    m_tVarsCache = 'table' -- 셀에 자식으로 붙게될 ui(menu)의 vars를 재사용하기 위한 캐쉬 테이블

,   m_objs = 'table' -- m_items의 item테이블 순서대로 링크된 obj(UI)의 인스턴스를 가지는 테이블

,   m_bUseEachSize = 'boolean'  -- 셀별 개별 크기 적용 여부(사용시 _size세팅 필수!!)
})

TableViewTD.__index = TableViewTD

-------------------------------------
-- function TableViewTD.extend
-------------------------------------
function TableViewTD.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, TableViewTD)
    return target
end

-------------------------------------
-- function TableViewTD.create
-------------------------------------
function TableViewTD.create(ccTableView)
    local tableView = TableViewTD.extend(ccTableView)
    if nil ~= tableView then
        tableView:init()
    end

    return tableView
end

-------------------------------------
-- function TableViewTD.createWithNode
-------------------------------------
function TableViewTD.createWithNode(root, node)
    local size = node:getContentSize()
    local anchor_point = node:getAnchorPoint()
    local posX, posY = node:getPosition()
    local dock_point = node:getDockPoint()
    local tableView = cc.TableView:create(size)
        
    tableView:setAnchorPoint(anchor_point)
    tableView:setDockPoint(dock_point)
    
    tableView:setPosition(cc.p(posX, posY))
    tableView:setScaleX(node:getScaleX())
    tableView:setScaleY(node:getScaleY())
    tableView:setSkewX(node:getSkewX())
    tableView:setSkewY(node:getSkewY())
    
    --tableView:isBounceable(true)
    tableView:setDirection(1)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setDelegate()
    
    root:addChild(tableView)

    return TableViewTD.create(tableView)
end

-------------------------------------
-- function init
-------------------------------------
function TableViewTD:init()
    self:_init()

    self.m_items = {}
    self.m_createUIFunc = function() end
    self.m_touchCellFunc = function() end
    self.m_nItemPerCell = 0
    self.m_cellSize = cc.size(0, 0)
    self.m_itemSize = cc.size(0, 0)
    self.m_gapSize = cc.size(0, 0)
    self.m_bReuseable = false
    self.m_tRootCache = {}
    self.m_tVarsCache = {}
    self.m_objs = {}
    self.m_bUseEachSize = false
    
    -- 셀에 자식으로 붙게될 ui(menu)를 재사용하기 위해 콜백함수 재등록
    local tableCellWillRecycle = function(table, cell)
        local idx = cell:getIdx() + 1
        local cellData = self.m_cellDatas[idx]
        if (not cellData) then
            --cclog('TableView error : cellData dont exist')
        elseif self.m_bReuseable then
            -- 재사용을 위해 캐쉬에 추가
            for i = 1, cellData:getMaxItemCount() do
                local root, vars = cellData:getDataForCache(i)
                if root then
                    --cclog('ksj addCache')
                    self:addCache('ui', root, vars)
                    root:removeFromParent(true)
                end
            end
        else
            -- 셀에 붙은 ui객체들의 ui:onClose()를 호출해주기 위한 목적으로 처리함
            -- 테이블뷰 삭제시 자식ui에 어떠한 콜백도 줄수 없기 때문에 ui의 스케줄 해제는 외부에서 처리가 필요!!
            cellData:removeData()
        end
        
        self.m_cells[idx] = nil
        
        -- obj인스턴스 테이블에서 해당 셀에 대한 정보 삭제
        do
            local baseIdx = (idx - 1) * self.m_nItemPerCell
            for i = 1, self.m_nItemPerCell do
                self.m_objs[baseIdx + i] = nil
            end
        end
    end

    self:registerScriptHandler(tableCellWillRecycle, cc.TABLECELL_WILL_RECYCLE)
end

-------------------------------------
-- function setReuseable
-------------------------------------
function TableViewTD:setReuseable(b)
    self.m_bReuseable = b
end

-------------------------------------
-- function addCache
-------------------------------------
function TableViewTD:addCache(key, root, vars)
    if not self.m_tRootCache[key] then
        self.m_tRootCache[key] = {}
        self.m_tVarsCache[key] = {}
    end
    
    local tRootCache = self.m_tRootCache[key]
    local tVarsCache = self.m_tVarsCache[key]
    if #tRootCache >= ROOT_CACHE_SIZE then
        tRootCache[1]:release()
        table.remove(tRootCache, 1)
        table.remove(tVarsCache, 1)
    end

    root:retain()
    table.insert(tRootCache, root)
    table.insert(tVarsCache, vars)
end

-------------------------------------
-- function getCache
-------------------------------------
function TableViewTD:getCache(key)
    if not self.m_tRootCache[key] or #self.m_tRootCache[key] == 0 then
        return 
    end
    
    local tRootCache = table.remove(self.m_tRootCache[key], 1)
    local tVarsCache = table.remove(self.m_tVarsCache[key], 1)
    
    return tRootCache, tVarsCache
end

-------------------------------------
-- function getCache
-------------------------------------
function TableViewTD:clearCache()
    for key, tCache in pairs(self.m_tRootCache) do
        for i, v in ipairs(tCache) do
            v:release()
        end
    end
end

-------------------------------------
-- function setCellInfo
-------------------------------------
function TableViewTD:setCellInfo(nItemPerCell, cellSize, itemSize, gapSize, bUseEachSize)
    self.m_nItemPerCell = nItemPerCell
    self.m_cellSize = cellSize
    self.m_itemSize = itemSize
    self.m_gapSize = gapSize or cc.size(0, 0)
    self.m_bUseEachSize = bUseEachSize or false
end

-------------------------------------
-- function setItemInfo
-------------------------------------
function TableViewTD:setItemInfo(items, createUIFunc, touchCellFunc)
    self.m_cellDatas = {}
    
    self.m_items = items or self.m_items
    self.m_createUIFunc = createUIFunc or self.m_createUIFunc
    self.m_touchCellFunc = touchCellFunc or self.m_touchCellFunc
        
    local lineCount = math_floor((#self.m_items - 1) / self.m_nItemPerCell) + 1
    for line = 1, lineCount do
        
        local newCellData
        if self.m_bUseEachSize then
            -- 1차원 리스트에서 셀별 크기값이 있다면 해당 크기로 설정
            newCellData = TableViewTDCellData(line, items[line]['_size'])
        else
            newCellData = TableViewTDCellData(line, self.m_cellSize)
        end

        newCellData:setBaseInfo(self, self.m_nItemPerCell, self.m_itemSize, self.m_gapSize, self:getDirection())
        newCellData:setEnterFunc(function(cell, cellData, cellIdx)
            cell:removeAllChildren(true)
            
            for i = 1, self.m_nItemPerCell do
                local idx = (cellIdx - 1) * self.m_nItemPerCell + i
                local item = self.m_items[idx]
                if item then
                    local param = {
                        item = item
                    ,    cell = cell
                    ,    cellData = cellData
                    ,    idxInCell = i
                    ,    idx = idx
                    ,    itemPos = cellData:getItemPos(i)
                    }
                    local cached_root, cached_vars = self:getCache('ui')
                    
                    local data, root, vars = self.m_createUIFunc(param, cached_root, cached_vars)
                    if cached_root then
                        cached_root:release()
                    end
                    cellData:setData(i, idx, data)
                    cellData:setDataForCache(i, root, vars)
                    
                    -- 삭제시 콜백함수가 추가되었다면 셀데이터에 등록
                    if param['cbRemove'] then
                        cellData:registerRemoveHandler(i, param['cbRemove'])
                    end
                    
                    -- 참조할 인스턴스객체가 추가되었다면 저장
                    if param['object'] then
                        self.m_objs[idx] = param['object']
                    end
                else
                    cellData:clear(i)
                end
            end
        end)
        if self.m_touchCellFunc and type(self.m_touchCellFunc) == 'function' then
            -- !!2차원 배열 형태의 테이블뷰에선 사용하지 않도록 한다. 셀내의 어떤 아이템이 클릭되었는지 판별하기 에매하기 때문
            newCellData:setTouchFunc(function(cellData, cellIdx)
                local idx = cellIdx
                local item = self.m_items[idx]
                local param = {
                        item = item
                    --,    cell = self.m_cells[idx]
                    ,    idxInCell = 1
                    ,    idx = idx
                    }
                self.m_touchCellFunc(param)
            end)
        end
        self:addData(newCellData)
    end
end

-------------------------------------
-- function update
-------------------------------------
function TableViewTD:update(bOffset)
    local curPos = self:getScrollPos()
    --cclog('ksj curPos = ' .. curPos)

    local lineCount = math_floor((#self.m_items - 1) / self.m_nItemPerCell) + 1
    local vCount = lineCount - #self.m_cellDatas
    if vCount ~= 0 then
        self:setItemInfo()
    end
    
    self:reloadData()
    
    if bOffset then
        self:moveToPosition(curPos)
    else
        self:moveToPosition(0)
    end
end

-------------------------------------
-- function getItems
-------------------------------------
function TableViewTD:getItems()
    return self.m_items
end

-------------------------------------
-- function getObj
-------------------------------------
function TableViewTD:getObj(idx)
    return self.m_objs[idx]
end

-------------------------------------
-- function getScrollPos
-------------------------------------
function TableViewTD:getScrollPos()
    local offset = self:getContentOffset()
    local minOffset = self:minContainerOffset()
    return offset.y - minOffset.y
end

-------------------------------------
-- function moveToPosition
-------------------------------------
function TableViewTD:moveToPosition(posY)
    local maxOffset = self:maxContainerOffset()
    local minOffset = self:minContainerOffset()
    local targetY = minOffset.y + posY

    --cclog('ksj maxOffset = ' .. maxOffset.y)
    --cclog('ksj minOffset = ' .. minOffset.y)
    --cclog('ksj targetY = ' .. targetY)
    
    -- !!TABLEVIEW_FILL_TOPDOWN, SCROLLVIEW_DIRECTION_VERTICAL옵션인 경우만 처리
    if minOffset.y < 0 then
        if targetY > 0 then
            -- 리스트의 끝 위치로 설정
            self:setContentOffset(cc.p(0, 0))
        else
            targetY = math_max(targetY, minOffset.y)
            targetY = math_min(targetY, maxOffset.y)
            self:setContentOffset(cc.p(0, targetY))
        end
    else
        -- 컨텐츠 크기가 뷰크기보다 작은 경우 시작 위치로 설정
        self:setContentOffset(cc.p(0, minOffset.y))
    end
end

-------------------------------------
-- function moveThisIndexToCenter
-------------------------------------
function TableViewTD:moveThisIndexToCenter(idx)
    local idx = math_max(idx, 1)
    local posY = self.m_cellSize.height * (idx - 1)
    self:moveToPosition(posY)
end

-------------------------------------
-- class TableViewTDCellData
-------------------------------------
TableViewTDCellData = class(TableViewCellData,{
    m_parent = 'TableViewTD'
,    m_maxItemCount = 'number'
,    m_commonItemSize = 'cc.size'
,    m_gapSize = 'cc.size'
,    m_direction = 'number'

,    m_tIdx = 'table'
,    m_tData = 'table'
,    m_cbRemove = 'table'

,    m_tRoot = 'table'
,    m_tVars = 'table'
})

-------------------------------------
-- function init
-------------------------------------
function TableViewTDCellData:init()
    self.m_parent = nil
    self.m_maxItemCount = 0
    self.m_commonItemSize = cc.size(0, 0)
    self.m_gapSize = cc.size(0, 0)
    self.m_direction = 1

    self.m_tIdx = {}
    self.m_tData = {}
    self.m_cbRemove = {}

    self.m_tRoot = {}
    self.m_tVars = {}
end

-------------------------------------
-- function getMaxItemCount
-------------------------------------
function TableViewTDCellData:getMaxItemCount()
    return self.m_maxItemCount
end

-------------------------------------
-- function setMaxItemCount
-------------------------------------
function TableViewTDCellData:setMaxItemCount(maxItemCount)
    self.m_maxItemCount = maxItemCount
end

-------------------------------------
-- function setBaseInfo
-------------------------------------
function TableViewTDCellData:setBaseInfo(parent, maxItemCount, itemSize, gapSize, direction)
    self.m_parent = parent
    self.m_maxItemCount = maxItemCount
    self.m_commonItemSize = itemSize or self.size
    self.m_gapSize = gapSize or cc.size(0, 0)
    self.m_direction = direction
end

-------------------------------------
-- function setBaseInfo
-------------------------------------
function TableViewTDCellData:getItemPos(idx)
    local viewSize = self.m_parent:getViewSize()
    local halfCount = self.m_maxItemCount / 2
    local itemSize = self.m_commonItemSize
    local gapSize = self.m_gapSize
    
    if self.m_direction == 1 then
        local centerX = viewSize.width / 2
        local posX = centerX + (idx - 1 - halfCount) * (itemSize.width + gapSize.width)
        
        -- 간격을 계산
        posX = posX + (gapSize.width / 2)
        
        return cc.p(posX, 0)
    else
        local centerY = viewSize.height / 2
        local posY = centerY + (idx - 1 - halfCount) * itemSize.height
        return cc.p(0, posY)
    end
end

-------------------------------------
-- function setData
-------------------------------------
function TableViewTDCellData:setData(i, idx, data)
    self.m_tIdx[i] = idx
    self.m_tData[i] = data or {}
end

-------------------------------------
-- function setDataForCache
-------------------------------------
function TableViewTDCellData:setDataForCache(i, root, vars)
    self.m_tRoot[i] = root
    self.m_tVars[i] = vars
end

-------------------------------------
-- function getData
-------------------------------------
function TableViewTDCellData:getData(i)
    return self.m_tIdx[i], self.m_tData[i]
end

-------------------------------------
-- function getDataForCache
-------------------------------------
function TableViewTDCellData:getDataForCache(i)
    return self.m_tRoot[i], self.m_tVars[i]
end

-------------------------------------
-- function getRemoveHandler
-------------------------------------
function TableViewTDCellData:getRemoveHandler(i)
    return self.m_cbRemove[i]
end

-------------------------------------
-- function registerRemoveHandler
-------------------------------------
function TableViewTDCellData:registerRemoveHandler(i, cbRemove)
    self.m_cbRemove[i] = cbRemove
end

-------------------------------------
-- function unregisterRemoveHandler
-------------------------------------
function TableViewTDCellData:unregisterRemoveHandler(i)
    self.m_cbRemove[i] = nil
end

-------------------------------------
-- function clear
-------------------------------------
function TableViewTDCellData:clear(i)
    self.m_tIdx[i] = nil
    self.m_tData[i] = nil
    self.m_cbRemove[i] = nil
    self.m_tRoot[i] = nil
    self.m_tVars[i] = nil
end

-------------------------------------
-- function removeData
-------------------------------------
function TableViewTDCellData:removeData()
    for i = 1, self:getMaxItemCount() do
        local cbRemove = self:getRemoveHandler(i)
        if cbRemove then
            cbRemove()
        end
    end

    self.m_tIdx = {}
    self.m_tData = {}
    self.m_cbRemove = {}
end
