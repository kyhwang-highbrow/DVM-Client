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
function UI_StoryDungeonEventShop:init(season_id) 
    self.m_seasonId = season_id
    local vars = self:load('story_dungeon_shop.ui')
    UIManager:open(self, UIManager.SCENE)
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_StoryDungeonEventShop')
    
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
    self:doActionReset()
    self:doAction(nil, false)
    
    self:initMember()
    self:initUI()
    self:initTableView()
    self:initButton()
    self:refresh()

    -- 시즌 타이머
    self:scheduleUpdate(function(dt) self:update(dt) end, 1, true)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StoryDungeonEventShop:initMember() 
    local vars = self.vars
    self.m_listNode = vars['listNode']
end

-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_StoryDungeonEventShop:initParentVariable()
    self.m_uiName = 'UI_StoryDungeonEventShop'
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

    local attr = table_dragon:getDragonAttr(did)
    local role_type = table_dragon:getDragonRole(did)
    local rarity_type = 'legend'
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 이름
    local dragon_name = table_dragon:getDragonName(did)
    vars['storyEventLabel']:setStringArg(Str(dragon_name))
    
--[[     -- 속성 ex) dark
    DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)

    -- 역할 ex) healer
    local role_type = table_dragon:getDragonRole(did)
    DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)

    -- 희귀도 ex) legend
    DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)

    -- 진화도 by 별
    local res = string.format('res/ui/icons/star/star_%s_%02d%02d.png', 'yellow', 2, 5)
    local sprite = IconHelper:getIcon(res)
	vars['starNode']:addChild(sprite) ]]

    do -- 드래곤 스파인
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setDragonAnimator(did, 3)
        dragon_animator:setTalkEnable(false)
        vars['dragonNode']:addChild(dragon_animator.m_node)
    end

    do -- 드래곤 카드
        local dragon_card = MakeSimpleDragonCard(did, {})
        dragon_card.root:setScale(100/150)
        vars['dragonIconNode']:removeAllChildren()
        vars['dragonIconNode']:addChild(dragon_card.root)
        -- 이벤트 소환 바로 가기
        dragon_card.vars['clickBtn']:registerScriptTapHandler(function() 
            self:click_gachaBtn()
        end)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StoryDungeonEventShop:initButton()
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
-- function update
-------------------------------------
function UI_StoryDungeonEventShop:update(dt)
    if (g_dmgateData:isActive() == false) then 
        g_dmgateData:MakeSeasonEndedPopup()
        self.root:unscheduleUpdate()
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StoryDungeonEventShop:initTableView() 
--[[     local vars = self.vars

    self.m_listNode:removeAllChildren()
    local product_list = g_dmgateData:getShopInfoProductList()

    local function create_callback(ui, data)
        ui.m_parent = self
    end
    
    -- create TableView
    local table_view = UIC_TableViewTD(self.m_listNode)
    
    --table_view:setCellSizeToNodeSize(true)
    table_view.m_cellSize = cc.size(225 + 5, 275 + 5)
    table_view.m_nItemPerCell = 3
    table_view:setCellUIClass(UI_StoryDungeonEventShopItem, create_callback)
    table_view:setItemList(product_list)
    table_view.m_scrollView:setTouchEnabled(false)

    self.m_productTableview = table_view ]]

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
    
    -- 테이블 뷰 인스턴스 생성
    require('UI_StoryDungeonEventShopItem')
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(235 + 5, 275 + 5)
    table_view_td.m_nItemPerCell = 3
    table_view_td:setCellUIClass(UI_StoryDungeonEventShopItem, create_cb_func)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel('')
    table_view_td:setItemList(l_item_list)
    self.m_tableView = table_view_td
end

-------------------------------------
-- function onClose
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_StoryDungeonEventShop:onClose() 
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end

-------------------------------------
-- function onFocus
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_StoryDungeonEventShop:onFocus() 
end

-------------------------------------
-- function click_gachaBtn
-------------------------------------
function UI_StoryDungeonEventShop:click_gachaBtn()
    require('UI_EventPopupTab_StoryDungeonGacha')
    UI_EventPopupTab_StoryDungeonGacha.open(self.m_seasonId)
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
function UI_StoryDungeonEventShop.open(season_id)
    UI_StoryDungeonEventShop(season_id)
 end