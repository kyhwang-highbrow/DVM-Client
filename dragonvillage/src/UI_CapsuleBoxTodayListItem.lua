local PARENT = UI

-------------------------------------
-- class UI_CapsuleBoxTodayListItem
-------------------------------------
UI_CapsuleBoxTodayListItem = class(PARENT, {
        m_did = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBoxTodayListItem:init(did)
    local vars = self:load('event_capsule_box_schedule_item.ui')
    self.m_did = did
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBoxTodayListItem:initUI()
    local vars = self.vars
    local table_dragon = TableDragon()
    local did = self.m_did

    local attr = table_dragon:getDragonAttr(did)
    local role_type = table_dragon:getDragonRole(did)
    local rarity_type = table_dragon:getDragonRarity(did)
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 이름
    local dragon_name = table_dragon:getDragonName(did)
    vars['nameLabel']:setString(Str(dragon_name))
    
    -- 속성 ex) dark
    vars['attrNode']:removeAllChildren()
    DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)

    -- 역할 ex) healer
    vars['typeNode']:removeAllChildren()
    DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)

    -- 희귀도 ex) legend
    vars['rarityNode']:removeAllChildren()
    DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)

    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(did, 3)
    dragon_animator:setTalkEnable(false)
    dragon_animator:setIdle()
    vars['dragonNode']:addChild(dragon_animator.m_node)
end

-------------------------------------
-- function initItemCard
-------------------------------------
function UI_CapsuleBoxTodayListItem:initButton()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBoxTodayListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBoxTodayListItem:refresh()
end
