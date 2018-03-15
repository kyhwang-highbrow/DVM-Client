local PARENT = UI

-------------------------------------
-- class UI_TeamBonus_Detail
-------------------------------------
UI_TeamBonus_Detail = class(PARENT, {
        m_selDid = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonus_Detail:init(did)
    local vars = self:load('team_bonus_dragon.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_dragonListBtn() end, 'UI_TeamBonus')

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

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1200, 130)
    table_view:setCellUIClass(UI_TeamBonusListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_teambonus)
end

-------------------------------------
-- function click_dragonListBtn
-------------------------------------
function UI_TeamBonus_Detail:click_dragonListBtn()
    self:close()
end