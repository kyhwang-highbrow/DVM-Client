local PARENT = UI_QuestListItem

-------------------------------------
-- class UI_StoryDungeonEventQuestListItem
-------------------------------------
UI_StoryDungeonEventQuestListItem = class(PARENT, {
    m_questData = 'StructQuestData',
    m_lRewardCardUI = 'list-ItemCard',
})

-------------------------------------
-- function init_after
-------------------------------------
function UI_StoryDungeonEventQuestListItem:init_after(t_data)
	-- UI load
	self:load('story_dungeon_quest_item.ui')
    self.m_lRewardCardUI = {}

	-- initialize
    self:initUI()
    self:initButton()
    self:refresh(t_data)
end

-------------------------------------
-- function setQuestDescLabel
-- @brief 퀘스트 설명 표시
-------------------------------------
function UI_StoryDungeonEventQuestListItem:setQuestDescLabel()
    local vars = self.vars
    local quest_type = self.m_questData['quest_type']
    local desc = self.m_questData:getQuestDesc()

    if quest_type == 'daily' then
        vars['questLabel']:setString(string.format('{@yellow}%s{@}',desc))
    else
        vars['questLabel']:setString(desc)
    end
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_StoryDungeonEventQuestListItem:click_rewardBtn(ui_quest_popup)
    
    --ui_quest_popup:setBlock(true)
	local cb_function = function(t_quest_data)
		
        local is_mail = TableEventQuest:isRewardMailTypeQuest(self.m_questData['qid'])
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
        -- self:checkPromoteQuestDouble(ui_quest_popup)
	end

	g_eventDragonStoryDungeon:requestStoryDungeonQuestReward(self.m_questData, cb_function)
end


-------------------------------------
-- function makeRewardList
-------------------------------------
function UI_StoryDungeonEventQuestListItem:makeRewardList()
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

    l_total_reward = table.reverse(l_total_reward)
    return l_total_reward
end


-------------------------------------
-- function setRewardCard
-- @brief 보상 아이콘 표시
-------------------------------------
function UI_StoryDungeonEventQuestListItem:setRewardCard()
    local vars = self.vars

    local l_reward_info = self.m_questData:getRewardInfoList()
    local l_rewardCardUI = self.m_lRewardCardUI

    -- 이전 상품 UI 제거
    for i = 1, 5 do
        if (vars['rewardNode' .. i] ~= nil) then
            vars['rewardNode' .. i]:removeAllChildren()
        end
    end
    
    local reward_idx = 1
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
