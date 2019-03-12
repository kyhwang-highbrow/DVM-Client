local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaidLastRankingTab
-------------------------------------
UI_ClanRaidLastRankingTab = class(PARENT,{
        m_rank_data = 'table',
        m_offset = 'number',
    })

local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidLastRankingTab:init()
    local vars = self:load('clan_raid_rank_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_offset = 1
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ClanRaidLastRankingTab')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    self:request_clanRank()
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidLastRankingTab:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidLastRankingTab:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidLastRankingTab:refresh()
    local vars = self.vars
end


--@CHECK
UI:checkCompileError(UI_ClanRaidLastRankingTab)

