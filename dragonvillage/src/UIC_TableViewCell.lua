-- UIC_TableView에서 사용되는 Cell 클래스
-- 실제로 사용될 때에는 이 클래스를 참조만 할 것
-- UI클래스를 상속받아서 별도의 Cell클래스를 생성하면 됨

TAG_CELL_MOVE_TO = 10002
TAG_CELL_WIDTH_TO = 10003
TAG_CELL_HEIGHT_TO = 10003

-------------------------------------
-- class ITableViewCell
-------------------------------------
ITableViewCell = {
        root = 'cc.Node',
        vars = 'table',
        m_cellSize = 'cc.size',
        m_bOrgCellVisible = 'boolean',
        m_cellVisibleRefCnt = 'number',
    }

-------------------------------------
-- function init
-------------------------------------
function ITableViewCell:init()
    -- cell 사이즈 설정 (UI의 실제 사이즈)
    self.m_cellSize = cc.size(100, 100)

    -- TableView에서 cell의 visible상태를 관리하기 위한 변수들
    self.m_bOrgCellVisible = true
    self.m_cellVisibleRefCnt = 0
end

-------------------------------------
-- function getCellSize
-------------------------------------
function ITableViewCell:getCellSize()
    return self.m_cellSize
end

-------------------------------------
-- function incCellVisibleCnt
-- @breif
-------------------------------------
function ITableViewCell:incCellVisibleCnt()
    self.m_cellVisibleRefCnt = (self.m_cellVisibleRefCnt + 1)

    if (self.m_cellVisibleRefCnt == 1) and (self.m_bOrgCellVisible == false) then        
        self.root:setVisible(true)
    end
end

-------------------------------------
-- function decCellVisibleCnt
-- @param
-------------------------------------
function ITableViewCell:decCellVisibleCnt()
    self.m_cellVisibleRefCnt = (self.m_cellVisibleRefCnt - 1)

    if (self.m_cellVisibleRefCnt <= 0) and (self.m_bOrgCellVisible == false) then
        self.root:setVisible(false)
    end
end

-------------------------------------
-- function setCellVisible
-- @param
-------------------------------------
function ITableViewCell:setCellVisible(visible)
    self.m_bOrgCellVisible = visible

    if (self.m_cellVisibleRefCnt <= 0) then
        self.root:setVisible(visible)
    else
        self.root:setVisible(true)
    end
end

-------------------------------------
-- function cellVisibleRetain
-- @param
-------------------------------------
function ITableViewCell:cellVisibleRetain(duration)
    self:incCellVisibleCnt()

    -- 이동 후에는 visible 상태를 체크
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(
        function()
            self:decCellVisibleCnt()
        end
    )))
end

-------------------------------------
-- function cellMoveTo
-- @param
-------------------------------------
function ITableViewCell:cellMoveTo(duration, offset)
    local node = self.root

    local move_action = cc.MoveTo:create(duration, offset)
    action = cc.EaseInOut:create(move_action, 2)
    cca.runAction(node, action, TAG_CELL_MOVE_TO)
end

-------------------------------------
-- function cellWidthTo
-- @param
-------------------------------------
function ITableViewCell:cellWidthTo(duration, target_width)
    local node = self.root

    local width, height = node:getNormalSize()
    local func = function(value)
        node:setNormalSize(value, height)
        node:setUpdateChildrenTransform()
    end

    local tween = cc.ActionTweenForLua:create(duration, width, target_width, func)
    action = cc.EaseInOut:create(tween, 2)
    cca.runAction(node, action, TAG_CELL_WIDTH_TO)

    self.m_cellSize['width'] = target_width
end






-------------------------------------
-- function getCloneTable
-------------------------------------
function ITableViewCell:getCloneTable()
	return clone(ITableViewCell)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function ITableViewCell:getCloneClass()
	return class(clone(ITableViewCell))
end


-------------------------------------
-- class UIC_TableViewCell
-------------------------------------
UIC_TableViewCell = class(ITableViewCell:getCloneTable())

-------------------------------------
-- function init
-------------------------------------
function UIC_TableViewCell:init()
    -- root 생성
    self.root = cc.Node:create()
    self.root:setDockPoint(cc.p(0.5, 0.5))
    self.root:setAnchorPoint(cc.p(0.5, 0.5))

    -- vars 초기화
    self.vars = {}

    -- cell 사이즈 설정 (UI의 실제 사이즈)
    self.m_cellSize = cc.size(100, 100)

    -- TableView에서 cell의 visible상태를 관리하기 위한 변수들
    self.m_bOrgCellVisible = true
    self.m_cellVisibleRefCnt = 0
end