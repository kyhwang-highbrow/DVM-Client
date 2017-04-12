local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_QuestListItem
-------------------------------------
UI_QuestListItem = class(PARENT, {
        m_questData = 'table',

		-- 각종 중요 숫자들은 테이블로 있으면 파악하기 힘들어 멤버 변수화
		m_rawCount = 'num',
		m_clearCount = 'num',
		m_rewardCount = 'num',
		m_goalCount = 'num',

		m_isCleared = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_QuestListItem:init(t_data, isHighlight)
	-- 멤버 변수
	self:setQuestData(t_data)
    
	-- UI load
	local ui_name = nil 
	if (isHighlight) then 
		ui_name = 'quest_list_highlight.ui'
	else
		ui_name = 'quest_list.ui'
	end
	self:load(ui_name)

	-- initialize
    self:initUI()
    self:initButton()
    self:refresh()
	
	--self:printQuestDebug()
end

-------------------------------------
-- function setQuestData
-- @brief 자주 활용할 숫자들을 멤버변수로 추출
-------------------------------------
function UI_QuestListItem:setQuestData(t_data)
	if (not t_data) then 
		return 
	end
	
    self.m_questData = t_data

	self.m_rawCount = self.m_questData['rawcnt']
	self.m_clearCount = self.m_questData['clearcnt']
	self.m_rewardCount = self.m_questData['rewardcnt']
	self.m_goalCount = self.m_questData['goal_cnt']
	self.m_isCleared = self.m_questData['is_cleared'] or self:getIsCleared()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_QuestListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_QuestListItem:initButton()
    local vars = self.vars
	
	if (vars['questLinkBtn']) then
		vars['questLinkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
	end

	-- vars['rewardBtn']은 list item 생성시에 등록함
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuestListItem:refresh(t_data)
	if (t_data) then
		self:setQuestData(t_data)
	end

	self:setVarsVisible()
	self:setQuestDescLabel()
	self:setRewardCard()
	self:setQuestProgress()
end

-------------------------------------
-- function setVarsVisible
-- @brief 퀘스트 진행 상태에 따라 visible on/off
-------------------------------------
function UI_QuestListItem:setVarsVisible()
    local vars = self.vars
	
	-- 퀘스트 보상까지 전부 수령시 표시
	vars['questCompletNode']:setVisible(self.m_isCleared)

	-- 보상 수령 가능시
	local is_activated_reward = (self.m_rewardCount < self.m_clearCount)
	vars['rewardBtn']:setVisible(true) --is_activated_reward)
	vars['rewardBtn']:setEnabled(is_activated_reward)

	-- 평시
	local is_temp = (not self.m_isCleared) and (not is_activated_reward)
	if string.find(self.m_questData['type'], '_all') then 
		vars['doingBtn']:setVisible(is_temp)
	else
		-- @TODO 퀘스트 바로가기 막음
		vars['questLinkBtn']:setVisible(false) --is_temp)
	end
end

-------------------------------------
-- function setQuestDescLabel
-- @brief 퀘스트 설명 표시
-------------------------------------
function UI_QuestListItem:setQuestDescLabel()
    local vars = self.vars
	local t_data = self.m_questData
	local goal_cnt = t_data['unit'] * self.m_goalCount

	vars['questLabel']:setString(Str(t_data['t_desc'], goal_cnt))
end

-------------------------------------
-- function setRewardCard
-- @brief 보상 아이콘 표시
-------------------------------------
function UI_QuestListItem:setRewardCard()
    local vars = self.vars
	local t_data = self.m_questData

	local reward_type, reward_unit, reward_card, reward_count = nil
	local t_reward = t_data['t_reward']

	for i = 1, 3 do 
		reward_type = t_reward['reward_type_' .. i]
		reward_unit = t_reward['reward_unit_' .. i]
		if (reward_type and reward_unit) then
            reward_count = reward_unit * math_min(self.m_goalCount, t_data['reward_max_cnt'])
		    reward_card = UI_RewardCard(reward_type, reward_count)
			reward_card.root:setScale(0.7)
			vars['rewardNode' .. i]:addChild(reward_card.root)
		else
			vars['rewardNode' .. i]:setVisible(false)
		end
	end
end

-------------------------------------
-- function setQuestProgress
-- @brief 퀘스트 진행도 표시
-------------------------------------
function UI_QuestListItem:setQuestProgress()
    local vars = self.vars
	local t_data = self.m_questData
	
	local goal_cnt = t_data['unit'] * self.m_goalCount
	local cur_cnt = self.m_rawCount
	
	vars['questGauge']:runAction(cc.ProgressTo:create(0.5, (cur_cnt / goal_cnt) * 100)) 
	vars['questGaugeLabel']:setString(cur_cnt .. ' / ' .. goal_cnt)
end

-------------------------------------
-- function getIsCleared
-------------------------------------
function UI_QuestListItem:getIsCleared()
	return (self.m_questData['max_cnt'] == self.m_clearCount == self.m_rewardCount)
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_QuestListItem:click_rewardBtn(ui_quest_popup)
	local qid = self.m_questData['qid']
	local cb_function = function(t_quest_data)
		-- 보상 수령 팝업
		local t_reward = clone(self.m_questData['t_reward'])
		t_reward['reward_cnt'] = self.m_rewardCount
		UI_RewardPopup(t_reward)
		
		-- 갱신
		self:refresh(t_quest_data)
		ui_quest_popup:refresh()
		g_topUserInfo:refreshData()
	end

	g_questData:requestQuestReward(qid, cb_function)
end

-------------------------------------
-- function click_questLinkBtn
-------------------------------------
function UI_QuestListItem:click_questLinkBtn()
	UIManager:toastNotificationRed(Str('"바로가기" 미구현'))
end

-------------------------------------
-- function printQuestDebug
-------------------------------------
function UI_QuestListItem:printQuestDebug()
	ccdump({
		desc = self.m_questData['t_desc'],
		type = self.m_questData['type'],
		unit = self.m_questData['unit'],
		raw_count = self.m_rawCount,
		clear_count = self.m_clearCount,
		reward_count = self.m_rewardCount,
		goal_count = self.m_goalCount,
	})
end