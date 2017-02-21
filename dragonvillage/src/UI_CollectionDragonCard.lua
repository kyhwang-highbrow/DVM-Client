local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_CollectionDragonCard
-------------------------------------
UI_CollectionDragonCard = class(PARENT, {
        m_tItemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionDragonCard:init(t_item_data)
    local vars = self:load('collection_dragon_card.ui')

    self:initUI(t_item_data)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionDragonCard:initUI(t_item_data)
    local vars = self.vars

    local did = t_item_data['did']
    local card = MakeSimpleDragonCard(did)
    card.root:setSwallowTouch(false)
    vars['cardNode']:addChild(card.root)

    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionDragonCard:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionDragonCard:refresh()
    local vars = self.vars
    vars['relationPointLabel']:setString('')
end