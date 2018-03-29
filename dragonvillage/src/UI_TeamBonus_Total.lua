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

    -- 적용중인 팀보너스가 없을 경우 cell 하나 추가해줌
    local initail_tab = self.m_owner_ui.m_initail_tab 
    if (initail_tab == TEAM_BONUS_MODE.TOTAL) then
        local l_my_teambonus = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)
        if (#l_my_teambonus == 0) then
            local temp_data = {
                id = TEAMBONUS_EMPTY_TAG,
                skill_type = 'none',
            }

            local temp_struct_teambonus = StructTeamBonus(temp_data)
            temp_struct_teambonus.m_bSatisfy = true
            table.insert(l_teambonus, temp_struct_teambonus)
        end
    end

    -- 배치 기능 활성화 여부
    local b_recommend = self.m_owner_ui.m_bRecommend
    local node = vars['allListNode']
    node:removeAllChildren()

    local make_func = function(data)
        local ui = UI_TeamBonusListItem(data, b_recommend)
        local apply_func = function(l_dragon_list)
            if (not l_dragon_list) then return end
            self.m_owner_ui:applyDeck(l_dragon_list) 
        end
        ui:setCloseCB(apply_func)
       
        return ui
    end
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1200, 130)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_teambonus)

    local sort_mgr = SortManager_TeamBonus(b_recommend)
    sort_mgr:sortExecution(table_view.m_itemList)
end