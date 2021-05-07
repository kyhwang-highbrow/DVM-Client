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

    local list = {
        {did = 120454, rate = math.random(0, 50)},
        {did = 120221, rate = math.random(0, 50)},
        {did = 120402, rate = math.random(0, 50)},
        {did = 120505, rate = math.random(0, 50)},
        {did = 120101, rate = math.random(0, 30)},
        {did = 120564, rate = math.random(0, 30)},
        {did = 120011, rate = math.random(0, 30)},
        {did = 120732, rate = math.random(0, 20)},
        {did = 120702, rate = math.random(0, 10)},
        {did = 120625, rate = math.random(0, 10)}
    }

    table.sort(list, function(a, b) return a['rate'] > b['rate'] end)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    --table_view.m_defaultCellSize = cc.size(720, 50)
    table_view:setCellUIClass(UI_DragonPickRateItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(list)
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

    local vars = self:load('dragon_pick_rate_item.ui')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonPickRateItem:initUI()
    local vars = self.vars

    if (vars['dragonIconNode']) then
        local icon = IconHelper:getDragonIconFromDid(self.m_dragonInfo['did'], 3, 1, 1)
        icon:setScale(0.33)
        vars['dragonIconNode']:addChild(icon)
    end

    if (vars['dragonNameLabel']) then
        local name = TableDragon():getDragonName(self.m_dragonInfo['did'])

        vars['dragonNameLabel']:setString( string.format('%s (%s%%)', name, tostring(self.m_dragonInfo['rate'])) )
    end

    if (vars['pickRateGauge']) then
        vars['pickRateGauge']:setPercentage(self.m_dragonInfo['rate'])
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