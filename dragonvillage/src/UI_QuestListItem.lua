local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_QuestListItem
-------------------------------------
UI_QuestListItem = class(PARENT, {
        m_questData = 'table',
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

	self:setQuestData()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function setQuestData
-------------------------------------
function UI_QuestListItem:setQuestData(t_data)
    self.m_questData = t_data
	local qid, server_quest
	for i, quest in pairs(self.m_questData) do 
		qid = quest['qid']
	end
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
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuestListItem:refresh()
    local vars = self.vars
	local t_data = self.m_questData
	
	-- 완료 표시 -> server 에서 값주면 max_cnt와 비교
	vars['questCompletNode']:setVisible(false)

	-- desc -> server 에서 주는 clear_cnt 반영하여 다음것 넣어줘야함
	vars['questLabel']:setString(Str(t_data['desc']))

	-- 보상 -> icon 및 수량 ... ㅠㅠ
	self:setRewardCard()

	-- 진행도 -> ..
	self:setQuestProgress()
end

-------------------------------------
-- function setRewardCard
-------------------------------------
function UI_QuestListItem:setRewardCard()
    local vars = self.vars
	local t_data = self.m_questData

	local reward_type, reward_value, reward_card = nil

	for i = 1, 3 do 
		reward_type = t_data['reward_type_' .. i]
		reward_value = t_data['reward_value_' .. i]
		if (reward_type) then
		    reward_card = UI_RewardCard(reward_type, reward_value)
			reward_card.root:setScale(0.7)
			vars['rewardNode' .. i]:addChild(reward_card.root)
			vars['rewardLabel' .. i]:setString('')
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
	
	-- (max_cnt는 server 에서 주는 clear_cnt 로 대체하면됨)
	local goal_cnt = self.m_questData['unit'] * self.m_questData['max_cnt'] 
	local cur_cnt = math_min(5, goal_cnt)
	
	vars['questGauge']:setPercentage((cur_cnt / goal_cnt) * 100)
	vars['questGaugeLabel']:setString(cur_cnt .. ' / ' .. goal_cnt)
end