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

    -- 텍스트 최기화
	vars['rewardLabel1']:setString('')
	vars['rewardLabel2']:setString('')

	-- 고대의 탑
	if (content_type == 'ancient') then
		local curr_floor = g_ancientTowerData:getClearFloor() or 0

		-- 탈출 : 정보 없거나 50층까지 전부 클리어 시
		if (not curr_floor) or (curr_floor >= 50) then
			return
		end

		t_item = {['item_id'] = 779215, ['count'] = 1} -- 스킬 슬라임
		
		local item_name = UIHelper:makeItemNamePlain(t_item)
		text_1 = Str('{1} 획득까지', item_name)

		local goal_floor = (50 > curr_floor) and (curr_floor >= 30) and 50 or 30
		local left_cnt = goal_floor - curr_floor
		text_2 = Str('{1}층 남음', left_cnt)

	-- 시험의 탑
	elseif (content_type == 'attr_tower') then
        t_item, text_1, text_2 = self:initCompetitionRewardInfo_attrTower()
        if (not t_item) then
            return
        end

	-- 콜로세움
	elseif (content_type == 'colosseum') then

        -- 콜로세움 (신규) 판수 보상
        if IS_ARENA_OPEN() then
            -- 판수
		    local struct_user = g_arenaData:getPlayerArenaUserInfo()
		    local cnt = struct_user and struct_user:getWinCnt() + struct_user:getLoseCnt() or 0

		    -- 다음 판수 보상
		    local next_reward_info = TableArenaWinReward:getNextReawardInfo(cnt)
		    if (not next_reward_info) then
			    return
		    end

		    t_item = next_reward_info['t_item']

		    local item_name = UIHelper:makeItemNamePlain(t_item)
		    text_1 = Str('{1} 획득까지', item_name)

		    local left_cnt = next_reward_info['play_cnt'] - cnt
		    text_2 = Str('{1}회 남음', left_cnt)


        -- 콜로세움 (기존) 승리 보상
        else
            -- 승수
		    local struct_user = g_colosseumData:getPlayerColosseumUserInfo()
		    local win = struct_user and struct_user:getWinCnt() or 0

		    -- 다음 승리 보상
		    local next_reward_info = TableColosseumWinReward:getNextReawardInfo(win)
		    if (not next_reward_info) then
			    return
		    end

		    t_item = next_reward_info['t_item']

		    local item_name = UIHelper:makeItemNamePlain(t_item)
		    text_1 = Str('{1} 획득까지', item_name)

		    local left_cnt = next_reward_info['win'] - win
		    text_2 = Str('{1}승 남음', left_cnt)
        end
	-- 콜로세움
	elseif (content_type == 'challenge_mode') then
        return
    end

	-- visible on
	vars['rewardMenu']:setVisible(true)

	-- 아이콘
	local icon = IconHelper:getItemIcon(t_item['item_id'])
	vars['itemNode']:addChild(icon)
	
	-- 텍스트
	vars['rewardLabel1']:setString(text_1)
	vars['rewardLabel2']:setString(text_2)			
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
        return
    end

	local t_item = struct_quest:getRewardInfoList()[1]

	local item_name = UIHelper:makeItemNamePlain(t_item)
	local text_1 = struct_quest:getQuestDesc()

	local _, text = struct_quest:getProgressInfo()
	local text_2 = Str('달성 : {1}', text)

    return t_item, text_1, text_2
end