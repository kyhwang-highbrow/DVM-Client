local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_EvolutionStoneCombine
-------------------------------------
UI_EvolutionStoneCombine = class(PARENT,{
        m_tableView = 'UIC_TableView',

        m_selMode = '',
        m_selID = 'number',
        m_selCard = 'table',
        m_selMulti = 'number',

        m_bUpdate = 'boolean',
        m_finishCB = 'function',
    })

local MODE = {
    COMBINE = 'combine',
    DIVISION = 'division',
}

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_EvolutionStoneCombine:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_EvolutionStoneCombine'
    self.m_bVisible = true
    self.m_titleStr = Str('조합/분해')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_EvolutionStoneCombine:init(item_id, finish_cb)
    local vars = self:load('evolution_stone_combine.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_finishCB = finish_cb

    -- 선택되지 않았다면 중급 진화의 보석 기본 선택
    self.m_selID = item_id or 701012 

    -- 가방에서 최하위 선택하고 들어온 경우 다음 단계로 처리
    if (self.m_selID % 10 == 1) then
        self.m_selID = self.m_selID + 1
    end

    self.m_selMulti = 1
    self.m_selCard = {}

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EvolutionStoneCombine')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EvolutionStoneCombine:initUI()
    self:init_mtrableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EvolutionStoneCombine:initButton()
    local vars = self.vars
    vars['plusBtn1']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['plusBtn2']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['minusBtn1']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['minusBtn2']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['combineBtn']:registerScriptTapHandler(function() self:click_combineBtn() end)
    vars['divisionBtn']:registerScriptTapHandler(function() self:click_divisionBtn() end)

    self:initTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EvolutionStoneCombine:refresh()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_EvolutionStoneCombine:initTab()
    local vars = self.vars
    self:addTabAuto(MODE.COMBINE, vars, vars['combineMenu'])
    self:addTabAuto(MODE.DIVISION, vars, vars['divisionMenu'])
    self:setTab(MODE.COMBINE)
end
-------------------------------------
-- function onChangeTab
-- @brief 모드 변경, 개수 초기화
-------------------------------------
function UI_EvolutionStoneCombine:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)
    self.m_selMode = tab
    self.m_selMulti = 1

    self:refresh_mtrIcon()
end

-------------------------------------
-- function init_mtrableView
-------------------------------------
function UI_EvolutionStoneCombine:init_mtrableView()
    local l_item_list = g_evolutionStoneData:getEvolutionStoneListWithType()
    local node = self.vars['listNode']

    -- 생성 콜백
    local function make_func(data)
        local click_func = function(item_id) self:click_mtrBtn(item_id) end
        return UI_EvolutionStoneCombineListItem(data, click_func)
    end

    local function create_func(ui, data)
        local btn_map = ui.m_btnMap
        if (btn_map[self.m_selID]) then
            self.m_selCard = btn_map[self.m_selID]
            self.m_selCard.vars['highlightSprite']:setVisible(true)
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(680, 104)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    local function default_sort_func(a, b)
        local a = a['unique_id']
        local b = b['unique_id']
        return a < b
    end
    table.sort(table_view.m_itemList, default_sort_func)

    self.m_tableView = table_view
end

-------------------------------------
-- function refresh_mtrTableView
-------------------------------------
function UI_EvolutionStoneCombine:refresh_mtrTableView(update)
    local item_list = self.m_tableView.m_itemList
    local combine_table = TableEvolutionItemCombine()

    local sel_id = self.m_selID
    local origin_id = self:getOriginID()
    local mode = self.m_selMode

    for _, v in ipairs(item_list) do
        local btn_map = v['ui'].m_btnMap

        if (btn_map[sel_id]) then
            local ori_card = btn_map[sel_id]
            ori_card.vars['highlightSprite']:setVisible(true)
            
            self.m_selCard = btn_map[sel_id]
        end

        -- count refesh option
        if (update) then
            local t_data 
            if (mode == MODE.COMBINE) then
                t_data = combine_table:getCombineTargetInfo(origin_id)

            elseif (mode == MODE.DIVISION) then
                t_data = combine_table:getDivisionTargetInfo(origin_id)
            end

            local origin_id = t_data['origin_item_id']
            if (btn_map[origin_id]) then
                local ori_card = btn_map[origin_id]
                local count = g_evolutionStoneData:getCount(origin_id)
                ori_card.vars['aniNumberLabel']:setNumber(count)
--                ori_card.vars['numberLabel']:setString(Str('{1}', comma_value(count)))
            end

            local target_id = t_data['target_item_id']
            if (btn_map[target_id]) then
                local tar_card = btn_map[target_id]
                local count = g_evolutionStoneData:getCount(target_id)
                tar_card.vars['aniNumberLabel']:setNumber(count)
--                tar_card.vars['numberLabel']:setString(Str('{1}', comma_value(count)))
            end
        end
    end
end

-------------------------------------
-- function getOriginID
-- @brief 조합인 경우 아래 단계가 재료가 됨
-------------------------------------
function UI_EvolutionStoneCombine:getOriginID()
    local sel_id = (self.m_selMode == MODE.COMBINE) and (self.m_selID - 1) or (self.m_selID)
    return sel_id
end

-------------------------------------
-- function getTargetNode
-------------------------------------
function UI_EvolutionStoneCombine:getTargetNode(node_name)
    local suffix = (self.m_selMode == MODE.COMBINE) and '1' or '2'
    return self.vars[node_name .. suffix]
end

-------------------------------------
-- function checkCondition
-------------------------------------
function UI_EvolutionStoneCombine:checkCondition(origin_id, need)
    local possible_color = cc.c3b(255, 215, 42)
    local impossible_color = cc.c3b(255, 0, 0)

    local current = g_evolutionStoneData:getCount(origin_id)

    local possible = (need <= current)
    self:getTargetNode('oriNumLabel'):setColor(possible and possible_color or impossible_color)
    self:getTargetNode('tarNumLabel'):setColor(possible and possible_color or impossible_color)

    self.vars['combineBtn']:setEnabled(possible)
    self.vars['divisionBtn']:setEnabled(possible)
end

-------------------------------------
-- function refresh_mtrIcon
-------------------------------------
function UI_EvolutionStoneCombine:refresh_mtrIcon()
    local vars = self.vars
    local mode = self.m_selMode
    local multi = self.m_selMulti

    local origin_id = self:getOriginID()
    local combine_table = TableEvolutionItemCombine()

    local t_data 
    if (mode == MODE.COMBINE) then
        t_data = combine_table:getCombineTargetInfo(origin_id)

    elseif (mode == MODE.DIVISION) then
        t_data = combine_table:getDivisionTargetInfo(origin_id)
    end

    if (not t_data) then return end

    -- target
    do
        local tarItemNode = self:getTargetNode('tarItemNode')
        tarItemNode:removeAllChildren()

        local target_id = t_data['target_item_id']
        local icon = IconHelper:getItemIcon(target_id)
        tarItemNode:addChild(icon)

        local nameLabel = self:getTargetNode('tarNameLabel')
        local name = TableItem:getItemName(target_id)
        nameLabel:setString(name)

        local numLabel = self:getTargetNode('tarNumLabel') 
        local cnt = t_data['target_item_count'] * multi
        numLabel:setString(Str('{1}개', cnt))
    end

    -- origin
    do
        local oriItemNode = self:getTargetNode('oriItemNode') 
        oriItemNode:removeAllChildren()

        local icon = IconHelper:getItemIcon(origin_id)
        oriItemNode:addChild(icon)

        local nameLabel = self:getTargetNode('oriNameLabel')
        local name = TableItem:getItemName(origin_id)
        nameLabel:setString(name)

        local numLabel = self:getTargetNode('oriNumLabel') 
        local cnt = t_data['origin_item_count'] * multi
        numLabel:setString(Str('{1}개', cnt))

        self:checkCondition(origin_id, cnt)
    end

    -- price
    do
        local price = t_data['req_gold'] * multi
        self:getTargetNode('priceLabel'):setString(Str('{1}', comma_value(price)))

        local price_icon = IconHelper:getPriceIcon('gold')
        self:getTargetNode('priceNode'):addChild(price_icon)
    end
end

-------------------------------------
-- function makeConfirmPopup
-------------------------------------
function UI_EvolutionStoneCombine:makeConfirmPopup(ok_cb)
    local mode = self.m_selMode
    local ori_name = self:getTargetNode('oriNameLabel'):getString()
    local ori_cnt = self:getTargetNode('oriNumLabel'):getString()
    local tar_name = self:getTargetNode('tarNameLabel'):getString()
    local tar_cnt = self:getTargetNode('tarNumLabel'):getString()

    local msg 
    if (mode == MODE.COMBINE) then
        msg = Str('{1} {@GOLD}{2}{@DESC}를 사용하여\n{3} {@GOLD}{4}{@DESC}를\n조합하시겠습니까?', ori_name, ori_cnt, tar_name, tar_cnt)

    elseif (mode == MODE.DIVISION) then
        msg = Str('{1} {@GOLD}{2}{@DESC}를\n{3} {@GOLD}{4}{@DESC}로\n분해하시겠습니까?', ori_name, ori_cnt, tar_name, tar_cnt)
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
end

-------------------------------------
-- function showEffect
-------------------------------------
function UI_EvolutionStoneCombine:showEffect()
    local block_ui = UI_BlockPopup()
    local vars = self.vars

    local bottom_node = self:getTargetNode('bottomVisual')
    bottom_node:setVisible(true)
    bottom_node:changeAni('success_bottom', false)
    bottom_node:addAniHandler(function()
        self.m_bUpdate = true

        self.m_selMulti = 1
        self:refresh_mtrIcon()
        self:refresh_mtrTableView(true)

        local msg = Str('{1}에 성공하였습니다.', (self.m_selMode == MODE.COMBINE) and '조합' or '분해')
        UIManager:toastNotificationGreen(msg)

        bottom_node:setVisible(false)
        block_ui:close()
    end)

    local top_node = self:getTargetNode('topVisual')
    top_node:setVisible(true)
    top_node:changeAni('success_top', false)
    top_node:addAniHandler(function()
        top_node:setVisible(false)
    end)
end

-------------------------------------
-- function click_mtrBtn
-------------------------------------
function UI_EvolutionStoneCombine:click_mtrBtn(item_id)
    if (self.m_selID == item_id) then
        return
    end

    -- 최하위 등급은 조합, 분해 선택 불가능
    if (item_id % 10 == 1) then
        local msg = Str('최하위 등급은 선택이 불가능합니다.')
        UIManager:toastNotificationRed(msg)
        return
    end

    if (self.m_selCard.vars) then
        self.m_selCard.vars['highlightSprite']:setVisible(false)
    end
    
    self.m_selID = item_id
    self:refresh_mtrIcon()
    self:refresh_mtrTableView()
end

-------------------------------------
-- function click_plusBtn
-------------------------------------
function UI_EvolutionStoneCombine:click_plusBtn()
    self.m_selMulti = self.m_selMulti + 1
    self:refresh_mtrIcon()
end

-------------------------------------
-- function click_minusBtn
-------------------------------------
function UI_EvolutionStoneCombine:click_minusBtn()
    if(self.m_selMulti <= 1) then return end 
    self.m_selMulti = self.m_selMulti - 1
    self:refresh_mtrIcon()
end

-------------------------------------
-- function click_combineBtn
-------------------------------------
function UI_EvolutionStoneCombine:click_combineBtn()
    local function ok_cb()
        g_evolutionStoneData:request_combine(self:getOriginID(), self.m_selMulti, function() self:showEffect() end)
    end

    self:makeConfirmPopup(ok_cb)
end

-------------------------------------
-- function click_divisionBtn
-------------------------------------
function UI_EvolutionStoneCombine:click_divisionBtn()
    local function ok_cb()
        g_evolutionStoneData:request_division(self:getOriginID(), self.m_selMulti, function() self:showEffect() end)
    end

    self:makeConfirmPopup(ok_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EvolutionStoneCombine:click_exitBtn()
    self:close()
    if (self.m_finishCB) then
        self.m_finishCB(self.m_bUpdate)
    end
end

--@CHECK
UI:checkCompileError(UI_EvolutionStoneCombine)
