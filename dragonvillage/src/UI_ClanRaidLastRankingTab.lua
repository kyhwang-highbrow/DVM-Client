
-------------------------------------
-- class UI_ClanRaidLastRankingTab
-------------------------------------
UI_ClanRaidLastRankingTab = class({
        m_rank_data = 'table',
        m_offset = 'number',
        m_vars = 'vars'
    })

local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidLastRankingTab:init(vars)
    self.m_vars = vars
    self.m_offset = 1

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidLastRankingTab:initUI()
    local vars = self.m_vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidLastRankingTab:initButton()
    local vars = self.m_vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidLastRankingTab:refresh()
    local vars = self.m_vars
end


--@CHECK
UI:checkCompileError(UI_ClanRaidLastRankingTab)

