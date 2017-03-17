local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_CollectionUnitListItem
-------------------------------------
UI_CollectionUnitListItem = class(PARENT, {
        m_dragonUnitID = 'number',
        m_lDragonCard = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionUnitListItem:init(unit_id)
    self.m_dragonUnitID = unit_id

    local vars = self:load('collection_unit_list.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionUnitListItem:initUI()
    local vars = self.vars

    local table_dragon_unit = TableDragonUnit()
    local t_dragon_unit = table_dragon_unit:get(self.m_dragonUnitID)

    -- 이름
    vars['titleLabel']:setString(Str(t_dragon_unit['t_name']))

    -- 설명
    vars['dscLabel']:setString(Str(t_dragon_unit['t_desc']))


    local t_dragon_unit_data = g_dragonUnitData:getDragonUnitData(self.m_dragonUnitID)
    local unit_list = t_dragon_unit_data['unit_list']

    local table_dragon = TableDragon()

    self.m_lDragonCard = {}

    for i,v in ipairs(unit_list) do
        local type = v['type']
        local value = v['value']

        local did
        if (type == 'dragon') then
            did = value
        elseif (type == 'category') then
            local dragon_type = value
            did = TableDragonType:getBaseDid(dragon_type)
        end

        local card = MakeSimpleDragonCard(did)
        card.root:setSwallowTouch(false)
        card.vars['starIcon']:setVisible(false)
        vars['dragonNode' .. i]:addChild(card.root)

        self.m_lDragonCard[i] = card
    end

    do -- 보상 표시
        local reward_str = t_dragon_unit_data['reward']
        local item_id, count = ServerData_Item:parsePackageItemStrIndivisual(reward_str)
        local icon = IconHelper:getItemIcon(item_id)
        vars['priceNode']:addChild(icon)
        vars['priceLabel']:setString(comma_value(count))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionUnitListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionUnitListItem:refresh()
    local vars = self.vars

    local t_dragon_unit_data = g_dragonUnitData:getDragonUnitData(self.m_dragonUnitID)
    local unit_list = t_dragon_unit_data['unit_list']

    for i,v in ipairs(unit_list) do
        local exist = v['exist']
        local ui = self.m_lDragonCard[i]
        ui:setShadowSpriteVisible(not exist)
    end


    -- 

    if t_dragon_unit_data['received'] then
        vars['rewardBtn']:setEnabled(false)
        vars['rewardNode']:setVisible(false)

        -- 적용 중이면
        if (g_dragonUnitData.m_selectedUnitID == self.m_dragonUnitID) then
            vars['buffSprite']:setVisible(true)
            vars['buffBtn']:setVisible(false)
        else
            vars['buffSprite']:setVisible(false)
            vars['buffBtn']:setVisible(true)
        end
    else
        if t_dragon_unit_data['active'] then
            vars['rewardBtn']:setEnabled(true)
            vars['rewardNode']:setVisible(true)
        else
            vars['rewardBtn']:setEnabled(false) 
            vars['rewardNode']:setVisible(false)   
        end

        vars['buffSprite']:setVisible(false)
        vars['buffBtn']:setVisible(false)
    end

    if t_dragon_unit_data['received'] then
        
    end

end