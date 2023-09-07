local PARENT = UI_DragonRunesBulkEquipPopup

-------------------------------------
-- class UI_PresetRunesBulkSettingPopup
-------------------------------------
UI_PresetRunesBulkSettingPopup = class(PARENT, {
    })


-------------------------------------
-- function initUI
-------------------------------------
function UI_PresetRunesBulkSettingPopup:initUI()
    local vars = self.vars
    vars['priceSprite']:setVisible(false)

    local dragon_obj = g_dragonsData:getDragonDataFromUid(self.m_doid)

    self.m_lBeforeRoidList = {}
    self.m_lAfterRoidList = {}

    for slot_idx = 1, 6 do
        self.m_lAfterRoidList[slot_idx] = dragon_obj['runes'][tostring(slot_idx)]
    end

    for slot_idx = 1, 6 do
        local before_roid = self.m_lBeforeRoidList[slot_idx] or ''
        local after_roid = self.m_lAfterRoidList[slot_idx] or ''

        -- 전 후 같은 경우 룬 카드만 생성 후 레이어 씌움
        if (before_roid == after_roid) then
            if (before_roid ~= '') then
                local rune_obj = g_runesData:getRuneObject(before_roid)
                local card = UI_RuneCard(rune_obj)
        
                vars['runeNode' .. slot_idx]:addChild(card.root)
            end
           
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

    self:initRuneSet()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_PresetRunesBulkSettingPopup:click_okBtn()
    if (self.m_finishCB) then
        self.m_finishCB(self.m_lAfterRoidList)
    end

    self:close()
end