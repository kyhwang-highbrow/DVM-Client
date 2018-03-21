local PARENT = UI

-------------------------------------
-- class UI_TeamBonus_Detail
-------------------------------------
UI_TeamBonus_Detail = class(PARENT, {
        m_selDid = 'number',
        m_closeCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonus_Detail:init(did)
    local vars = self:load('team_bonus_dragon.ui')

    self.m_selDid = did
    self:initUI()
    self:initTableView()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TeamBonus_Detail:initUI()
    local vars = self.vars
    local did = self.m_selDid
    local name = TableDragon:getDragonName(did)
    vars['dragonLabel']:setString(name)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TeamBonus_Detail:initButton()
    local vars = self.vars
    vars['dragonListBtn']:registerScriptTapHandler(function() self:click_dragonListBtn() end)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_TeamBonus_Detail:initTableView()
    if (not self.m_selDid) then
        return
    end

    local vars = self.vars
    local node = vars['dragonListNode2']
    node:removeAllChildren()

    local did = self.m_selDid
    local l_teambonus = TeamBonusHelper:getTeamBonusDataFromDid(did)

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

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1200, 130)
    table_view:setCellUIClass(UI_TeamBonusListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_teambonus)
end

-------------------------------------
-- function setCloseCB
-------------------------------------
function UI_TeamBonus_Detail:setCloseCB(func)
    self.m_closeCB = func
end

-------------------------------------
-- function click_dragonListBtn
-------------------------------------
function UI_TeamBonus_Detail:click_dragonListBtn()
    self.root:removeFromParent()

    if (self.m_closeCB) then
        self.m_closeCB()
    end
end