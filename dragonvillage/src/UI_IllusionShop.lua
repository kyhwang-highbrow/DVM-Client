local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_IllusionShop
-------------------------------------
UI_IllusionShop = class(PARENT, {
        m_lCurExchange = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionShop:init()
    local vars = self:load('event_illusion_shop.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_lCurExchange = {}

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
    self.m_subCurrency = 'event_illusion'
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

    -- 교환소 남은 시간
    if (not g_illusionDungeonData:getIllusionState() == Serverdata_IllusionDungeon.STATE['OPEN']) then
        local state_text = g_illusionDungeonData:getIllusionExchanageStatusText()
        local remain_str = Str('교환 기간: {1}', state_text)
        vars['timeLabel']:setString(remain_str)
    else
        vars['timeLabel']:setString('')
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IllusionShop:refresh()
    local vars = self.vars

    local finish_cb = function(ret)
        self.m_lCurExchange = ret['my_exchange_list'] 
        local l_shop = ret['exchange_list']
        vars['listNode']:removeAllChildren()

        local create_cb = function(ui, data)        
            local buy_cnt = self:getProductCnt(data['table']['id'])
            ui:setBuyCnt(buy_cnt)
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view_td = UIC_TableViewTD(vars['listNode'])
        table_view_td.m_cellSize = cc.size(235 + 5, 255 + 5)
        table_view_td.m_nItemPerCell = 4
	    table_view_td:setCellUIClass(UI_IllusionShopListItem, create_cb)
        table_view_td:setItemList(l_shop)
	    
	    table_view_td:setCellCreateInterval(0)
	    table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
        table_view_td:setCellCreatePerTick(3)
    end

    -- 교환소 통신
    g_illusionDungeonData:request_illusionShopInfo(finish_cb)
    local res = 'res/character/npc/narvi/narvi.json'

    --Tamer를 랜덤으로 출력
    local random_number = math_random(1, 5)
    if (random_number == 1) then res = 'res/character/tamer/durun_i/durun_i.json'
    elseif (random_number == 2) then res = 'res/character/tamer/goni_i/goni_i.json'
    elseif (random_number == 3) then res = 'res/character/tamer/dede_i/dede_i.json'
    elseif (random_number == 4) then res = 'res/character/tamer/kesath_i/kesath_i.json'
    elseif (random_number == 5) then res = 'res/character/tamer/mokoji_i/mokoji_i.json'
    end


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

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_IllusionShop:getProductCnt(target_product_id)
    local target_product_id = tostring(target_product_id)

    for product_id, count in pairs(self.m_lCurExchange) do
         if (target_product_id == product_id) then
             return tonumber(count)
         end
    end

   return 0
end






local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_IllusionShopListItem
-------------------------------------
UI_IllusionShopListItem = class(PARENT, {
        m_data = 'table',
        m_buyCnt = 'number',
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
    if (tonumber(item_cnt) > 1) then
        item_name = item_name .. ' ' .. Str('{1}개', comma_value(item_cnt))
    end

    vars['itemLabel']:setString(Str(item_name))
    local price = data['price']
    vars['priceLabel']:setString(comma_value(price))

    -- 아이템 카드
    local ui_item_card = UI_ItemCard(item_id)
    ui_item_card:setSwallowTouch()
    vars['itemNode']:addChild(ui_item_card.root)

    -- 재화 아이콘
    local price_sprite = cc.Sprite:create('res/ui/icons/inbox/inbox_staminas_event_illusion_01.png')
    price_sprite:setPosition(20, 30)
    vars['priceNode']:addChild(price_sprite)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionShopListItem:initButton()
    local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionShopListItem:setBuyCnt(buy_cnt)
    local data = self.m_data
    local vars = self.vars 

    -- 구매 가능 횟수
    local buy_cnt_str = Str('구매 가능 {1}/{2}', data['buy_count'] - buy_cnt, data['buy_count'])
    self.vars['maxBuyTermLabel']:setString(buy_cnt_str)
    if (data['buy_count'] == buy_cnt) then
        self.vars['maxBuyTermLabel']:setColor(cc.c3b(255, 0, 0))
        vars['buyBtn']:setEnabled(false)
    else
        self.vars['maxBuyTermLabel']:setColor(cc.c3b(0, 255, 0))
    end
    self.m_buyCnt = buy_cnt
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_IllusionShopListItem:click_buyBtn()
    local data = self.m_data
    local vars = self.vars

    if (not data) then
        return
    end

    -- 재화 체크
    if (g_userData:get('event_illusion') < data['price']) then
        UIManager:toastNotificationRed(Str('{1}이 부족합니다.', Str('환상 토큰')))
        return
    end

    local finish_cb = function(ret)
        self:setBuyCnt(ret['buy_item'])
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

    end

    local cb_func = function(cnt)
        if (not cnt) then
            cnt = 1
        end
        g_illusionDungeonData:request_illusionExchange(data['id'], cnt, finish_cb)  
    end



     local item_str = data['item']
     local l_item_str = pl.stringx.split(item_str, ';') -- 703003;1
     local item_id = tonumber(l_item_str[1])
     local item_cnt = l_item_str[2]
     local item_name = TableItem:getItemName(item_id)
     if (tonumber(item_cnt) > 1) then
         item_name = item_name .. ' ' .. Str('{1}개', comma_value(item_cnt))
     end
     local ui_popup = UI_BundlePopupNew(item_id, self.m_buyCnt, data['buy_count'], 'event_illusion', data['price'], cb_func, item_name)
     if (data['buy_count'] == 1) then
         ui_popup.vars['quantityBtn1']:setVisible(false)
         ui_popup.vars['quantityBtn2']:setVisible(false)
     end
end
