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
function UI_DragonPickRates:init(parent, item_ui_name)
    if (not parent) then
        error('UI_DragonPickRates need a parent!!!')
        return 
    end

    self.root = parent
    UI_DragonPickRateItem.itemUIName = item_ui_name and item_ui_name or 'dmgate_rank_popup_stage_dragon_item.ui'

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
    local root_width, root_height = node:getNormalSize()
    
    -- 생성 시 함수
    local function create_func(ui, data)
    end

    table_view:setCellSizeToNodeSize(true)
    table_view:setGapBtwCells(5)
    table_view:setCellUIClass(UI_DragonPickRateItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))

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

    table.sort(item_list, function(a, b) return a['rank'] < b['rank'] end)

    self.m_tableView:setItemList(item_list, true)
    self.m_tableView:relocateContainerFirstFromIndex(1)
end

-------------------------------------
-- class UI_DragonPickRateItem
-------------------------------------
UI_DragonPickRateItem = class(PARENT, IRankListItem:getCloneTable(), {
        m_marginBtwLabelAndBar = 'number',
        m_dragonInfo = 'table',
        m_dragonStruct = 'StructDragonObject',
    })

-- 리스트 아이템 이름
UI_DragonPickRateItem.itemUIName = 'dmgate_rank_popup_stage_dragon_item.ui'

-------------------------------------
-- function init
-------------------------------------
function UI_DragonPickRateItem:init(t_dragon_info)
    self.m_dragonInfo = t_dragon_info
    self.m_marginBtwLabelAndBar = 10

    local t_data = {}
    t_data['did'] = t_dragon_info['did']
    if (not isJako(t_dragon_info['did'])) then
        t_data['evolution'] = 3
    end

    self.m_dragonStruct = StructDragonObject(t_data)

    self:load(UI_DragonPickRateItem.itemUIName)
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonPickRateItem:initUI()
    local vars = self.vars

    if (vars['rankLabel']) then
        local rank = self.m_dragonInfo['rank']
        if rank and tonumber(rank) > 0 then
            vars['rankLabel']:setString(Str('{1}위', comma_value(rank)))
        else
            vars['rankLabel']:setString('-')
        end
    end

    if (vars['dragonIconNode']) then
        --local icon = IconHelper:getDragonIconFromDid(self.m_dragonInfo['did'], 3, 1, 1)
        local card = UI_BookDragonCard(self.m_dragonStruct)
        card.root:setSwallowTouch(false)
        --icon:setScale(0.8)
        vars['dragonIconNode']:addChild(card.root)

        card.vars['clickBtn']:registerScriptPressHandler(function()
            UI_BookDetailPopup.openWithFrame(self.m_dragonInfo['did'], nil, 3, 0.8, true)
        end)
    end

    if (vars['dragonNameLabel']) then
        local name = TableDragon():getDragonName(self.m_dragonInfo['did'])

        vars['dragonNameLabel']:setString(name)
    end

    local percent = tonumber(self.m_dragonInfo['per'])

    if (vars['pickRateLabel']) then
        local pos_x = vars['pickRateLabel']:getPositionX()
        vars['pickRateLabel']:setPositionX(pos_x * percent * 0.01 + self.m_marginBtwLabelAndBar)
        vars['pickRateLabel']:setString(string.format('%.02f%%', percent))
    end

    if (vars['pickRateGauge']) then
        vars['pickRateGauge']:setPercentage(0)
        local duration = math_random(6, 8) * 0.1
        local action = cc.ProgressTo:create(duration, percent)
        vars['pickRateGauge']:runAction(action)
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