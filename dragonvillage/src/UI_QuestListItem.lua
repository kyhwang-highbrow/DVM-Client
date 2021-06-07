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

        m_lRewardCardUI = 'list-ItemCard',
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


    self.m_lRewardCardUI = {}

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
	    self:setRewardCard() -- 보상 카드 만들기
        self:setVarsVisible() -- 보상 수령 여부에 따른 상태 갱신(보상카드 상태도 바뀌므로 setRewardCard() 함수 다음에 수행되어야함)
	    self:setQuestDescLabel()
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
    local l_rewardCardUI = self.m_lRewardCardUI

    -- 이전 상품 UI 제거
    for i = 1, 5 do
        if (vars['rewardNode' .. i] ~= nil) then
            vars['rewardNode' .. i]:removeAllChildren()
        end
    end

    -- @mskim UI에 출력할 순서에 따라 아래 보상 추가 로직의 순서를 변경한다.

    local reward_idx = 1

    -- 이벤트 보상 (3주년 신비의 알 100개 부화 이벤트, event_daily_quest)
    -- @mskim 이벤트 보상은 이벤트 스프라이트를 표시한다.
    if (self.m_questData:isDailyType()) then
        local l_event_reward_list = self.m_questData:getEventRewardInfoList()
        if (l_event_reward_list) then
            for i, v in ipairs(l_event_reward_list) do
                local reward_card = UI_ItemCard(v['item_id'], v['count'])
                reward_card.root:setSwallowTouch(false)
                local reward_node = vars['rewardNode' .. reward_idx]
                if (reward_node) then
                    if (reward_card) then
                        reward_node:removeAllChildren()
                        reward_node:addChild(reward_card.root)
                        reward_idx = reward_idx + 1
                        table.insert(l_rewardCardUI, reward_card)
                    end
                end
                -- 아이템카드의 이벤트 스프라이트
                if (reward_card.vars['eventSprite']) then
                    reward_card.vars['eventSprite']:setVisible(true)
                end
            end
        end
    end

    -- 일일 퀘스트 보상 2배 적용 중일 경우
    if self.m_questData:isDailyType() and g_supply:isActiveSupply_dailyQuest() then
        for i, v in ipairs(l_reward_info) do
            local drainage = 2 -- 2배
            local reward_card = UI_ItemCard(v['item_id'], tonumber(v['count']) * drainage)
            reward_card.root:setSwallowTouch(false)
            local reward_node = vars['rewardNode' .. reward_idx]
            reward_card.vars['bonusSprite']:setVisible(true)
            reward_card.vars['bonusLabel']:setString('')
            if (reward_node) then
                if (reward_card) then
                    reward_node:removeAllChildren()
                    reward_node:addChild(reward_card.root)
                    reward_idx = reward_idx + 1
                    table.insert(l_rewardCardUI, reward_card)
                end
            end
        end
    else
        -- 기본 퀘스트 보상
        for i, v in ipairs(l_reward_info) do
            local reward_card = UI_ItemCard(v['item_id'], v['count'])
            reward_card.root:setSwallowTouch(false)
            local reward_node = vars['rewardNode' .. reward_idx]
            if (reward_node) then
                if (reward_card) then
                    reward_node:removeAllChildren()
                    reward_node:addChild(reward_card.root)
                    reward_idx = reward_idx + 1
                    table.insert(l_rewardCardUI, reward_card)
                end
            end
        end
    end

	-- 클랜 경험치
	if (not g_clanData:isClanGuest()) then
		local clan_exp = self.m_questData:getRewardClanExp()
		if (clan_exp) then
			local clan_exp_card = UI_ClanExpCard(clan_exp)
            clan_exp_card.root:setSwallowTouch(false)
			local reward_node = vars['rewardNode' .. reward_idx]
			if (reward_node) then
                if (clan_exp_card) then
                    reward_node:removeAllChildren()
				    reward_node:addChild(clan_exp_card.root)
                    reward_idx = reward_idx + 1
                    table.insert(l_rewardCardUI, clan_exp_card)
                end
            end
		end
	end

	-- 배틀패스 포인트
	if (self.m_questData:isDailyType() and g_questData:isBattlePassActive()
        and g_battlePassData:isPurchasedAnyProduct()) then
        -- 당분간 고정으로 10만 지급함
		local battlePassExp = 10
        local battle_pass_exp_card = UI_BattlePassCard(battlePassExp)
        battle_pass_exp_card.root:setSwallowTouch(false)
        local reward_node = vars['rewardNode' .. reward_idx]
        if (reward_node) then
            if (battle_pass_exp_card) then
                reward_node:removeAllChildren()
                reward_node:addChild(battle_pass_exp_card.root)
                reward_idx = reward_idx + 1
                table.insert(l_rewardCardUI, battle_pass_exp_card)
            end
        end
	end

    local max_reward = reward_idx - 1
    -- 아이템 카드에 보상 받음 여부 표시(체크 표시)
    for i = 1, max_reward do
        local reward_check_node = vars['checkNode' .. i]
        if (reward_check_node) then
            reward_check_node:removeAllChildren()
            local check_sprite = cc.Sprite:create('res/ui/icons/check_icon_0103.png')
            if (check_sprite) then
                check_sprite:setDockPoint(CENTER_POINT)
                check_sprite:setAnchorPoint(CENTER_POINT)
                reward_check_node:addChild(check_sprite)

                local is_reward_done = self:isRewardDone()
                reward_check_node:setVisible(is_reward_done)
            end
        end
    end
end

-------------------------------------
-- function isRewardDone
-------------------------------------
function UI_QuestListItem:isRewardDone()
    local quest_data = self.m_questData

    local has_reward = quest_data:hasReward()
    local is_end = quest_data:isEnd()

    local reward_done = (not has_reward) and (is_end)
    return reward_done
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
    
    --ui_quest_popup:setBlock(true)
	local cb_function = function(t_quest_data)
		
        local is_mail = TableQuest:isRewardMailTypeQuest(self.m_questData['qid'])
        local l_reward = self:makeRewardList()
        if (not is_mail) then
            UI_ObtainToastPopup(l_reward)
        else
            -- 우편함으로 전송
		    local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
            UI_ToastPopup(toast_msg)
		end

        -- idx 교체 (테이블뷰의 아이템을 찾기위해 현재것으로 idx 지정)
        if (t_quest_data) then
            t_quest_data['idx'] = self.m_questData['idx']
        end

		-- 갱신
		self:refresh(t_quest_data)
		ui_quest_popup:refresh(t_quest_data)
		--ui_quest_popup:setBlock(false)

        -- 일일퀘스트 보상 2배 상품 판매촉진하는 팝업 조건 체크 후 팝업 출력
        self:checkPromoteQuestDouble(ui_quest_popup)
	end

	g_questData:requestQuestReward(self.m_questData, cb_function)
end

-------------------------------------
-- function makeRewardList
-------------------------------------
function UI_QuestListItem:makeRewardList()
    local l_total_reward = {}
    local l_reward_info = self.m_questData:getRewardInfoList()
    for _, v in ipairs(l_reward_info) do
        table.insert(l_total_reward, v)
    end
    
    -- 일퀘에만 적용
    if (not self.m_questData:isDailyType()) then
        l_total_reward = table.reverse(l_total_reward)
        return l_total_reward
    end
    
    -- 구독 상품인 경우 상품 한 번 더 표시
    if g_supply:isActiveSupply_dailyQuest() then
        for _, v in ipairs(l_reward_info) do
            table.insert(l_total_reward, v)
        end
    end
    
    -- 클랜 경험치 표시
    if (not g_clanData:isClanGuest()) then
		local clan_exp = self.m_questData:getRewardClanExp()
		if (clan_exp) then
            local t_data = {}
            t_data['item_id'] = 'clan_exp'
            t_data['count'] = clan_exp
            table.insert(l_total_reward, t_data)
		end
    end

	-- 배틀패스 포인트
	if (self.m_questData:isDailyType() and g_questData:isBattlePassActive()) then
        -- 당분간 고정으로 10만 지급함
		local battlePassExp = 10
        local t_data = {}
        t_data['item_id'] = 'pass_point'
        t_data['count'] = battlePassExp
        table.insert(l_total_reward, t_data)
	end

    -- 일일 퀘스트 이벤트 (3주년 신비의 알 100개 부화 이벤트, event_daily_quest)
    local l_event_reward_list = self.m_questData:getEventRewardInfoList()
    if (l_event_reward_list) then
        for i, v in ipairs(l_event_reward_list) do
            table.insert(l_total_reward, v)
        end
    end

    l_total_reward = table.reverse(l_total_reward)
    return l_total_reward
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

    if (g_supply:isActiveSupply_dailyQuest()) then
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
        --UI_PromoteQuestDouble(func_refresh, true) -- param : cb_func, is_promote
        require('UI_SupplyProductInfoPopup_QuestDouble')
        UI_SupplyProductInfoPopup_QuestDouble(true, func_refresh) -- param : is_promote, cb_func
    end

    -- 3. 퀘스트 UI 갱신 (2배 상품 적용)
    func_refresh = function(ret)
        --[[
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
        ui_quest_popup:close()
        UI_QuestPopup()
        --]]
        
        -- 일일 퀘스트 보상 2배 상품 구매 후 콜백
        ui_quest_popup:questDoubleBuySuccessCB(ret)
	end
    func_show_popup()

    -- 2019-01-08 일일퀘스트 2배 보상 상품 판매 촉진하는 팝업 쿨타임 7일
    local next_cool_time = cur_time + datetime.dayToSecond(7)
    -- 쿨 타임 만료시간 갱신
    g_settingData:setPromoteCoolTime('quest_double', next_cool_time)
end

-------------------------------------
-- function click_questLinkBtn
-------------------------------------
function UI_QuestListItem:click_questLinkBtn(ui_quest_popup)
    -- 바로가기
    local clear_type = self.m_questData:getQuestClearType()
	
    -- 인연 던전일 경우 활성화된 던전이 있는지 체크
    if (string.find(clear_type, 'ply_rel') or string.find(clear_type, 'fnd_rel')) then
        if (not g_secretDungeonData:isSecretDungeonExist()) then
            UIManager:toastNotificationRed(Str('발견한 인연던전이 없습니다.'))
			return
        end
    end

    -- 퀘스트 팝업은 꺼버린다.
    if (ui_quest_popup and ui_quest_popup.closed == false) then
        ui_quest_popup:closeWithoutCB()
    end

    QuickLinkHelper.quickLink(clear_type)
end