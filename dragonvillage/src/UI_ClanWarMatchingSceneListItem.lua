local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchingSceneListItem
-------------------------------------
UI_ClanWarMatchingSceneListItem = class(PARENT,{
        m_structUserInfoClan = 'StructUserInfoClan',
    })

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_ClanWarMatchingSceneListItem:initButton()
end

-------------------------------------
-- function setClanMemberInfo
-------------------------------------
function UI_ClanWarMatchingSceneListItem:setClanMemberInfo(struct_user_info_clan)
    self.m_structUserInfoClan = struct_user_info_clan
    self:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarMatchingSceneListItem:refresh()
    local vars = self.vars

    local nick_name = self.m_structUserInfoClan:getNickname() or ''
    vars['userNameLabel']:setString(nick_name)
    
    local leader_dragon_card = self.m_structUserInfoClan:getLeaderDragonCard()
    if (leader_dragon_card) then
        vars['dragonNode']:addChild(leader_dragon_card.root)
    end
end












local PARENT = UI_ClanWarMatchingSceneListItem

-------------------------------------
-- class UI_ClanWarMatchingSceneListItem_My
-------------------------------------
UI_ClanWarMatchingSceneListItem_My = class(PARENT,{

    })


-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingSceneListItem_My:init(data)
    local vars = self.vars
    vars = self:load('clan_war_match_scene_item_me.ui')
end











local PARENT = UI_ClanWarMatchingSceneListItem

-------------------------------------
-- class UI_ClanWarMatchingSceneListItem_Enemy
-------------------------------------
UI_ClanWarMatchingSceneListItem_Enemy = class(PARENT,{

    })


-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingSceneListItem_Enemy:init(data)
    local vars = self.vars
    vars = self:load('clan_war_match_scene_item_rival.ui')
end
