local PARENT = UI

-------------------------------------
-- class UI_DragonPickRates
-------------------------------------
UI_DragonPickRates = class(PARENT,{
    m_tableView = 'UIC_TableView',
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

    local list = {
        {rank = 1, did = 120454, rate = 72},
        {rank = 2, did = 120221, rate = 65},
        {rank = 3, did = 120402, rate = 63},
        {rank = 4, did = 120505, rate = 61},
        {rank = 5, did = 120101, rate = 60},
        {rank = 6, did = 120564, rate = 47},
        {rank = 7, did = 120011, rate = 47},
        {rank = 8, did = 120732, rate = 43},
        {rank = 9, did = 120702, rate = 41},
        {rank = 10, did = 120625, rate = 36}
    }

    table.sort(list, function(a, b) return a['rank'] < b['rank'] end)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    local root_width, root_height = node:getNormalSize()

    table_view:setCellSizeToNodeSize(true)
    table_view:setGapBtwCells(5)
    table_view:setCellUIClass(UI_DragonPickRateItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.m_tableView = table_view
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


-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonPickRates:updateList(data)
    if (not data) or (not data['dragon_use_list']) then return end

    local item_list = data['dragon_use_list']

    self.m_tableView:setItemList(item_list, true)
end

-------------------------------------
-- class UI_DragonPickRateItem
-------------------------------------
UI_DragonPickRateItem = class(PARENT, IRankListItem:getCloneTable(), {
        m_dragonInfo = 'table',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_DragonPickRateItem:init(t_dragon_info)
    self.m_dragonInfo = t_dragon_info

    local vars = self:load('dmgate_rank_popup_stage_dragon_item.ui')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonPickRateItem:initUI()
    local vars = self.vars

    if (vars['rankLabel']) then
        vars['rankLabel']:setString(self.m_dragonInfo['rank'])
    end

    if (vars['dragonIconNode']) then
        local icon = IconHelper:getDragonIconFromDid(self.m_dragonInfo['did'], 3, 1, 1)
        icon:setScale(0.8)
        vars['dragonIconNode']:addChild(icon)
    end

    if (vars['dragonNameLabel']) then
        local name = TableDragon():getDragonName(self.m_dragonInfo['did'])

        vars['dragonNameLabel']:setString(name)
    end

    if (vars['pickRateLabel']) then
        vars['pickRateLabel']:setString(string.format('%s%%', tostring(self.m_dragonInfo['per'])))
    end

    if (vars['pickRateGauge']) then
        vars['pickRateGauge']:setPercentage(self.m_dragonInfo['per'])
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonPickRateItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonPickRateItem:refresh()
end