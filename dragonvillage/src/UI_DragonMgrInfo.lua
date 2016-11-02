local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonMgrInfo
-------------------------------------
UI_DragonMgrInfo = class(PARENT,{
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonMgrInfo:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonMgrInfo'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 관리') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMgrInfo:init()
    local vars = self:load('dragon_manage_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMgrInfo')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMgrInfo:initUI()
    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonMgrInfo:initButton()
    local vars = self.vars
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMgrInfo:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonMgrInfo:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_upgradeBtn
-- @brief 승급 버튼
-------------------------------------
function UI_DragonMgrInfo:click_upgradeBtn()
    local function close_cb()
        --self:refreshSelectDragonInfo()
        cclog('cb')
        self.root:setVisible(true)
    end

    self.root:setVisible(false)
    local ui = UI_DragonMgrSubmenu()
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_DragonMgrInfo:init_dragonTableView()
    local list_table_node = self.vars['listTableNode']

    -- 생성
    local function create_func(item)
        local ui = item['ui']
        ui.root:setScale(0.8)
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)

    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node)
    table_view_ext:setCellInfo(120, 120)
    table_view_ext:setItemUIClass(UI_DragonCard, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    --table_view_ext:setItemInfo(g_dragonListData.m_lDragonList)
    table_view_ext:setItemInfo(g_dragonsData:getDragonsList())
    table_view_ext:update()

    -- 정렬
    local function default_sort_func(a, b)
        local a = a['data']
        local b = b['data']

        return a['did'] < b['did']
    end
    table_view_ext:insertSortInfo('default', default_sort_func)

    table_view_ext:sortTableView('default')

end

--@CHECK
UI:checkCompileError(UI_DragonMgrInfo)
