local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

UI_ShopPackageScene = class(PARENT, {
    m_tableView = 'UIC_TableView',
    m_scrollView = 'cc.ScrollView',
    m_targetButton = 'UIC_Button',

    m_dragonPkgUI = 'UI_GetDragonPackage',
})

----------------------------------------------------------------------
-- function initParentVariable
----------------------------------------------------------------------
function UI_ShopPackageScene:initParentVariable()
    self.m_uiName = 'UI_ShopPackageScene'
    self.m_titleStr = Str('패키지')
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_ShopPackageScene:init(package_name)
    local vars = self:load('shop_package.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ShopPackageScene')
    
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(package_name)
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ShopPackageScene:initUI(package_name)
    local vars = self.vars

    self:createPackageScrollView()

    self:createButtonTableView(package_name)
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_ShopPackageScene:initButton()

end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ShopPackageScene:refresh()
    if (not self.m_targetButton) then
        local item = self.m_tableView:getItemFromIndex(1)
        self.m_targetButton = item['ui'] or item['generated_ui']
    end
    self.m_targetButton:click_btn()

    local index = self.m_targetButton:getCellIndex()
    self.m_tableView:relocateContainerFromIndex(index)
end

----------------------------------------------------------------------
-- function createPackageScrollView
-- brief : 
----------------------------------------------------------------------
function UI_ShopPackageScene:createPackageScrollView()
    local content_size = self.vars['contentsListNode']:getContentSize()

    local scroll_view = cc.ScrollView:create()
    scroll_view:setDockPoint(CENTER_POINT)
    scroll_view:setAnchorPoint(CENTER_POINT)
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    scroll_view:setNormalSize(content_size)
    scroll_view:setContentSize(content_size)
    self.vars['contentsListNode']:addChild(scroll_view)

    self.m_scrollView = scroll_view
end

----------------------------------------------------------------------
-- function createButtonTableView
----------------------------------------------------------------------
function UI_ShopPackageScene:createButtonTableView(package_name)
    if self.m_tableView then
        self.m_tableView:removeAllChildren()
        self.m_tableView = nil
    end

    local table_view = UIC_TableView(self.vars['listNode'])
    table_view:setCellSizeToNodeSize()
    table_view:setGapBtwCells(3)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    
    self:setTableView(table_view, package_name)
    self.m_tableView = table_view
end

----------------------------------------------------------------------
-- function setTableView
----------------------------------------------------------------------
function UI_ShopPackageScene:setTableView(table_view, package_name)
    local item_list = g_shopDataNew:getActivatedPackageList()
    local dragonList = table.MapToList(g_getDragonPackage:getPackageList())
    local total_PackageList = table.merge(dragonList, item_list)

    --일반 패키지 UI 생성 후 CallBack Function
    local createPkg_func = function(ui, key)
        ui.m_parent = self
        ui.m_scrollView = self.m_scrollView
        ui.m_contractBtn = self.vars['contractBtn']
        local data = total_PackageList[key]
        if (data['t_name'] == package_name) then
            self.m_targetButton = ui
        end

        ui:refresh()
    end

    --드래곤 패키지 UI 생성 후 CallBack Function
    local createDragonPkg_func = function(ui, key)
        local data = total_PackageList[key]
        ui.m_parent = self
        if (data:getDragonID() == package_name) then
            self.m_targetButton = ui
        end
        ui:refresh()
    end

    --ItemList 추가는 여기서 작업[count, UI, createCB]
    local keyPartition = {}
    table.insert(keyPartition, {count = #dragonList, UI = UI_DragonPackageCategoryButton , createCB = createDragonPkg_func})
    table.insert(keyPartition, {count = #item_list, UI = UI_PackageCategoryButton, createCB = createPkg_func})

    --List에서 Key를 통해 UI 찾아서 return
    local UI_CreateFunc= function(key)
        local ui = nil
        local keyCnt = 0
        for _, value in ipairs(keyPartition) do
            keyCnt = keyCnt + value['count']
            if (key <= keyCnt) then
                ui = value['UI']
                break
            end
        end
        return ui(total_PackageList[key])
    end
    --List에서 Key를 통해 CreateCB를 찾아서 호출
    local Create_CBFunc= function(ui, key)
        local func = nil
        local keyCnt = 0
        for _, value in ipairs(keyPartition) do
            keyCnt = keyCnt + value['count']
            if (key <= keyCnt) then
                func = value['createCB']
                break
            end
        end
        func(ui, key)
    end


    local tableItem = {}
    for i = 1, #total_PackageList, 1 do
        tableItem[i] = i
    end

    table_view:setCellUIClass(UI_CreateFunc, Create_CBFunc)
    table_view:setItemList(tableItem, true)   --드래곤 획득 패키지
end


----------------------------------------------------------------------
-- function changeTargetUI
----------------------------------------------------------------------
function UI_ShopPackageScene:changeTargetUI(newTarget)
    local targetUI = self.m_targetButton
    if (targetUI) then
        targetUI:SetTarget(false)
    end

    newTarget:SetTarget(true)
    self.m_targetButton = newTarget

    local data = newTarget.m_data
    local t_name = data['t_name']

    if t_name then
        g_settingData:setPackageSetting(true, t_name)
    end
end

----------------------------------------------------------------------
-- function setOff_DragonPackageUI
----------------------------------------------------------------------
function UI_ShopPackageScene:setOff_DragonPackageUI()
    local oldUI = self.m_dragonPkgUI or nil

    --기존 UI Visivle끄고 타이머 멈춤
    if (oldUI) then
        oldUI:setVisible(false)
        oldUI:unSetTimerSchedule()
    end
end

----------------------------------------------------------------------
-- function setDragonPackageUI
----------------------------------------------------------------------
function UI_ShopPackageScene:setDragonPackageUI(packageUI, isNew)
    local vars = self.vars
    local contentsNode = vars['contentsNode']

    --OldUI관련
    self:setOff_DragonPackageUI()

    packageUI:setVisible(true)
    packageUI:setTimerSchedule()

    --New Node 추가
    if isNew then
        contentsNode:addChild(packageUI.root)
    end

    self.m_dragonPkgUI = packageUI
    self.m_scrollView:setVisible(false)
    vars['contractBtn']:setVisible(false)
end

----------------------------------------------------------------------
-- function click_exitBtn
----------------------------------------------------------------------
function UI_ShopPackageScene:click_exitBtn()
    self:close()
end