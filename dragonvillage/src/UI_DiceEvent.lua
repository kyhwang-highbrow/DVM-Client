local PARENT = UI

-------------------------------------
-- class UI_DiceEvent
-------------------------------------
UI_DiceEvent = class(PARENT,{
        m_container = 'ScrolView Container',
        m_containerTopPosY = 'number',
        m_isContainerMoving = 'bool',

        m_cellUIList = 'table<ui>',
        m_lapRewardInfoList = 'table<ui, data>',

        m_selectAnimator = 'Animator',
        m_rollAnimator = 'Animator',
        m_maskingUI = 'UI',
        
        m_coroutineHelper = 'CoroutineHelper',
        m_directingState = 'number',
        m_destCell = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DiceEvent:init()
    local vars = self:load('event_dice.ui')

    -- initailze 
    self.m_cellUIList = {}
    self.m_lapRewardInfoList = {}
    self.m_container = nil
    self.m_containerTopPosY = nil
    self.m_isContainerMoving = false
    self.m_selectAnimator = nil
    self.m_rollAnimator = nil
    self.m_maskingUI = nil

    self.m_coroutineHelper = nil
    self.m_directingState = 0
    self.m_destCell = 0

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DiceEvent:initUI()
    local vars = self.vars

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
                    
    -- make select sprite
    local res = 'res/ui/a2d/event_dice/event_dice.vrp'
    local select_ani = MakeAnimator(res)
    local curr_cell = dice_info:getCurrCell()
    local pos_x, pos_y = self.vars['node' .. curr_cell]:getPosition()
    select_ani:setPosition(pos_x, pos_y)
    select_ani:changeAni('select', true)
    vars['boardNode']:addChild(select_ani.m_node)
    self.m_selectAnimator = select_ani

    -- 주사위를 부각시키기 위한 음영 효과 용 UI, skip도 처리한다.
	do
		local masking_ui = UI()
		masking_ui:load('empty.ui')
		local function touch_func(touch, event)
			-- 연출 중일 때만 동작
			if (self.m_coroutineHelper) then
				event:stopPropagation()
                -- 연출 스킵
                self:skipDirectingDice()                
			end
		end
		UIManager:makeSkipAndMaskingLayer(masking_ui, touch_func)
		self.root:addChild(masking_ui.root)
		masking_ui.root:setVisible(false)
        masking_ui.root:setPosition(cc.p(0, -280))
		self.m_maskingUI = masking_ui

        -- roll a dice ani
        local res = 'res/ui/spine/dice/dice.json'
        local roll_ani = MakeAnimator(res)
        masking_ui.root:addChild(roll_ani.m_node, 99)
        roll_ani:setVisible(false)
        self.m_rollAnimator = roll_ani
	end

    -- touch 먹히도록 함
    self.root:setSwallowTouch(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DiceEvent:initButton()
    local vars = self.vars
    vars['diceBtn']:registerScriptTapHandler(function() self:click_diceBtn() end)
	vars['goldBtn']:registerScriptTapHandler(function() self:click_diceBtn() end)
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
    vars['lapLabel']:setString(Str('{1}회 완주', lap_cnt))

    -- 셀렉트 처리
    self:moveCell(curr_cell)

    -- 최초 출발 처리
    local is_first = ((curr_cell == 1) and (lap_cnt == 0))
    local first_cell_ui = self.m_cellUIList[1]

    --first_cell_ui.vars['startSprite']:setVisible(is_first)
    --first_cell_ui.vars['iconNode']:setVisible(not is_first)

    -- 완주 보상 UI 처리
    for i, t_ui in ipairs(self.m_lapRewardInfoList) do
        self.refershLap(t_ui['ui'], t_ui['data'], lap_cnt)
    end

	-- 추가 주사위 처리
	do
		local is_add = (curr_dice == 0)
		vars['goldBtn']:setEnabled(is_add)
		vars['diceBtn']:setEnabled(not is_add)
	
		-- 추가 주사위 현황
		local add_desc = dice_info:getAdditionalStateDesc()
		vars['goldCountLabel']:setString(add_desc)
	end
end

-------------------------------------
-- function:moveCell
-------------------------------------
function UI_DiceEvent:moveCell(cell, cb_func, immediately)
    local pos_x, pos_y = self.vars['node' .. cell]:getPosition()
    
    -- 셀 이동
    if (immediately) then
        self.m_selectAnimator:stopAllActions()
        self.m_selectAnimator:setPosition(pos_x, pos_y)
    else
        local duration = 0.15
        local move = cca.makeBasicEaseMove(duration, pos_x, pos_y)
        self.m_selectAnimator:runAction(move)
    end

    -- 콜백
    if (cb_func) then
        cb_func()
    end

    -- 컨테이너 이동 시킨다 
    -- @mskim 주사위 이벤트 개편으로 제외
    -- self:moveContainer(pos_y)
end

-------------------------------------
-- function moveContainer
-------------------------------------
function UI_DiceEvent:moveContainer(compare_y, is_force)
    -- 컨테이너가 없거나 이동중이면 다시 움직이지 않는다.
    if (not is_force) then
        if (not self.m_container) then
            return
        end
        if (self.m_isContainerMoving) then
            return
        end
    end

    -- 움직인 Y좌표에 따라 2가지 값 사용 (위 또는 아래 포커스)
    local pos_y
    if (compare_y > 0) then
        pos_y = self.m_containerTopPosY
    elseif (compare_y == 0) then
        pos_y = (self.m_containerTopPosY / 2)
    else
        pos_y = 0
    end

    -- 현재의 좌표와 이동할 좌표가 같다면 이동하지 않음.. 강제는 가능
    if (not is_force) and (self.m_container:getPositionY() == pos_y) then
        return
    end
    self.m_container:stopAllActions()

    local duration = 0.5
    local move = cca.makeBasicEaseMove(duration, 0, pos_y)
    local cb = cc.CallFunc:create(function()
        self.m_isContainerMoving = false
    end)
    local sequence = cc.Sequence:create(move, cb)
    self.m_container:runAction(sequence)
    
    self.m_isContainerMoving = true
end

-------------------------------------
-- function setContainerAndPosY
-- @breif 외부에서 컨테이너 추가해준다.
-------------------------------------
function UI_DiceEvent:setContainerAndPosY(container, pos_y)
    self.m_container = container
    self.m_containerTopPosY = pos_y

    -- 주사위가 있다면 판 위치로 이동
    if g_eventDiceData:getDiceInfo():getCurrDice() > 0 then
        self:moveContainer(-280, true)
    end
end

-------------------------------------
-- function click_diceBtn
-------------------------------------
function UI_DiceEvent:click_diceBtn()
    -- 추가 주사위 또는 주사위가 있을 때만 동작하도록 한다.
    local dice_info = g_eventDiceData:getDiceInfo()
    local curr_dice = dice_info:getCurrDice()
	local use_add_all = dice_info:useAllAddDice()
    if (use_add_all) and (curr_dice < 1) then
        UIManager:toastNotificationRed(Str('주사위가 부족합니다'))
        return
    end

	-- 추가 주사위 사용하는 경우 골드 검사
	if (not use_add_all) and (curr_dice == 0) then
		local curr_gold = g_userData:get('gold')
		if (curr_gold <= 100000) then
			UIManager:toastNotificationRed(Str('골드가 부족합니다'))
			return
		end
	end

    -- 이미 연출 중
    if (self.m_coroutineHelper) then
        return
    end

    self:directingDice()
end

-------------------------------------
-- function directingDice
-------------------------------------
function UI_DiceEvent:directingDice()
    -- 연출은 코루틴이 좋다.
    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co

		-- 코루틴 종료 콜백
		local function close_cb()
			self.m_coroutineHelper = nil
			-- 백키 블럭 해제
            UIManager:blockBackKey(false)
		end
		co:setCloseCB(close_cb)

        -- 백키 블럭
        UIManager:blockBackKey(true)

        -- 서버와 통신
        co:work()
        local ret_cache
        local function request_finish(ret)
            ret_cache = ret
            co.NEXT()
        end
        g_eventDiceData:request_diceRoll(request_finish)
        if co:waitWork() then return end

        -- Directing State 1
        self.m_directingState = 1

        -- 굴리기 연출 ON
        self.m_rollAnimator:setTimeScale(2)
        self.m_rollAnimator:setVisible(true)
        self.m_maskingUI.root:setVisible(true)
        self.m_maskingUI.root:setOpacity(0)
        self.m_maskingUI.root:runAction(cc.FadeIn:create(0.2))

        -- 사운드 재생
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')

        -- 나온 주사위 눈
        local dt_cell = ret_cache['dt_cell']

        -- ani list 재생
        local ani_list = {'appear', 'idle', 'disappear', tostring(dt_cell)}
        while (#ani_list > 0) do
            -- skip 시 강제 탈출 하도록 함
            if (self.m_directingState == 2) then
                -- 주사위 연출을 숨기고 애니메이션 정지
                self.m_rollAnimator:setAnimationPause(true)
                self.m_rollAnimator:setVisible(false)
                self.m_maskingUI.root:setVisible(false)
                break
            end

            co:work()

            local ani_name = ani_list[1]
            table.remove(ani_list, 1)
            self.m_rollAnimator:changeAni(ani_name)
            self.m_rollAnimator:addAniHandler(function()
                co.NEXT()
            end)

            if co:waitWork() then return end
        end
        
        -- Directing State 2
        self.m_directingState = 2

        -- 굴리기 연출 OFF
        self.m_rollAnimator:setVisible(false)
        self.m_maskingUI.root:setVisible(false)

        -- 이동 연출
        local old_cell = ret_cache['old_pos']
        local new_cell = ret_cache['new_pos']
        
        -- 개발 모드에서 도착 위치 출력
        if (IS_TEST_MODE()) then
            ccdisplay('destination : ' .. new_cell)
        end

        local move_cell = old_cell
        self.m_destCell = new_cell
        repeat
            co:work()

            move_cell = move_cell + 1
            if (move_cell > 32) then
                move_cell = 1
            end
            self:moveCell(move_cell, co.NEXT)
            co:waitTime(0.15)

            if co:waitWork() then return end

            -- skip 시 강제 탈출 하도록 함
            if (self.m_directingState == 3) then
                -- 도착지로 즉시 이동함
                self:moveCell(self.m_destCell, nil, true)
                break
            end
        until(new_cell == move_cell)
        
        -- Directing State 3
        self.m_directingState = 3
        
        -- 도착 연출
        do  
            local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
            UI_ToastPopup(toast_msg)

            self:refresh()
                
            self.m_selectAnimator:changeAni('arrival')
            self.m_selectAnimator:addAniHandler(function()
                -- 도착 후 정리
                self.m_selectAnimator:changeAni('select', true)
            end)
        end

        -- 끝
        co:close()
    end

    Coroutine(coroutine_function, 'DiceEvent Directing')
end

-------------------------------------
-- function skipDirectingDice
-------------------------------------
function UI_DiceEvent:skipDirectingDice()
    self.m_coroutineHelper.NEXT()

    -- 주사위 연출 중 스킵
    if (self.m_directingState == 1) then
        self.m_directingState = 2

    -- cell 이동 중 스킵
    elseif (self.m_directingState  == 2) then
        self.m_directingState = 3

    end
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
    -- 보상 수량
    vars['quantityLabel']:setString(comma_value(t_data['value']))
    
    --리소스가 비어있는 경우
    if( res == '' ) then
        --드래곤인지 확인
        local did = tonumber(TableItem:getDidByItemId(item_id))
        if (did and (did > 0)) then
            --드래곤 카드 생성
            local icon = UI_ItemCard(item_id)
            icon.root:setPositionY(-20)
            icon.root:setScale(0.8)
            vars['iconNode']:addChild(icon.root)
            vars['quantityLabel']:setVisible(false)
        end
    else
        local icon = IconHelper:getIcon(res)
        vars['iconNode']:addChild(icon)
    end

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

    -- 보상 아이콘
    local gap = 30
    local ft = gap/2
    local l_reward = t_data['l_reward']
    local reward_cnt = #l_reward
    local item_id, res, icon, pos_x, value, item_type
    local l_item_id_list = {}
    for i, t_reward in ipairs(l_reward) do
        item_id = t_reward['item_id']
        value = t_reward['value']
        item_type = TableItem:getItemType(item_id)

        -- 드래곤 카드
        if (item_type == 'dragon') then

            local did = tonumber(TableItem:getDidByItemId(item_id))
            icon = UI_ItemCard(item_id, nil)

            local function click_btn()
                UI_BookDetailPopup.openWithFrame(did, nil, nil, 0.8, true)
            end
            icon.vars['clickBtn']:registerScriptTapHandler(function() click_btn() end)

            icon.root:setScale(0.95)
            vars['rewardNode']:addChild(icon.root)
            
        -- 그 외
        else
            icon = IconHelper:getItemIcon(item_id)
            
            if (item_type == 'reinforce_point') or (item_type == 'dragon') or (item_type == 'slime')then
                icon:setScale(0.8)
            end
            vars['rewardNode']:addChild(icon)
    
            -- 보상 갯수에 따라 위치 조정
            pos_x = (gap * i) - (ft + (ft * reward_cnt))
            icon:setPositionX(pos_x)
        end

        table.insert(l_item_id_list, item_id)
    end

    -- 상품 수량은 표기하기 애매한데?
    if (reward_cnt == 1) then
        vars['cntLabel']:setString(Str('{1}개', comma_value(value)))
    else
        vars['cntLabel']:setString(Str('각 {1}개', comma_value(value)))
    end
    vars['cntLabel']:setScale(0.8)

    -- 0회차
    local lap = t_data['lap']
    vars['timeLabel']:setString(Str('{1}회 완주', lap))

    -- 터치시 툴팁
    vars['clickBtn']:registerScriptTapHandler(function()
        local desc = ''
        for i, item_id in ipairs(l_item_id_list) do
            desc = desc .. TableItem:getToolTipDesc(item_id) .. '\n'
        end

        local tool_tip = UI_Tooltip_Skill(70, -145, desc)
        tool_tip:autoPositioning(vars['clickBtn'])
    end)

    -- 보상 수령
    vars['rewardBtn']:registerScriptTapHandler(function()
        local function finish_cb(ret)
            t_data['is_recieved'] = true
            UI_DiceEvent.refershLap(ui, t_data, 0)

            local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
            UI_ToastPopup(toast_msg)
        end
        g_eventDiceData:request_diceReward(lap, finish_cb)
    end)

    -- 20190117 1주년 이벤트 마지막 완주 보상은 돋보이도록 이미지로 표시, 마지막 완주 횟수 : 40
    if (tonumber(lap) == 40) then
        vars['lastRewardSprite']:setVisible(true)
    end

    return ui
end

-------------------------------------
-- function refershLap
-- @static
-------------------------------------
function UI_DiceEvent.refershLap(lap_ui, t_lap, curr_lap)
    local lap = t_lap['lap']
    local is_recieved = t_lap['is_recieved']
    local is_able = (lap <= curr_lap)
    local is_btn_able, btn_str, btn_color
    
    -- 이미 수령
    if (is_recieved) then
        is_btn_able = false
        btn_str = Str('완료')
        btn_color = COLOR['MUSTARD']
    
    -- 받기 가능
    elseif (is_able == true) and (is_recieved == false) then
        is_btn_able = true
        btn_str = Str('받기')
        btn_color = COLOR['BLACK']

    -- 아직 받을 수 없음
    elseif (is_able == false) and (is_recieved == false) then
        is_btn_able = false
        btn_str = Str('받기')
        btn_color = COLOR['SKILL_DESC_MOD']

    end

    lap_ui.vars['rewardBtn']:setEnabled(is_btn_able)
    lap_ui.vars['rewardLabel']:setString(btn_str)
    lap_ui.vars['rewardLabel']:setColor(btn_color)
    lap_ui.vars['checkSprite']:setVisible(is_recieved)
end
