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
    local str

    if (satisfy < 4) then
        --[[
        -- 모든 조건을 충족한 경우 괄호로 표시
        if (0 < satisfy) then
            str = Str('{@R}{1}{@G}({2}){@w}/{3}', cnt, satisfy, 4)
        -- 드래곤만 가지고 있을 경우
        else
            str = Str('{@R}{1}{@w}/{2}', cnt, 4)
        end
        --]]

        -- 조합 가능한 드래곤이 있는 상태
        str = Str('{@R}{1}{@w}/{2}', satisfy, 4)
    else
        -- 조합 가능한 드래곤이 있는 상태
        str = Str('{@G}{1}{@w}/{2}', satisfy, 4)
    end

    vars['notiSprite']:setVisible(satisfy >= 4)
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