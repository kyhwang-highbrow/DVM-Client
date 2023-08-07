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
        m_selDragonData = '',
        m_quantityBtnPress = 'UI_CntBtnPress',
        m_bUpdate = 'boolean',
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
function UI_EvolutionStoneCombine:init(item_id, dragon_data)
    local vars = self:load('evolution_stone_combine.ui')
    UIManager:open(self, UIManager.POPUP)

    -- 선택되지 않았다면 중급 진화의 보석 기본 선택
    self.m_selID = item_id or 701012 
    self.m_selDragonData = dragon_data

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
    local vars = self.vars

    local cnt_func = function ()
        return self.m_selMulti
    end

    local cond_func = function (next_count)
        local origin_id = self:getOriginID()
        local need = self:getOriginCnt(origin_id, next_count)
        local curr_cnt = g_evolutionStoneData:getCount(origin_id)
        if (need > curr_cnt) then
            UIManager:toastNotificationRed(Str('진화재료가 부족합니다.'))
            return false
        end

        if(next_count <= 0) then 
            return false
        end

        self.m_selMulti = next_count
        self:refresh_mtrIcon()
        return true
    end

    self.m_quantityBtnPress = UI_CntBtnPress(self, cnt_func, cond_func)
    self:init_mtrableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EvolutionStoneCombine:initButton()
    local vars = self.vars
    vars['plusBtn1']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['plusBtn2']:registerScriptTapHandler(function() self:click_plusBtn() end)

    vars['plusBtn1']:registerScriptPressHandler(function() self:press_quantityBtn(1, true) end)
    vars['plusBtn2']:registerScriptPressHandler(function() self:press_quantityBtn(2, true) end)

    vars['minusBtn1']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['minusBtn2']:registerScriptTapHandler(function() self:click_minusBtn() end)

    vars['minusBtn1']:registerScriptPressHandler(function() self:press_quantityBtn(1, false) end)
    vars['minusBtn2']:registerScriptPressHandler(function() self:press_quantityBtn(2, false) end)

    vars['combineBtn']:registerScriptTapHandler(function() self:click_combineBtn() end)
    vars['divisionBtn']:registerScriptTapHandler(function() self:click_divisionBtn() end)

    self:initTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EvolutionStoneCombine:refresh()
    self:refresh_dragonMtrCount()
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
-- function setTab
-- @brief 최상위, 최하위 분해 조합 불가능한 경우는 탭 안되게 
-------------------------------------
function UI_EvolutionStoneCombine:setTab(tab, force)
    if (not self:check_possible(self.m_selID, tab)) then
        return
    end
    PARENT.setTab(self, tab, force)
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
        if v['ui'] then
            local btn_map = v['ui'].m_btnMap

            if (btn_map[sel_id]) then
                local ori_card = btn_map[sel_id]
                ori_card.vars['highlightSprite']:setVisible(true)
                
                self.m_selCard = btn_map[sel_id]
            end

            -- count refesh option
            if (update) then
                local t_data = self:getCombineData()

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
end

-------------------------------------
-- function getOriginID
-- @brief 조합인 경우 아래 단계가 재료가 됨, 분해인 경우 윗 단계가 재료가 됨
-------------------------------------
function UI_EvolutionStoneCombine:getOriginID()
    local sel_id = (self.m_selMode == MODE.COMBINE) and (self.m_selID - 1) or (self.m_selID + 1)
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
    self.vars['combineBtn']:setEnabled(possible)
    self.vars['divisionBtn']:setEnabled(possible)
end

-------------------------------------
-- function getOriginCnt
-------------------------------------
function UI_EvolutionStoneCombine:getOriginCnt(origin_id, multi)
    local origin_id = origin_id or self:getOriginID()
    local combine_table = TableEvolutionItemCombine()
    local mode = self.m_selMode

    local t_data = self:getCombineData()

    local origin_cnt = t_data['origin_item_count'] * multi
    return origin_cnt
end

-------------------------------------
-- function refresh_mtrIcon
-------------------------------------
function UI_EvolutionStoneCombine:refresh_mtrIcon()
    local vars = self.vars
    local mode = self.m_selMode
    local multi = self.m_selMulti

    local origin_id = self:getOriginID()
    local t_data = self:getCombineData()

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
        local target_str = (self.m_selMode == MODE.COMBINE) and Str('조합') or Str('분해')
        numLabel:setString(string.format('{@user_title}%s {@possible}x%s', target_str, comma_value(cnt)))

        local beforeLabel = self:getTargetNode('tarNumBeforeLabel')
        local before_cnt = g_evolutionStoneData:getCount(target_id)
        beforeLabel:setString(comma_value(before_cnt))

        local afterLabel = self:getTargetNode('tarNumAfterLabel')
        local after_cnt = math_max(0, before_cnt + cnt)
        afterLabel:setString(comma_value(after_cnt))
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
        numLabel:setString(Str('{@dark_brown}재료 사용 {@possible}x{1}', cnt))

        local beforeLabel = self:getTargetNode('oriNumBeforeLabel')
        local before_cnt = g_evolutionStoneData:getCount(origin_id)
        beforeLabel:setString(comma_value(before_cnt))

        local afterLabel = self:getTargetNode('oriNumAfterLabel')
        local after_cnt = math_max(0, before_cnt - cnt)
        afterLabel:setString(comma_value(after_cnt))

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
-- function refresh_dragonMtrCount
-------------------------------------
function UI_EvolutionStoneCombine:refresh_dragonMtrCount()
    local vars = self.vars
    local t_dragon_data = self.m_selDragonData
    if (not t_dragon_data) then 
        vars['combineMenu2']:setPositionY(10)
        vars['divisionMenu2']:setPositionY(10)
        return 
    end

    vars['itemNode']:setVisible(true)

    local table_item = TableItem()
    local did = t_dragon_data['did']
    local table_dragon_evolution = TABLE:get('dragon_evolution')
    local t_dragon_evolution = table_dragon_evolution[did]

    local evolution = t_dragon_data['evolution'] + 1
    local evolution_str = ''
    if (evolution == 2) then
        evolution_str = 'hatchling'
    elseif (evolution == 3) then
        evolution_str = 'adult'
    else
        error('evolution : ' .. evolution)
    end

    for i = 1,3 do
        local item_id = t_dragon_evolution[evolution_str .. '_item' .. i]
        local item_value = t_dragon_evolution[evolution_str .. '_value' .. i]

        do -- 진화재료 아이콘
            vars['itemNode' .. i]:removeAllChildren()
            local item_icon = IconHelper:getItemIcon(item_id)
            vars['itemNode' .. i]:addChild(item_icon)
        end
        
        do -- 바로가기 버튼
            vars['itemBtn' .. i]:registerScriptTapHandler(function() self:click_mtrBtn(item_id) end)
        end

        do -- 갯수 체크
            local req_count = item_value
            local own_count = g_userData:get('evolution_stones', tostring(item_id)) or 0
            local str = Str('{1} / {2}', own_count, req_count)

            if (req_count <= own_count) then
                str = '{@possible}' .. str
            else
                str = '{@impossible}' .. str
            end

            vars['itemLabel' .. i]:setString(str)
        end
    end
end

-------------------------------------
-- function makeConfirmPopup
-------------------------------------
function UI_EvolutionStoneCombine:makeConfirmPopup(ok_cb)
    local mode = self.m_selMode
    local multi = self.m_selMulti

    local t_data = self:getCombineData()
    local ori_name = self:getTargetNode('oriNameLabel'):getString()
    local ori_cnt = string.format('x%d', t_data['origin_item_count'] * multi)
    local tar_name = self:getTargetNode('tarNameLabel'):getString()
    local tar_cnt = string.format('x%d', t_data['target_item_count'] * multi)

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

    local top_node = self:getTargetNode('topVisual')
    top_node:setVisible(true)
    top_node:changeAni('stone_top', false)
    top_node:addAniHandler(function()
        self.m_bUpdate = true

        self.m_selMulti = 1
        self:refresh_mtrIcon()
        self:refresh_mtrTableView(true)
        self:refresh_dragonMtrCount()

        local msg = Str('{1}에 성공하였습니다.', (self.m_selMode == MODE.COMBINE) and Str('조합') or Str('분해'))
        UIManager:toastNotificationGreen(msg)

        top_node:setVisible(false)
        block_ui:close()
    end)
end

-------------------------------------
-- function click_mtrBtn
-------------------------------------
function UI_EvolutionStoneCombine:click_mtrBtn(item_id)
    if (self.m_selID == item_id) then
        return
    end

    if (not self:check_possible(item_id)) then
        return
    end

    if (self.m_selCard.vars) then
        self.m_selCard.vars['highlightSprite']:setVisible(false)
    end
    
    self.m_selID = item_id
    self.m_selMulti = 1
    self:refresh_mtrIcon()
    self:refresh_mtrTableView()
end

-------------------------------------
-- function check_possible
-------------------------------------
function UI_EvolutionStoneCombine:check_possible(item_id, mode)
    local mode = mode or self.m_selMode

    -- 최하위 등급 - 조합 불가능
    if (item_id % 10 == 1) and (mode == MODE.COMBINE) then
        local msg = Str('최하위 등급은 조합으로 획득할 수 없습니다.')
        UIManager:toastNotificationRed(msg)
        return false
    end

    -- 최상위 등급 - 분해 불가능
    if (item_id % 10 == 4) and (mode == MODE.DIVISION) then
        local msg = Str('최상위 등급은 분해로 획득할 수 없습니다.')
        UIManager:toastNotificationRed(msg)
        return false
    end

    return true
end

-------------------------------------
-- function getCombineData
-------------------------------------
function UI_EvolutionStoneCombine:getCombineData()
    local mode = self.m_selMode
    local origin_id = self:getOriginID()
    local combine_table = TableEvolutionItemCombine()
    local t_data 
    if (mode == MODE.COMBINE) then
        t_data = combine_table:getCombineTargetInfo(origin_id)

    elseif (mode == MODE.DIVISION) then
        t_data = combine_table:getDivisionTargetInfo(origin_id)
    end

    return t_data
end

-------------------------------------
-- function click_plusBtn
-------------------------------------
function UI_EvolutionStoneCombine:click_plusBtn()
    local origin_id = self:getOriginID()
    local add_multi = self.m_selMulti + 1
    local need = self:getOriginCnt(origin_id, add_multi)
    local curr_cnt = g_evolutionStoneData:getCount(origin_id)
    if (need > curr_cnt) then
        UIManager:toastNotificationRed(Str('진화재료가 부족합니다.'))
        return
    end

    self.m_selMulti = add_multi
    self:refresh_mtrIcon()
end

-------------------------------------
-- function click_minusBtn
-------------------------------------
function UI_EvolutionStoneCombine:click_minusBtn()
    local origin_id = self:getOriginID()
    local sub_multi = self.m_selMulti - 1
    local need = self:getOriginCnt(origin_id, sub_multi)
    local curr_cnt = g_evolutionStoneData:getCount(origin_id)
    if (need > curr_cnt) then
        UIManager:toastNotificationRed(Str('진화재료가 부족합니다.'))
        return
    end

    if(self.m_selMulti <= 1) then return end 

    self.m_selMulti = sub_multi
    self:refresh_mtrIcon()
end


-------------------------------------
-- function press_quantityBtn
-- @param is_add 수량에 더할지 뺄지 결정
-------------------------------------
function UI_EvolutionStoneCombine:press_quantityBtn(idx, is_add)
	local vars = self.vars

    local quantity_btn
    if (is_add) then
        quantity_btn = vars[string.format('plusBtn%d', idx)]
    else
        quantity_btn = vars[string.format('minusBtn%d', idx)]
    end

    self.m_quantityBtnPress:quantityBtnPressHandler(quantity_btn, is_add and 1 or -1)
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
    if (not self.m_bUpdate) then
        self:setCloseCB(nil)
    end
end

--@CHECK
UI:checkCompileError(UI_EvolutionStoneCombine)
