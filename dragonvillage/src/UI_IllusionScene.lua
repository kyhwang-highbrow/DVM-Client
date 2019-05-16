local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_IllusionStageMenu
-------------------------------------
UI_IllusionScene = class(PARENT, {

     })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionScene:init()
    local vars = self:load('dungeon_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_IllusionScene')

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_IllusionScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_IllusionScene'
    self.m_bVisible = true
    self.m_titleStr = Str('환상 던전')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'capsule_coin'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionScene:initUI()
    local vars = self.vars
    local node = self.vars['detailTableViewNode']
    
    -- 난이도에 따른 던전 리스트 아이템 세팅
    local l_table = {}
    for i=1,4 do
        local t_table = {}
        t_table['t_name'] = '악몽'
        t_table['diff'] = i
        table.insert(l_table, t_table)
    end

    local create_func = function(ui, data)
        ui.vars['enterButton']:registerScriptTapHandler(function() self:click_dungeonBtn(data['diff']) end)
        ui.vars['dungeonLevelLabel']:setString('환상 던전')
    end
    
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(886, 120 + 10)
    table_view:setCellUIClass(UI_NestDungeonStageListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_table, make_item)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionScene:click_dungeonBtn(difficulty)
    local stage_id = 1910001 + difficulty * 1000
    UI_ReadySceneNew_IllusionDungeon(stage_id)
end
