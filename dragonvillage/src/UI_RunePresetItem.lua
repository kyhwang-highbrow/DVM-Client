local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_RunePresetItem
-------------------------------------
UI_RunePresetItem = class(PARENT, {
    m_presetRune = 'StructRunePreset',
    m_ownerUI = '',
    m_tableViewUI = 'UIC_TableViewTD',
    m_selectRuneCB = 'function',
    m_runeUIMap = 'Map<number, UI_RuneCard>',
})

-------------------------------------
-- function init
-------------------------------------
function UI_RunePresetItem:init(struct_rune_preset, owner_ui)
    self.m_presetRune = struct_rune_preset
    self.m_ownerUI = owner_ui
    self.m_runeUIMap = {}
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
        vars[slot_node_str]:registerScriptPressHandler(function() self:press_runeCard(slot_idx) end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RunePresetItem:refresh()
    self:refreshRunes()
    self:refreshSelect()
end

-------------------------------------
-- function refreshRunes
-------------------------------------
function UI_RunePresetItem:refreshRunes()
    local active_set_map = self.m_presetRune:getRunesSetMap()
    for slot_idx = 1, 6 do
        self:refreshRuneCard(slot_idx, active_set_map)
    end
end

-------------------------------------
-- function refreshRuneCard
-- @brief 해당 함수는 룬 카드 변경이 필요할 때만 호출
-------------------------------------
function UI_RunePresetItem:refreshRuneCard(slot_idx, active_set_map)
    local vars = self.vars
    vars['runeSlot' .. slot_idx]:removeAllChildren()

    local visual = vars['runeVisual'..slot_idx]
    visual:setVisible(false)

    local runes_map = self.m_presetRune:getRunesMap()
    self.m_runeUIMap[slot_idx] = nil

    local roid = runes_map[slot_idx]
    if (roid == nil) then
        return
    end

    local rune_obj = g_runesData:getRuneObject(roid)
    local set_id = TableRune:getRuneSetId(rune_obj.rid)
    local card = UI_RuneCardDragon(rune_obj)
    local t_set_info = active_set_map[set_id]

    if t_set_info ~= nil and t_set_info['active'] == true then
        t_set_info['count'] = t_set_info['count'] + 1
        if t_set_info['need_equip'] >=  t_set_info['count'] and t_set_info['active_cnt'] > 0 then
            local ani_name = TableRuneSet:getRuneSetVisualName(slot_idx, set_id)
            visual:setVisible(true)
            visual:changeAni(ani_name, true)

            if t_set_info['need_equip'] ==  t_set_info['count'] then
                t_set_info['active_cnt'] = t_set_info['active_cnt'] - 1
                t_set_info['count'] = 0
            end
        end
    end

    card:makeDragonAttrIcon()
    card:makeDragonIcon()
    card:setCloseInfoCallback(function() self.m_ownerUI:refreshTableView()  end)

    card.vars['clickBtn']:setEnabled(false)
    
    vars['runeSlot' .. slot_idx]:removeAllChildren()
    vars['runeSlot' .. slot_idx]:addChild(card.root)

    self.m_runeUIMap[slot_idx] = card
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
end

-------------------------------------
-- function press_runeCard
-------------------------------------
function UI_RunePresetItem:press_runeCard(slot_idx)
    local rune_ui = self.m_runeUIMap[slot_idx]

    if rune_ui ~= nil then
        rune_ui:press_clickBtn()
    end
end