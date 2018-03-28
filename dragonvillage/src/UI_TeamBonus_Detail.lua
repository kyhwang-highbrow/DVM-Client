local PARENT = UI

-------------------------------------
-- class UI_TeamBonus_Detail
-------------------------------------
UI_TeamBonus_Detail = class(PARENT, {
        m_selDid = 'number',
        m_closeCB = 'function',
        m_owner_ui = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonus_Detail:init(owener_ui, did)
    local vars = self:load('team_bonus_dragon.ui')

    self.m_owner_ui = owener_ui
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
    -- 배치 기능 활성화 여부
    local b_recommend = self.m_owner_ui.m_bRecommend
    local node = vars['dragonListNode2']
    node:removeAllChildren()

    local make_func = function(data)
        local apply_func
        if (b_recommend) then
            apply_func = function(l_dragon_list)
                self.m_owner_ui:applyDeck(l_dragon_list) 
            end
        end
       
        return UI_TeamBonusListItem(data, b_recommend, apply_func)
    end

    local did = self.m_selDid
    local l_teambonus = TeamBonusHelper:getTeamBonusDataFromDid(did)
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1200, 130)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_teambonus)

    local sort_mgr = SortManager_TeamBonus(b_recommend)
    sort_mgr:sortExecution(table_view.m_itemList)
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