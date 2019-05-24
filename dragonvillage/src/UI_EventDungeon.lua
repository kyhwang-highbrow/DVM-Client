local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventDungeon
-------------------------------------
UI_EventDungeon = class(PARENT, {

     })

-------------------------------------
-- function init
-------------------------------------
function UI_EventDungeon:init()
    local vars = self:load('event_dungeon_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventDungeon')

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_EventDungeon:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_EventDungeon'
    self.m_bVisible = true
    self.m_titleStr = Str('이벤트 던전')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'capsule_coin'
end

-------------------------------------
-- function initUI
------------------------------------
function UI_EventDungeon:initUI()
    local vars = self.vars
    local node = self.vars['listNode']

    local l_item_list = { [1] = '환상던전'}

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(264, 104 + 5)
    table_view:setCellUIClass(UI_EventDungeonTabListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    table_view:setItemList(l_item_list)
    local event_ui = UI_AdventureScene_Illusion()
    vars['eventNode']:addChild(event_ui.root)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventDungeon:click_exitBtn()
    self:close()
end



local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EventDungeonTabListItem
-------------------------------------
UI_EventDungeonTabListItem = class(PARENT, {

     })

-------------------------------------
-- function init
-------------------------------------
function UI_EventDungeonTabListItem:init()
    local vars = self:load('event_dungeon_scene_item.ui')

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDungeonTabListItem:initUI()
    local vars = self.vars

    vars['eventLabel']:setString(Str('환상 던전'))

    local time_text = g_illusionDungeonData:getIllusionStatusText('event_illusion_legend')
    vars['timeLabel']:setString(time_text)

    local event_sprite = cc.Sprite:create('res/ui/event/list_ed_illusion.png')
    event_sprite:setDockPoint(cc.p(0.5, 0.5))
    vars['listNode']:removeAllChildren()
    vars['listNode']:addChild(event_sprite)
end