local PARENT = class(UI, ITableViewCell:getCloneTable())


-------------------------------------
-- class UI_HatcheryCombineItem
-------------------------------------
UI_HatcheryCombineItem = class(PARENT, {
        m_did = 'number',
        m_characterCard = 'UI_CharacterCard',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryCombineItem:init(t_data)
    self.m_did = t_data['did']
    local vars = self:load('hatchery_relation_item.ui')

    self:initUI(t_data)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcheryCombineItem:initUI(t_data)
    local vars = self.vars

    local character_card = UI_CharacterCard(t_data)
    self.m_characterCard = character_card
    character_card.root:setSwallowTouch(false)
    vars['dragonNode']:addChild(character_card.root)
    character_card.vars['clickBtn']:setEnabled(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HatcheryCombineItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_HatcheryCombineItem:refresh()
    local vars = self.vars

    local did = self.m_did

    local cnt, satisfy = g_hatcheryData:combineMaterialInfo(did)
    local color

    if (satisfy < 4) then
        color = 'R'
    else
        color = 'G'
    end

    local str = Str('{@{1}}{2}{@w}/{3}', color, cnt, 4)
    vars['relationLabel']:setString(str)
end

-------------------------------------
-- function setSelected
-- @brief
-------------------------------------
function UI_HatcheryCombineItem:setSelected(is_selected)
    local vars = self.vars
    vars['selectSprite']:setVisible(is_selected)
    vars['selectSprite']:stopAllActions()

    -- 깜빡임 액션
    if is_selected then
        vars['selectSprite']:setOpacity(255)
        vars['selectSprite']:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
    end
end