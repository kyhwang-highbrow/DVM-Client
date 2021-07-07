-------------------------------------
-- class UI_ArenaNewResult
-------------------------------------
UI_ArenaNewResult = class(UI, {
        m_isWin = 'boolean',
        m_resultData = '',

        m_workIdx = 'number',
        m_lWorkList = 'list',

        m_autoCount = 'boolean',
     })

local ACTION_MOVE_Y = 700

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_ArenaNewResult:init(is_win, t_data)
    self.m_isWin = is_win
    self.m_resultData = t_data
    self.m_autoCount = false

    local vars = self:load('arena_new_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_ArenaNewResult')

    self:initUI()
    self:initButton()

    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewResult:initUI()
    local vars = self.vars
    vars['resultVisual']:setVisible(false)
    vars['resultMenu']:setVisible(false)
    local ori_y = vars['resultMenu']:getPositionY()
    vars['resultMenu']:setPositionY(ori_y - ACTION_MOVE_Y)

	vars['colosseumNode']:setVisible(true)
    vars['normalBtnMenu']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewResult:initButton()
    local vars = self.vars
	vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
    vars['homeBtn']:registerScriptTapHandler(function() self:click_homeBtn() end)
    if (vars['infoBtn']) then
        vars['infoBtn']:registerScriptTapHandler(function() self:click_statusInfo() end)
        vars['infoBtn']:setVisible(true)
    end
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_ArenaNewResult:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}
--    table.insert(self.m_lWorkList, 'direction_showTamer')
--    table.insert(self.m_lWorkList, 'direction_hideTamer')
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_end')

	local t_data = self.m_resultData
    if (t_data['bonus_item_list'] and #t_data['bonus_item_list'] > 0) then
        table.insert(self.m_lWorkList, 'direction_showBox')
        table.insert(self.m_lWorkList, 'direction_openBox')
    end

	table.insert(self.m_lWorkList, 'direction_winReward')
    table.insert(self.m_lWorkList, 'direction_masterRoad')
end

-------------------------------------
-- function direction_showTamer
-------------------------------------
function UI_ArenaNewResult:direction_showTamer()
    local is_win = self.m_isWin
    local vars = self.vars

	local user_info = g_arenaNewData.m_playerUserInfo
    local tamer_id = user_info:getDeckTamerID()

	local t_tamer =  TableTamer():get(tamer_id)
    local tamer_node = vars['tamerNode']
    local talk_node = vars['talkLabel']

    local tamer_res = t_tamer['res']
    local animator = MakeAnimator(tamer_res)
    animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    tamer_node:addChild(animator.m_node)
    tamer_node:setVisible(true)
    talk_node:setVisible(is_win)

	local face_ani = TableTamer:getTamerFace(t_tamer['type'], is_win)
	animator:changeAni(face_ani, true)

    self:doNextWorkWithDelayTime(2.5)
end

-------------------------------------
-- function direction_showTamer_click
-------------------------------------
function UI_ArenaNewResult:direction_showTamer_click()
    self:doNextWork()
end

-------------------------------------
-- function direction_hideTamer
-------------------------------------
function UI_ArenaNewResult:direction_hideTamer()
    local vars = self.vars
    local tamer_node = vars['tamerNode']
    local hide_act = cc.EaseExponentialOut:create(cc.MoveTo:create(1, cc.p(0, -1000)))
    local after_act = cc.CallFunc:create(function()
		tamer_node:setVisible(false)
        self:doNextWork()
	end)

    tamer_node:runAction(cc.Sequence:create(hide_act, after_act))
end

-------------------------------------
-- function direction_hideTamer_click
-------------------------------------
function UI_ArenaNewResult:direction_hideTamer_click()
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_ArenaNewResult:direction_start()
    local is_win = self.m_isWin
    local vars = self.vars
    local visual_node = vars['resultVisual']
    visual_node:setVisible(true)

    -- 성공 or 실패
    if (is_win == true) then
        SoundMgr:playBGM('bgm_dungeon_victory', false)    
        visual_node:changeAni('victory_appear', false)
        visual_node:addAniHandler(function()
            visual_node:changeAni('victory_idle', true)
        end)
    else
        SoundMgr:playBGM('bgm_dungeon_lose', false)
        visual_node:changeAni('defeat_appear', false)
        visual_node:addAniHandler(function()
            visual_node:changeAni('defeat_idle', true)
        end)
    end

    self:doNextWorkWithDelayTime(0.5)
end

-------------------------------------
-- function direction_start_click
-------------------------------------
function UI_ArenaNewResult:direction_start_click()
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_ArenaNewResult:direction_end()
    local vars = self.vars
    local resultMenu = vars['resultMenu']
    resultMenu:setVisible(true)

    -- 연출 준비
    local t_data = self.m_resultData
    local numbering_time = 0.5
    local score_label1 = NumberLabel(vars['scoreLabel1'], 0, numbering_time)
    local score_label2 = vars['scoreLabel2']
    local honer_label1 = NumberLabel(vars['honorLabel1'], 0, numbering_time)
    local honer_label2 = vars['honorLabel2']
    vars['eventNode1']:setVisible(false)
    vars['eventNode2']:setVisible(false)

    -- 연출 액션들
    local function compare_func(data, up_arrow, down_arrow, label)
        up_arrow:setVisible(data > 0)
        down_arrow:setVisible(data < 0)

        if (data == 0) then 
            label:setString('') 
        else
            up_arrow:runAction(cc.JumpBy:create(0.3, cc.p(0, 0), 20, 1))
            down_arrow:runAction(cc.JumpBy:create(0.3, cc.p(0, 0), 20, 1))
        end
    end

    local show_act = cc.EaseExponentialOut:create(cc.MoveBy:create(0.3, cc.p(0, ACTION_MOVE_Y)))
    local number_act = cc.CallFunc:create(function()
        -- 현재 점수
        --local rp = t_data['point'] and t_data['point'] or 0
        local rpBefore = t_data['before_point'] and t_data['before_point'] or 0
        local rp = t_data['point'] and t_data['point'] or 0
        score_label1:setNumber(rp)

        -- 획득 점수
        --local addedRp = t_data['added_rp'] and t_data['added_rp'] or 0
        local addedRp = rp - rpBefore
        score_label2:setString(Str('{1}점', comma_value(addedRp)))
        compare_func(addedRp, vars['scoreArrowSprite1'], vars['scoreArrowSprite2'], score_label2)

        local bonusHonor = self:getRewardeHonorIfExsist()

        -- 현재 명예
        local honor = g_userData:get('honor')
        honer_label1:setNumber(honor - bonusHonor)

        -- 획득 명예
        honer_label2:setString(Str('{1}', comma_value(t_data['added_honor'] - bonusHonor)))
        compare_func(t_data['added_honor'], vars['honorArrowSprite1'], vars['honorArrowSprite2'], honer_label2)
    end)

    -- 이벤트 아이템 표시
    local event_act = cc.CallFunc:create(function()
        if (not t_data['win_item_list']) then 
            return 
        end
        local drop_list = t_data['win_item_list'] or {}
		local idx = 1
        for _, item in ipairs(drop_list) do
			-- 보호 장치
			if (idx > 2) then
				break
			end

            -- item_id 로 직접 체크한다
            if (item['from'] == 'event' or item['from'] == 'event_bingo') then
				-- visible on
                vars['eventNode' .. idx]:setVisible(true)

				-- 재화 아이콘
				local item_id = item['item_id']
				local icon = IconHelper:getItemIcon(item_id)
				vars['eventIconNode' .. idx]:addChild(icon)

				-- 재화 이름
				local item_name = TableItem:getItemName(item_id)
                vars['eventNameLabel' .. idx]:setString(item_name)

				-- 재화 수량
                local cnt = item['count']
                vars['eventLabel' .. idx]:setString(comma_value(cnt))

				idx = idx + 1
			end
        end

        -- 특정 상황에선 노드 이동
        if (vars['eventNode1']:isVisible() == false) and (vars['eventNode2']:isVisible() == true) then
            vars['eventNode2']:setPositionY(100)
        end
    end)

    resultMenu:runAction(cc.Sequence:create(show_act, number_act, event_act))

    self:doNextWorkWithDelayTime(0.5)
end

-------------------------------------
-- function direction_end_click
-------------------------------------
function UI_ArenaNewResult:direction_end_click()
end

-------------------------------------
-- function getRewardeHonorIfExsist
-------------------------------------
function UI_ArenaNewResult:getRewardeHonorIfExsist()
    local t_data = self.m_resultData
    if (not t_data['bonus_item_list'] or #t_data['bonus_item_list'] <= 0) then
		return 0
    end

    local itemsList = t_data['bonus_item_list']
    local total_cnt = table.count(itemsList)

	if (total_cnt == 1) then
		-- 보상 아이템 표기
		local t_item = itemsList[1]
        local id = t_item['item_id']
		local count = t_item['count']

        if (tonumber(id) == 700005 or tostring(id) == 'honor') then
            return tonumber(count)
        end

	-- 패치후 최초 업데이트 시점을 위한 분기 처리 (나중에 정리)
	else
		for idx, t_item in ipairs(itemsList) do
			local item_id = t_item['item_id']
			local item_cnt = t_item['count']
			
            if (tonumber(item_id) == 700005 or tostring(item_id) == 'honor') then
                return tonumber(item_cnt)
            end
		end
	end

    return 0
end

-------------------------------------
-- function direction_winReward
-------------------------------------
function UI_ArenaNewResult:direction_winReward()
	local t_data = self.m_resultData
    if (not t_data['bonus_item_list'] or #t_data['bonus_item_list'] <= 0) then
        self:doNextWork()
		return
    end

    local itemsList = t_data['bonus_item_list']
    local total_cnt = table.count(itemsList)
	local ui = UI()
	ui:load('arena_new_play_reward_popup.ui')
	UIManager:open(ui, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'temp')

    local winCount = t_data['win_count'] and t_data['win_count'] or 5

	if (total_cnt == 1) then
		-- 판수 표시
		local win = t_data['season']['win']
        local lose = t_data['season']['lose']

		-- 보상 아이템 표기
		local t_item = itemsList[1]
		local icon = IconHelper:getItemIcon(t_item['item_id'])
		ui.vars['rewardNode']:addChild(icon)
		local count = comma_value(t_item['count'])
		ui.vars['rewardLabel']:setString(count)

	-- 패치후 최초 업데이트 시점을 위한 분기 처리 (나중에 정리)
	else
		for idx, t_item in ipairs(itemsList) do
			local item_id = t_item['item_id']
			local item_cnt = t_item['count']
			local card = UI_ItemCard(item_id, item_cnt)
			ui.vars['rewardTempNode']:addChild(card.root)

			local pos_x = UIHelper:getCardPosX(total_cnt, idx)
			card.root:setPositionX(pos_x)

			ui.vars['rewardFrameNode']:setVisible(false)
			ui.vars['rewardLabel']:setVisible(false)
		end
	end

	ui.vars['infoLabel']:setString(Str('승리 {1}회 달성 보상', winCount))

	-- 버튼
	ui.vars['okBtn']:registerScriptTapHandler(function() ui:close() end)

    -- 연속 전투 진행중이라면 그냥 바로 넘기자
    if (g_autoPlaySetting:isAutoPlay()) then
        self:doNextWork()
    else
        ui:setCloseCB(function() self:doNextWork() end)
    end
end
-------------------------------------
-- function direction_winReward_click
-------------------------------------
function UI_ArenaNewResult:direction_winReward_click()
end

-------------------------------------
-- function direction_showBox
-- @brief 상자 연출 시작
-------------------------------------
function UI_ArenaNewResult:direction_showBox()
    local vars = self.vars
    local is_success = self.m_isWin
    if (not is_success) then 
        self:doNextWork()
        return
    end

    vars['boxVisual']:setVisible(true)
    vars['boxVisual']:changeAni('box_01', false)
    vars['boxVisual']:addAniHandler(function()
        --vars['boxVisual']:changeAni('box_02', true)
        self:doNextWork()
    end)
end

-------------------------------------
-- function direction_showBox_click
-- @brief 상자 연출 시작
-------------------------------------
function UI_ArenaNewResult:direction_showBox_click()
    self:doNextWork()
end

-------------------------------------
-- function direction_openBox
-- @brief 상자 연출 시작
-------------------------------------
function UI_ArenaNewResult:direction_openBox()
    local vars = self.vars
    local is_success = self.m_isWin
    if (not is_success) then 
        self:doNextWork()
        return
    end

    vars['boxVisual']:changeAni('box_03', false)
    vars['boxVisual']:addAniHandler(function()
        vars['boxVisual']:setVisible(false) 
        self:doNextWork()
    end)
	
	-- 상자가 열리면서 사운드
    -- SoundMgr:playEffect('UI', 'ui_reward')
end

-------------------------------------
-- function direction_masterRoad
-------------------------------------
function UI_ArenaNewResult:direction_masterRoad()
    -- @ MASTER ROAD
    local t_data = {game_mode = GAME_MODE_COLOSSEUM}
    g_masterRoadData:updateMasterRoad(t_data)

    -- @ GOOGLE ACHIEVEMENT
    GoogleHelper.updateAchievement(t_data)

    self.vars['normalBtnMenu']:setVisible(true)

    self:checkAutoPlay()
end

-------------------------------------
-- function direction_masterRoad_click
-------------------------------------
function UI_ArenaNewResult:direction_masterRoad_click()
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_ArenaNewResult:doNextWork()
    self.m_workIdx = (self.m_workIdx + 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function doNextWorkWithDelayTime
-------------------------------------
function UI_ArenaNewResult:doNextWorkWithDelayTime(second)
    local second = second or 1
    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_ArenaNewResult:click_statsBtn()
    if (self:checkAutoPlayRelease()) then return end

	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_okBtn
-- @brief "확인" 버튼
-------------------------------------
function UI_ArenaNewResult:click_okBtn()
    if (self:checkAutoPlayRelease()) then return end

	UINavigator:goTo('arena_new')
end

-------------------------------------
-- function click_quickBtn
-- @brief 바로재시작 버튼
-------------------------------------
function UI_ArenaNewResult:click_quickBtn()
    local start_func = function()
        self:startGame()
    end

    local cancel_func = function()
        -- 자동 전투 off
        g_autoPlaySetting:setAutoPlay(false)
    end

    -- 콜로세움에선 룬 획득, 드래곤 획득 없으므로 입장권만 체크
    local need_cash = 50 -- 유료 입장 다이아 개수

    -- 기본 입장권 부족시
    if (not g_staminasData:checkStageStamina(ARENA_NEW_STAGE_ID)) then
        -- 유료 입장권 체크
        local is_enough, insufficient_num = g_staminasData:hasStaminaCount('arena_new', 1)
        if (is_enough) then
            is_cash = true
            local msg = Str('입장권을 모두 소모하였습니다.\n{1}다이아몬드를 사용하여 진행하시겠습니까?', need_cash)
            MakeSimplePopup_Confirm('cash', need_cash, msg, start_func, cancel_func)

        -- 유료 입장권도 부족시 입장 불가 
        else
            local msg = Str('입장권을 모두 소모하였습니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg, cancel_func)
        end
    else
        is_cash = false
        start_func()
    end
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_ArenaNewResult:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        if (self:checkAutoPlayRelease()) then return end
        self[func_name](self)
    end
end

-------------------------------------
-- function click_statusInfo
-------------------------------------
function UI_ArenaNewResult:click_statusInfo()
    if (self:checkAutoPlayRelease()) then return end

    UI_HelpStatus()
end

-------------------------------------
-- function countAutoPlay
-- @brief 연속 전투일 경우 재시작 하기전 카운트 해줌
-------------------------------------
function UI_ArenaNewResult:countAutoPlay()
    if (not g_autoPlaySetting:isAutoPlay()) then return false end

    self.m_autoCount = true
    local vars = self.vars
    local node = vars['autoBattleNode']

    if (node) then node:setVisible(true) end

    local count_label = vars['countLabel']
    count_label:setString('')

    local count_num = 3
    local count_time = 1

    -- count ani
    for i = count_num, 1, -1 do
        local act1 = cc.DelayTime:create((count_num - i) * count_time)
        local act2 = cc.CallFunc:create(function() 
            count_label:setString(tostring(i)) 
            count_label:setOpacity(255)
            count_label:setScale(1)
        end)
        local act3 = cc.Spawn:create(cc.FadeOut:create(count_time), cc.ScaleTo:create(count_time, 0.8))

        count_label:runAction(cc.Sequence:create(act1, act2, act3))        
    end

    -- close
    do
        local act1 = cc.DelayTime:create(count_num * count_time)
        local act2 = cc.CallFunc:create(function()
            node:setVisible(false) 
            self:click_quickBtn(true) -- params : skip_check_auto_play_release
        end)
        self.root:runAction(cc.Sequence:create(act1, act2))
    end
end


-------------------------------------
-- function startGame
-------------------------------------
function UI_ArenaNewResult:startGame()
    local function cb(ret)
        -- 시작이 두번 되지 않도록 하기 위함
        UI_BlockPopup()

        -- 연속 전투일 경우 횟수 증가
		if (g_autoPlaySetting:isAutoPlay()) then
			g_autoPlaySetting.m_autoPlayCnt = (g_autoPlaySetting.m_autoPlayCnt + 1)

            local next_rival_data = g_arenaNewData:getValidRivalItem()
            
            if (next_rival_data) then g_arenaNewData:setMatchUser(next_rival_data) end
		end

        local scene = SceneGameArenaNew()
        scene:runScene()
    end

    g_arenaNewData:request_arenaStart(false, nil, cb)
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_ArenaNewResult:click_homeBtn()
    if (self:checkAutoPlayRelease()) then return end

	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local block_ui = UI_BlockPopup()

	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function checkAutoPlayRelease
-- @brief 연속 전투일 경우 스크린 터치시 연속 전투 해제 팝업 출력
-------------------------------------
function UI_ArenaNewResult:checkAutoPlayRelease()
    cclog('1')
    if (not g_autoPlaySetting:isAutoPlay()) then return false end

    local function f_pause(node) node:pause() end
    local function f_resume(node) node:resume() end
    doAllChildren(self.root, f_pause)

    local function ok_cb()
        -- 자동 전투 off
        g_autoPlaySetting:setAutoPlay(false)
        doAllChildren(self.root, f_resume)

        -- 카운트 중이었다면 off
        if (self.m_autoCount) then
            self.root:stopAllActions()
            self.vars['autoBattleNode']:setVisible(false)
        end
    end

    local function cancel_cb()
        doAllChildren(self.root, f_resume)
    end
    cclog('2')
    local msg = Str('연속 전투 진행 중입니다. \n연속 전투를 종료하시겠습니까?')
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb, cancel_cb)
    
    return true
end

-------------------------------------
-- function checkAutoPlay
-- @brief
-------------------------------------
function UI_ArenaNewResult:checkAutoPlay()
    if (not g_autoPlaySetting:isAutoPlay()) then
        return
    end

    local next_rival_data = g_arenaNewData:getValidRivalItem()
            
    if (not next_rival_data) then return end
        
	local auto_play_stop, msg = self:checkAutoPlayCondition()
    
    if (auto_play_stop == true) then
        -- 자동 전투 off
        g_autoPlaySetting:setAutoPlay(false)

        -- 메세지 있는 경우에만 팝업 출력
        if (msg) then MakeSimplePopup(POPUP_TYPE.OK, msg) end
        return
    end

    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function() self:countAutoPlay()  end)))
end

-------------------------------------
-- function checkAutoPlayCondition
-- @brief 콜로세움 연속 전투 멈추는 조건
-------------------------------------
function UI_ArenaNewResult:checkAutoPlayCondition()
    local auto_play_stop = false
    local msg = nil
    
    -- 패배 시 연속 전투 종료
    if g_autoPlaySetting:get('stop_condition_lose') then
        if (self.m_isWin == false) then
            auto_play_stop = true
            msg = Str('패배로 인해 연속 전투가 종료되었습니다.')
        end
    end

	return auto_play_stop, msg
end