local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonReinforceItem
-------------------------------------
UI_DragonReinforceItem = class(PARENT, {
        --m_did = 'number',
		m_type = 'string',
		m_tData = 'table',
        m_card = 'UI_Card',

		m_bShowMaxRelationPoint = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonReinforceItem:init(item_type, t_data)
    --self.m_did = t_data['did']
	self.m_type = item_type
	self.m_tData = t_data
	self.m_bShowMaxRelationPoint = false
    local vars = self:load('hatchery_relation_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonReinforceItem:initUI()
    local vars = self.vars
	local item_type = self.m_type
	local t_data = self.m_tData

	-- 드래곤 인연포인트 카드
	if (item_type == 'dragon') then
		
		local card = UI_RelationCard(t_data)
		card.root:setSwallowTouch(false)
		card.vars['clickBtn']:setEnabled(false)
		self.m_card = card
		
		vars['dragonNode']:addChild(card.root)

	-- 강화 포인트
	elseif (item_type == 'item') then

		local card = UI_ReinforcePointCard(t_data)
		card.root:setSwallowTouch(false)
		card.vars['clickBtn']:setEnabled(false)
		self.m_card = card

		vars['dragonNode']:addChild(card.root)

	-- 빔
	elseif (item_type == 'empty') then
		vars['clickBtn']:setEnabled(false)
		vars['relationLabel']:setString('')
		vars['emptyNode']:setVisible(true)

	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonReinforceItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_DragonReinforceItem:refresh()
    local vars = self.vars
	local item_type = self.m_type
	local t_data = self.m_tData

	local point = 0

	-- 드래곤 인연포인트 카드
	if (item_type == 'dragon') then
		local did = self.m_tData:getDid()
		point = g_bookData:getRelationPoint(did)

	-- 강화 포인트
	elseif (item_type == 'item') then
		local item_id = t_data['item']
		point = g_userData:getReinforcePoint(item_id)

	else
		return

	end

	if (self.m_type == 'dragon') and self.m_bShowMaxRelationPoint then
		local did = self.m_tData:getDid()
		point = g_bookData:getRelationPoint(did)
		max_point = TableDragon:getRelationPoint(did)

		local string_format
		if point >= max_point then
			string_format = '{@w}%s / %s'
		else
			string_format = '{@red}%s {@w}/ %s'
		end

		self.vars['relationLabel']:setString(string.format(string_format, point, max_point))
	else
		vars['relationLabel']:setString(string.format('{@w}%s', comma_value(point)))
	end
end

-------------------------------------
-- function disable
-- @brief
-------------------------------------
function UI_DragonReinforceItem:disable()
	self.vars['clickBtn']:setEnabled(false)
end

-------------------------------------
-- function showMaxRelationPoint
-- @brief
-------------------------------------
function UI_DragonReinforceItem:showMaxRelationPoint(isTrue)
	if isTrue == nil then
		isTrue = true
	end

	self.m_bShowMaxRelationPoint = isTrue
	--self:refresh()
end