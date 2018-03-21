-------------------------------------
-- class UI_TeamBonus_Total
-------------------------------------
UI_TeamBonus_Total = class({
        m_owner_ui = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonus_Total:init(owner_ui)
    self.m_owner_ui = owner_ui
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_TeamBonus_Total:onEnterTab(first)
    if (first) then
        self:initTableView()
    end
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_TeamBonus_Total:initTableView(only_my_team)
    local vars = self.m_owner_ui.vars
    local only_my_team = only_my_team or false
    local l_deck = self.m_owner_ui.m_selDeck or {}

    local l_teambonus
    if (only_my_team) then
        l_teambonus = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck) 
    else
        l_teambonus = TeamBonusHelper:getAllTeamBonusDataFromDeck(l_deck) 
    end

    local l_my_teambonus = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

    -- 적용중인 팀보너스가 없을 경우 cell 하나 추가해줌
    local initail_tab = self.m_owner_ui.m_initail_tab 
    if (initail_tab == TEAM_BONUS_MODE.TOTAL) and (#l_my_teambonus == 0) then
        local temp_data = {
            id = 0,
            skill_type = 'none',
        }

        local temp_struct_teambonus = StructTeamBonus(temp_data)
        temp_struct_teambonus.m_bSatisfy = true
        table.insert(l_teambonus, temp_struct_teambonus)
    end

    -- 적용중인 팀보너스 위로
    table.sort(l_teambonus, function(a, b)
		local a_value = a:isSatisfied() and 99 or 0
		local b_value = b:isSatisfied() and 99 or 0

		if (a_value == b_value) then
			local a_priority = a.m_priority or 0
			local b_priority = b.m_priority or 0
			return a_priority > b_priority
		else
			return a_value > b_value
		end
	end)

    local node = vars['allListNode']
    node:removeAllChildren()

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1200, 130)
    table_view:setCellUIClass(UI_TeamBonusListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_teambonus)
end