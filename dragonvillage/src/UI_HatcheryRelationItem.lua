local PARENT = class(UI, ITableViewCell:getCloneTable())


-------------------------------------
-- class UI_HatcheryRelationItem
-------------------------------------
UI_HatcheryRelationItem = class(PARENT, {
        --m_did = 'number',
		m_tData = 'table',
        m_characterCard = 'UI_CharacterCard',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryRelationItem:init(t_data)
    --self.m_did = t_data['did']
	self.m_tData = t_data
    local vars = self:load('hatchery_relation_item.ui')

    self:initUI(t_data)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcheryRelationItem:initUI(t_data)
    local vars = self.vars
    local character_card = UI_RelationCard(t_data)
    self.m_characterCard = character_card
    character_card.root:setSwallowTouch(false)
    vars['dragonNode']:addChild(character_card.root)
    character_card.vars['clickBtn']:setEnabled(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HatcheryRelationItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_HatcheryRelationItem:refresh()
    local vars = self.vars

    local did = self.m_tData:getDid()

    -- 인연포인트 값 얻어오기
    local req_rpoint = TableDragon():getRelationPoint(did)
    local cur_rpoint = g_bookData:getRelationPoint(did)
    local color

    if (cur_rpoint < req_rpoint) then
        color = 'R'
		vars['completeSprite']:setVisible(false)
    else
        color = 'G'
		vars['completeSprite']:setVisible(true)
    end

    local str = Str('{@{1}}{2}{@w}/{3}', color, comma_value(cur_rpoint), comma_value(req_rpoint))
    vars['relationLabel']:setString(str)
end

-------------------------------------
-- function setSelected
-- @brief
-------------------------------------
function UI_HatcheryRelationItem:setSelected(is_selected)
    local vars = self.vars
    vars['selectSprite']:setVisible(is_selected)
    vars['selectSprite']:stopAllActions()

    -- 깜빡임 액션
    if is_selected then
        vars['selectSprite']:setOpacity(255)
        vars['selectSprite']:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
    end
end