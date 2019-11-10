local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchingSceneListItem
-------------------------------------
UI_ClanWarMatchingSceneListItem = class(PARENT,{
        m_structMatch = 'StructClanWarMatch,'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingSceneListItem:init(data)
    local vars = self:load('clan_war_match_scene_item_me.ui')
    self.m_structMatch = data
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingSceneListItem:initUI()
    local vars = self.vars
    local attack_state = self.m_structMatch:getAttackState()
    if (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_SUCCESS']) then
        vars['winSprite']:setVisible(true)
        return
    elseif (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']) then
        vars['loseSprite']:setVisible(true)
        return
    end

    vars['winSprite']:setVisible(false)
end