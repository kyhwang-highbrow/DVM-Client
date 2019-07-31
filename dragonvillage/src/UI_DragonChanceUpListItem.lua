local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonChanceUpListItem
-------------------------------------
UI_DragonChanceUpListItem = class(PARENT,{
		m_did = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonChanceUpListItem:init(did)
    self:load('event_chanceup_item.ui')
    self.m_did = did

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonChanceUpListItem:initUI()
    local vars = self.vars
    local did = self.m_did
    local table_dragon = TableDragon()
    local attr = table_dragon:getDragonAttr(did)
    local role_type = table_dragon:getDragonRole(did)
    local rarity_type = table_dragon:getValue(did, 'rarity')
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 이름
    local name = table_dragon:getChanceUpDragonName(did)
    vars['nameLabel']:setString(name)

    -- 희귀도
    DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)

    -- 역할
    DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    
    -- 속성
    DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    
    -- 드래곤
    local animator = AnimatorHelper:makeDragonAnimator_usingDid(did, 3)
    vars['dragonNode']:addChild(animator.m_node)

    -- 배경
    local bg_path = table_dragon:getChanceUpDragonBgPath(did)
    local bg = cc.Sprite:create(bg_path)
    bg:setAnchorPoint(ZERO_POINT)
    bg:setDockPoint(ZERO_POINT)
    vars['bgNode']:addChild(bg)  
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonChanceUpListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonChanceUpListItem:refresh()
	local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_DragonChanceUpListItem)
