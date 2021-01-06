local PARENT = UI

-------------------------------------
-- class UI_DragonRunesBulkEquipPopup
-------------------------------------
UI_DragonRunesBulkEquipPopup = class(PARENT, {
        m_doid = 'string',
        m_lBeforeRoidList = 'list', -- 일괄장착 이전
        m_lAfterRoidList = 'list', -- 일괄장착 이후 
        m_price = 'number',

        m_finishCB = 'function',
    })

-------------------------------------
-- function init
-- @param doid : 타겟 드래곤 oid
-- @parma l_after_roid_list : 변경 후 룬 리스트
-- @param price : 총 소모되는 골드
-------------------------------------
function UI_DragonRunesBulkEquipPopup:init(doid, l_after_roid_list, price, finish_cb)
    local vars = self:load('dragon_rune_popup_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, 'UI_DragonRunesBulkEquipPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    local l_before_roid_list = {}
    
    for idx = 1, 6 do
        table.insert(l_before_roid_list, dragon_obj['runes'][tostring(idx)])
    end

    self.m_doid = doid
    self.m_lBeforeRoidList = l_before_roid_list
    self.m_lAfterRoidList = l_after_roid_list
    self.m_price = price
    self.m_finishCB = finish_cb

    self:initUI()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesBulkEquipPopup:initUI()
    local vars = self.vars
    
    -- 가격 표시
    local price = self.m_price
    vars['priceLabel']:setString(comma_value(price))

    for slot_idx = 1, 6 do
        local before_roid = self.m_lBeforeRoidList[slot_idx] or ''
        local after_roid = self.m_lAfterRoidList[slot_idx] or ''

        -- 전 후 같은 경우 룬 카드만 생성 후 레이어 씌움
        if (before_roid == after_roid) and (before_roid ~= '') then
            local rune_obj = g_runesData:getRuneObject(before_roid)
            local card = UI_RuneCard(rune_obj)
        
            vars['runeNode' .. slot_idx]:addChild(card.root)
            vars['deselectSprite' .. slot_idx]:setVisible(true)
            vars['arrowSprite' .. slot_idx]:setVisible(false)

        -- 다른 경우 룬 카드 생성 + 장착 중인 룬이었다면 드래곤 카드 생성
        else
            if (after_roid ~= '') then
                local rune_obj = g_runesData:getRuneObject(after_roid)
                local card = UI_RuneCard(rune_obj)
        
                vars['runeNode' .. slot_idx]:addChild(card.root)
                vars['deselectSprite' .. slot_idx]:setVisible(false)
                vars['arrowSprite' .. slot_idx]:setVisible(true)

                -- 드래곤 카드 생성
                local owner_doid = rune_obj['owner_doid']
                if (owner_doid ~= nil) then
                    local dragon_obj = g_dragonsData:getDragonDataFromUid(owner_doid)
                    local dragon_card = UI_DragonCard(dragon_obj)
                    vars['dragonNode' .. slot_idx]:addChild(dragon_card.root)

                else
                    vars['inventorySprite' .. slot_idx]:setVisible(true)
                end
            
            -- 룬 해제의 경우
            else
                vars['arrowSprite' .. slot_idx]:setVisible(false)
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquipPopup:initButton()
    local vars = self.vars

    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesBulkEquipPopup:refresh()
    local vars = self.vars
    
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_DragonRunesBulkEquipPopup:click_cancelBtn()
    self.m_closeCB = nil
    self:close()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonRunesBulkEquipPopup:click_okBtn()
    
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
    
    local roids = nil

    for slot_idx = 1, 6 do
        local after_roid = self.m_lAfterRoidList[slot_idx] or ''
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


