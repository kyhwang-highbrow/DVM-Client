local PARENT = UI

-------------------------------------
-- class UI_DragonRunesEquipPopup
-------------------------------------
UI_DragonRunesEquipPopup = class(PARENT, {
        m_doid = 'string',
        m_slot = 'int', -- 룬 슬롯
        m_beforeRoid = 'string', -- 장착 이전
        m_afterRoid = 'string', -- 장착 이후 
        m_price = 'number',

        m_finishCB = 'function',
    })

-------------------------------------
-- function init
-- @param doid : 타겟 드래곤 oid
-- @param rune_slot : 변경하는 룬 슬롯
-- @parma after_roid : 변경 후 룬
-- @param price : 총 소모되는 골드
-------------------------------------
function UI_DragonRunesEquipPopup:init(doid, rune_slot, after_roid, price, finish_cb)
    self.m_uiName = 'UI_DragonRunesEquipPopup'
    local vars = self:load('dragon_rune_equip_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, 'UI_DragonRunesEquipPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    
    self.m_doid = doid
    self.m_slot = rune_slot
    self.m_beforeRoid = dragon_obj['runes'][tostring(rune_slot)]
    self.m_afterRoid = after_roid
    self.m_price = price
    self.m_finishCB = finish_cb

    self:initUI()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesEquipPopup:initUI()
    local vars = self.vars
    
    -- 가격 표시
    local price = self.m_price
    vars['priceLabel']:setString(comma_value(price))

    local before_roid = self.m_beforeRoid or ''
    local after_roid = self.m_afterRoid or ''
    local slot_idx = self.m_slot


    if (before_roid ~= '') then
        local rune_obj = g_runesData:getRuneObject(before_roid)
        local card = UI_RuneCard(rune_obj)
        
        vars['runeBeforeNode']:addChild(card.root)
    else
        vars['runeBeforeSprite' .. slot_idx]:setVisible(true)
    end

    -- 룬 카드 생성 + 장착 중인 룬이었다면 드래곤 카드 생성
    if (after_roid ~= '') then
        local rune_obj = g_runesData:getRuneObject(after_roid)
        local card = UI_RuneCard(rune_obj)
        
        vars['runeAfterNode']:addChild(card.root)
        vars['arrowSprite']:setVisible(true)

        -- 드래곤 카드 생성
        local owner_doid = rune_obj['owner_doid']
        if (owner_doid ~= nil) then
            local dragon_obj = g_dragonsData:getDragonDataFromUid(owner_doid)
            local dragon_card = UI_DragonCard(dragon_obj)
            vars['dragonNode']:addChild(dragon_card.root)

        else
            vars['inventorySprite']:setVisible(true)
        end
            
    -- 룬 해제의 경우
    else
        vars['arrowSprite']:setVisible(false)
        vars['runeAfterSprite' .. slot_idx]:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesEquipPopup:initButton()
    local vars = self.vars

    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesEquipPopup:refresh()
    local vars = self.vars
    
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_DragonRunesEquipPopup:click_cancelBtn()
    self.m_closeCB = nil
    self:close()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonRunesEquipPopup:click_okBtn()
    
    -- 골드가 충분히 있는지 확인
    local need_gold = self.m_price
    if (not ConfirmPrice('gold', need_gold)) then -- 골드가 부족한경우 상점이동 유도 팝업이 뜬다. (ConfirmPrice함수 안에서)
	    return
    end

    local function finish_cb(ret)
        if (self.m_finishCB) then
            self.m_finishCB()
        end
        
        self:close()
    end

    local doid = self.m_doid
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    local roids = nil

    for slot_idx = 1, 6 do
        local after_roid
        if (slot_idx == self.m_slot) then
            after_roid = self.m_afterRoid or ''
        else
            after_roid = dragon_obj['runes'][tostring(slot_idx)] or ''
        end

        if (after_roid ~= '') then
            if (roids == nil) then
                roids = after_roid
            else
                roids = roids .. ',' .. after_roid
            end
        end
    end 

    g_runesData:request_runesEquipNew(doid, roids, finish_cb, nil) -- @param : doid, roids, finish_cb, fail_cb
end


