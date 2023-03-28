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