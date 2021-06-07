local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_QuestListItem_Contents
-------------------------------------
UI_QuestListItem_Contents = class(PARENT, {
        m_data = 'table',
        --{
        --        "t_desc_2":"자수정, 룬 획득 가능",
        --        "req_stage_id":1110107,
        --        "content_name":"exploration",
        --        "beta":"",
        --        "t_name":"탐험",
        --        "reward":"700001;100"
        --}

        m_rewardUI = 'ItemCard',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_QuestListItem_Contents:init(data)
	self:load('quest_item_contents_open.ui')
    self.m_data = data

	-- 컨텐츠 퀘스트 리스트에 보상이 없는 경우는 들어와서는 안됨
	-- UI만들다가 오류나므로 return
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
    local content_name = data['content_name']
    
    
    -- table_conent_help.csv *********
    local table_contents = TABLE:get('table_content_help')
    local t_contents = table_contents[content_name]

    if (not t_contents) then
        return
    end

    -- 컨텐츠 이름
    local content_name = t_contents['t_name']
    vars['contentsLabel']:setString(Str(content_name))

    -- 컨텐츠 설명
    local desc = t_contents['t_desc_2']
    vars['dscLabel']:setString(Str(desc))

    -- 컨텐츠 이미지
    local res = t_contents['res']
    local contents_icon = cc.Sprite:create(res)
    if (contents_icon) then
        vars['contentsNode']:addChild(contents_icon)
        contents_icon:setPositionX(75)
        contents_icon:setPositionY(75)
    end


    -- table_conent_lock.csv ************

    -- 컨텐츠 열리는 조건(스테이지)
	local condition_str = UI_QuestListItem_Contents.makeConditionDesc(data['req_stage_id'], data['t_desc'])
    vars['conditionLabel']:setString(Str(condition_str))

    -- 퀘스트 보상
    -- @jhakim 190822 컨텐츠 보상은 하나만 있는 상태
    local t_item = plSplit(data['reward'], ';')
    local item_id = tonumber(t_item[1])
    local item_cnt = tonumber(t_item[2])
    local reward_card = UI_ItemCard(item_id, item_cnt)
	if (reward_card) then
		reward_card.root:setSwallowTouch(false)
		vars['rewardNode']:addChild(reward_card.root)
	    self.m_rewardUI = reward_card
    end    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_QuestListItem_Contents:initButton()
    local vars = self.vars
    local data = self.m_data
    
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn(data['t_name']) end)
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_QuestListItem_Contents:click_rewardBtn(ui_quest_popup)
    local data = self.m_data
    local content_name = data['content_name']
    local finish_cb = function(l_reward_item) -- added_items로 받은 보상
        
        -- 갱신
        self:refresh()
		ui_quest_popup:refresh()

        -- 콘텐츠 오픈 팝업
        local ui_open = UI_ContentOpenPopup(content_name)
        UI_ObtainToastPopup(l_reward_item)
    end
    g_contentLockData:request_contentsOpenReward(content_name, finish_cb) 
end

-------------------------------------
-- function click_questLinkBtn
-------------------------------------
function UI_QuestListItem_Contents:click_questLinkBtn(ui_quest_popup)
    local data = self.m_data
    local content_name = data['content_name']
	
	if (content_name == 'daily_shop') then
		--UINavigator:goTo('shop_daily', true) -- content_name, is_popup
        UINavigator:goTo('package_shop_test', 'package_daily')
	else
		-- 바로가기
		UINavigator:goTo(content_name)
	end

 
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
    
    -- 버튼 상태 초기화
    vars['lockBtn']:setEnabled(false)
    vars['rewardBtn']:setVisible(false)
    vars['questLinkBtn']:setVisible(false)
    vars['lockBtn']:setVisible(false)

    -- 아이템 카드 체크 표시 안 한 상태로 초기화
    self.m_rewardUI:setCheckSpriteVisible(false)


    -- return 0 : 잠금
    -- return 1 : 보상 가능
    -- return 2 : 보상 받음
    local reward_state = UI_QuestListItem_Contents.getRewardState(content_name)

    -- 보상 받기 가능, 바로가기 버튼, 잠금 버튼
    if (reward_state == 0) then
        vars['lockBtn']:setVisible(true)
    elseif (reward_state == 1) then
        vars['rewardBtn']:setVisible(true)
    elseif (reward_state == 2) then
        vars['questLinkBtn']:setVisible(true)
        self.m_rewardUI:setCheckSpriteVisible(true)
    else
        vars['questLinkBtn']:setVisible(true)
    end
end

-------------------------------------
-- function getRewardState
-- @return 0 : 잠금
-- @return 1 : 보상 가능
-- @return 2 : 보상 받음
-------------------------------------
function UI_QuestListItem_Contents.getRewardState(content_name)
    local reward_done = g_contentLockData:isRewardDone(content_name)
    local is_lock = g_contentLockData:isContentLock(content_name)
    
    if (reward_done) then
        return 2
    elseif (is_lock) then
        return 0
    elseif (not reward_done) then
        return 1
    else
        return 0
    end
end

-------------------------------------
-- function makeConditionDesc
-- ex) 모험 보통 1-7 스테이지 클리어 필요/ 문구를 조합해서 만듬
-------------------------------------
function UI_QuestListItem_Contents.makeConditionDesc(req_stage_id, t_desc)
    local t_desc = Str(t_desc)

	if (not req_stage_id) then
		return ''
	end

	if (req_stage_id == '') then
		return t_desc or ''
	end

	if (not t_desc) then
		return ''
	end

    local req_stage_id = req_stage_id
    local condition_str = t_desc
    local t_diff = {Str('보통'), Str('어려움'), Str('지옥'), Str('불지옥')}
	
	local condition_str = ''
    local difficulty, chapter, stage = parseAdventureID(req_stage_id)
    local stage_name = chapter .. '-' .. stage
    condition_str = Str(t_desc, t_diff[difficulty], stage_name) -- ex) 모험 보통 1-7 스테이지 클리어 필요/ 문구를 조합해서 만듬
	return condition_str
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_QuestListItem_Contents:click_infoBtn()
    local data = self.m_data
    local content_name = data['content_name']
    UI_HelpContents(content_name)
end
