local PARENT = UIC_TableView

-------------------------------------
-- class UIC_TableView_TrainSlotList
-------------------------------------
UIC_TableView_TrainSlotList = class(PARENT, {
        m_itemUICreateCB = 'function',
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