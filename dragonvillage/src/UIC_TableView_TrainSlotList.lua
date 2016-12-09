local PARENT = UIC_TableView

-------------------------------------
-- class UIC_TableView_TrainSlotList
-------------------------------------
UIC_TableView_TrainSlotList = class(PARENT, {
        m_itemUICreateCB = 'function',
        m_bExpanded = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_TableView_TrainSlotList:init(node)
    -- 기본값 설정
    self.m_defaultCellSize = cc.size(100, 100)
    self:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
end

-------------------------------------
-- function setItemUICreateCB
-------------------------------------
function UIC_TableView_TrainSlotList:setItemUICreateCB(item_ui_create_cb)
    self.m_itemUICreateCB = item_ui_create_cb
end

-------------------------------------
-- function makeItemUI
-------------------------------------
function UIC_TableView_TrainSlotList:makeItemUI(data)
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

    if self.m_itemUICreateCB then
        self.m_itemUICreateCB(ui, data)
    end

    return ui
end

-------------------------------------
-- function setExpand
-- @param
-------------------------------------
function UIC_TableView_TrainSlotList:setExpand(expand, duration)
    if (self.m_bExpanded == expand) then
        return
    end

    self.m_bExpanded = expand

    for i,v in ipairs(self.m_itemList) do
        local ui = v['ui']
        ui:setExpand(expand, duration)
    end

    --self:_updateCellPositions()
    --self:_updateContentSize()
    --self:scrollViewDidScroll()

    self:expandTemp(duration)


    if (not expand) then
        self:relocateContainerDefault(true)
    end
end

-------------------------------------
-- function expandTemp
-- @param
-------------------------------------
function UIC_TableView_TrainSlotList:expandTemp(duration)
    local duration = duration or 0.15

    -- 현재 보여지는 애들 리스트
    local l_visible_cells = {}
    for i,v in ipairs(self._cellsUsed) do
        local idx = v['idx']
        l_visible_cells[idx] = v
    end

    self:_updateCellPositions()
    self:_updateContentSize(true)
    self:scrollViewDidScroll()

    -- 변경 후 보여질 애들 리스트
    for i,v in ipairs(self._cellsUsed) do
        local idx = v['idx']
        l_visible_cells[idx] = v
    end

    -- 눈에 보여지도록 추가
    for i,v in pairs(l_visible_cells) do
        v['ui']:increaseVisibleCnt()
        v['ui']:setVisible(true)

        -- 이동 후에는 visible 상태를 체크
        v['ui'].root:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(
            function()
                v['ui']:decreaseVisibleCnt()
            end
        )))
    end
    

    for i,v in ipairs(self.m_itemList) do
        local ui = self.m_itemList[i]['ui']
        local offset = self:_offsetFromIndex(i)
        local action = cc.MoveTo:create(duration, offset)
        ui.root:runAction(action)
    end

    
end