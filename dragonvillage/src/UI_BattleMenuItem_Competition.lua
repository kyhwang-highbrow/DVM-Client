local PARENT = UI_BattleMenuItem

-------------------------------------
-- class UI_BattleMenuItem_Competition
-------------------------------------
UI_BattleMenuItem_Competition = class(PARENT, {
        m_menuListCnt = 'number', -- 컨텐츠가 몇 개인지
    })

local THIS = UI_BattleMenuItem_Competition

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem_Competition:init(content_type, list_count)
    self.m_menuListCnt = list_count
    local ui_name = 'battle_menu_competition_item.ui'

    if (list_count == 4) then
        ui_name = 'battle_menu_competition_item_02.ui'
    elseif (list_count >= 5) then
        ui_name = 'battle_menu_competition_item_03.ui'
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
	elseif (content_type == 'challenge_mode') or (content_type == 'grand_arena') then
		self:initCompetitionRewardInfo(content_type)

	end


    --[[
    if (self.m_contentType == 'league_raid') 
        and (g_leagueRaidData:canPlay()) then
            local node = self.vars['newSprite']
            if node then
                node:setVisible(true)
                self.root:setLocalZOrder(self.root:getLocalZOrder() + 1)
            end
    end]]

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
    vars['descLabel']:setString('')

	-- 고대의 탑
	if (content_type == 'ancient') then
		t_item, text_1, text_2, desc = self:initCompetitionRewardInfo_ancient()

	-- 시험의 탑
	elseif (content_type == 'attr_tower') then
        t_item, text_1, text_2, desc = self:initCompetitionRewardInfo_attrTower()

	-- 콜로세움
	elseif (content_type == 'colosseum') then
		t_item, text_1, text_2, desc = self:initCompetitionRewardInfo_colosseum()
        
    -- 신규 아레나 code name : arena_new
	elseif (content_type == 'arena_new') then
		t_item, text_1, text_2, desc = self:initCompetitionRewardInfo_arenaNew()

	-- 그림자의 신전
	elseif (content_type == 'challenge_mode') then
        t_item, text_1, text_2, desc = self:initCompetitionRewardInfo_challengeMode()

    -- 그랜드 콜로세움
    elseif (content_type == 'grand_arena') then
        t_item, text_1, text_2, desc = self:initCompetitionRewardInfo_grandArena()

    end

	-- 아이콘
	if (t_item) then
		local icon = IconHelper:getItemIcon(t_item['item_id'])
		vars['itemNode']:addChild(icon)
        vars['itemContainerNode']:setVisible(true)
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
    if (desc) then
        vars['descLabel']:setString(desc)
    end
end

-------------------------------------
-- function initCompetitionRewardInfo_attrTower
-- @brief 경쟁 메뉴 보상 안내
-- @comment 갱신되는 케이스는 없어 initialize 로 만듬
-- @jhakim 190618 로비 통신이랑 quest/info 통신이랑 다른 정보를 받음, 일단 하드코딩
-------------------------------------
function UI_BattleMenuItem_Competition:initCompetitionRewardInfo_attrTower()
    local struct_quest

    -- 로비에서 145001, 145002, 145003 퀘스트의 rawcnt 값을 받음, 
    -- 다 같은 값이라서 하나만 사용
    for i = 1, 3 do 
        struct_quest = g_questData:getQuest(TableQuest.CHALLENGE, 14500 + i)
        if (struct_quest) then
            break
        end
    end

    -- 예외 처리
    if (not struct_quest) then
        return nil, nil, nil
    end
    
    -- 예외 처리   
    if (not struct_quest['rawcnt']) then
        return nil, nil, nil
    end

    -- 달성 스테이지에 해당하는 퀘스트를 찾음 (보상 여부 상관없이)
    -- 해당 퀘스트 설명 문구 설정
    local l_quest_value = {50, 100, 150}
    local rawcnt = struct_quest['rawcnt']
    local max_cnt = 0
    local now_quest_id = 0
    local quest_desc = Str('시험의 탑 모든 속성 50층 클리어')
    for i, value in ipairs(l_quest_value) do
        if (rawcnt < value) then
            if (self.m_menuListCnt == 5) then
                quest_desc = Str('시험의 탑 모든 속성\n{1}층 클리어', value)
            else
                quest_desc =Str('시험의 탑 모든 속성 {1}층 클리어', value)
            end
            now_quest_id =  14500 + i
            max_cnt = value
            break
        end
    end

    -- 끝까지 달성했을 경우 예외 처리
    if (rawcnt > 150) then
        return nil, nil, nil
    end

    -- 퀘스트 라벨
    local text_1 = quest_desc
    local cnt_str = Str('{1}/{2}', rawcnt, max_cnt)
    local text_2 = Str('달성 : {1}', cnt_str)
    local desc = nil

    -- 퀘스트 보상
    local table_quest = TableQuest()
    local t_quest = table_quest:get(now_quest_id)
    if (not t_quest) then
        return nil, nil, nil
    end

    local t_reward = t_quest['t_reward']
    local t_item = {}
    if (t_reward[1] and t_reward[1]['item_id']) then
        t_item['item_id'] = t_reward[1]['item_id']
    else
        t_item = nil
    end

    return t_item, text_1, text_2, desc
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

    local text_1 = ''
    
    if (self.m_menuListCnt == 5) then
        text_1 = Str('{1} \n획득까지', item_name)
    else
        text_1 = Str('{1} 획득까지', item_name)
    end

	local goal_floor = (50 > curr_floor) and (curr_floor >= 30) and 50 or 30
	local left_cnt = goal_floor - curr_floor
	local text_2 = Str('{1}층 남음', left_cnt)
    local desc = nil

	return t_item, text_1, text_2, desc
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
    local desc = nil

	return t_item, text_1, text_2, desc
end

-------------------------------------
-- function initCompetitionRewardInfo_arenaNew
-- @brief 콜로세움
-------------------------------------
function UI_BattleMenuItem_Competition:initCompetitionRewardInfo_arenaNew()
	-- 판수
	local struct_user = g_arenaNewData:getPlayerArenaUserInfo()
	local cnt = struct_user and struct_user:getWinCnt() + struct_user:getLoseCnt() or 0

	-- 다음 판수 보상
	local next_reward_info = TableArenaWinReward:getNextReawardInfo(cnt)
	if (not next_reward_info) then
		return nil, nil, nil
	end

	local t_item = {['item_id'] = 700005, ['count'] = 1} -- 명예

	local item_name = ''
	local text_1 = ''

	local left_cnt = ''
	local text_2 = ''
    local desc = nil

	return t_item, text_1, text_2, desc
end

-------------------------------------
-- function initCompetitionRewardInfo_challengeMode
-- @brief 이벤트 그림자의 신전
-------------------------------------
function UI_BattleMenuItem_Competition:initCompetitionRewardInfo_challengeMode()
	local vars = self.vars
	local state = g_challengeMode:getChallengeModeState_Routine()
	local t_item, text_1, text_2, desc
	
	local use_timer = false
	local has_reward = false
	local timer_key

	-- 비활성화 상태 .. 정상적이라면 여기로 들어오지 않는다.
	if (state == ServerData_ChallengeMode.STATE['INACTIVE']) then
		text_1 = g_challengeMode:getChallengeModeStatusText()
        return nil, text_1, nil

	-- 일반적으로 lock은 UI_BattleMenuItem:initUI() 에서 처리하나 타이머 동작하기 위해서 여기로 보냄
	elseif (state == ServerData_ChallengeMode.STATE['LOCK']) then
		use_timer = false
		timer_key = 'event_challenge'

	-- 그림자의 신전 사용 가능 상태
	elseif (state == ServerData_ChallengeMode.STATE['OPEN']) then
		if (self.m_contentType == 5) then
            text_1 = Str('여러분의 한계에 도전해 보세요!')
        else
            text_1 = Str('한계에 도전해 보세요!')
        end     

		local team = g_challengeMode:getLastChallengeTeam()
		if (team ~= 0) then
			text_2 = Str('다음 도전 상대 : {1}위', team)
		end

		use_timer = false
		timer_key = 'event_challenge'

        --[[
        t_item = {item_id=ITEM_ID_GOLD}
        desc = Str('최대 10,000,000골드 획득 가능!')
        --]]

	-- 그림자의 신전 보상 수령 상태
	elseif (state == ServerData_ChallengeMode.STATE['REWARD']) then
		text_1 = Str('시즌이 종료되었습니다.')
		text_2 = Str('보상을 획득하세요')

		use_timer = false
		has_reward = true
		timer_key = 'event_challenge_reward'

	elseif (state == ServerData_ChallengeMode.STATE['DONE']) then
		text_1 = g_challengeMode:getChallengeModeStatusText()

	else
		return nil, nil, nil

	end

	-- 타이머 사용하는 경우 스케쥴러 등록
	if (use_timer) then
		self:startUpdateChallengeMode(timer_key, has_reward)
	end

	return t_item, text_1, text_2, desc
end

-------------------------------------
-- function initCompetitionRewardInfo_grandArena
-- @brief 이벤트 그랜드 콜로세움
-------------------------------------
function UI_BattleMenuItem_Competition:initCompetitionRewardInfo_grandArena()
	local vars = self.vars
	local state = g_grandArena:getGrandArenaState()
	local t_item, text_1, text_2, desc
	
	local use_timer = false
	local has_reward = false
	local timer_key
    local param_title
    local param_msg

	-- 비활성화 상태 .. 정상적이라면 여기로 들어오지 않는다.
	if (state == ServerData_GrandArena.STATE['INACTIVE']) then
		return nil, nil, nil

	-- 일반적으로 lock은 UI_BattleMenuItem:initUI() 에서 처리하나 타이머 동작하기 위해서 여기로 보냄
	elseif (state == ServerData_GrandArena.STATE['LOCK']) then
		use_timer = true
		timer_key = 'event_grand_arena'

    -- 연습전
    elseif (state == ServerData_GrandArena.STATE['PRESEASON']) then

		use_timer = true
		timer_key = 'event_grand_arena_preseason'
        param_title = Str('연습전 종료까지')
        param_msg = '{1} 남음'

	-- 그랜드 콜로세움 사용 가능 상태
	elseif (state == ServerData_GrandArena.STATE['OPEN']) then
		text_1 = Str('10 vs 10 대규모 대전 등장!')

		use_timer = true
		timer_key = 'event_grand_arena'

	-- 그랜드 콜로세움  보상 수령 상태
	elseif (state == ServerData_GrandArena.STATE['REWARD']) then
		text_1 = Str('이벤트가 종료되었습니다.')
		text_2 = Str('보상을 획득하세요')

		use_timer = false
		has_reward = true
		timer_key = 'event_grand_arena_reward'

	elseif (state == ServerData_GrandArena.STATE['DONE']) then
		text_1 = Str('이벤트가 종료되었습니다.')

	else
		return nil, nil, nil

	end

	-- 타이머 사용하는 경우 스케쥴러 등록
	if (use_timer) then
		self:startUpdateChallengeMode(timer_key, has_reward, param_title, param_msg)
	end

	return t_item, text_1, text_2, desc
end

-------------------------------------
-- function startUpdateChallengeMode
-- @brief 이벤트 그림자의 신전
-------------------------------------
function UI_BattleMenuItem_Competition:startUpdateChallengeMode(timer_key, has_reward, param_title, param_msg)
	local vars = self.vars
	local timer = 1
	local title = (has_reward) and Str('보상 수령 가능') or Str('기간 한정 이벤트')
    if param_title then
        title = param_title
    end
		
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

                local time_str = Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(time))
                if param_msg then
                    time_str = Str(param_msg, ServerTime:getInstance():makeTimeDescToSec(time))
                end
				vars['timeLabel']:setString(title .. '\n' .. time_str)
			end
		end
	end

	self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
end