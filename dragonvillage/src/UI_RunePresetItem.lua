local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_RunePresetItem
-------------------------------------
UI_RunePresetItem = class(PARENT, {
    m_presetRune = 'StructRunePreset',
    m_ownerUI = '',
    m_tableViewUI = 'UIC_TableViewTD',
    m_selectRuneCB = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_RunePresetItem:init(struct_rune_preset, owner_ui)
    self.m_presetRune = struct_rune_preset
    self.m_ownerUI = owner_ui
    self:load('rune_preset_list_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RunePresetItem:initUI()
    local vars = self.vars

    -- 룬 활성화
    for slot_idx = 1, 6 do
        local node_name = 'selectSprite' .. slot_idx

        vars[node_name]:stopAllActions()
        vars[node_name]:runAction(cca.flash())
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RunePresetItem:initButton()
    local vars = self.vars
    self.root:setSwallowTouch(false)
    for slot_idx = 1, 6 do
        local slot_node_str = 'runeSlotBtn' .. slot_idx
        vars[slot_node_str]:registerScriptTapHandler(function() self:click_runeCard(slot_idx) end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RunePresetItem:refresh()
    self:refreshName()
    self:refreshRunes()
    self:refreshSelect()
end

-------------------------------------
-- function refreshName
-------------------------------------
function UI_RunePresetItem:refreshName()
    local vars = self.vars
    local struct_rune_preset = self.m_presetRune
--[[ 
    do -- 이름
        vars['nameLabel']:setString(struct_rune_preset:getRunePresetName())
    end

    local l_align_ui_list = {vars['nameLabel'], vars['nameBtn']}
    AlignUIPos(l_align_ui_list, 'HORIZONTAL', 'HEAD', 10) ]]
end

-------------------------------------
-- function refreshRunes
-------------------------------------
function UI_RunePresetItem:refreshRunes()
    local vars = self.vars

    for slot_idx = 1, 6 do
        self:refreshRuneCard(slot_idx)
    end

--[[ 
    -- 각 룬 등록칸에 룬 카드 생성하기
    for idx = 1, 6 do
        local is_blank_index = t_rune_combine_data:isBlankIndex(idx)
        
        if (is_blank_index) then
            vars['itemNode' .. idx]:removeAllChildren() -- 제거
            self.m_mRuneCardUI[idx] = nil

        else
            if (self.m_mRuneCardUI[idx] == nil) then -- 룬 정보가 있는데 UI 카드가 없던 경우생성
                local t_rune_data = t_rune_combine_data:getRuneDataFromIndex(idx)
                local rune_card_ui = UI_RuneCardOption(t_rune_data)
                rune_card_ui.root:setSwallowTouch(false)
                rune_card_ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_rune(t_rune_data) end)
                vars['itemNode' .. idx]:addChild(rune_card_ui.root)
                
                cca.uiReactionSlow(rune_card_ui.root, 1, 1, 1.3)
                self.m_mRuneCardUI[idx] = rune_card_ui

                -- UI_RuneCard의 press_clickBtn으로 열린 UI_ItemInfoPopup이 닫힐 때 불리는 callback function
                local function close_info_callback()
                    -- 룬이 잠금처리 되어 있을 경우 tableview에서 삭제
                    if rune_card_ui:isRuneLock() then
                        -- UI_RuneForgeCombineItem에서 제거
                        self:click_rune(rune_card_ui.m_runeData)

                        -- 좌측 UI_RuneForgeCombineTab의 m_tableView에서 제거
                        self.m_ownerUI.m_tableView:delItem(t_rune_data:getObjectId())
                        self.m_ownerUI:refresh()
                    end
                end

                rune_card_ui:setCloseInfoCallback(close_info_callback)
            end
        end
    end ]]

end

-------------------------------------
-- function refreshRuneCard
-- @brief 해당 함수는 룬 카드 변경이 필요할 때만 호출
-------------------------------------
function UI_RunePresetItem:refreshRuneCard(slot_idx)
    local vars = self.vars
    vars['runeSlot' .. slot_idx]:removeAllChildren()
    local runes_map = self.m_presetRune:getRunesMap()
       

    local roid = runes_map[slot_idx] or ''
    if (roid ~= '') then
        local rune_obj = g_runesData:getRuneObject(roid)
        local card = UI_RuneCardDragon(rune_obj)

        card:makeDragonAttrIcon()
        card:makeDragonIcon()

        card.vars['clickBtn']:setEnabled(false)
        --cca.uiReactionSlow(card.root)

        vars['runeSlot' .. slot_idx]:removeAllChildren()
        vars['runeSlot' .. slot_idx]:addChild(card.root)
    end
end

-------------------------------------
-- function refreshSelect
-------------------------------------
function UI_RunePresetItem:refreshSelect()
    local vars = self.vars
    local is_preset_selected = self.m_presetRune:getIndex() == self.m_ownerUI:getSelectPresetIdx()

    -- 활성화 상태 표시
    vars['selectLayer']:setVisible(is_preset_selected)

    -- 룬 활성화
    for slot_idx = 1, 6 do
        local node_name = 'selectSprite' .. slot_idx
        local is_slot_selected = slot_idx == self.m_ownerUI:getSelectPresetSlotIdx()
        vars[node_name]:setVisible(is_preset_selected and is_slot_selected)
    end
end


-------------------------------------
-- function isFocusSlot
-------------------------------------
function UI_RunePresetItem:isFocusSlot(slot_idx)
    local is_preset_selected = self.m_presetRune:getIndex() == self.m_ownerUI:getSelectPresetIdx()
    local is_slot_selected = slot_idx == self.m_ownerUI:getSelectPresetSlotIdx()

    return is_preset_selected and is_slot_selected
end

-------------------------------------
-- function click_runeCard
-------------------------------------
function UI_RunePresetItem:click_runeCard(slot_idx)
    local runes_map = self.m_presetRune:getRunesMap()

    -- 현재 포커싱된 덱일 경우 클릭을 한 번 더 하면 지워짐
    if self:isFocusSlot(slot_idx) == true then
        if runes_map[slot_idx] ~= nil then
            self.m_ownerUI:setFocusRune(slot_idx, nil)
            return
        end
    end

    if self.m_selectRuneCB ~= nil then
        self.m_selectRuneCB(self.m_presetRune:getIndex(), slot_idx)
    end

    self:refreshSelect()


--[[     local struct_rune = g_runesData:getRuneObject(roid)
    local slot_idx = struct_rune['slot']

    -- before인 경우 시뮬레이터에 기존 룬 장착
    if (type == 'before') then
        self.m_ownerUI:simulateRune(slot_idx, roid)

    -- after인 경우 
    else
        -- 해당 룬 슬롯 인덱스에 포커싱되있던 경우 장착 해제
        if (slot_idx == self.m_ownerUI:getRuneSlot()) then
            self.m_ownerUI:simulateRune(slot_idx, nil)
        
        -- 해당 룬 슬롯 포커싱 안되있었다면 포커싱
        else
            self.m_ownerUI:changeRuneSlot(slot_idx)
        end
    end ]]
end


-------------------------------------
-- function click_changeBtn
-------------------------------------
function UI_RunePresetItem:click_changeBtn()
--[[     local success_cb = function (preset_deck_new)
        self.m_presetDeck:setDeckMap(preset_deck_new:getDeckMap())
        self.m_presetDeck:setFormation(preset_deck_new:getFormation())
        self.m_presetDeck:setLeader(preset_deck_new:getLeader())

        self:refresh()
        self.m_ownerUI:onChanged(clone(self.m_presetDeck))
    end

    UI_PresetDeckSetting.open(clone(self.m_presetDeck), success_cb) ]]
end

-------------------------------------
-- function click_nameBtn
-------------------------------------
function UI_RunePresetItem:click_nameBtn()
    local struct_preset_deck = self.m_presetDeck

    local success_cb = function (name)
        struct_preset_deck:setPresetDeckName(name)
        self:refreshName()
        self.m_ownerUI:onChanged(clone(struct_preset_deck))
    end

    require('UI_ChangePresetNamePopup')
    local ui = UI_ChangePresetNamePopup(success_cb)
end

-------------------------------------
-- function click_rune
-------------------------------------
function UI_RunePresetItem:click_rune()
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_RunePresetItem:click_applyBtn()
    local struct_preset_deck = self.m_presetDeck
    self.m_ownerUI:onApply(struct_preset_deck)
end