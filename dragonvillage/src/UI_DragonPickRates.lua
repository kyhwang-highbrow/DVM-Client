local PARENT = UI

-------------------------------------
-- class UI_DragonPickRates
-------------------------------------
UI_DragonPickRates = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonPickRates:init(parent)
    if (not parent) then
        error('UI_DragonPickRates need a parent!!!')
        return 
    end

    self.root = parent
    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonPickRates:initUI()
    local node = self.root


    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 50)
    table_view:setCellUIClass(UI_ArenaNewTierInfoListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --table_view:setItemList(list)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonPickRates:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonPickRates:refresh()
end
