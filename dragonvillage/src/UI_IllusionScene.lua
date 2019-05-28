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

    local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
    local stage_id = struct_illusion:getCurIllusionStageId()
    self.m_titleStr = g_stageData:getStageName(stage_id)
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'event_illusion'
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_IllusionScene:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionScene:initUI()
    local vars = self.vars
    local node = self.vars['detailTableViewNode']

    local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
    local l_stage_info = struct_illusion:getIllusionStageList()
    
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(886, 120 + 10)
    table_view:setCellUIClass(UI_IllusionStageListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_stage_info, make_item)

    -- 왼측 환상 던전용 정보창
    local ui_illusion_info = UI()
    ui_illusion_info:load('event_dungeon_item.ui')
    ui_illusion_info.vars['titleLabel']:setString(Str('죄악의 환상'))

    local struct_illusion  = g_illusionDungeonData:getEventIllusionInfo()   
    local highest_score = struct_illusion:getIllusionHighestScore()
    ui_illusion_info.vars['meRankLabel']:setString(Str('내 최고 점수 : {1}점', highest_score))
    
    local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
    ui_illusion_info.vars['topRankLabel']:setString(Str('내 순위 : {1}위', struct_illusion.rank ))
    
    local time_text = g_illusionDungeonData:getIllusionStatusText('event_illusion')
    ui_illusion_info.vars['timeLabel']:setString(Str(time_text))
    
    -- 배경 이미지
    local event_sprite = cc.Sprite:create('res/ui/event/event_dungeon/ed_tab_illusion.png')
    event_sprite:setDockPoint(cc.p(0.5, 0.5))
    ui_illusion_info.vars['dungeonImgNode']:addChild(event_sprite)

    vars['dungeonNode']:addChild(ui_illusion_info.root)

    vars['dscLabel']:setVisible(true)
    vars['rankBtn']:setVisible(true)

    vars['eventDungeonVisual']:setVisible(true)
    vars['bgVisual']:setVisible(false)
end


