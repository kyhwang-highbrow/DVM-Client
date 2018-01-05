local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ClanRaidRankListItem
-------------------------------------
UI_ClanRaidRankListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidRankListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('clan_raid_scene_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidRankListItem:initUI()
    local vars = self.vars
    local t_rank_info = self.m_rankInfo
    local tag = t_rank_info.m_tag

    -- 점수 표시
    vars['damageLabel']:setString(t_rank_info:getScoreText())

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['nameLabel']:setString(t_rank_info:getUserText())

    -- 순위 표시
    vars['rankLabel']:setString(t_rank_info:getRankText())
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidRankListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidRankListItem:refresh()
end
