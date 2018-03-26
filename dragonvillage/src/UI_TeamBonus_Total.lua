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
                id = 0,
                skill_type = 'none',
            }

            local temp_struct_teambonus = StructTeamBonus(temp_data)
            temp_struct_teambonus.m_bSatisfy = true
            table.insert(l_teambonus, temp_struct_teambonus)
        end
    end

    -- 덱이 설정되었다면 추천 기능 활성화
    local b_recommend = (self.m_owner_ui.m_selDeck) and true or false
    local node = vars['allListNode']
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

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1200, 130)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_teambonus)

    local sort_mgr = SortManager_TeamBonus(b_recommend)
    sort_mgr:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()
end