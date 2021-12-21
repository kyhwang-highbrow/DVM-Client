local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_RandomShop
-------------------------------------
UI_RandomShop = class(PARENT,{
        m_tableViewTD = '',

        m_selectUI = 'UI_RandomShopListItem',
        m_selectItem = 'StructRandomShopItem',
        m_selectRuneOptionLabel = 'ui',
    })

local NEED_REFRESH_TYPE = 'cash'
-------------------------------------
-- function init
-------------------------------------
function UI_RandomShop:init()
    local vars = self:load('shop_random.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_selectRuneOptionLabel = nil

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_RandomShop')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_RandomShop:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RandomShop'
    self.m_titleStr = Str('마녀의 상점')
    self.m_subCurrency = 'ancient' -- 고대주화 노출
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RandomShop:initUI()
    local vars = self.vars
    self:initTableView()

    do -- 새로고침
        local icon = IconHelper:getPriceIcon(NEED_REFRESH_TYPE)
        vars['refreshPriceNode']:addChild(icon)
        vars['refreshPriceLabel']:setString(comma_value(g_randomShopData.m_refreshPrice))
    end

    do -- 나르비 테이머 추가
        local res = 'res/character/npc/narvi/narvi.json'
        vars['npcNode']:removeAllChildren(true)
        local animator = MakeAnimator(res)
        if (animator.m_node) then
            animator:changeAni('idle', true)
            vars['npcNode']:addChild(animator.m_node)
        end
    end

    do -- 갱신시간
        self:registerUpdate()
    end

    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['bgVisual']:setScale(scr_size.width / 1280)
end

-------------------------------------
-- function registerUpdate
-------------------------------------
function UI_RandomShop:registerUpdate()
    local vars = self.vars
    local function update(dt)
        if (g_randomShopData.m_bDirty) then
            g_randomShopData.m_bDirty = false
            self:refresh_shopInfo()
            vars['timeLabel']:setString('')
            -- 중복 호출 막기 위해 스케쥴러 해제
            self.root:unscheduleUpdate()
        else
            local str = g_randomShopData:getStatusText()
            vars['timeLabel']:setString(str)
        end
    end
    self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RandomShop:initButton()
    local vars = self.vars
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn(1) end) -- 1번째 재화로 구매
    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn(1) end) -- 1번째 재화로 구매
    vars['buyBtn2']:registerScriptTapHandler(function() self:click_buyBtn(2) end) -- 2번째 재화로 구매

    if (g_localData:isKoreaServer() or IS_DEV_SERVER()) then
        if (vars['plugInfoBtn']) then vars['plugInfoBtn']:registerScriptTapHandler(function() SDKManager:goToWeb('https://cafe.naver.com/dragonvillagemobile/146207') end) end
    else
        if (vars['plugInfoBtn']) then vars['plugInfoBtn']:setVisible(false) end
    end
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_RandomShop:initTableView()
    local vars = self.vars
    local node = vars['listNode']
    node:removeAllChildren()
    
    local l_item_list = g_randomShopData:getProductList()
    local function create_func(ui, data)
        local struct_item = data
        local product_idx = struct_item:getProductIdx()
        -- 상품 갱신되면 첫번째 아이템 선택되게
        if (tonumber(product_idx) == 1) then
            self:click_selectItem(ui)
        end
        ui.vars['selectBtn']:registerScriptTapHandler(function() self:click_selectItem(ui) end)
    end

    -- 테이블 뷰 인스턴스 생성
    table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(305, 135)
    table_view_td.m_nItemPerCell = 2
	table_view_td:setCellUIClass(UI_RandomShopListItem, create_func)
    table_view_td:setItemList(l_item_list)
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RandomShop:refresh()
end

-------------------------------------
-- function refresh_itemInfo
-- @brief 우측 선택된 아이템 정보 갱신
-------------------------------------
function UI_RandomShop:refresh_itemInfo()
    local vars = self.vars
    local struct_item = self.m_selectItem
    local item_id = struct_item:getItemID()
    vars['rightMenu']:setVisible(true)

    -- 설명 부분 초기화
    vars['relationNode']:setVisible(false)
    vars['itemDscNode2']:setVisible(false)
    vars['itemNumNode']:setVisible(false)

    do -- 이름
        local name = struct_item:getName()
        vars['itemNameLabel']:setString(name)
    end

    do -- 아이템 카드
        vars['itemNode']:removeAllChildren()
        local card = struct_item:getCard()
        vars['itemNode']:addChild(card.root)
    end

    do -- 설명
        local is_rune = struct_item:isRuneItem()
        vars['itemDscLabel']:setVisible(not is_rune)
        vars['runeDscNode']:setVisible(is_rune)
        vars['itemDscLabel2']:setVisible(is_rune) -- 룬 세트 효과 노드

        if (is_rune) then
            local t_rune_data = struct_item:getRuneData()
            --[[
            local desc = t_rune_data:makeRuneDescRichText()
            vars['runeDscLabel']:setString(desc)
            --]]
            local struct_rune = StructRuneObject(t_rune_data)
            if (not self.m_selectRuneOptionLabel) then
                self.m_selectRuneOptionLabel = struct_rune:getOptionLabel()
                vars['runeDscNode']:addChild(self.m_selectRuneOptionLabel.root)                   
            end
            struct_rune:setOptionLabel(self.m_selectRuneOptionLabel, 'use', nil) 

            -- 임시 룬 오브젝트를 생성 (룬 세트 설명 함수를 사용하기 위해)
            local _data = {}
            _data['rid'] = struct_item:getItemID()
            local _struct_rune_obj = StructRuneObject(_data)
        
            -- 룬 세트 설명 출력
            local str = _struct_rune_obj:makeRuneSetDescRichText() or ''
            vars['itemDscLabel2']:setString(str)
            vars['itemDscNode2']:setVisible(true)
        else
            local desc = struct_item:getDesc()
            vars['itemDscLabel']:setString(desc)
        end
            
        -- 인연 포인트 갯수 출력
        if (struct_item:isRelationItem()) then     
            local did = TableItem:getDidByItemId(item_id)
            
            local req_rpoint = TableDragon():getRelationPoint(did)
            local cur_rpoint = g_bookData:getRelationPoint(did)

            -- 인연 포인트 충분한지 색상으로 표시
            local str_color = '{@impossible}'
            if (cur_rpoint >= req_rpoint) then
                str_color = '{@possible}'
            end
            
            vars['relationNode']:setVisible(true)
            vars['quantityLabel']:setString(string.format('%s%d/%d', str_color, cur_rpoint, req_rpoint))
        else
            vars['relationNode']:setVisible(false)
        end

        local item_count = nil
        -- 진화 보석의 경우 보유량 출력
        if (struct_item:isEvolutionItem()) then            
            item_count = g_userData:get('evolution_stones', tostring(item_id)) or 0
        end

        -- 열매의 경우 보유량 출력
        if (struct_item:isFruitItem()) then 
            item_count = g_userData:getFruitCount(item_id) or 0
        end

        -- 강화 포인트의 경우 보유량 출력
        if (struct_item:isReinforcePoint()) then 
            item_count = g_userData:getReinforcePoint(item_id) or 0
        end

        -- 보유량있을 경우 출력
        if (item_count) then
            local msg = Str('{1}개', comma_value(item_count))
            vars['itemDscNode2']:setVisible(false)
            vars['itemNumNode']:setVisible(true)
            vars['numberLabel']:setString(msg)
        end
    end

    -- 할인 마크
    local is_sale = struct_item:isSale()
    vars['badgeNode']:removeAllChildren()
    if (is_sale) then
        local sale_value = struct_item:getSaleValue()
        local path = string.format('ui/typo/ko/badge_discount_%d.png', sale_value)
        local badge = cc.Sprite:create('res/' .. Translate:getTranslatedPath(path))
        if (badge) then
            badge:setAnchorPoint(CENTER_POINT)
            badge:setDockPoint(CENTER_POINT)
            vars['badgeNode']:addChild(badge)
        end
    end

    -- 구매가능한 상태면
    if (struct_item:isBuyable()) then
        self:setPirceInfo()
    else
        vars['buyBtn']:setVisible(false)
        vars['buyBtn1']:setVisible(false)
        vars['buyBtn2']:setVisible(false)

        vars['saleNode']:setVisible(false)
        vars['saleNode1']:setVisible(false)
        vars['saleNode2']:setVisible(false)
    end
end

-------------------------------------
-- function setPirceInfo
-- @brief 우측 선택된 아이템 판매 가격 정보 
-------------------------------------
function UI_RandomShop:setPirceInfo()
    local vars = self.vars
    local struct_item = self.m_selectItem
    local is_sale = struct_item:isSale()

    -- 가격 정보
    local l_price_type, l_final_price, l_origin_price = struct_item:getPriceInofList()

    -- 구매 가능한 재화 한개일 경우
    if (#l_price_type == 1) then
        vars['buyBtn']:setVisible(true)
        vars['saleNode']:setVisible(false)
        vars['priceNode']:removeAllChildren()

        -- 구매 재화 아이콘
        local icon = IconHelper:getPriceIcon(l_price_type[1])
        if (icon) then
            vars['priceNode']:addChild(icon)
        end
        -- 최종 가격
        local price = l_final_price[1]
        vars['priceLabel']:setString(comma_value(price))
        -- 가격 아이콘 및 라벨, 배경 조정
		UIHelper:makePriceNodeVariable(nil,  vars['priceNode'], vars['priceLabel'])

        -- 할인중이라면 원래 가격 표시
        if (is_sale) then
            local origin_price = l_origin_price[1]
            local tar_x = vars['priceLabel']:getPositionX()
            vars['saleNode']:setVisible(true)
            vars['saleNode']:setPositionX(tar_x)
            vars['saleLabel']:setString(comma_value(origin_price))
        end

    -- 구매 가능한 재화 여러개일 경우
    else
        vars['buyBtn']:setVisible(false)
        for i = 1, 2 do
            vars['saleNode'..i]:setVisible(false)
            vars['priceNode'..i]:removeAllChildren()
        end

        -- 구매 재화 아이콘
        for i, price_type in ipairs(l_price_type) do
            vars['buyBtn'..i]:setVisible(true)

            local icon = IconHelper:getPriceIcon(price_type)
            if (icon) then
                vars['priceNode'..i]:addChild(icon)
            end
        end
        -- 최종 가격
        for i, price in ipairs(l_final_price) do
            vars['priceLabel'..i]:setString(comma_value(price))
        end

        -- 할인중이라면 원래 가격 표시
        if (is_sale) then
            for i, price in ipairs(l_origin_price) do
                vars['saleNode'..i]:setVisible(true)
                vars['saleLabel'..i]:setString(comma_value(price))
            end
        end
    end
end

-------------------------------------
-- function refresh_shopInfo
-- @brief 무료 갱신 가능한 상태 : 클라에서 서버에 shopInfo 다시 호출
-------------------------------------
function UI_RandomShop:refresh_shopInfo()
    -- 해당 UI가 열린후 생성된 UI 모두 닫아줌
    local is_opend, idx, ui = UINavigatorDefinition:findOpendUI('UI_RandomShop')
    if (is_opend) then
        UINavigatorDefinition:closeUIList(idx, false) -- param : idx, include_idx
    end
    
    -- UI 블럭
    local block_ui = UI_BlockPopup()
    -- 백키 블럭 
    UIManager:blockBackKey(true)

    local finish_cb = function()
        self:initTableView()
        self:refresh_itemInfo()

        -- UI 블럭 해제
        block_ui:close()
        -- 백키 블럭 해제
        UIManager:blockBackKey(false)

        local msg = Str('새로운 상품으로 교체되었습니다.')
        UIManager:toastNotificationGreen(msg)

        self:registerUpdate()
    end

    cclog('# 랜덤 상점 무료 갱신중')
	g_randomShopData:request_shopInfo(finish_cb)
end

-------------------------------------
-- function click_refreshBtn
-------------------------------------
function UI_RandomShop:click_refreshBtn()
    -- 재화 부족
    if (not ConfirmPrice(NEED_REFRESH_TYPE, g_randomShopData.m_refreshPrice)) then
        return
    end

    local function ok_btn_cb()
        local finish_cb = function()
            self:initTableView()

            local msg = Str('새로운 상품으로 교체되었습니다.')
            UIManager:toastNotificationGreen(msg)
        end

        g_randomShopData:request_refreshInfo(finish_cb)
    end

    local msg = Str('새로운 상품으로 교체하시겠습니까?')
    UI_ConfirmPopup(NEED_REFRESH_TYPE, g_randomShopData.m_refreshPrice, msg, ok_btn_cb)
end

-------------------------------------
-- function click_selectItem
-------------------------------------
function UI_RandomShop:click_selectItem(tar_ui)
    for i,v in pairs(self.m_tableViewTD.m_itemList) do
        local ui = v['ui'] or v['generated_ui']
        if (ui) then
            ui.vars['selectSprite']:setVisible(false)
        end
    end

    tar_ui.vars['selectSprite']:setVisible(true)
    self.m_selectUI = tar_ui
    self.m_selectItem = tar_ui.m_structItem
    self:refresh_itemInfo()
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_RandomShop:click_buyBtn(idx)
    local struct_item = self.m_selectItem
    local l_price_type, l_final_price = struct_item:getPriceInofList()
    local product_idx = struct_item:getProductIdx()
    local price = l_final_price[idx]
    local price_type = l_price_type[idx]

    -- 재화 부족
    if (not ConfirmPrice(price_type, price)) then
        return
    end

    local function cb_func(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)

        local data = ret['info']['products'][tostring(product_idx)]
        local new_data = StructRandomShopItem(data)
        self.m_selectItem = new_data
        self.m_selectUI.m_structItem = new_data
        self.m_selectUI:refresh()

        self:refresh_itemInfo()
    end

    local function ok_btn_cb()
        -- 구매 api 호출
        g_randomShopData:request_buy(product_idx, price_type, cb_func)
    end

    local name = struct_item:getName()
    local cnt = struct_item:getCount()
    local msg = Str('{@item_name}"{1} x{2}"\n{@default}구매하시겠습니까?', name, cnt)
    UI_ConfirmPopup(price_type, price, msg, ok_btn_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RandomShop:click_exitBtn() 
    self:close()
end

--@CHECK
UI:checkCompileError(UI_RandomShop)