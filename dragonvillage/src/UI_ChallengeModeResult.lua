-------------------------------------
-- class UI_ChallengeModeResult
-------------------------------------
UI_ChallengeModeResult = class(UI, {
        m_isWin = 'boolean',
        m_resultData = '',

        m_workIdx = 'number',
        m_lWorkList = 'list',
     })

local ACTION_MOVE_Y = 700

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_ChallengeModeResult:init(is_win, t_data)
    self.m_isWin = is_win
    self.m_resultData = t_data

    local vars = self:load('arena_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_ChallengeModeResult')

    self:initUI()
    self:initButton()

    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeModeResult:initUI()
    local vars = self.vars
    vars['resultVisual']:setVisible(false)
    vars['resultMenu']:setVisible(false)
    local ori_y = vars['resultMenu']:getPositionY()
    vars['resultMenu']:setPositionY(ori_y - ACTION_MOVE_Y)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModeResult:initButton()
    local vars = self.vars
	vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
    vars['homeBtn']:registerScriptTapHandler(function() self:click_homeBtn() end)
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_ChallengeModeResult:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_end')
	table.insert(self.m_lWorkList, 'direction_winReward')
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_ChallengeModeResult:direction_start()
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
function UI_ChallengeModeResult:direction_start_click()
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_ChallengeModeResult:direction_end()
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
      
        --[[
        -- 현재 점수
        local rp = g_arenaData.m_playerUserInfo.m_rp
        score_label1:setNumber(rp)

        -- 획득 점수
        score_label2:setString(Str('{1}점', comma_value(t_data['added_rp'])))
        compare_func(t_data['added_rp'], vars['scoreArrowSprite1'], vars['scoreArrowSprite2'], score_label2)

        -- 현재 명예
        local honor = g_userData:get('honor')
        honer_label1:setNumber(honor)

        -- 획득 명예
        honer_label2:setString(Str('{1}', comma_value(t_data['added_honor'])))
        compare_func(t_data['added_honor'], vars['honorArrowSprite1'], vars['honorArrowSprite2'], honer_label2)
        --]]
    end)

    resultMenu:runAction(cc.Sequence:create(show_act, number_act))

    self:doNextWorkWithDelayTime(0.5)
end

-------------------------------------
-- function direction_end
-------------------------------------
function UI_ChallengeModeResult:direction_end_click()
end

-------------------------------------
-- function direction_winReward
-------------------------------------
function UI_ChallengeModeResult:direction_winReward()
	local t_data = self.m_resultData
	if (not t_data['mail_item_info']) then
		self:doNextWork()
		return
	end

	-- 주간 승리 보상 (승수에 따라 고정 지급)
	local ui = UI()
	ui:load('arena_play_reward_popup.ui')
	UIManager:open(ui, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'temp')

	if (table.count(t_data['mail_item_info']) == 1) then
		-- 판수 표시
		local win = t_data['season']['win']
        local lose = t_data['season']['lose']

		ui.vars['playLabel']:setString(Str('콜로세움 {1}회 참여 보상', win + lose))

		-- 보상 아이템 표기
		local t_item = t_data['mail_item_info'][1]
		local icon = IconHelper:getItemIcon(t_item['item_id'])
		ui.vars['rewardNode']:addChild(icon)
		local count = comma_value(t_item['count'])
		ui.vars['rewardLabel']:setString(count)

	-- 패치후 최초 업데이트 시점을 위한 분기 처리 (나중에 정리)
	else
		local total_cnt = table.count(t_data['mail_item_info'])
		for idx, t_item in ipairs(t_data['mail_item_info']) do
			local item_id = t_item['item_id']
			local item_cnt = t_item['count']
			local card = UI_ItemCard(item_id, item_cnt)
			ui.vars['rewardTempNode']:addChild(card.root)

			local pos_x = UIHelper:getCardPosX(total_cnt, idx)
			card.root:setPositionX(pos_x)

			ui.vars['playLabel']:setString(Str('콜로세움 주간 참여 보상'))
			ui.vars['rewardFrameNode']:setVisible(false)
			ui.vars['rewardLabel']:setVisible(false)
		end
	end

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
-- function direction_winReward
-------------------------------------
function UI_ChallengeModeResult:direction_winReward_click()
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_ChallengeModeResult:doNextWork()
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
function UI_ChallengeModeResult:doNextWorkWithDelayTime(second)
    local second = second or 1
    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_ChallengeModeResult:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_okBtn
-- @brief "확인" 버튼
-------------------------------------
function UI_ChallengeModeResult:click_okBtn()
	UINavigator:goTo('challenge_mode')
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_ChallengeModeResult:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        if (UI_GameResultNew.checkAutoPlayRelease(self)) then return end
        self[func_name](self)
    end
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_ChallengeModeResult:click_homeBtn()
	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local block_ui = UI_BlockPopup()

	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end