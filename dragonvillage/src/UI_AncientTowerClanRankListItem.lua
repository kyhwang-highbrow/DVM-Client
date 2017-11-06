local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerClanRankListItem
-------------------------------------
UI_AncientTowerClanRankListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerClanRankListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
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
end
