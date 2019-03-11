local PARENT = UI

-------------------------------------
-- class UI_BookEgg
-------------------------------------
UI_BookEgg = class(PARENT,{
        m_shortcutsFunc = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BookEgg:init()
    local vars = self:load('hatchery_incubate_info.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_BookEgg')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	self.m_uiName = 'UI_BookEgg'

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BookEgg:initUI()
    local vars = self.vars

    local node = self.vars['listNode']

	local item_list = TableSummonGacha:getSummonEggList()

    -- 생성 콜백
    local function make_func(data)
        local ui = UI_BookEggListItem(data)
        local egg_id = data['item_id']
        ui.vars['moveBtn']:registerScriptTapHandler(function() self:click_moveBtn(egg_id) end)

        return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1235, 100 + 3)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(item_list)

    -- 우선 순위로 정렬
    local function sort_func(a, b)
        local a_priority = a['data']['ui_priority']
        local b_priority = b['data']['ui_priority']
        return a_priority > b_priority
    end

    table.sort(table_view.m_itemList, sort_func)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BookEgg:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BookEgg:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_BookEgg:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_moveBtn
-- @brief 선택한 알 바로가기 
-------------------------------------
function UI_BookEgg:click_moveBtn(egg_id)
    if (self.m_shortcutsFunc) then
        self:close()
        self.m_shortcutsFunc(egg_id)
    end
end

--@CHECK
UI:checkCompileError(UI_BookEgg)
