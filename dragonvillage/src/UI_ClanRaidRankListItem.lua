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

    -- 유저 정보 표시 
    vars['levelLabel']:setString(t_rank_info:getLvText())
    vars['nameLabel']:setString(t_rank_info:getUserText())

    -- 기여도 
    vars['percentLabel']:setString(t_rank_info:getContributionText())

    -- 순위  
    local rank = t_rank_info.m_rank
    vars['rankNode']:removeAllChildren()

    if (rank <= 3) then
        vars['rankLabel']:setString('')
        local path = string.format('res/ui/icons/rank/clan_raid_02%02d.png', rank)
        local icon = cc.Sprite:create(path)

        if (icon) then
            icon:setAnchorPoint(ZERO_POINT)
            icon:setDockPoint(ZERO_POINT)
            vars['rankNode']:addChild(icon)
        end
    else
        vars['rankLabel']:setString(t_rank_info:getRankText())
    end
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
