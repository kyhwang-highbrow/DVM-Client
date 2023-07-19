local PARENT = UI

-------------------------------------
-- class UI_AutoPlaySettingDragSkillPopup
-------------------------------------
UI_AutoPlaySettingDragSkillPopup = class(PARENT, {
        m_deckList = 'List<string>',
        m_deckName = 'string',
        m_tableView = 'UIC_TableViewTD',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:init()
    self.m_uiName = 'UI_AutoPlaySettingDragSkillPopup'
    self.m_deckList = self:getSelectDeckList()
    
    self:load('battle_ready_auto_popup_new.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_AutoPlaySettingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

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
-- function click_okBtn
-------------------------------------
function UI_AutoPlaySettingDragSkillPopup:click_closeBtn()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_AutoPlaySettingDragSkillPopup)