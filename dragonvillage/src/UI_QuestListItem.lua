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

    local quest_data = self.m_questData

    local vars = self.vars
	
    if vars['lockBtn'] then
        if quest_data:isLock() then
            vars['lockBtn']:setVisible(true)
            vars['questCompletNode']:setVisible(false)
            vars['rewardBtn']:setVisible(false)
            vars['doingBtn']:setVisible(false)
            return
        else
            vars['lockBtn']:setVisible(false)
        end
    end

	-- 퀘스트 보상까지 전부 수령시 표시
	vars['questCompletNode']:setVisible(quest_data:isQuestEnded())

	-- 보상 수령 가능시
	vars['rewardBtn']:setVisible(quest_data:hasReward())

	-- 평시
    vars['doingBtn']:setVisible((not quest_data:hasReward()) and (not quest_data:isQuestEnded()))
end

-------------------------------------
-- function setQuestDescLabel
-- @brief 퀘스트 설명 표시
-------------------------------------
function UI_QuestListItem:setQuestDescLabel()
    local vars = self.vars
    local desc = self.m_questData:getQuestDesc()
	vars['questLabel']:setString(desc)
end

-------------------------------------
-- function setRewardCard
-- @brief 보상 아이콘 표시
-------------------------------------
function UI_QuestListItem:setRewardCard()
    local vars = self.vars

    local l_reward_info = self.m_questData:getRewardInfoList()

    for i,v in ipairs(l_reward_info) do
        local reward_card = UI_ItemCard(v['item_id'], v['count'])
		reward_card.root:setScale(0.7)
        vars['rewardNode' .. i]:addChild(reward_card.root)
    end
end

-------------------------------------
-- function setQuestProgress
-- @brief 퀘스트 진행도 표시
-------------------------------------
function UI_QuestListItem:setQuestProgress()
    local vars = self.vars
	local percentage, text = self.m_questData:getProgressInfo()
	
	vars['questGauge']:runAction(cc.ProgressTo:create(0.5, percentage)) 
	vars['questGaugeLabel']:setString(text)
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
		UI_RewardPopup()
		
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