local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_RuneForgePresetTab
-------------------------------------
UI_RuneForgePresetTab = class(PARENT,{
        m_doid = 'string', 
        m_presetUI = 'UI_RunePreset',
        m_price = 'number', -- 현재까지 필요한 가격
        m_bDirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgePresetTab:init(owner_ui)
    self.m_presetUI = nil
    local vars = self:load('rune_forge_preset.ui')
end

-------------------------------------
-- function initTab
-- @brief type : rune, dragon
-------------------------------------
function UI_RuneForgePresetTab:initTab()
    local vars = self.vars
    local type = 'rune'

    self.m_bInitDefaultTab = false
    self.m_prevTab = nil
    self.m_currTab = nil
    self.m_mTabData = {}

    local rune_tab = UI_DragonRunesBulkEquipRuneTab(self)
    local dragon_tab = UI_DragonRunesBulkEquipDragonTab(self)
    -- 룬을 출력하는 TableView(runeTableViewNode)가 relative size의 영향을 받는다.
    -- UI가 생성되고 부모 노드에 addChild가 된 후에 해당 노드의 크기가 결정되므로 외부에서 호출하도록 한다.
    -- setTab -> onChangeTab -> initTableView 의 순서로 TableView가 생성됨.
    vars['indivisualTabMenu']:removeAllChildren()

    rune_tab:setParentAndInit(vars['indivisualTabMenu'])
    dragon_tab:setParentAndInit(vars['indivisualTabMenu'])

    self:addTabWithTabUIAndLabel('rune', vars['runeTabBtn'], vars['runeTabLabel'], rune_tab)            -- 룬
    self:addTabWithTabUIAndLabel('dragon', vars['dragonTabBtn'], vars['dragonTabLabel'], dragon_tab)    -- 드래곤

    self:setTab(type)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgePresetTab:onEnterTab(first)
    self.m_ownerUI:hideNpc() -- NPC 숨김

    self:initUI()
    self:initTab()
    self:initButton()
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgePresetTab:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgePresetTab:initUI()
    local vars = self.vars

    do -- 배경
        --local animator = ResHelper:getUIDragonBG('earth', 'idle')
        --vars['bgNode']:addChild(animator.m_node)
    end

    do
        local ui = UI_RunePreset(self)
        vars['runeList']:removeAllChildren()
        vars['runeList']:addChild(ui.root)
        self.m_presetUI = ui
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgePresetTab:initButton()
    local vars = self.vars
    vars['resetBtn']:registerScriptTapHandler(function() self:click_resetBtn() end)
    vars['saveBtn']:registerScriptTapHandler(function() self:click_saveBtn() end)
end

-------------------------------------
-- function simulateRune
-- @brief 룬 한개 장착
-------------------------------------
function UI_RuneForgePresetTab:simulateRune(slot_idx, roid)
    --self.m_afterUI:simulateRune(slot_idx, roid)
    --self:refreshPrice()

    self.m_presetUI:setFocusRune(slot_idx, roid)
end

-------------------------------------
-- function simulateDragonRune
-- @brief 특정 드래곤의 룬 장착
-------------------------------------
function UI_RuneForgePresetTab:simulateDragonRune(doid)
    local finish_cb = function(l_runes)
        self.m_presetUI:setFocusRune(nil, l_runes)
    end

    local ui = UI_PresetRunesBulkSettingPopup(doid, {}, 0, finish_cb)
end

-------------------------------------
-- function simulatePresetRune
-- @brief 특정 드래곤의 룬 장착
-------------------------------------
function UI_RuneForgePresetTab:simulatePresetRune(l_runes)
end

-------------------------------------
-- function isEquipRune
-- @brief 현재 시뮬레이터상 장착된 룬인지
-------------------------------------
function UI_RuneForgePresetTab:isEquipRune(roid)
    return false
end

-------------------------------------
-- function refreshRuneCheck
-- @brief UI_DragonRunesBulkEquipRuneTab의 테이블뷰 룬 카드 체크 표시 갱신
-------------------------------------
function UI_RuneForgePresetTab:refreshRuneCheck(slot_idx, roid)
    local ui = self.m_mTabData['rune']['ui']
    ui:refreshRuneCheck(slot_idx, roid)
end

-------------------------------------
-- function changeRuneSlot
-- @brief UI_DragonRunesBulkEquipRuneTab 의 테이블뷰 룬 슬롯 변경
-------------------------------------
function UI_RuneForgePresetTab:changeRuneSlot(slot_idx)
    local ui = self.m_mTabData['rune']['ui']
    ui:setTab(slot_idx)
end

-------------------------------------
-- function focusSlotIndex
-------------------------------------
function UI_RuneForgePresetTab:getRuneSlot()
    local ui = self.m_mTabData['rune']['ui']
    local slot_idx = ui.m_currTab
    return slot_idx
end

-------------------------------------
-- function focusSlotIndex
-------------------------------------
function UI_RuneForgePresetTab:focusSlotIndex(slot_idx)
    self.m_presetUI:setFocusRuneSlotIndex(slot_idx)
end

-------------------------------------
-- function onFocusSlotIndex
-------------------------------------
function UI_RuneForgePresetTab:onFocusSlotIndex(slot_idx)
    if self.m_mTabData['rune'] == nil then
        return
    end

    local ui = self.m_mTabData['rune']['ui']
    if ui == nil then
        return
    end


    ui:setTab(slot_idx)
end

-------------------------------------
-- function click_saveBtn
-------------------------------------
function UI_RuneForgePresetTab:click_saveBtn()
    local preset_data = self.m_presetUI:getCurrentPresetData()

    if g_runePresetData:isSameWithCurrentPresetMap(preset_data) == true then
        UIManager:toastNotificationRed(Str('변경된 정보가 없습니다.'))
        return
    end

    local success_cb = function()
        UIManager:toastNotificationGreen(Str('설정한 프리셋이 저장되었습니다.'))
    end

    g_runePresetData:request_setRunePreset(preset_data, success_cb)
end

-------------------------------------
-- function click_resetBtn
-------------------------------------
function UI_RuneForgePresetTab:click_resetBtn()
    local vars = self.vars

    local finish_cb = function()
        self.m_presetUI:resetPresetData()
        
    end

    local msg = Str('프리셋 설정을 되돌리시겠습니까?')
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, finish_cb)
end