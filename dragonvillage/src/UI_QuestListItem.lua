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
	-- UI load
	local ui_name = nil 
	if (isHighlight) then 
		ui_name = 'quest_list_highlight.ui'
	else
		ui_name = 'quest_item.ui'
	end
	self:load(ui_name)

	-- initialize
    self:initUI()
    self:initButton()
    self:refresh(t_data)
end

-------------------------------------
-- function setQuestData
-- @brief 자주 활용할 숫자들을 멤버변수로 추출
-------------------------------------
function UI_QuestListItem:setQuestData(t_data)
    self.m_questData = t_data
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_QuestListItem:initUI()
    local vars = self.vars
    vars['questGauge']:setPercentage(0)
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
	    self:setVarsVisible()
	    self:setQuestDescLabel()
	    self:setRewardCard()
	    self:setQuestProgress()
        self:setChallengeTitle()
    end
end

-------------------------------------
-- function setVarsVisible
-- @brief 퀘스트 진행 상태에 따라 visible on/off
-------------------------------------
function UI_QuestListItem:setVarsVisible()
    local vars = self.vars
    local quest_data = self.m_questData

	-- 보상 수령 가능시
	vars['rewardBtn']:setVisible(quest_data:hasReward())

    -- 퀘스트 완료
    vars['questCompletNode']:setVisible((not quest_data:hasReward()) and (quest_data:isEnd()))

    -- 바로가지
    vars['questLinkBtn']:setVisible(true)
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

    for i, v in ipairs(l_reward_info) do
        local reward_card = UI_ItemCard(v['item_id'], v['count'])
        vars['rewardNode' .. i]:addChild(reward_card.root)
    end
end

-------------------------------------
-- function setQuestProgress
-- @brief 퀘스트 진행도 표시
-------------------------------------
function UI_QuestListItem:setQuestProgress()
    local vars = self.vars
    local quest_data = self.m_questData

	local percentage, text = quest_data:getProgressInfo()

    local sequence = cc.Sequence:create(
        cc.ProgressTo:create(0.5, percentage),
        cc.CallFunc:create(function()
            if (percentage >= 100) then
                vars['maxSprite']:setVisible(true)
            end
        end)
    )

    vars['maxSprite']:setVisible(quest_data:isEnd()) -- 갱신할 때 다시 안보이도록
	vars['questGauge']:runAction(sequence) 
	vars['questGaugeLabel']:setString(text)
end

-------------------------------------
-- function setChallengeTitle
-- @brief 퀘스트 진행도 표시
-------------------------------------
function UI_QuestListItem:setChallengeTitle()
    local vars = self.vars
    local quest_data = self.m_questData

    if (not quest_data:isChallenge()) then
        return
    end

    local title = quest_data:getTamerTitleStr()
    if (not title) then
        return
    end

    -- 칭호 노드 on
    vars['titleNode']:setVisible(true)

    -- 칭호 go!
    vars['titleLabel']:setString(title)
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_QuestListItem:click_rewardBtn(ui_quest_popup)
	local cb_function = function(t_quest_data)
		-- 우편함으로 전송
		local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)
		
		-- 갱신
		self:refresh(t_quest_data)
		ui_quest_popup:refresh()
	end

	g_questData:requestQuestReward(self.m_questData, cb_function)
end

-------------------------------------
-- function click_questLinkBtn
-------------------------------------
function UI_QuestListItem:click_questLinkBtn()
    local clear_type = self.m_questData:getQuestClearType()
	ServerData_MasterRoad.quickLink(clear_type)
end