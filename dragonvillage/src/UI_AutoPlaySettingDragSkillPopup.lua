local PARENT = UI

-------------------------------------
-- class UI_AutoPlaySettingDragSkillPopup
-------------------------------------
UI_AutoPlaySettingDragSkillPopup = class(PARENT, {
        m_deckList = 'List<string>',
        m_deckName = 'string',
        m_tableView = 'UIC_TableViewTD',
        m_selectList = 'List<number>'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:init(deck_name)
    self.m_uiName = 'UI_AutoPlaySettingDragSkillPopup'
    self.m_deckList, self.m_deckName = self:getSelectDeckList()
    self.m_selectList = g_settingData:getAutoDragSkillLockDidMap(self.m_deckName)
    
    self:load('battle_ready_auto_popup_new.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_AutoPlaySettingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    self:correctData()
    self:initUI()
    self:initButton()
    self:initTableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:initTableView()
    local vars = self.vars

    local node = vars['dragonListNode']

    local function make_func(data)
        local ui = UI_DeckDragSkillItemList(data, self)
        return ui
    end

    local deck_list = self.m_deckList
    -- 테이블뷰 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(500, 130)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(deck_list)
    self.m_tableView = table_view_td
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function isDragonSelected
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:isDragonSelected(did)
    local is_locked = table.find(self.m_selectList, did) ~= nil
    return is_locked
end

-------------------------------------
-- function getSelectDeckList
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:getSelectDeckList()
    local deck_list = {}
    local deck_name = g_deckData:getSelectedDeckName()

    if string.find(deck_name, 'league_raid') ~= nil then
        deck_list = {'league_raid_1', 'league_raid_2', 'league_raid_3'}
        deck_name = 'league_raid'
    elseif string.find(deck_name, 'clan_raid') ~= nil then
        deck_list = {'clan_raid_up', 'clan_raid_down'}
        deck_name = 'clan_raid'
    else
        table.insert(deck_list, deck_name)
    end

    return deck_list, deck_name
end

-------------------------------------
-- function correctData
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:correctData()
    local did_list = {}
    for _, deck_name in ipairs(self.m_deckList) do
        local l_deck = g_deckData:getDeck(deck_name)
        for _, v in pairs(l_deck) do
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
            if (t_dragon_data) then
                table.insert(did_list, t_dragon_data['did'])
            end
        end
    end

    for idx, did in ipairs(self.m_selectList) do
        if table.find(did_list, did) == nil then
            idx = table.remove(self.m_selectList, idx)
        end
    end
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:click_closeBtn()    
    self:correctData()
    g_settingData:setAutoDragSkillLockDidMap(self.m_deckName, self.m_selectList)
    self:close()
end

-------------------------------------
-- function click_dragonCard
-- @brief 드래곤 카드 클릭
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:click_dragonCard(did)
    local find_idx = table.find(self.m_selectList, did)
    if find_idx ~= nil then
        table.remove(self.m_selectList, find_idx)
    else
        table.insert(self.m_selectList, did)
    end
end

--@CHECK
UI:checkCompileError(UI_AutoPlaySettingDragSkillPopup)