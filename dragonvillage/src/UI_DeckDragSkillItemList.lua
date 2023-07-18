local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DeckDragSkillItemList
-------------------------------------
UI_DeckDragSkillItemList = class(PARENT, {
    m_keyName = 'string',
    m_ownerUI = 'UI',
    m_tableView = 'UIC_TableViewTD',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DeckDragSkillItemList:init(key_name, owner_ui)
    self.m_keyName = key_name
    self.m_ownerUI = owner_ui
    self:load('ui_item_deck_dragon.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DeckDragSkillItemList:initUI()
    local vars = self.vars
    local node = vars['dragonListNode']
    local function create_func(ui, data)
        ui.root:setScale(0.6)
        local is_locked = self.m_ownerUI:isDragonSelected(data['did'])
        ui:setCheckSpriteVisible(is_locked)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() 
            self.m_ownerUI:click_dragonCard(data['did'])
            local is_locked = self.m_ownerUI:isDragonSelected(data['did'])
            ui:setCheckSpriteVisible(is_locked)
        end)
    end

    local deck_dragon_list = self:getDeckDragonList()
    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setItemList(deck_dragon_list)
    table_view_td.m_scrollView:setTouchEnabled(false)
    self.m_tableView = table_view_td
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DeckDragSkillItemList:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DeckDragSkillItemList:refresh()
    local vars = self.vars
end

-------------------------------------
-- function refreshTableView
-------------------------------------
function UI_DeckDragSkillItemList:refreshTableView()
    for i,v in pairs(self.m_tableView.m_itemList) do
        local ui = v['ui']
        local data = v['data']
        local did = data['did']
        local is_locked = self.m_ownerUI:isDragonSelected(did)
        --ui:setCheckSpriteVisible(is_locked)
    end
end

-------------------------------------
-- function getDeckDragonList
-------------------------------------
function UI_DeckDragSkillItemList:getDeckDragonList()
    local vars = self.vars
    local l_deck, formation, deck_name, leader = g_deckData:getDeck(self.m_keyName)
    local l_dragon_data = {}

    for _, v in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
        if (t_dragon_data) then
            table.insert(l_dragon_data, t_dragon_data)
        end
    end

    return l_dragon_data
end
