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
    self.m_bUseEachSize = true
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
    ui.vars['trainButtonB']:getParent():setSwallowTouch(false)

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

    self:expandTemp(duration)

    if (not expand) then
        self:relocateContainer(true)
    end
end