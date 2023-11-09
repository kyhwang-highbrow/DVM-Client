local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())
-------------------------------------
--- @class UI_Research
-------------------------------------
UI_Research = class(PARENT,{
    m_researchTableViewList = 'List<TableView>',
})

-------------------------------------
--- @function initParentVariable
--- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Research:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Research'
    self.m_subCurrency = 'blessing_ticket'  -- 상단 유저 재화 정보 중 서브 재화    
    self.m_titleStr = Str('연구')
    self.m_bUseExitBtn = true -- click_exitBtn()함구 구현이 반드시 필요함
    --self.m_bShowInvenBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_Research:init(doid)
    self:load('research.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Research')

    self:doActionReset()
	self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:makeTableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Research:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_Research:initButton()
    local vars = self.vars
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_Research:makeTableView()
    local vars = self.vars
    self.m_researchTableViewList = {}
    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['infoBtn']:registerScriptTapHandler(function()
            self:click_infoBtn(data)
        end)
    end

    for type = 1,2 do
        local str = string.format('list%dNode', type)
        local item_list = TableResearch:getInstance():getIdListByType(type)

        local table_view = UIC_TableView(vars[str])
        table_view.m_defaultCellSize = cc.size(120, 200)
        table_view:setCellUIClass(UI_ResearchItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        table_view:setItemList(item_list)

        self.m_researchTableViewList[type] = table_view
        table_view:update(0)
        table_view:relocateContainerFromIndex(100)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Research:refresh()
end

-------------------------------------
--- @function click_infoBtn
-------------------------------------
function UI_Research:click_infoBtn(research_id)
    UI_ResearchConfirmPopup(research_id)
end

-------------------------------------
-- function click_helpBtn
-------------------------------------
function UI_Research:click_helpBtn()
    --UI_Help('lair')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Research:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_Research)
