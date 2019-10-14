local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarListItem
-------------------------------------
UI_ClanWarListItem = class(PARENT, {

    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarListItem:init()
    local vars = self:load('clan_war_list_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarListItem:initButton()
	local vars = self.vars
	vars['stageBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
end

-------------------------------------
-- function click_startBtn
-------------------------------------
function UI_ClanWarListItem:click_startBtn()
    local finish_cb = function()
        UI_MatchReadyClanWar()
    end
    -- 임시로 아레나 통신 사용
    g_arenaData:request_arenaInfo(finish_cb)
end
