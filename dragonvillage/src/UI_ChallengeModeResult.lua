local PARENT = UI_ArenaResult

-------------------------------------
-- class UI_ChallengeModeResult
-------------------------------------
UI_ChallengeModeResult = class(PARENT, {
		m_currStage = 'number',
		m_playReward = 'table',
		m_winReward = 'table',
		m_isOpenNextTeam = 'boolean',
     })

local ACTION_MOVE_Y = 700

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeResult:init(is_win, t_data, stage, is_open_next_team)
	self.m_currStage = stage

	-- 다음 팀 열림
	self.m_isOpenNextTeam = is_open_next_team
	
	-- 승리 보상
	local items_list = t_data['added_items']['items_list']
	if (items_list) then
        self.m_winReward = items_list
	end

end

-------------------------------------
-- function initUI
-- @override
-------------------------------------
function UI_ChallengeModeResult:initUI()
    PARENT.initUI(self)

	local vars = self.vars
	vars['colosseumNode']:setVisible(false)
	vars['resultBgSprite']:setVisible(false)
end

-------------------------------------
-- function initButton
-- @override
-------------------------------------
function UI_ChallengeModeResult:initButton()
    PARENT.initButton(self)
end

-------------------------------------
-- function setWorkList
-- @override
-------------------------------------
function UI_ChallengeModeResult:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_end')
	-- table.insert(self.m_lWorkList, 'direction_playReward')
    -- 승리 시, 승리 보상 UI 출력
    if (self.m_isWin) then
	    table.insert(self.m_lWorkList, 'direction_winReward')
	end
    table.insert(self.m_lWorkList, 'direction_nextStage')
end

-------------------------------------
-- function direction_end
-- @override
-- @brief 종료 연출
-------------------------------------
function UI_ChallengeModeResult:direction_end()
    local vars = self.vars
    local resultMenu = vars['resultMenu']
    resultMenu:setVisible(true)

    -- 연출 준비
    local t_data = self.m_resultData
	vars['resultVisual']:setPositionY(100)
	vars['okBtn']:setPositionY(-100)
	vars['statsBtn']:setPositionY(-100)
	vars['homeBtn']:setPositionY(-100)
    vars['eventNode1']:setVisible(false)
    vars['eventNode2']:setVisible(false)

    -- 이벤트 아이템 표시
    local event_act = cc.CallFunc:create(function()
        if (not t_data['added_items']) then 
            return 
        end
        local drop_list = t_data['added_items']['items_list'] or {}
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
    end)
    local move_func = cc.EaseExponentialOut:create(cc.MoveBy:create(0.3, cc.p(0, ACTION_MOVE_Y)))
    local show_act = cc.Sequence:create(move_func, event_act)
	resultMenu:runAction(show_act)

    self:doNextWorkWithDelayTime(0.5)
end

-------------------------------------
-- function direction_playReward
-------------------------------------
function UI_ChallengeModeResult:direction_playReward()
	local t_item = self.m_playReward
	if (not t_item) then
		self:doNextWork()
		return
	end

	self:makeRewardPopup(t_item, Str('도전 보상 획득!'))
end

-------------------------------------
-- function direction_winReward
-------------------------------------
function UI_ChallengeModeResult:direction_winReward()
	local t_item = self.m_winReward
	
    -- 이벤트(수집 이벤트) 보상이 섞여 들어왔을 때는 보상 목록에서 제외
    local remove_ind = nil
    for ind, item_data in ipairs(t_item) do
        if (item_data['from'] == 'event' or item_data['from'] == 'event_bingo') then
            remove_ind = ind
            break
        end
    end
    
    if (remove_ind) then
        table.remove(t_item, remove_ind)
    end

    if (#t_item == 0) then
		self:doNextWork()
		return
	end

    self:makeRewardPopup(t_item, Str('승리 보상 획득!'))
end

-------------------------------------
-- function direction_nextStage
-------------------------------------
function UI_ChallengeModeResult:direction_nextStage()
	if (not self.m_isOpenNextTeam) then
		self:doNextWork()
		return
	end

	local function ok_func()
		self:doNextWork()
	end

    -- 다음 도전할 층
    local challenge_stage = 0

    -- 마스터 시즌이 아니라면
    if (not g_challengeMode:isChallengeModeMasterMode()) then
        local stage_limit = g_challengeMode:getMasterStage()
        local cur_stage = g_challengeMode:getTopStage() - self.m_currStage

        -- 마스터 구간까지 깻을 경우
        if (cur_stage <= stage_limit) then
            
            -- 남은 시간 표기
            local sec = g_challengeMode:getChallengeModeMasterStatusText()
            local time_str = ServerTime:getInstance():makeTimeDescToSec(sec, false, false, false)
            local remain_time_str = (Str('마스터 구역 잠금해제까지\n{1}', Str(time_str)))
            MakeSimplePopup2(POPUP_TYPE.OK, Str('다음 순위부터는 마스터 구역입니다.'), remain_time_str, ok_func)
            return
        end
    end      
        challenge_stage = g_challengeMode:getTopStage() - self.m_currStage
        MakeSimplePopup2(POPUP_TYPE.OK, Str('다음 순위 잠금해제!'), Str('{1}위 팀에 도전할 수 있습니다.', challenge_stage), ok_func)
end

-------------------------------------
-- function makeRewardPopup
-------------------------------------
function UI_ChallengeModeResult:makeRewardPopup(t_item, title)
	local ui = UI()
	ui:load('arena_play_reward_popup.ui')
	UIManager:open(ui, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'temp')

	-- 제목
	ui.vars['playLabel']:setString(title)

	-- 우편 안내 숨김
	ui.vars['mailInfoLabel']:setVisible(false)
    
    -- @jhakim 20190130 테이블 뷰로 나오도록 후에 수정할것!
    if (t_item) then
       for i, v in ipairs(t_item) do
            -- @jhakim UI에 아이템 출력하는 칸이 두개밖에 없는 상태라서 서버에서 그 이상 줘도 UI에 아이템 출력하지 않음
            if (i<=2) then
	            -- 보상 아이템 표기    
	            local icon = IconHelper:getItemIcon(v['item_id'])
	            local count = comma_value(v['count'])

                if (#t_item > 1) then
                    ui.vars['rewardFrameNode' .. i+1]:setVisible(true)
                    ui.vars['rewardNode' .. i+1]:addChild(icon)
	                ui.vars['rewardLabel' .. i+1]:setString(count)
                    ui.vars['rewardFrameNode']:setVisible(false)
                else
                    ui.vars['rewardNode']:addChild(icon)
	                ui.vars['rewardLabel']:setString(count)          
                end
            end
       end
    end

	-- 버튼
	ui.vars['okBtn']:registerScriptTapHandler(function() ui:close() end)

	-- UI 종료시 다음으로 진행
    ui:setCloseCB(function() self:doNextWork() end)
end

-------------------------------------
-- function click_okBtn
-- @override
-- @brief "확인" 버튼
-------------------------------------
function UI_ChallengeModeResult:click_okBtn()
	UINavigator:goTo('challenge_mode')
end