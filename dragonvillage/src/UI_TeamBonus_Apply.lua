-------------------------------------
-- class UI_TeamBonus_Apply
-------------------------------------
UI_TeamBonus_Apply = class({
        m_owner_ui = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonus_Apply:init(owner_ui)
    self.m_owner_ui = owner_ui
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_TeamBonus_Apply:onEnterTab(first)
    if (first) then
        self:initTableView()
    end
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_TeamBonus_Apply:initTableView()
    local vars = self.m_owner_ui.vars
    local node = vars['useListNode']

    local l_deck = self.m_owner_ui.m_selDeck or {}

    -- doid 리스트인지, dragon_struct 리스트인지 (내 덱이 아닌 경우)
    local is_struct_dragon = false
    for _, v in ipairs(l_deck) do
        if (v['id']) then
            is_struct_dragon = true
            break
        end
    end

    local l_teambonus = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck, is_struct_dragon)

    -- 생성 콜백
	local create_func = function(data)
		local ui = UI_TeamBonusListItem(data)
        ui.vars['selectSprite']:setVisible(true)
		return ui
    end

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1200, 130)
    table_view:setCellUIClass(create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_teambonus)
    table_view:makeDefaultEmptyMandragora(Str('적용중인 팀 보너스가 없다고라'))
end