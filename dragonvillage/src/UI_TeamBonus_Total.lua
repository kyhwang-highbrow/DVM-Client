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
function UI_TeamBonus_Total:initTableView()
    local vars = self.m_owner_ui.vars

    local l_deck = self.m_owner_ui.m_selDeck or {}
    local is_struct_dragon = false
    for _, v in ipairs(l_deck) do
        if (v['id']) then
            is_struct_dragon = true
            break
        end
    end

    local l_teambonus = TeamBonusHelper:getAllTeamBonusDataFromDeck(l_deck, is_struct_dragon)

    -- 적용 중인 팀보너스 위로
    table.sort(l_teambonus, function(a, b)
		local a_value = a:isSatisfied() and 99 or 0
		local b_value = b:isSatisfied() and 99 or 0

		if (a_value == b_value) then
			local a_id = a.m_id
			local b_id = b.m_id
			return a_id < b_id
		else
			return a_value > b_value
		end
	end)

    local node = vars['allListNode']
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1200, 130)
    table_view:setCellUIClass(UI_TeamBonusListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_teambonus)
end