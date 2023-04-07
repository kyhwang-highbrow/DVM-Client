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
        self:checkPromoteQuestDouble(ui_quest_popup)
	end

	g_eventDragonStoryDungeon:requestStoryDungeonQuestReward(self.m_questData, cb_function)
end
