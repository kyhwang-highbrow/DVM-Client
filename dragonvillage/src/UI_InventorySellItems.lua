local PARENT = UI

-------------------------------------
-- class UI_InventorySellItems
-------------------------------------
UI_InventorySellItems = class(PARENT, {
        m_itemID = 'number',
        m_maxCount = 'number',
        m_currCount = 'number',
        m_sellCB = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventorySellItems:init(item_id, max_count, sell_cb)
    self.m_itemID = item_id
    self.m_maxCount = max_count
    self.m_currCount = max_count
    self.m_sellCB = sell_cb

    local vars = self:load('inventory_sell_popup_01.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_InventorySellItems')

    self:initUI()
    self:initButton()
    self:refresh()
end
-------------------------------------
-- function initUI
-------------------------------------
function UI_InventorySellItems:initUI()
    local vars = self.vars

    local table_item = TableItem()
    local item_id = self.m_itemID

    -- 아이템 아이콘
    local item = UI_ItemCard(item_id, self.m_maxCount)
    vars['itemNode']:addChild(item.root)

    -- 아이템 이름
    local name = table_item:getValue(item_id, 't_name')
    vars['itemLabel']:setString(Str(name))

    self:makeSliderBar()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_InventorySellItems:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
    vars['quantityBtn1']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['quantityBtn3']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['quantityBtn4']:registerScriptTapHandler(function() self:click_maxBtn() end)
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_InventorySellItems:refresh(ignore_slider_bar)
    local vars = self.vars

    local table_item = TableItem()
    local item_id = self.m_itemID

    -- 판매 가격
    local price = table_item:getValue(item_id, 'sale_price')
    vars['priceaLabel']:setString(comma_value(price * self.m_currCount))

    -- 판매 갯수
    vars['quantityLabel']:setString(comma_value(self.m_currCount) .. '/' .. comma_value(self.m_maxCount))

    -- 퍼센트 지정
    if (not ignore_slider_bar) then
        local percentage = (self.m_currCount / self.m_maxCount) * 100
        vars['quantityGuage']:stopAllActions()
        vars['quantityGuage']:runAction(cc.ProgressTo:create(0.2, percentage))
    
        local pos_x = 230 * (self.m_currCount / self.m_maxCount)
        vars['quantityBtn2']:stopAllActions()
        vars['quantityBtn2']:runAction(cc.MoveTo:create(0.2, cc.p(pos_x, 0)))
    end
end

-------------------------------------
-- function setCurrCount
-------------------------------------
function UI_InventorySellItems:setCurrCount(count, ignore_slider_bar)
    local count = math_clamp(count, 1, self.m_maxCount)
    
    if (self.m_currCount == count) then
        return
    end

    self.m_currCount = count

    self:refresh(ignore_slider_bar)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_InventorySellItems:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_minusBtn
-------------------------------------
function UI_InventorySellItems:click_minusBtn()
    self:setCurrCount(self.m_currCount - 1)
end

-------------------------------------
-- function click_plusBtn
-------------------------------------
function UI_InventorySellItems:click_plusBtn()
    self:setCurrCount(self.m_currCount + 1)
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_InventorySellItems:click_maxBtn()
    self:setCurrCount(self.m_maxCount)
end


-------------------------------------
-- function makeSliderBar
-- @brief 터치 레이어 생성
-------------------------------------
function UI_InventorySellItems:makeSliderBar()
    local node = self.vars['sliderBar']

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end


-------------------------------------
-- function onTouchBegan
-------------------------------------
function UI_InventorySellItems:onTouchBegan(touch, event)
    local vars = self.vars

    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['quantityBtn2']:getBoundingBox()
    local local_location = vars['quantityBtn2']:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)

    return is_contain
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function UI_InventorySellItems:onTouchMoved(touch, event)
    local vars = self.vars

    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['quantityBtn2']:getBoundingBox()
    local local_location = vars['quantityBtn2']:getParent():convertToNodeSpace(location)

    local content_size = vars['quantityBtn2']:getParent():getContentSize()

    local x = math_clamp(local_location['x'], 0, content_size['width'])
    local percentage = x / content_size['width']

    vars['quantityBtn2']:stopAllActions()
    vars['quantityBtn2']:setPositionX(x)

    vars['quantityGuage']:stopAllActions()
    vars['quantityGuage']:setPercentage(percentage * 100)

    local count = math_floor(self.m_maxCount * percentage)
    local ignore_slider_bar = true
    self:setCurrCount(count, ignore_slider_bar)
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_InventorySellItems:onTouchEnded(touch, event)
end

-------------------------------------
-- function click_sellBtn
-------------------------------------
function UI_InventorySellItems:click_sellBtn()
    local item_id = self.m_itemID
    local count = self.m_currCount

    local rune_oids = nil
    local items = nil
    items = tostring(item_id) .. ':' .. count

    local function cb(ret)
        if self.m_sellCB then
            self.m_sellCB(ret)
        end

        self:close()
    end
    g_inventoryData:request_itemSell(rune_oids, items, cb)
end