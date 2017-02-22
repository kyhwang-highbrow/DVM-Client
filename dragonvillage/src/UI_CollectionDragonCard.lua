local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_CollectionDragonCard
-------------------------------------
UI_CollectionDragonCard = class(PARENT, {
        m_tItemData = 'table',
        m_dragonCard = 'UI_DragonCard',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionDragonCard:init(t_item_data)
    self.m_tItemData = t_item_data
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
    self.m_dragonCard = card

    card.vars['starIcon']:setVisible(false)
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

    local did = self.m_tItemData['did']

    do -- 인연포인트
        -- 인연포인트 값 얻어오기
        local req_rpoint = TableDragon():getRelationPoint(did)
        local cur_rpoint = g_collectionData:getRelationPoint(did)
        
        -- 인연포인트 표시
        local str = Str('{1}/{2}', comma_value(cur_rpoint), comma_value(req_rpoint))
        vars['relationPointLabel']:setString(str)

        -- 하일라이트
        if (cur_rpoint >= req_rpoint) then
            vars['notiSprite']:setVisible(true)
        else
            vars['notiSprite']:setVisible(false)
        end
    end

    -- 획득한적이 있는지 없는지 체크
    if (not g_collectionData:isExist(did)) then
        vars['disableSprite']:setVisible(true)
    else
        vars['disableSprite']:setVisible(false)
    end
end