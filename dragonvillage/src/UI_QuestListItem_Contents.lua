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


    if (data['reward'] == '') then
        return
    end

    if (not data['reward']) then
        return
    end

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_QuestListItem_Contents:initUI()
    local vars = self.vars
    local data = self.m_data

    -- 컨텐츠 이름
    local content_name = data['t_name']
    vars['contentsLabel']:setString(Str(content_name))

    -- 컨텐츠 설명
    local desc = data['t_desc_2']
    vars['dscLabel']:setString(Str(desc))

    -- 컨텐츠 열리는 조건
    local req_stage_id = data['req_stage_id']
    local difficulty, chapter, stage = parseAdventureID(req_stage_id)
    local stage_name = chapter .. '-' .. stage
    local condition_str = Str(data['t_desc'], stage_name, '') 
    vars['conditionLabel']:setString(Str(condition_str))

    -- 컨텐츠 이미지
    local res = data['res']
    local contents_icon = cc.Sprite:create(res)
    if (contents_icon) then
        vars['contentsNode']:addChild(contents_icon)
    end

    -- 퀘스트 보상
    -- @jhakim 190822 컨텐츠 보상은 하나만 있는 상태
    -- 2개이상 올 경우 대비해서 리스트 형식으로 보상을 출력
    local l_reward_info = TableQuest.arrangeDataByStr(data['reward'])
    local reward_idx = 1
    for i, v in ipairs(l_reward_info) do
        local reward_card = UI_ItemCard(v['item_id'], v['count'])
        reward_card.root:setSwallowTouch(false)
        vars['rewardNode']:addChild(reward_card.root)
        reward_idx = reward_idx + 1
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_QuestListItem_Contents:initButton()

end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_QuestListItem_Contents:click_rewardBtn(ui_quest_popup)
    local data = self.m_data

    local finish_cb = function()
        -- 우편함으로 전송
		local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)
        
        -- 갱신
        self:refresh()
        ui_quest_popup:refresh()
        ui_quest_popup:setBlock(false)
    end
    g_contentLockData:request_contentsOpenReward(data['content_name'], finish_cb) 
end

-------------------------------------
-- function click_questLinkBtn
-------------------------------------
function UI_QuestListItem_Contents:click_questLinkBtn()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuestListItem_Contents:refresh()
    local vars = self.vars
    local data = self.m_data

    local req_stage = data['req_stage_id']
    local is_available = g_adventureData:isClearStage(req_stage)
    local is_lock = g_contentLockData:isContentLock(data['content_name'])

    -- 컨텐츠 조건 만족 상태, 컨텐츠 잠금 상태 조합해서 버튼 상태 설정
    local reward_able = is_available and is_lock
    local after_reward = is_available and not is_lock
    local before_reward = not is_available
    
    vars['lockBtn']:setEnabled(false)
    vars['rewardBtn']:setVisible(false)
    vars['questLinkBtn']:setVisible(false)
    vars['lockBtn']:setVisible(false)

    -- 보상 받기 가능, 바로가기 버튼, 잠금 버튼
    if (reward_able) then
        vars['rewardBtn']:setVisible(true)
    elseif (after_reward) then
        vars['questLinkBtn']:setVisible(true)
    elseif (before_reward) then
        vars['lockBtn']:setVisible(true)
    else
        vars['lockBtn']:setVisible(true)
    end
end
