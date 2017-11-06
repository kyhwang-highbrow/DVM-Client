local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerClanRankListItem
-------------------------------------
UI_AncientTowerClanRankListItem = class(PARENT, {
        m_structRank = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerClanRankListItem:init(struct_rank)
    self.m_structRank = struct_rank
    local vars = self:load('tower_scene_ranking_item_clan.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerClanRankListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerClanRankListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerClanRankListItem:refresh()
    local vars = self.vars
    local struct_clan_rank = self.m_structRank

    if (not struct_clan_rank) then
        return
    end

    -- 클랜 마크
    local icon = struct_clan_rank:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan_rank:getClanName()
    vars['clanLabel']:setString(clan_name)

    -- 클랜 마스터
    local clan_master = struct_clan_rank:getMasterNick()
    vars['masterLabel']:setString(clan_name)

    -- 점수
    local clan_score = struct_clan_rank:getClanScore()
    vars['scoreLabel']:setString(clan_score)
    
    -- 등수 
    local clan_rank = struct_clan_rank:getClanRank()
    vars['rankLabel']:setString(clan_rank)
end
