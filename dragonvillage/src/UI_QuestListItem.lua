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
    local ui_name = nil 
	if (isHighlight) then 
		ui_name = 'quest_list_highlight.ui'
	else
		ui_name = 'quest_list.ui'
	end
	local vars = self:load(ui_name)

	self:setQuestData(t_data)

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

	self.m_rawCount = self.m_questData['rawcnt'] or 0
	self.m_clearCount = self.m_questData['clearcnt'] or 0
	self.m_rewardCount = self.m_questData['rewardcnt'] or 0
	self.m_goalCount = self.m_clearCount + 1
	if (not (t_data['type'] == TableQuest.CHALLENGE)) then 
		self.m_goalCount = math_min(self.m_goalCount, 1)
	end
		
	self.m_isCleared = self:getIsCleared()
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
	vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
	if (vars['questLinkBtn']) then
		vars['questLinkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
	end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuestListItem:refresh()
    local vars = self.vars

	-- 완료 표시 -> server 에서 값주면 max_cnt와 비교
	self:setVarsVisible()
	 
	-- desc -> server 에서 주는 clear_cnt 반영하여 다음것 넣어줘야함
	self:setQuestDescLabel()

	-- 보상
	self:setRewardCard()

	-- 진행도 -> ..
	self:setQuestProgress()
end

-------------------------------------
-- function setVarsVisible
-------------------------------------
function UI_QuestListItem:setVarsVisible()
    local vars = self.vars
	
	vars['questCompletNode']:setVisible(self.m_isCleared)

	local is_activated_reward = self.m_rewardCount < self.m_clearCount
	vars['rewardBtn']:setVisible(is_activated_reward)
	if string.find(self.m_questData['type'], '_all') then 
		vars['doingBtn']:setVisible(not is_activated_reward)
	else
		vars['questLinkBtn']:setVisible(not is_activated_reward)
	end
end

-------------------------------------
-- function setQuestDescLabel
-------------------------------------
function UI_QuestListItem:setQuestDescLabel()
    local vars = self.vars
	local t_data = self.m_questData
	local goal_cnt = t_data['unit'] * self.m_goalCount

	vars['questLabel']:setString(Str(t_data['t_desc'], goal_cnt))
end

-------------------------------------
-- function setRewardCard
-------------------------------------
function UI_QuestListItem:setRewardCard()
    local vars = self.vars
	local t_data = self.m_questData

	local reward_type, reward_unit, reward_card, reward_count = nil

	for i = 1, 3 do 
		reward_type = t_data['reward_type_' .. i]
		reward_unit = t_data['reward_unit_' .. i]
		reward_count = reward_unit * math_min(self.m_goalCount, t_data['reward_max_cnt'])
		if (reward_type) then
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
-------------------------------------
function UI_QuestListItem:setQuestProgress()
    local vars = self.vars
	local t_data = self.m_questData
	
	local goal_cnt = t_data['unit'] * self.m_goalCount
	local cur_cnt = self.m_rawCount
	
	vars['questGauge']:setPercentage((cur_cnt / goal_cnt) * 100)
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
function UI_QuestListItem:click_rewardBtn()
	UIManager:toastNotificationRed(Str('"보상받기" 미구현'))
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