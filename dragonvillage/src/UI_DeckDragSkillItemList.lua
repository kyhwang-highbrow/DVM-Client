local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DeckDragSkillItemList
-------------------------------------
UI_DeckDragSkillItemList = class(PARENT, {
    m_keyName = 'string',
    m_ownerUI = 'UI',
    m_tableView = 'UIC_TableViewTD',
    m_selectList = 'List<number>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DeckDragSkillItemList:init(key_name)
    self.m_keyName = key_name
    self.m_selectList = g_settingData:getAutoDragSkillLockDidMap(self.m_keyName)

    self:load('ui_item_deck_dragon.ui')

    self:correctData()
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
        local is_locked = self:isDragonSelected(data['did'])
        ui:setCheckSpriteVisible(is_locked)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() 
            self:saveData(data['did'])
            local is_locked = self:isDragonSelected(data['did'])
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

-------------------------------------
-- function correctData
-------------------------------------
function UI_DeckDragSkillItemList:correctData()
    local did_list = {}    
    local dirty = false
    local l_deck = g_deckData:getDeck(self.m_keyName)
    for _, v in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
        if (t_dragon_data) then
            table.insert(did_list, t_dragon_data['did'])
        end
    end
    
    for idx, did in ipairs(self.m_selectList) do
        if table.find(did_list, did) == nil then
            idx = table.remove(self.m_selectList, idx)
            dirty = true
        end
    end

    if dirty == true then
        g_settingData:setAutoDragSkillLockDidMap(self.m_keyName, self.m_selectList)
    end
end

-------------------------------------
-- function saveData
-------------------------------------
function UI_DeckDragSkillItemList:saveData(did)
    if did ~= nil then
        local find_idx = table.find(self.m_selectList, did)
        if find_idx ~= nil then
            table.remove(self.m_selectList, find_idx)
        else
            table.insert(self.m_selectList, did)
        end
    end

    g_settingData:setAutoDragSkillLockDidMap(self.m_keyName, self.m_selectList)
end

-------------------------------------
-- function isDragonSelected
-------------------------------------
function UI_DeckDragSkillItemList:isDragonSelected(did)
    local is_locked = table.find(self.m_selectList, did) ~= nil
    return is_locked
end