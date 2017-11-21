local PARENT = UI

-------------------------------------
-- class UI_DiceEvent
-------------------------------------
UI_DiceEvent = class(PARENT,{
        m_container = 'ScrolView Container',

        m_cellUIList = 'table<ui>',
        m_lapRewardInfoList = 'table<ui, data>',

        m_selectedCellUI = 'UI temporary',
        m_selectAnimator = 'Animator',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DiceEvent:init()
    local vars = self:load('event_dice.ui')

    -- initailze 
    self.m_cellUIList = {}
    self.m_lapRewardInfoList = {}
    self.m_selectedCellUI = nil
    self.m_container = nil

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DiceEvent:initUI()
    local vars = self.vars
                
    -- make select sprite
    local res = 'res/ui/a2d/event_dice/event_dice.vrp'
    local select_ani = MakeAnimator(res)
    vars['boardNode']:addChild(select_ani.m_node)
    self.m_selectAnimator = select_ani

    -- cell list
    local cell_list = g_eventDiceData:getCellList()
    for i, t_cell in ipairs(cell_list) do
        local ui = self.makeCell(t_cell)
        vars['node' .. i]:addChild(ui.root)
        self.m_cellUIList[i] = ui
    end

    -- lap list
    local lap_list = g_eventDiceData:getLapList()
    for i, t_lap in ipairs(lap_list) do
        if (vars['rewardMenu' .. i]) then
            local ui = self.makeLap(t_lap)
            vars['rewardMenu' .. i]:addChild(ui.root)
            self.m_lapRewardInfoList[i] = {
                ['ui'] = ui,
                ['data'] = t_lap
            }
        end
    end

    -- 남은 시간 
    vars['timeLabel']:setString(g_eventDiceData:getStatusText())
    
    local dice_info = g_eventDiceData:getDiceInfo()
    do
        -- 모험
        local state_desc = dice_info:getObtainingStateDesc('adv')
        vars['obtainLabel1']:setString(state_desc)

        -- 던전
        state_desc = dice_info:getObtainingStateDesc('dungeon')
        vars['obtainLabel2']:setString(state_desc)

        -- 콜로세움
        state_desc = dice_info:getObtainingStateDesc('pvp')
        vars['obtainLabel3']:setString(state_desc)

        -- 탐험
        state_desc = dice_info:getObtainingStateDesc('explore')
        vars['obtainLabel4']:setString(state_desc)

        -- 일일 총합
        state_desc = dice_info:getTodayObtainingDesc()
        vars['obtainLabel5']:setString(state_desc)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DiceEvent:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DiceEvent:refresh()
    local vars = self.vars
    
    -- 필요 정보
    local dice_info = g_eventDiceData:getDiceInfo()
    local curr_dice = dice_info:getCurrDice()
    local curr_cell = dice_info:getCurrCell()
    local lap_cnt = dice_info:getCurrLapCnt()
    local curr_cell_ui = self.m_cellUIList[curr_cell]

    -- 주사위 갯수
    vars['diceLabel']:setString(curr_dice)

    -- 현재 완주 횟수
    vars['lapLabel']:setString(Str('{1}회', lap_cnt))

    -- 셀렉트 처리
    self:selectCell(curr_cell_ui)
    self.m_selectedCellUI = curr_cell_ui

    -- 최초 출발 처리
    if (curr_cell == 1) and (lap_cnt == 0) then
        curr_cell_ui.vars['startSprite']:setVisible(true)
    end

    -- 완주 보상 UI 처리
    for i, t_ui in ipairs(self.m_lapRewardInfoList) do
        self.refershLap(t_ui['ui'], t_ui['data'], lap_cnt)
    end
end

-------------------------------------
-- function selectCell
-------------------------------------
function UI_DiceEvent:selectCell(cell_ui)
    local pos_x, pos_y = cell_ui.root:getPosition()
    local duration = 0.5
    local move = cca.makeBasicEaseMove(duration, pos_x, pos_y)

    self.m_selectAnimator:runAction(move)
end

-------------------------------------
-- function setContainer
-------------------------------------
function UI_DiceEvent:setContainer(container)
    self.m_container = container
end









-------------------------------------
-- function makeCell
-- @static
-------------------------------------
function UI_DiceEvent.makeCell(t_data)
    local ui = UI()
    local vars = ui:load('event_dice_item.ui')

    -- 선택 표시
    vars['selectSprite']:setVisible(false)
    
    -- 보상 아이콘
    local item_id = t_data['item_id']
    local res = TableItem:getItemIcon(item_id)
    local icon = IconHelper:getIcon(res)
    vars['iconNode']:addChild(icon)

    -- 보상 수량
    local value = t_data['value']
    vars['quantityLabel']:setString(value)

    -- 터치시 툴팁
    vars['clickBtn']:registerScriptTapHandler(function()
        local desc = TableItem:getToolTipDesc(item_id)
        local tool_tip = UI_Tooltip_Skill(70, -145, desc)
        tool_tip:autoPositioning(vars['clickBtn'])
    end)

    return ui
end

-------------------------------------
-- function makeLap
-- @static
-------------------------------------
function UI_DiceEvent.makeLap(t_data)
    local ui = UI()
    local vars = ui:load('event_dice_reward_item.ui')
    ccdump(t_data)

    -- 보상 아이콘
    local gap = 30
    local ft = gap/2
    local l_reward = t_data['l_reward']
    local reward_cnt = #l_reward
    local item_id, res, icon, pos_x, value
    local l_item_id_list = {}
    for i, t_reward in ipairs(l_reward) do
        item_id = t_reward['item_id']
        value = t_reward['value']
        res = TableItem:getItemIcon(item_id)
        icon = IconHelper:getIcon(res)
        vars['rewardNode']:addChild(icon)

        -- 보상 갯수에 따라 위치 조정
        pos_x = (gap * i) - (ft + (ft * reward_cnt))
        icon:setPositionX(pos_x)

        table.insert(l_item_id_list, item_id)
    end

    -- 상품 수량은 표기하기 애매한데?
    if (value > 1) then
        vars['rewardLabel']:setString(value)
    else
        vars['rewardLabel']:setString('')
    end

    -- 0회차
    local lap = t_data['lap']
    vars['timeLabel']:setString(Str('{1}회차', lap))

    -- 터치시 툴팁
    vars['clickBtn']:registerScriptTapHandler(function()
        local desc = ''
        for i, item_id in ipairs(l_item_id_list) do
            desc = desc .. TableItem:getToolTipDesc(item_id) .. '\n'
        end

        local tool_tip = UI_Tooltip_Skill(70, -145, desc)
        tool_tip:autoPositioning(vars['clickBtn'])
    end)

    return ui
end

-------------------------------------
-- function refershLap
-- @static
-------------------------------------
function UI_DiceEvent.refershLap(lap_ui, t_lap, curr_lap)
    local lap = t_lap['lap']
    local is_recieve = t_lap['is_recieve']

    if (lap > curr_lap) or (is_recieve) then
        lap_ui.vars['rewardBtn']:setEnabled(false)
    end
end
