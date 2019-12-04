-------------------------------------
-- class UI_ClanWarTournamentTreeLeaf
-------------------------------------
UI_ClanWarTournamentTreeLeaf = class(UI, {
    m_clan1Win = 'boolean',
    m_clan2Win = 'boolean',
})

local WIN_COLOR = cc.c3b(127, 255, 212)
-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTreeLeaf:init()
    local vars = self:load('clan_war_tournament_item_leaf.ui')
    
	vars['lineMenu']:setVisible(true)
    
    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    local _, height = vars['leftHorizontalSprite']:getNormalSize()
    if (g_clanWarData:getMaxRound() == 64) then
        vars['leftHorizontalSprite']:setNormalSize(110, height)
    else
        vars['leftHorizontalSprite']:setNormalSize(170, height)
    end
end

-------------------------------------
-- function setWin
-------------------------------------
function UI_ClanWarTournamentTreeLeaf:setWin(is_clan1_win, is_clan2_win)
    self.m_clan1Win = is_clan1_win
    self.m_clan2Win = is_clan2_win
end

-------------------------------------
-- function setLine
-------------------------------------
function UI_ClanWarTournamentTreeLeaf:setLine(is_both)
    local vars = self.vars

    vars['leftHorizontalSprite']:setVisible(not is_both)
end

-------------------------------------
-- function setRightHeightLine
-------------------------------------
function UI_ClanWarTournamentTreeLeaf:setRightHeightLine(idx, height)
    local vars = self.vars

    if (idx%2 == 0) then
	    vars['rightLine2']:setScaleY(-1)
    end
    local width, _ = vars['rightLine2']:getNormalSize()
    vars['rightLine2']:setNormalSize(width, height)
end

-------------------------------------
-- function setWinLineColor
-------------------------------------
function UI_ClanWarTournamentTreeLeaf:setWinLineColor(is_up_win)
    local vars = self.vars

	if (is_up_win) then
		vars['topClanLine1']:setColor(WIN_COLOR)
		vars['topClanLine2']:setColor(WIN_COLOR)
	else
		vars['bottomClanLine1']:setColor(WIN_COLOR)
		vars['bottomClanLine2']:setColor(WIN_COLOR)		
	end
    vars['rightLine1']:setColor(WIN_COLOR)
	vars['rightLine2']:setColor(WIN_COLOR)
end

-------------------------------------
-- function getMyInfoInCurRound
-------------------------------------
function UI_ClanWarTournamentTreeLeaf:getMyInfoInCurRound(today_round)
    local l_list = self.m_structTournament:getTournamentListByRound(today_round)
    local my_clan_id = g_clanWarData:getMyClanId()
    for idx, data in ipairs(l_list) do
        if (my_clan_id == data['clan_id']) then
            return data, idx
        end
    end
    return nil
end

-------------------------------------
-- function setLineConnectedToFinal
-------------------------------------
function UI_ClanWarTournamentTreeLeaf:setLineConnectedToFinal()
    self.vars['rightHorizontalSprite']:setVisible(true)
end

-------------------------------------
-- function setColorConnectedToFinal
-------------------------------------
function UI_ClanWarTournamentTreeLeaf:setColorConnectedToFinal()
    self.vars['rightHorizontalSprite']:setColor(WIN_COLOR)
end









-------------------------------------
-- class UI_ClanWarTournamentTreeListItem
-------------------------------------
UI_ClanWarTournamentTreeListItem = class(UI, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTreeListItem:init(round)
    local vars = self:load('clan_war_tournament_item_title.ui')
    vars['roundLabel']:setString(Str('{1}강', round) .. Str('({1})', g_clanWarData:getRoundOfWeekString(round)))
end

-------------------------------------
-- function setInProgress
-------------------------------------
function UI_ClanWarTournamentTreeListItem:setInProgress()
	local vars = self.vars
    vars['todaySprite']:setVisible(false)

	local round_text = vars['roundLabel']:getString()
	if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
        vars['todaySprite']:setVisible(true)
        vars['roundLabel']:setColor(COLOR['black'])
	end
	vars['roundLabel']:setString(round_text)
end
