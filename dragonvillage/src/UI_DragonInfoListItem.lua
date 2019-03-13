local PARENT = UI

-------------------------------------
-- class UI_DragonInfoListItem
-------------------------------------
UI_DragonInfoListItem = class(PARENT, {
        m_did = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonInfoListItem:init(did, ui_res)
    local vars = self:load(ui_res)
    self.m_did = tonumber(did)
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonInfoListItem:initUI()
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
    local rarity_str = table_dragon:getDragonRarity(did)
    local rarity_icon = IconHelper:getRarityIcon(rarity_str)
    vars['rarityNode']:addChild(rarity_icon)
    vars['rarityLabel']:setString(dragonRarityName(rarity_str))

    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(did, 3)
    dragon_animator:setTalkEnable(false)
    vars['dragonNode']:addChild(dragon_animator.m_node)
end

-------------------------------------
-- function initItemCard
-------------------------------------
function UI_DragonInfoListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonInfoListItem:refresh()
end
