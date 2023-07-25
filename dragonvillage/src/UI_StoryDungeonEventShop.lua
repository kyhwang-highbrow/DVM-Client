local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

UI_StoryDungeonEventShop = class(PARENT, {
    m_modeId = 'number',
    m_dragonNode = '',
    m_relationNode = '',
    m_listNode = '',
    m_npcNode = '',
    m_productTableview = '',
    m_relationUI = '',
    m_seasonId = 'string',
    m_tableView = 'TableView',
})

-------------------------------------
-- function init
-------------------------------------
function UI_StoryDungeonEventShop:init() 
    self.m_seasonId = g_eventDragonStoryDungeon:getStoryDungeonSeasonId()
    self.m_uiName = 'UI_StoryDungeonEventShop'
    self:load('story_dungeon_shop.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_StoryDungeonEventShop')

    -- @UI_ACTION
    -- self:doActionReset()
    -- self:doAction(nil, false)

    self:initUI()
    self:initTableView()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_StoryDungeonEventShop:initParentVariable()
    self.m_titleStr = TableStoryDungeonEvent:getStoryDungeonEventName(self.m_seasonId)
    self.m_subCurrency = TableStoryDungeonEvent:getStoryDungeonEventTokentKey(self.m_seasonId)
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StoryDungeonEventShop:initUI() 
    local vars = self.vars
    local did =  TableStoryDungeonEvent:getStoryDungeonEventDid(self.m_seasonId)
    local table_dragon = TableDragon()

    --local attr = table_dragon:getDragonAttr(did)
    --local role_type = table_dragon:getDragonRole(did)
    --local rarity_type = 'legend'
    --local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 이름
    local dragon_name = table_dragon:getDragonName(did)
    vars['storyEventLabel']:setStringArg(Str(dragon_name))

    do -- 드래곤 스파인
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setDragonAnimator(did, 3)
        dragon_animator:setTalkEnable(false)
        vars['dragonNode']:addChild(dragon_animator.m_node)
    end

    do -- 드래곤 카드
        local dragon_card = MakeSimpleDragonCard(did, {})
        dragon_card.root:setScale(100/150)
        dragon_card.vars['attrNode']:setVisible(false)

        vars['dragonIconNode']:removeAllChildren()
        vars['dragonIconNode']:addChild(dragon_card.root)
        
        dragon_card.vars['clickBtn']:setEnabled(false)
    end

    do -- 배경 이미지
        local bg_res = TableStoryDungeonEvent:getStoryDungeonEventBgRes(self.m_seasonId)
        local animator = MakeAnimator(bg_res)
        vars['bgNode']:removeAllChildren()
        vars['bgNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StoryDungeonEventShop:initButton()
    local vars = self.vars
    -- 이벤트 소환 바로 가기
    vars['storyEventBtn']:registerScriptTapHandler(function() 
        self:click_gachaBtn()
    end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_StoryDungeonEventShop:refresh()
    if self.m_tableView then
        self.m_tableView:refreshAllItemUI()
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StoryDungeonEventShop:initTableView() 
    self.m_listNode = self.vars['listNode']

    local shop_tab_key = TableStoryDungeonEvent:getStoryDungeonEventShopTabKey(self.m_seasonId)
    local list_table_node = self.m_listNode
    local l_item_list = g_shopDataNew:getProductList(shop_tab_key)

    -- 생성 콜백
	local function create_cb_func(ui, data)
        ui:setBuyCB(
            function ()
                self:refresh()
            end
        )
	end

    local function sort_func(a, b)
        local struct_a = a['data']
        local struct_b = b['data']
        return struct_a:getUIPriority() > struct_b:getUIPriority()
    end
    
    -- 테이블 뷰 인스턴스 생성
    require('UI_StoryDungeonEventShopItem')
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(235 + 5, 275 + 5)
    table_view_td.m_nItemPerCell = 3
    table_view_td:setCellUIClass(UI_StoryDungeonEventShopItem, create_cb_func)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:makeDefaultEmptyDescLabel('') -- 리스트가 비었을 때
    table_view_td:setItemList(l_item_list)
    table_view_td:insertSortInfo('sort', sort_func)
    table_view_td:sortImmediately('sort')

    self.m_tableView = table_view_td
end

-------------------------------------
-- function click_gachaBtn
-------------------------------------
function UI_StoryDungeonEventShop:click_gachaBtn()
    require('UI_EventPopupTab_StoryDungeonGacha')
    local ui = UI_EventPopupTab_StoryDungeonGacha(true)
    ui:open()
end

-------------------------------------
-- function click_exitBtn
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_StoryDungeonEventShop:click_exitBtn()
   self:close()
end

-------------------------------------
-- function UI_StoryDungeonEventShop.open()
-------------------------------------
function UI_StoryDungeonEventShop.open()
    UI_StoryDungeonEventShop()
 end