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
-------------------------------------
function UI_QuestListItem:setQuestData(t_data)
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

	-- quest popup 변수를 받기 위해서 생성 후 등록
	--vars['questLinkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
    --vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
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

    local has_reward = quest_data:hasReward()
    local is_end = quest_data:isEnd()
    local clear_type = self.m_questData:getQuestClearType()
    local possible_link = QuickLinkHelper.possibleLink(clear_type)

	-- 보상 수령 가능시
	vars['rewardBtn']:setVisible(has_reward)

    -- 퀘스트 완료
    vars['questCompletNode']:setVisible((not has_reward) and (is_end))

    -- 바로가기
    vars['questLinkBtn']:setVisible(not is_end and possible_link)
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

    vars['questGauge']:setPercentage(0)

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

    -- 업적만 칭호가 있다.
    if (not quest_data:isChallenge()) then
        return
    end

    local title = quest_data:getTamerTitleStr()
    local have_title = (title ~= nil) and (title ~= '')

    -- 칭호 노드 on
    vars['titleNode']:setVisible(have_title)

    -- 칭호 go!
    if (have_title) then
        vars['titleLabel']:setString(title)
    end
end 

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_QuestListItem:click_rewardBtn(ui_quest_popup)
	local cb_function = function(t_quest_data)
		-- 우편함으로 전송
		local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)
		
        -- idx 교체 (테이블뷰의 아이템을 찾기위해 현재것으로 idx 지정)
        if (t_quest_data) then
            t_quest_data['idx'] = self.m_questData['idx']
        end

		-- 갱신
		self:refresh(t_quest_data)
		ui_quest_popup:refresh(t_quest_data)
	end

	g_questData:requestQuestReward(self.m_questData, cb_function)
end

-------------------------------------
-- function click_questLinkBtn
-------------------------------------
function UI_QuestListItem:click_questLinkBtn(ui_quest_popup)
    -- 바로가기
    local clear_type = self.m_questData:getQuestClearType()
	QuickLinkHelper.quickLink(clear_type)

    -- 퀘스트 팝업은 꺼버린다.
    if (ui_quest_popup and ui_quest_popup.closed == false) then
        ui_quest_popup:close()
    end
end