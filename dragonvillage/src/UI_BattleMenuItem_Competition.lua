local PARENT = UI_BattleMenuItem

-------------------------------------
-- class UI_BattleMenuItem_Competition
-------------------------------------
UI_BattleMenuItem_Competition = class(PARENT, {
        m_isThin = 'boolean', -- 가로 넓이가 얇은 모드인지
    })

local THIS = UI_BattleMenuItem_Competition

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem_Competition:init(content_type, is_thin)
    self.m_isThin = is_thin
    local ui_name = 'battle_menu_competition_item.ui'
    if (is_thin == true) then
        ui_name = 'battle_menu_competition_item_02.ui'
    end

    local vars = self:load(ui_name)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenuItem_Competition:initUI()
    local vars = self.vars
    PARENT.initUI(self)

    local content_type = self.m_contentType
    local is_content_lock, req_user_lv = g_contentLockData:isContentLock(content_type)
    local is_open = not is_content_lock

    vars['rewardLabel1']:setVisible(is_open)
	vars['rewardLabel2']:setVisible(is_open)	

	if (is_open) then
		self:initCompetitionRewardInfo(content_type)

	-- lock 상태에서도 시간 표시 할 수 있도록 강제로 보냄
	elseif (content_type == 'challenge_mode') then
		self:initCompetitionRewardInfo(content_type)

	end

    -- 컨텐츠 타입별 지정
    if (self.m_isThin == true) then
        vars['itemVisual']:changeAni(content_type .. '_list', true)
    end
end

-------------------------------------
-- function initCompetitionRewardInfo
-- @brief 경쟁 메뉴 보상 안내
-- @comment 갱신되는 케이스는 없어 initialize 로 만듬
-------------------------------------
function UI_BattleMenuItem_Competition:initCompetitionRewardInfo(content_type)
	local vars = self.vars

	local t_item, text_1, text_2
	
	-- visible on
	vars['rewardMenu']:setVisible(true)

    -- 텍스트 초기화
	vars['rewardLabel1']:setString('')
	vars['rewardLabel2']:setString('')

	-- 고대의 탑
	if (content_type == 'ancient') then
		t_item, text_1, text_2 = self:initCompetitionRewardInfo_ancient()

	-- 시험의 탑
	elseif (content_type == 'attr_tower') then
        t_item, text_1, text_2 = self:initCompetitionRewardInfo_attrTower()

	-- 콜로세움
	elseif (content_type == 'colosseum') then
		t_item, text_1, text_2 = self:initCompetitionRewardInfo_colosseum()
        
	-- 콜로세움
	elseif (content_type == 'challenge_mode') then
        t_item, text_1, text_2 = self:initCompetitionRewardInfo_challengeMode()

    end

	-- 아이콘
	if (t_item) then
		local icon = IconHelper:getItemIcon(t_item['item_id'])
		vars['itemNode']:addChild(icon)
	else
		vars['itemContainerNode']:setVisible(false)
	end

	-- 텍스트
	if (text_1) then
		vars['rewardLabel1']:setString(text_1)
	end
	if (text_2) then
		vars['rewardLabel2']:setString(text_2)
	end
end

-------------------------------------
-- function initCompetitionRewardInfo_attrTower
-- @brief 경쟁 메뉴 보상 안내
-- @comment 갱신되는 케이스는 없어 initialize 로 만듬
-------------------------------------
function UI_BattleMenuItem_Competition:initCompetitionRewardInfo_attrTower()
	local struct_quest_50 = g_questData:getQuest(TableQuest.CHALLENGE, 14501) -- 시험의 탑 모든 속성 50층 클리어 : 전설의 알
    local struct_quest_100 = g_questData:getQuest(TableQuest.CHALLENGE, 14502) -- 시험의 탑 모든 속성 100층 클리어 : 절대적인 전설의 알

    local struct_quest = nil

    -- 퀘스트 정보가 없을 경우
    if (struct_quest_50) and (not struct_quest_50:isEnd()) then
        struct_quest = struct_quest_50

    elseif (struct_quest_100) and (not struct_quest_100:isEnd()) then
        struct_quest = struct_quest_100
    end

    -- 종료 처리
    if (not struct_quest) then
        return nil, nil, nil
    end

	local t_item = struct_quest:getRewardInfoList()[1]

	local item_name = UIHelper:makeItemNamePlain(t_item)
	local text_1 = struct_quest:getQuestDesc()

	local _, text = struct_quest:getProgressInfo()
	local text_2 = Str('달성 : {1}', text)

    return t_item, text_1, text_2
end

-------------------------------------
-- function initCompetitionRewardInfo_ancient
-- @brief 고대의 탑
-------------------------------------
function UI_BattleMenuItem_Competition:initCompetitionRewardInfo_ancient()
	local curr_floor = g_ancientTowerData:getClearFloor() or 0

	-- 탈출 : 정보 없거나 50층까지 전부 클리어 시
	if (not curr_floor) or (curr_floor >= 50) then
		return nil, nil, nil
	end

	local t_item = {['item_id'] = 779215, ['count'] = 1} -- 스킬 슬라임
		
	local item_name = UIHelper:makeItemNamePlain(t_item)
	local text_1 = Str('{1} 획득까지', item_name)

	local goal_floor = (50 > curr_floor) and (curr_floor >= 30) and 50 or 30
	local left_cnt = goal_floor - curr_floor
	local text_2 = Str('{1}층 남음', left_cnt)

	return t_item, text_1, text_2
end

-------------------------------------
-- function initCompetitionRewardInfo_colosseum
-- @brief 콜로세움
-------------------------------------
function UI_BattleMenuItem_Competition:initCompetitionRewardInfo_colosseum()
	-- 판수
	local struct_user = g_arenaData:getPlayerArenaUserInfo()
	local cnt = struct_user and struct_user:getWinCnt() + struct_user:getLoseCnt() or 0

	-- 다음 판수 보상
	local next_reward_info = TableArenaWinReward:getNextReawardInfo(cnt)
	if (not next_reward_info) then
		return nil, nil, nil
	end

	local t_item = next_reward_info['t_item']

	local item_name = UIHelper:makeItemNamePlain(t_item)
	local text_1 = Str('{1} 획득까지', item_name)

	local left_cnt = next_reward_info['play_cnt'] - cnt
	local text_2 = Str('{1}회 남음', left_cnt)

	return t_item, text_1, text_2
end

-------------------------------------
-- function initCompetitionRewardInfo_challengeMode
-- @brief 이벤트 그림자의 신전
-------------------------------------
function UI_BattleMenuItem_Competition:initCompetitionRewardInfo_challengeMode()
	local vars = self.vars
	local state = g_challengeMode:getChallengeModeState()
	local t_item, text_1, text_2
	
	local use_timer = false
	local has_reward = false
	local timer_key

	-- 비활성화 상태 .. 정상적이라면 여기로 들어오지 않는다.
	if (state == ServerData_ChallengeMode.STATE['INACTIVE']) then
		return nil, nil, nil

	-- 일반적으로 lock은 UI_BattleMenuItem:initUI() 에서 처리하나 타이머 동작하기 위해서 여기로 보냄
	elseif (state == ServerData_ChallengeMode.STATE['LOCK']) then
		use_timer = true
		timer_key = 'event_challenge'

	-- 그림자의 신전 사용 가능 상태
	elseif (state == ServerData_ChallengeMode.STATE['OPEN']) then
		text_1 = Str('여러분의 한계에 도전해 보세요!')

		local team = g_challengeMode:getLastChallengeTeam()
		if (team ~= 0) then
			text_2 = Str('다음 도전 상대 : {1}위', team)
		end

		use_timer = true
		timer_key = 'event_challenge'

	-- 그림자의 신전 보상 수령 상태
	elseif (state == ServerData_ChallengeMode.STATE['REWARD']) then
		text_1 = Str('이벤트가 종료 되었습니다.')
		text_2 = Str('보상을 획득하세요.')

		use_timer = true
		has_reward = true
		timer_key = 'event_challenge_reward'

	elseif (state == ServerData_ChallengeMode.STATE['DONE']) then
		text_1 = Str('이벤트가 종료 되었습니다.')

	else
		return nil, nil, nil

	end

	-- 타이머 사용하는 경우 스케쥴러 등록
	if (use_timer) then
		self:startUpdateChallengeMode(timer_key, has_reward)
	end

	return t_item, text_1, text_2
end

-------------------------------------
-- function updateChallengeMode
-- @brief 이벤트 그림자의 신전
-------------------------------------
function UI_BattleMenuItem_Competition:startUpdateChallengeMode(timer_key, has_reward)
	local vars = self.vars
	local timer = 1
	local title = (has_reward) and Str('보상 수령 가능') or Str('기간 한정 이벤트')
		
	vars['timeSprite']:setVisible(true)
		
	local function update(dt)
		timer = timer + dt

		if (timer > 1) then
			timer = timer - 1
			if (has_reward) then
				local time_str = g_hotTimeData:getEventRemainTimeText(timer_key)
				vars['timeLabel']:setString(title .. '\n' .. time_str)
			else
				local time = g_hotTimeData:getEventRemainTime(timer_key)
					
				-- 이벤트가 안걸려있거나 0이하인 경우 탈출 처리
				if (not time) or (time <= 0) then
					vars['timeSprite']:setVisible(false)
					self.root:unscheduleUpdate()
					return
				end

				local time_str = Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time))
				vars['timeLabel']:setString(title .. '\n' .. time_str)
			end
		end
	end

	self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
end