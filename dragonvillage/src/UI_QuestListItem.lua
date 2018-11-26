local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_QuestListItem
-------------------------------------
UI_QuestListItem = class(PARENT, {
        m_questData = 'StructQuestData',
        --{
        --        ['t_quest']={
        --                ['r_val_1']=30;
        --                ['clear_value']=1;
        --                ['t_reward']={
        --                        {
        --                                ['item_id']=700001;
        --                                ['count']='30';
        --                        };
        --                        {
        --                                ['item_id']=700002;
        --                                ['count']='7000';
        --                        };
        --                };
        --                ['r_title']='';
        --                ['score']=1;
        --                ['qid']=30005;
        --                ['default']='';
        --                ['r_reward_1']='다이아';
        --                ['r_val_2']=7000;
        --                ['r_reward_2']='골드';
        --                ['title']='';
        --                ['t_desc']='고대의 탑 또는 시험의 탑 {1}회 플레이';
        --                ['type']='daily';
        --                ['r_grade']='';
        --                ['key']='ply_tower_ext';
        --                ['reward']='700001;30,700002;7000';
        --        };
        --        ['qid']=30005;
        --        ['is_end']=false;
        --        ['reward']=false;
        --        ['rawcnt']=0;
        --        ['idx']=5;
        --        ['quest_type']='daily';
        --}
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

    local reward_idx = 1
    for i, v in ipairs(l_reward_info) do
        local reward_card = UI_ItemCard(v['item_id'], v['count'])
        reward_card.root:setSwallowTouch(false)
        vars['rewardNode' .. i]:addChild(reward_card.root)
        reward_idx = reward_idx + 1
    end

    -- 일일 퀘스트 보상 2배 적용 중일 경우
    if self.m_questData:isDailyType() and g_questData:isSubscriptionActive() then
        for i, v in ipairs(l_reward_info) do
            local reward_card = UI_ItemCard(v['item_id'], v['count'])
            reward_card.root:setSwallowTouch(false)
            local reward_node = vars['rewardNode' .. reward_idx]
            reward_card.vars['bonusSprite']:setVisible(true)
            reward_card.vars['bonusLabel']:setString('')
            if reward_node then
                reward_node:addChild(reward_card.root)
            end
			reward_idx = reward_idx + 1
        end
    end

	-- 클랜 경험치
	if (not g_clanData:isClanGuest()) then
		local clan_exp = self.m_questData:getRewardClanExp()
		if (clan_exp) then
			local clan_exp_card = UI_ClanExpCard(clan_exp)
			local reward_node = vars['rewardNode' .. reward_idx]
			if (reward_node) then
				reward_node:addChild(clan_exp_card.root)
			end
		end
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
    
    ui_quest_popup:setBlock(true)
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
		ui_quest_popup:setBlock(false)

        -- 일일퀘스트 보상 2배 상품 판매촉진하는 팝업 조건 체크 후 팝업 출력
        self:checkPromoteQuestDouble(ui_quest_popup)
	end

	g_questData:requestQuestReward(self.m_questData, cb_function)
end

------------------------------------
-- function checkPromoteQuestDouble
-- @return 일일퀘스트 보상 2배 상품 판매 촉진하는 팝업 조건 체크 후 팝업 출력
-------------------------------------
function UI_QuestListItem:checkPromoteQuestDouble(ui_quest_popup)
    -- 1. 조건 확인     
    --      a. 퀘스트 10개 달성 보상 버튼만
    --      b. 일일퀘스트 보상 2배 상품 적용 비활성화 상태
    --      c. 쿨 타임 
    -- 2. 퀘스트 2배 상품 소개 팝업
    -- 3. 퀘스트 UI 갱신 (2배 상품 적용)
    local quest_struct = self.m_questData
    local cur_time = Timer:getServerTime()

    -- 1. 조건 확인
    -- a. 퀘스트 10개 달성 보상 버튼만
    if (not quest_struct:isQuest_ClearTen()) then
        return
    end

    -- b. 일일퀘스트 보상 2배 상품 적용 비활성화 상태
    if (not quest_struct:isDailyType()) then
        return
    end

    if (g_questData:isSubscriptionActive()) then
        return
    end

    -- c. 쿨 타임 
    local cool_time = g_settingData:getPromoteExpired('quest_double')
    if (cur_time < cool_time) then
        return
    end

    local func_show_popup 
    local func_refresh 
    -- 2. 퀘스트 2배 상품 소개 팝업
    func_show_popup = function()
        UI_PromoteQuestDouble(func_refresh, true) -- param : cb_func, is_promote
    end

    -- 3. 퀘스트 UI 갱신 (2배 상품 적용)
    func_refresh = function(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
        ui_quest_popup:close()
        UI_QuestPopup()
	end
    func_show_popup()

    -- 2018-11-20 일일퀘스트 2배 보상 상품 판매 촉진하는 팝업 쿨타임 14일
    local next_cool_time = cur_time + datetime.dayToSecond(14)
    -- 쿨 타임 만료시간 갱신
    g_settingData:setPromoteCoolTime('quest_double', next_cool_time)
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