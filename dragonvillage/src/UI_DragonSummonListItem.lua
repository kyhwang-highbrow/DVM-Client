local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonSummonListItem
-------------------------------------
UI_DragonSummonListItem = class(PARENT, {
        m_tItemData = 'table',
        m_refreshCB = 'function',
        m_freeType = 'string',
        m_bFreeMode = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSummonListItem:init(t_item_data)
    self.m_tItemData = t_item_data
    self.m_bFreeMode = false

    local vars = self:load('dragon_summon_list_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSummonListItem:initUI()
    local vars = self.vars
    local t_item_data = self.m_tItemData

    local ui_type = t_item_data['ui_type']

    -- 상품 배경 이미지
    local res = string.format('res/ui/dragon_gacha/dragon_gacha_%s.png', ui_type)
    local sprite = cc.Sprite:create(res)
    if sprite then
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        vars['bgNode']:addChild(sprite)
    end

    -- 텍스트 이미지
    local res = string.format('res/ui/typo/kr/dragon_gacha_%s.png', ui_type)
    local sprite = cc.Sprite:create(res)
    if sprite then
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        vars['textNode']:addChild(sprite)
    end
    

    -- 무료 뽑기 관련 UI 숨김
    vars['freeLabel']:setVisible(false)
    vars['freeBtn']:setVisible(false)

    do
        local dsmid = t_item_data['dsmid']
        local free_type = g_dragonSummonData:getFreeDragonSummonType(dsmid)

        self.m_freeType = free_type

        if free_type then
            vars['freeLabel']:setVisible(true)
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSummonListItem:initButton()
    local vars = self.vars

    -- 11연차 소환
    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn(11) end)

    -- 단차 소환
    vars['buyBtn2']:registerScriptTapHandler(function() self:click_buyBtn(1) end)

    -- 무료 소환
    vars['freeBtn']:registerScriptTapHandler(function() self:click_freeBtn(1) end)
end

-------------------------------------
-- function refresh_tableViewCell
-------------------------------------
function UI_DragonSummonListItem:refresh_tableViewCell(t_item_data)
    self.m_tItemData = t_item_data
    self:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSummonListItem:refresh()
    self:refresh_priceInfo()
    self:refresh_freeSummon()
end

-------------------------------------
-- function refresh_freeNormalSummon
-------------------------------------
function UI_DragonSummonListItem:refresh_freeSummon()
    if (not self.m_freeType) then
        return
    end

    local vars = self.vars
    local free_type = self.m_freeType
    if (not g_dragonSummonData:canFreeDragonSummon(free_type)) then
        vars['buyBtn2']:setVisible(true)
        vars['freeBtn']:setVisible(false)
        self.m_bFreeMode = false
    else
        -- 이벤트 노드 hide
        vars['eventPriceNode2']:setVisible(false)
        vars['buyBtn2']:setVisible(false)
        vars['freeBtn']:setVisible(true)
        vars['freeLabel']:setString('')
        self.m_bFreeMode = true
    end
end

-------------------------------------
-- function refresh_priceInfo
-------------------------------------
function UI_DragonSummonListItem:refresh_priceInfo()
    local vars = self.vars
    local t_item_data = self.m_tItemData

    vars['eventDscLabel']:setString('')
    
    local price_type = t_item_data['price_type']
    local price_icon
    local price_icon2
    if (price_type == 'cash') then
        price_icon = cc.Sprite:create('res/ui/icon/item/cash.png')
        price_icon2 = cc.Sprite:create('res/ui/icon/item/cash.png')
    elseif (price_type == 'gold') then
        price_icon = cc.Sprite:create('res/ui/icon/item/gold.png')
        price_icon2 = cc.Sprite:create('res/ui/icon/item/gold.png')
    end

    price_icon:setDockPoint(cc.p(0.5, 0.5))
    price_icon:setAnchorPoint(cc.p(0.5, 0.5))
    price_icon:setScale(0.5)

    price_icon2:setDockPoint(cc.p(0.5, 0.5))
    price_icon2:setAnchorPoint(cc.p(0.5, 0.5))
    price_icon2:setScale(0.5)

    vars['priceNode1']:addChild(price_icon)
    vars['priceNode2']:addChild(price_icon2)

    vars['priceLabel1']:setString(comma_value(t_item_data['11th_price_value']))
    vars['priceLabel2']:setString(comma_value(t_item_data['price_value']))
    

    vars['limitNode']:setVisible(false)

    -- 할인 이벤트 중
    if (t_item_data['disc_event_active'] == true) then
        vars['eventPriceNode1']:setVisible(true)
        vars['eventPriceNode2']:setVisible(true)

        -- 할인 가격
        vars['eventPriceLabel1']:setString(comma_value(t_item_data['disc_11th_price_value']))
        vars['eventPriceLabel2']:setString(comma_value(t_item_data['disc_price_value']))

        -- 구매 횟수 제한
        if (t_item_data['disc_limit'] ~= '') then
            vars['limitNode']:setVisible(true)
            vars['limitLabel']:setString(Str('{1}/{2}\n구매가능', t_item_data['disc_purchase_cnt'], t_item_data['disc_limit']))
        end
    else
        vars['eventPriceNode1']:setVisible(false)
        vars['eventPriceNode2']:setVisible(false)

        -- 구매 횟수 제한
        if (t_item_data['limit_purchase'] ~= '') then
            vars['limitNode']:setVisible(true)
            vars['limitLabel']:setString(Str('{1}/{2}\n구매가능', t_item_data['purchase_cnt'], t_item_data['limit_purchase']))
        end
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_DragonSummonListItem:click_buyBtn(type)
    -- 드래곤 소환에 필요한 매개변수들 생성
    local dsmid, price_type, price, is_discount = self:makeSummonRequestParams(type)
    local is_free = false

    -- 컨펌 확인 콜백
    local function ok_cb()
        local function finish_cb(ret)
            if self.m_refreshCB then
                self.m_refreshCB()
            end

            local l_dragon_list = ret['added_dragons']
            UI_GachaResult_Dragon(l_dragon_list)
        end

        -- 서버에 드래곤 소환 요청
        g_dragonSummonData:request_dragonSummon(dsmid, type, price_type, price, is_discount, is_free, finish_cb)
    end

    -- 구매 여부 확인
    local msg = self:makeSummonConfirmMsg(dsmid, price_type, price, is_discount, type)
    MakeSimplePopup_Confirm(price_type, price, msg, ok_cb, nil)
end

-------------------------------------
-- function click_freeBtn
-------------------------------------
function UI_DragonSummonListItem:click_freeBtn()
    local type = 1

    -- 드래곤 소환에 필요한 매개변수들 생성
    local dsmid, price_type, price, is_discount = self:makeSummonRequestParams(type)
    local is_free = true

    local function finish_cb(ret)
        if self.m_refreshCB then
            self.m_refreshCB()
        end

        local l_dragon_list = ret['added_dragons']
        UI_GachaResult_Dragon(l_dragon_list)
    end

    -- 서버에 드래곤 소환 요청
    g_dragonSummonData:request_dragonSummon(dsmid, type, price_type, price, is_discount, is_free, finish_cb)
end

-------------------------------------
-- function makeSummonRequestParams
-------------------------------------
function UI_DragonSummonListItem:makeSummonRequestParams(type)
    local t_item_data = self.m_tItemData

    -- 변수 설정
    local dsmid = t_item_data['dsmid']
    local price_type = t_item_data['price_type']

    -- 가격
    local price
    local is_discount
    if (t_item_data['disc_event_active'] == true) then
        if (type == 1) then
            price = t_item_data['disc_price_value']
        elseif (type == 11) then
            price = t_item_data['disc_11th_price_value']
        else
            error('type : ' .. type)
        end
        is_discount = true
    else
        if (type == 1) then
            price = t_item_data['price_value']
        elseif (type == 11) then
            price = t_item_data['11th_price_value']
        else
            error('type : ' .. type)
        end
        is_discount = false
    end

    return dsmid, price_type, price, is_discount
end

-------------------------------------
-- function makeSummonConfirmMsg
-------------------------------------
function UI_DragonSummonListItem:makeSummonConfirmMsg(dsmid, price_type, price, is_discount, type)
    local msg = ''
    local price_str = comma_value(price)
    local type_str

    if (type == 1) then
        type_str = '1'
    elseif (type == 11) then
        type_str = '10+1'
    else
        error('type : ' .. type)
    end

    if (price_type == 'cash') then
        msg = Str('{1}회 드래곤 소환을 하시겠습니까?', type_str)
        
    elseif (price_type == 'gold') then
        msg = Str('{1}회 드래곤 소환을 하시겠습니까?', type_str)

    else
        error('price_type : ' .. price_type)
    end

    -- @TODO sgkim횟수제한 이벤트에 걸린 경우에만 출력하자
    --msg = msg .. '\n' .. Str('이벤트 소환의 경우 횟수 제한이 있을 수 있습니다. 횟수는 "10+1회", "1회"가 동시 적용됩니다.')

    return msg
end

-------------------------------------
-- function update
-------------------------------------
function UI_DragonSummonListItem:update(dt)
    if (not self.m_freeType) then
        return
    end

    if self.m_bFreeMode then
        return
    end

    local free_type = self.m_freeType
    local text = g_dragonSummonData:getFreeDragonSummonTimeText(free_type)
    local vars = self.vars
    vars['freeLabel']:setString(text)

    if g_dragonSummonData:canFreeDragonSummon(free_type) then
        self:refresh_freeSummon()
    end
end