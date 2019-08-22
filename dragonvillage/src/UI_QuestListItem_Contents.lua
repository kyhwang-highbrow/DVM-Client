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
    local t_item = plSplit(data['reward'], ';')
    local item_id = tonumber(t_item[1])
    local item_cnt = tonumber(t_item[2])
    local reward_card = UI_ItemCard(item_id, item_cnt)
    reward_card.root:setSwallowTouch(false)
    vars['rewardNode']:addChild(reward_card.root)

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
    local content_name = data['content_name']
    local finish_cb = function()
        
        local close_cb = function()
            -- 우편함으로 전송
            local t_item = plSplit(data['reward'], ';')
            local t_data = {}
            t_data['item_id'] = tonumber(t_item[1])
            t_data['count'] = tonumber(t_item[2])
            local reward_str = UIHelper:makeItemStr(t_data)
            UI_ToastPopup(reward_str)
        end
        
        local ui_open = UI_ContentOpenPopup(content_name)
        ui_open:setCloseCB(close_cb)
        
        -- 갱신
        self:refresh()
    end
    g_contentLockData:request_contentsOpenReward(content_name, finish_cb) 
end

-------------------------------------
-- function click_questLinkBtn
-------------------------------------
function UI_QuestListItem_Contents:click_questLinkBtn(ui_quest_popup)
    local data = self.m_data
    
    -- 바로가기
    UINavigator:goTo(data['content_name'])

    -- 퀘스트 팝업은 꺼버린다.
    if (ui_quest_popup and ui_quest_popup.closed == false) then
        ui_quest_popup:close()
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuestListItem_Contents:refresh()
    local vars = self.vars
    local data = self.m_data
    local content_name = data['content_name']
    local req_stage = data['req_stage_id']


    -- 컨텐츠 조건 만족 상태, 컨텐츠 잠금 상태 조합해서 버튼 상태 설정
    local is_reward = UI_QuestListItem_Contents.isRewardable(content_name, req_stage)
    local after_reward = UI_QuestListItem_Contents.isRewardAfter(content_name, req_stage)
    local before_reward = UI_QuestListItem_Contents.isRewardBefore(content_name, req_stage)
    
    vars['lockBtn']:setEnabled(false)
    vars['rewardBtn']:setVisible(false)
    vars['questLinkBtn']:setVisible(false)
    vars['lockBtn']:setVisible(false)

    -- 보상 받기 가능, 바로가기 버튼, 잠금 버튼
    if (is_reward) then
        vars['rewardBtn']:setVisible(true)
    elseif (after_reward) then
        vars['questLinkBtn']:setVisible(true)
    elseif (before_reward) then
        vars['lockBtn']:setVisible(true)
    else
        vars['lockBtn']:setVisible(true)
    end
end

-------------------------------------
-- function isRewardable
-------------------------------------
function UI_QuestListItem_Contents.isRewardable(content_name, req_stage)
    local is_available = g_adventureData:isClearStage(req_stage)
    local is_lock = g_contentLockData:isContentLock(content_name)

    -- 컨텐츠 조건 만족 상태, 컨텐츠 잠금 상태 조합해서 버튼 상태 설정
    local reward_able = is_available and is_lock
    return reward_able
end

-------------------------------------
-- function isRewardAfter
-------------------------------------
function UI_QuestListItem_Contents.isRewardAfter(content_name, req_stage)
    local is_available = g_adventureData:isClearStage(req_stage)
    local is_lock = g_contentLockData:isContentLock(content_name)

    -- 컨텐츠 조건 만족 상태, 컨텐츠 잠금 상태 조합해서 버튼 상태 설정
    local after_reward = is_available and not is_lock
    return after_reward
end

-------------------------------------
-- function isRewardBefore
-------------------------------------
function UI_QuestListItem_Contents.isRewardBefore(content_name, req_stage)
    local is_available = g_adventureData:isClearStage(req_stage)
    local is_lock = g_contentLockData:isContentLock(content_name)

    -- 컨텐츠 조건 만족 상태, 컨텐츠 잠금 상태 조합해서 버튼 상태 설정
    local before_reward = not is_available

    return before_reward
end
