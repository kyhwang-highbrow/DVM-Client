local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EvolutionStoneCombineListItem
-------------------------------------
UI_EvolutionStoneCombineListItem = class(PARENT, {
        m_tItemData = 'table',
        m_clickFunc = 'function',
        m_btnMap = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EvolutionStoneCombineListItem:init(data, click_func)
    local vars = self:load('evolution_stone_combine_item.ui')
    self.m_tItemData = data
    self.m_clickFunc = click_func
    self.m_btnMap = {}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EvolutionStoneCombineListItem:initUI()
    local vars = self.vars
    local item_data = self.m_tItemData

    -- attr
    local attr = item_data['attr']
    if (attr) then
        local icon = IconHelper:getAttributeIconButton(attr)
        vars['attrNode']:addChild(icon)
    end

    -- name
    local name = item_data['name']
    if (name) then
        vars['titleLabel']:setString(name)
    end

    -- item
    local t_data = item_data['data']
    for i, item_id in ipairs(t_data) do
        local idx = (item_id % 10)
        local card = UI_ItemCard(item_id, 0)

        local count = g_evolutionStoneData:getCount(item_id)
        card.vars['aniNumberLabel'] = NumberLabel(card.vars['numberLabel'], 0, 0.3)
        card.vars['aniNumberLabel']:setNumber(count)
        card.vars['clickBtn']:registerScriptTapHandler(function() 
            self.m_clickFunc(item_id) 
        end)

        card.root:setScale(0.6)
        vars['itemNode'..idx]:addChild(card.root)

        self.m_btnMap[item_id] = card
    end 
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EvolutionStoneCombineListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EvolutionStoneCombineListItem:refresh()
    local vars = self.vars
end


