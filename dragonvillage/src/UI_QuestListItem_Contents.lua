local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_QuestListItem_Contents
-------------------------------------
UI_QuestListItem_Contents = class(PARENT, {
        m_data = 'table',
        --{
        --        "t_desc_2":"자수정, 룬 획득 가능",
        --        "req_stage_id":1110107,
        --        "content_name":"exploation",
        --        "res":"res/ui/icons/content/dungeon_tree.png",
        --        "beta":"",
        --        "t_desc":"모험 {1}{2} 스테이지 클리어 필요",
        --        "open_desc":"",
        --        "t_name":"탐험",
        --        "reward":"700001;100"
        --}
    })

-------------------------------------
-- function init
-------------------------------------
function UI_QuestListItem_Contents:init(data)
	self:load('quest_item_contents_open.ui')
    self.m_data = data

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_QuestListItem_Contents:initButton()
    local vars = self.vars
    local data = self.m_data
    vars['rewardBtn']:registerScriptTapHandler(function() g_contentLockData:request_contentsOpenReward(data['content_name']) end)
end