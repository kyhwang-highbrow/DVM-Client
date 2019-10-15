local PARENT = UI

-------------------------------------
-- class UI_ClanWarTeamChart
-------------------------------------
UI_ClanWarTeamChart = class(PARENT, {

     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTeamChart:init()
    local vars = self:load('clan_war_tournament_tree.ui')
    UIManager:open(self, UIManager.POPUP)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarTeamChart')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarTeamChart:initButton()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarTeamChart:initUI()
	local vars = self.vars
    for i = 1, 6 do
        local ui = UI()
        ui:load('clan_war_tournament_tree_item.ui')
        local clan_A = 'A'
        local clan_B = 'B'
        local label = Str('{1} vs {2}', clan_A, clan_B)
        ui.vars['clanLabel']:setString(label)
        ui.vars['clanLabel']:setPosition(-400, 300 - 50* i)
        self.root:addChild(ui.root)
    end 
end

