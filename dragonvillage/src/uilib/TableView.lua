-------------------------------------
-- class TableView
-------------------------------------
TableView = class
{
    m_cells = 'table'            -- cc.TableViewCell
,    m_cellDatas = 'table'        -- TableViewCellData
,   m_cbDidScroll = 'function'
,   m_cbDidZoom = 'function'
}

TableView.__index = TableView

-------------------------------------
-- function init
-------------------------------------
function TableView:init()
    self:_init()
end

-------------------------------------
-- function _init
-------------------------------------
function TableView:_init()
    self.m_cells = {}    
    self.m_cellDatas = {}
    self.m_cbDidScroll = function() end
    self.m_cbDidZoom = function() end

    local scrollViewDidScroll = function(view)
        --cclog('scrollViewDidScroll')
        self.m_cbDidScroll()
    end

    local scrollViewDidZoom = function(view)
        --cclog('scrollViewDidZoom')
        self.m_cbDidZoom()
    end

    local tableCellTouched = function(table, cell)
        --cclog('cell touched at index: ' .. cell:getIdx())
        local idx = cell:getIdx() + 1
        local cellData = self.m_cellDatas[idx]
        if not cellData then
            --cclog_error('TableView error : cellData dont exist')
            return 0, 0
        end
        
        cellData.onTouchFunc(cellData, idx)
    end
    
    local cellSizeForTable = function(table, idx) 
        local idx = idx + 1
        local cellData = self.m_cellDatas[idx]
        if not cellData then
            cclog_error('TableView error : cellData dont exist')
            return 0, 0
        end
        
        local ccSize = cellData:getSize()
        return ccSize.width, ccSize.height
    end
    
    local tableCellAtIndex = function(table, idx)
        local idx = idx + 1
        local cell = table:dequeueCell()
        local cellData = self.m_cellDatas[idx]
        if not cell then
            cell = cc.TableViewCell:new()
        end
        self.m_cells[idx] = cell
        cellData.onEnterFunc(cell, cellData, idx)
        return cell
    end

    local tableCellWillRecycle = function(table, cell)
        local idx = cell:getIdx() + 1
        self.m_cells[idx] = nil
    end

    local numberOfCellsInTableView = function(table)
        return #self.m_cellDatas
    end

    self:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self:registerScriptHandler(tableCellWillRecycle, cc.TABLECELL_WILL_RECYCLE)
    self:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self:reloadData()
end

-------------------------------------
-- function setDidScrollHandler
-------------------------------------
function TableView:setDidScrollHandler(func)
    self.m_cbDidScroll = func
end

-------------------------------------
-- function setDidZoomHandler
-------------------------------------
function TableView:setDidZoomHandler(func)
    self.m_cbDidZoom = func
end

-------------------------------------
-- function addData
-------------------------------------
function TableView:addData(cellData)
    if isInstanceOf(cellData, TableViewCellData) then
        table.insert(self.m_cellDatas, cellData)
    else
        cclog_error('TableView error : wrong data type')
    end
end

-------------------------------------
-- function removeData
-------------------------------------
function TableView:removeData(idx)
    table.remove(self.m_cellDatas, idx)
end

-------------------------------------
-- function clear
-------------------------------------
function TableView:clear()
    self.m_cellDatas = {}
end

-------------------------------------
-- function update
-------------------------------------
function TableView:update()
    -- TODO: reload() 등의 테이블뷰 갱신 처리를 한다.
end

-------------------------------------
-- function extend
-------------------------------------
function TableView.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, TableView)
    return target
end

-------------------------------------
-- function create
-------------------------------------
function TableView.create(ccTableView)
    local tableView = TableView.extend(ccTableView)
    if nil ~= tableView then
        tableView:init()
    end

    return tableView
end

-------------------------------------
-- class TableViewCellData
-------------------------------------
TableViewCellData = class
{
    cellIdx = 'number'            -- 링크되어야할 TableViewCell객체의 idx
,    size = 'CCSize'
,    onEnterFunc = 'function'    -- 인덱스에 해당하는 셀내용(ui)을 정의하기 위한 함수(리스트내에서 셀이 처음 등장하거나 갱신될 경우 호출됨)
,    onTouchFunc = 'function'    -- 셀이 터치되었을때 호출
}

-------------------------------------
-- function init
-------------------------------------
function TableViewCellData:init(cellIdx, ccSize)
    self.cellIdx = cellIdx
    self.size = ccSize
    self.onEnterFunc = function() end
    self.onTouchFunc = function() end
end

-------------------------------------
-- function setSize
-------------------------------------
function TableViewCellData:setSize(size)
    self.size = size
end

-------------------------------------
-- function getSize
-------------------------------------
function TableViewCellData:getSize()
    return self.size
end

-------------------------------------
-- function setEnterFunc
-------------------------------------
function TableViewCellData:setEnterFunc(onEnterFunc)
    if not onEnterFunc then return end
    self.onEnterFunc = onEnterFunc
end

-------------------------------------
-- function setTouchFunc
-------------------------------------
function TableViewCellData:setTouchFunc(onTouchFunc)
    if not onTouchFunc then return end
    self.onTouchFunc = onTouchFunc
end