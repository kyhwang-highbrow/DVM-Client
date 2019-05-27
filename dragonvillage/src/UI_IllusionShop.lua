local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_IllusionShop
-------------------------------------
UI_IllusionShop = class(PARENT, {

     })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionShop:init()
    local vars = self:load('event_illusion_shop.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_IllusionShop')

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_IllusionShop:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_IllusionShop'
    self.m_bVisible = true
    self.m_titleStr = Str('환상 던전 교환소')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'capsule_coin'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionShop:initUI()
    local vars = self.vars

    --Npc가 환상 드래곤일 경우 애니메이션
    local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
    local l_illusion_dragon = struct_illusion:getIllusionDragonList()
    local illusion_dragon_did = tonumber(l_illusion_dragon[1])
    local dragon_animator = UIC_DragonAnimator()

    dragon_animator:setDragonAnimator(illusion_dragon_did, 3)
    dragon_animator:setTalkEnable(false)
    dragon_animator:setIdle()
    vars['npcNode']:addChild(dragon_animator.m_node)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IllusionShop:refresh()
    local vars = self.vars

    local finish_cb = function(ret)
        local l_shop = ret['exchange_list']
        -- 테이블 뷰 인스턴스 생성
        local table_view_td = UIC_TableViewTD(vars['listNode'])
        table_view_td.m_cellSize = cc.size(235, 255)
        table_view_td.m_nItemPerCell = 4
	    table_view_td:setCellUIClass(UI_IllusionShopListItem)
        table_view_td:setItemList(l_shop)
	    
	    table_view_td:setCellCreateInterval(0)
	    table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
        table_view_td:setCellCreatePerTick(3)
    end

    -- 교환소 통신
    g_illusionDungeonData:request_illusionShopInfo(finish_cb)
    

    --Npc가 환상 드래곤일 경우 애니메이션
    local res = 'res/character/npc/narvi/narvi.json'
    vars['npcNode']:removeAllChildren(true)
    local animator = MakeAnimator(res)
    if (animator.m_node) then
         animator:changeAni('idle', true)
         vars['npcNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_IllusionShop:click_exitBtn()
   self:close()
end







local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_IllusionShopListItem
-------------------------------------
UI_IllusionShopListItem = class(PARENT, {
        m_data = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionShopListItem:init(data)
    local vars = self:load('event_illusion_shop_item.ui')
    self.m_data = data['table']

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionShopListItem:initUI()
    local vars = self.vars
    local data = self.m_data

    if (not data) then
        return
    end

    local item_str = data['item']
    local l_item_str = pl.stringx.split(item_str, ';') -- 703003;1
    local item_id = tonumber(l_item_str[1])
    local item_cnt = l_item_str[2]
    local item_name = TableItem:getItemName(item_id)

    vars['itemLabel']:setString(Str(item_name))
    vars['priceLabel']:setString(data['price'])

    -- 아이템 카드
    local ui_item_card = UI_ItemCard(item_id)
    vars['itemNode']:addChild(ui_item_card.root)

    -- 구매 가능 횟수
    local buy_cnt_str = string.format('%s/%s', 0, data['buy_count'])
    vars['maxBuyTermLabel']:setString(buy_cnt_str)

    -- 재화 아이콘
    local price_sprite = cc.Sprite:create('res/ui/icons/item/ticket_5_rune.png')
    local str_width = vars['priceLabel']:getStringWidth() + 5 
    local opt_pos_x, opt_pos_y = vars['priceLabel']:getPosition()
    price_sprite:setPosition(opt_pos_x + str_width - 65, 30)
    vars['priceNode']:addChild(price_sprite)
    
end
