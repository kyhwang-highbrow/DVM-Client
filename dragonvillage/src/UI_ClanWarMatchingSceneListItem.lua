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
    local struct_match_item = self.m_structMatch

    -- ½Â/ÆÐ Ç¥½Ã
    local attack_state = struct_match_item:getAttackState()
    vars['winSprite']:setVisible(false)

    if (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_SUCCESS']) then
        vars['winSprite']:setVisible(true)
    elseif (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']) then
        vars['loseSprite']:setVisible(true)
    end

    -- µå·¡°ï ÃÊ»óÈ­
    local struct_clan_info = struct_match_item:getUserInfo()
    local dragon_icon = struct_clan_info:getLeaderDragonCard()
    if (dragon_icon) then
        vars['dragonNode']:addChild(dragon_icon.root)
    end   
end