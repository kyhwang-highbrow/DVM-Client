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

    -- 이름
    local name = table_dragon:getChanceUpDragonName(did)
    vars['nameLabel']:setString(name)

    -- 희귀도
    local rarity = table_dragon:getValue(did, 'rarity')
    local icon = IconHelper:getRarityIconButton(rarity)
    vars['rarityNode']:addChild(icon)
    vars['rarityLabel']:setString(dragonRarityName(rarity))

    -- 역할
    local role = table_dragon:getDragonRole(did)
    local icon = IconHelper:getRoleIconButton(role)
    vars['typeNode']:addChild(icon)
    vars['typeLabel']:setString(dragonRoleTypeName(role))
    
    -- 속성
    local attr = table_dragon:getDragonAttr(did) 
    local icon = IconHelper:getAttributeIconButton(attr)
    vars['attrNode']:addChild(icon)
    vars['attrLabel']:setString(dragonAttributeName(attr))
    
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
