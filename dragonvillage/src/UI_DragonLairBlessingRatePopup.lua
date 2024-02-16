local PARENT = UI

-------------------------------------
-- class UI_DragonLairBlessingRatePopup
-------------------------------------
UI_DragonLairBlessingRatePopup = class(PARENT,{
    m_specialAbilityStr = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingRatePopup:init(str)
    local vars = self:load('dragon_lair_blessing_rate.ui')
    self.m_specialAbilityStr = str
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairBlessingRatePopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLairBlessingRatePopup:initUI()
    local vars = self.vars
    local list = 
    {
        { -- 일반 축복
            {['step'] = 1, ['rate'] = 100},
            {['step'] = 2, ['rate'] = 100},
            {['step'] = 3, ['rate'] = 100},
            {['step'] = 4, ['rate'] = 100},
            {['step'] = 5, ['rate'] = 100},
            {['step'] = 6, ['rate'] = 100},
            {['step'] = 7, ['rate'] = 100},        
            {['step'] = 8, ['rate'] = 100},
            {['step'] = 9, ['rate'] = 100},
            {['step'] = 10, ['rate'] = 100},
            {['step'] = 11, ['rate'] = 100},
            {['step'] = 12, ['rate'] = 100},
            {['step'] = 13, ['rate'] = 100},
            {['step'] = 14, ['rate'] = 100},
            {['step'] = 15, ['rate'] = 100},
            {['step'] = 16, ['rate'] = 100},
            {['step'] = 17, ['rate'] = 100},
            {['step'] = 18, ['rate'] = 100},
            {['step'] = 19, ['rate'] = 100},
            {['step'] = 20, ['rate'] = 100},
        },

        { -- 특화 시즌 축복
            {['step'] = 1, ['rate'] = 100},
            {['step'] = 2, ['rate'] = 100},
            {['step'] = 3, ['rate'] = 100},
            {['step'] = 4, ['rate'] = 100},
            {['step'] = 5, ['rate'] = 100},
            {['step'] = 6, ['rate'] = 100},
            {['step'] = 7, ['rate'] = 100},        
            {['step'] = 8, ['rate'] = 100},
            {['step'] = 9, ['rate'] = 100},
            {['step'] = 10, ['rate'] = 100},
            {['step'] = 11, ['rate'] = 100},
            {['step'] = 12, ['rate'] = 100},
            {['step'] = 13, ['rate'] = 100},
            {['step'] = 14, ['rate'] = 100},
            {['step'] = 15, ['rate'] = 100},
            {['step'] = 16, ['rate'] = 100},
            {['step'] = 17, ['rate'] = 100},
            {['step'] = 18, ['rate'] = 100},
            {['step'] = 19, ['rate'] = 100},
            {['step'] = 20, ['rate'] = 100},
            {['step'] = 21, ['rate'] = 100},
            {['step'] = 22, ['rate'] = 100},
            {['step'] = 23, ['rate'] = 100},
            {['step'] = 24, ['rate'] = 100},
            {['step'] = 25, ['rate'] = 100},
            {['step'] = 26, ['rate'] = 100},
            {['step'] = 27, ['rate'] = 100},
            {['step'] = 28, ['rate'] = 100},
            {['step'] = 29, ['rate'] = 100},
            {['step'] = 30, ['rate'] = 100},
        }
    }

    for i, v in ipairs(list) do
        self:makeTableView(string.format('%dListNode', i), v)
    end

    do
        local option = g_lairData:getLairSeasonOption()
        local table_status = TableStatus()
        
        local str_list = plSplit(option, '_')
        option = str_list[1]

        local season_color = g_lairData:getLairSeasonColor()
        local name = table_status:getValue(option, 't_name')

        local rate_str = Str('{1} 확률', Str(name))
        local str = string.format('{@%s}<%s>{@}', season_color, rate_str)
        vars['specialLabel']:setString(str)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonLairBlessingRatePopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
--- @function makeTableView
-------------------------------------
function UI_DragonLairBlessingRatePopup:makeTableView(node_name, item_list)
    local vars = self.vars
    local node = vars[node_name]
    node:removeAllChildren()

    local make_func = function()
        local ui_class = class(UI, ITableViewCell:getCloneTable(), {})
        local ui = ui_class()
        ui:load('dragon_lair_blessing_rate_item.ui')
        return ui
    end

    local idx = 1
    local create_func = function(ui, data)
        ui.vars['stepLabel']:setString(Str('{1}단계', data['step']))
        ui.vars['rateLabel']:setString(string.format('%0.2f%%', data['rate']))        
        local odd_num = idx % 2 == 0 and 1 or 2

        local str_1 = string.format('color%02d%02d', odd_num ,1)
        local str_2 = string.format('color%02d%02d', odd_num ,2)

        ui.vars[str_1]:setVisible(true)
        ui.vars[str_2]:setVisible(true)
        idx = idx + 1
    end

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(555, 44)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setCellCreateDirecting(nil)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(item_list, true)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLairBlessingRatePopup:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonLairBlessingRatePopup:click_closeBtn()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_DragonLairBlessingRatePopup)
