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
    local nick_with_enemy = self.m_structMatch:getNameTextWithEnemy() or ''
    vars['userNameLabel']:setString(nick_with_enemy)
end