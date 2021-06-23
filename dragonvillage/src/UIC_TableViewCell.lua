-- UIC_TableView에서 사용되는 Cell 클래스
-- 실제로 사용될 때에는 이 클래스를 참조만 할 것
-- UI클래스를 상속받아서 별도의 Cell클래스를 생성하면 됨

TAG_CELL_MOVE_TO = 10002
TAG_CELL_WIDTH_TO = 10003
TAG_CELL_HEIGHT_TO = 10003
TAG_CELL_MOVE_TO_FORCE = 10004

-------------------------------------
-- class ITableViewCell
-------------------------------------
ITableViewCell = {
        root = 'cc.Node',
        vars = 'table',
        m_cellIndex = 'number',
        m_cellSize = 'cc.size',
        m_bOrgCellVisible = 'boolean',
        m_cellVisibleRefCnt = 'number',
		m_highligtFrame = 'sprite',
        m_tableView = 'UIC_TableView',
    }

-------------------------------------
-- function init
-------------------------------------
function ITableViewCell:init()
    -- cell 사이즈 설정 (UI의 실제 사이즈)
    self.m_cellSize = nil

    -- TableView에서 cell의 visible상태를 관리하기 위한 변수들
    self.m_bOrgCellVisible = true
    self.m_cellVisibleRefCnt = 0
end

-------------------------------------
-- function setCellIndex
-------------------------------------
function ITableViewCell:setCellIndex(index)
    self.m_cellIndex = index
end

-------------------------------------
-- function getCellIndex
-------------------------------------
function ITableViewCell:getCellIndex()
    return self.m_cellIndex
end

-------------------------------------
-- function setCellSize
-------------------------------------
function ITableViewCell:setCellSize(cell_size)
    self.m_cellSize = cell_size
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
function ITableViewCell:cellMoveTo(duration, offset, force)
    local node = self.root

    -- UIC_TableView의 cellMoveTo와 외부에서 선언한 cellMoveTo의 액션이 겹치는 것을 방지
    -- TAG_CELL_MOVE_TO_FORCE 액션 실행중이면 skip 
    local action = node:getActionByTag(TAG_CELL_MOVE_TO_FORCE)
    if action then
        return
    end

    local move_action = cc.MoveTo:create(duration, offset)
    action = cc.EaseInOut:create(move_action, 2)
    local tag = force and TAG_CELL_MOVE_TO_FORCE or TAG_CELL_MOVE_TO
    cca.runAction(node, action, tag)
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
-- function setHighlightFrame
-------------------------------------
function ITableViewCell:setHighlightFrame(visible)
	if (self.m_highligtFrame) then
		self.m_highligtFrame:setVisible(visible)

	else
		local rect = cc.rect(0, 0, 0, 0)
		local sprite = cc.Scale9Sprite:create(rect, 'res/ui/frames/temp/icon_frame_02.png')
		sprite:setContentSize(self.m_cellSize['width'], self.m_cellSize['height'])
		sprite:setDockPoint(CENTER_POINT)
		sprite:setAnchorPoint(CENTER_POINT)

		self.root:addChild(sprite)
		self.m_highligtFrame = sprite

	end
end

-------------------------------------
-- function setTableView
-------------------------------------
function ITableViewCell:setTableView(table_view)
	self.m_tableView = table_view
end

-------------------------------------
-- function delThis
-------------------------------------
function ITableViewCell:delThis()
    if (not self.m_tableView) then
        return
    end

    if (not self.m_tableView.m_itemMap) then
        return
    end

    for key, t_item in pairs(self.m_tableView.m_itemMap) do
        if (t_item['ui'] == self) then
            self.m_tableView:delItem(key)
            break
        end
    end
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
    self.root = cc.Menu:create()
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