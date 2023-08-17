local PARENT = class(UI, ITabUI:getCloneTable())

UI_DragonLairBlessingPopup = class(PARENT, {
    m_listView = 'UIC_TableView',
})

--------------------------------------------------------------------------
-- @function init  
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:init()
    local vars = self:load('dragon_lair_blessing.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairBlessingPopup') -- backkey 지정
    
    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.3)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:makeTableView()
    self:refresh()
end

--------------------------------------------------------------------------
-- @function initUI
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:initUI()
    self:initTab()
end

--------------------------------------------------------------------------
-- @function initButton
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:initButton()
    local vars = self.vars

    vars['blessBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['blessAutoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

--------------------------------------------------------------------------
-- @function refresh 
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:refresh()
end

--------------------------------------------------------------------------
-- @function initTab
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:initTab()
    local vars = self.vars

    local func_cb = function (tab, first)
        self:onEnterTab(tab, first)
    end

    self:setChangeTabCB(func_cb)

    for i = 1, 5 do
        self:addTabAuto(i, vars)
    end

    self:setTab(1)
end

--------------------------------------------------------------------------
-- @function onEnterTab
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:onEnterTab(tab, first)
    local vars = self.vars
    self:makeTableView(self.m_currTab)

    do -- 타입별 모든 능력치 
        local attr_str = TableLairStatus:getInstance():getLairOverlapStatStrByIds({10001, 10004, 10006, 10007})
        vars['infoLabel']:setString(attr_str)
    end
end

--------------------------------------------------------------------------
-- @function makeTableView
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:makeTableView(curr_tab)
    local vars = self.vars
    local node = vars['optionNode']
    node:removeAllChildren()

    local item_list = TableLair:getInstance():getLairIdListByType(curr_tab)

    local function create_func(data)
        local ui = UI_DragonLairBlessingPopupItem(data)
        return ui
    end

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(990, 25)
    table_view:setCellUIClass(create_func)
    --table_view.m_gapBtwCellsSize = 5
    table_view:setCellSizeToNodeSize()
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(item_list, true)
    
    self.m_listView = table_view
end

--------------------------------------------------------------------------
-- @function click_autoBtn
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:click_autoBtn()
    UIManager:toastNotificationRed('작업 중입니다.')
end

--------------------------------------------------------------------------
-- @function click_closeBtn
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup:click_closeBtn()
    self:close()
end

--------------------------------------------------------------------------
-- @function open
--------------------------------------------------------------------------
function UI_DragonLairBlessingPopup.open()
    local ui = UI_DragonLairBlessingPopup()
    return ui
end