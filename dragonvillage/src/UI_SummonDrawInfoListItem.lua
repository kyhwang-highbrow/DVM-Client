local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_SummonDrawInfoListItem
-------------------------------------
UI_SummonDrawInfoListItem = class(PARENT, {
        m_did = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SummonDrawInfoListItem:init(did)
    local vars = self:load('event_capsule_box_schedule_item.ui')
    self.m_did = tonumber(did)
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SummonDrawInfoListItem:initUI()
    local vars = self.vars
    local table_dragon = TableDragon()
    local did = self.m_did


    -- 이름
    local dragon_name = table_dragon:getDragonName(did)
    vars['nameLabel']:setString(Str(dragon_name))
    
    -- 속성 ex) dark
    local dragon_attr = table_dragon:getDragonAttr(did)
    local attr_icon = IconHelper:getAttributeIcon(dragon_attr)
    vars['attrNode']:addChild(attr_icon)
    vars['attrLabel']:setString(dragonAttributeName(dragon_attr))

    -- 역할 ex) healer
    local role_type = table_dragon:getDragonRole(did)
    local role_icon = IconHelper:getRoleIcon(role_type)
    vars['typeNode']:addChild(role_icon)
    vars['typeLabel']:setString(dragonRoleTypeName(role_type))

    -- 희귀도 ex) legend
    local rarity_icon = IconHelper:getRarityIcon('legend')
    vars['rarityNode']:addChild(rarity_icon)
    vars['rarityLabel']:setString(dragonRarityName('legend'))

    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(did, 3)
    dragon_animator:setTalkEnable(false)
    vars['dragonNode']:addChild(dragon_animator.m_node)
end

-------------------------------------
-- function initItemCard
-------------------------------------
function UI_SummonDrawInfoListItem:initButton()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SummonDrawInfoListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SummonDrawInfoListItem:refresh()
end
