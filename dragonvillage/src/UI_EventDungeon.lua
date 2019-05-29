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
    self.m_subCurrency = 'event_illusion'
end

-------------------------------------
-- function initUI
------------------------------------
function UI_EventDungeon:initUI()
    local vars = self.vars
    local node = self.vars['listNode']

    local l_item_list = { [1] = '환상던전', [2] = 'lock', [3] = 'lock'} -- 임시로 락 걸린 이벤트를 걸어준다. 아직 이벤트 던전 관리 테이블이 없음

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(320, 125)
    table_view:setCellUIClass(UI_EventDungeonTabListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    table_view:setItemList(l_item_list)
    local event_ui = UI_EventScene_Illusion()
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
        m_data = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_EventDungeonTabListItem:init(data)
    local vars = self:load('event_dungeon_scene_item.ui')
    self.m_data = data

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
    if (self.m_data == 'lock') then
        vars['lockNode']:setVisible(true)
        vars['eventLabel']:setVisible(false)
        vars['timeLabel']:setVisible(false)
        return
    end


    vars['eventLabel']:setString(Str('환상 던전'))

    -- 남은 시간 출력
    local time_text = ''
    if (g_illusionDungeonData:getIllusionState() == Serverdata_IllusionDungeon.STATE['OPEN']) then
        time_text = g_illusionDungeonData:getIllusionStatusText()
    else
        time_text = g_illusionDungeonData:getIllusionExchanageStatusText()
    end
    vars['timeLabel']:setString(time_text)

    -- 환상던전 이미지 출력
    local event_sprite = cc.Sprite:create('res/ui/event/list_ed_illusion.png')
    event_sprite:setDockPoint(cc.p(0.5, 0.5))
    vars['listNode']:removeAllChildren()
    vars['listNode']:addChild(event_sprite)
end