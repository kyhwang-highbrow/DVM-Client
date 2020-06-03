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

    local attr = table_dragon:getDragonAttr(did)
    local role_type = table_dragon:getDragonRole(did)
    local rarity_type = table_dragon:getDragonRarity(did)
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 이름
    local dragon_name = table_dragon:getDragonName(did)
    vars['nameLabel']:setString(Str(dragon_name))
    
    -- 속성 ex) dark
    DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)

    -- 역할 ex) healer
    DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)

    -- 희귀도 ex) legend
    DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)

    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(did, 3)
    dragon_animator:setTalkEnable(false)
    vars['dragonNode']:addChild(dragon_animator.m_node)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonInfoListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonInfoListItem:refresh()
end
