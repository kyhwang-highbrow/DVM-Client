local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_RunePresetItem
-------------------------------------
UI_RunePresetItem = class(PARENT, {
    m_presetRune = 'StructRunePreset',
    m_ownerUI = '',
    m_tableViewUI = 'UIC_TableViewTD',
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
    self:refreshName()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RunePresetItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RunePresetItem:initButton()
    local vars = self.vars
    --vars['importBtn']:registerScriptTapHandler(function() self:click_importBtn() end)
    --vars['changeBtn']:registerScriptTapHandler(function() self:click_changeBtn() end)
    --vars['nameBtn']:registerScriptTapHandler(function() self:click_nameBtn() end)
    --vars['applyBtn']:registerScriptTapHandler(function() self:click_applyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RunePresetItem:refresh()
    self:refreshName()
    self:refreshRunes()
end

-------------------------------------
-- function refreshName
-------------------------------------
function UI_RunePresetItem:refreshName()
    local vars = self.vars
    local struct_rune_preset = self.m_presetRune

    do -- 이름
        vars['nameLabel']:setString(struct_rune_preset:getRunePresetName())
    end

    local l_align_ui_list = {vars['nameLabel'], vars['nameBtn']}
    AlignUIPos(l_align_ui_list, 'HORIZONTAL', 'HEAD', 10)
end

-------------------------------------
-- function refreshRunes
-------------------------------------
function UI_RunePresetItem:refreshRunes()
    local vars = self.vars

    local struct_rune_preset = self.m_presetRune
    local m_runes = struct_rune_preset:getRunesMap()

    for idx = 1, 6 do
        local roid = m_runes[idx] or 0
        local t_rune_data = g_runesData:getRuneObject(roid)
        local rune_card_ui = UI_RuneCardOption(t_rune_data)

        rune_card_ui.root:setSwallowTouch(false)
        rune_card_ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_rune() end)
        vars['itemNode' .. idx]:addChild(rune_card_ui.root)
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