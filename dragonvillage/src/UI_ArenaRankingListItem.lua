local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaRankingListItem
-------------------------------------
UI_ArenaRankingListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaRankingListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('arena_rank_popup_item_user_ranking.ui')

    --self:initUI()
    --self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaRankingListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaRankingListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaRankingListItem:refresh()
end
