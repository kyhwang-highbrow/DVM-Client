local PARENT = UI
-------------------------------------
-- class UI_StoryDungeonEventQuest
-------------------------------------
UI_StoryDungeonEventQuest = class(PARENT,{
    m_seasonId = 'string',
    m_itemUiList = '',
    m_titleStr = '',
    m_container = '',
    m_containerTopPosY = '',
    m_tableView = 'tableview',
    m_allClearQuestCell = 'UI_QuestListItem',
})

-------------------------------------
-- function init
-------------------------------------
function UI_StoryDungeonEventQuest:init(season_id)
    self.m_seasonId = season_id
    self.m_uiName = 'UI_StoryDungeonEventQuest'
    self.m_titleStr = ''
    local vars = self:load('story_dungeon_quest.ui')
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_StoryDungeonEventQuest')
    UIManager:open(self, UIManager.SCENE)
    self:initUI()
    self:initButton()

    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StoryDungeonEventQuest:initUI()
    local vars = self.vars
    self:makeQuestTableView(TableQuest.CHALLENGE, vars['listNode'])

    do -- 타이틀
        local str = TableStoryDungeonEvent:getStoryDungeonEventName(self.m_seasonId)
        vars['titleLabel']:setString(str)
    end

--[[     -- 종료 시간
    local end_text = g_mandragoraQuest:getStatusText()
    vars['timeLabel']:setString(end_text)

    -- 최종 보상을 받기 위한 퀘스트 수
    local last_reward_condition = g_mandragoraQuest:getLastRewardCondition()
    vars['infoLabel']:setString(Str('{1}일차 클리어 시 스페셜 보상 획득!', last_reward_condition))

    -- 퀘스트 UI
    self.m_itemUiList = {}
    local quest_info = g_mandragoraQuest.m_questInfo
    for i, v in ipairs(quest_info) do
        local ui = UI_StoryDungeonEventQuestListItem(v)
        ui.m_refreshFunc = function()
            self:refresh()
        end

        local node = vars['node'.. i]
        if (node) then
            node:addChild(ui.root)
            table.insert(self.m_itemUiList, ui)
        end
    end


    -- 최종 보상 UI
    do
        local last_reward_info = g_mandragoraQuest:getLastRewardInfo()

        for idx, v in ipairs(last_reward_info) do
            local node_name = 'itemNode' .. idx

            if (vars[node_name] == nil) then
                if (idx == 1) then
                    node_name = 'itemNode'
                else
                    break
                end
            end

            local item_card_ui = UI_ItemCard(v['item_id'], v['count'])
            local item_id = v['item_id']
            local did = tonumber(TableItem:getDidByItemId(item_id))
            if did and (0 < did) then
                item_card_ui.vars['clickBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 1, 0.8, true) end)
            end

            vars[node_name]:addChild(item_card_ui.root)
        end
    end ]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StoryDungeonEventQuest:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end) -- 닫기
end

-------------------------------------
-- function makeQuestTableView
-------------------------------------
function UI_StoryDungeonEventQuest:makeQuestTableView(tab, node)
    local vars = self.vars

	-- 퀘스트 뭉치
	local l_quest = g_eventDragonStoryDungeon:getQuestList()
    for idx, v in pairs(l_quest) do
        v['idx'] = idx
    end

    -- 테이블 뷰 생성
    node:removeAllChildren()

    -- 퀘스트 팝업 자체를 각 아이템이 가지기 위한 생성 콜백
    local create_cb_func = function(ui, data)
        self:cellCreateCB(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    require('UI_StoryDungeonEventQuestListItem')
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1160 + 10, 80 + 10)
    table_view:setCellUIClass(UI_StoryDungeonEventQuestListItem, create_cb_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_quest)
    table_view:insertSortInfo('sort', self.sortQuestList)
    self.m_tableView = table_view
end

-------------------------------------
-- function sortQuestList
-------------------------------------
function UI_StoryDungeonEventQuest.sortQuestList(a, b)
    local a_data = a['data']
    local b_data = b['data']

    -- "일일 퀘스트 10개 클리어하기" 항목은 최상단으로 고정
    if (a_data:getQuestClearType() ~= b_data:getQuestClearType()) then
        if (a_data:getQuestClearType() == 'dq_clear') then
            return true
        elseif (b_data:getQuestClearType() == 'dq_clear') then
            return false
        end
    end

    if (a_data:isEnd() and not b_data:isEnd()) then
        return false
    elseif (not a_data:isEnd() and b_data:isEnd()) then
        return true
    elseif (a_data:hasReward() and not b_data:hasReward()) then
        return true
    elseif (not a_data:hasReward() and b_data:hasReward()) then
        return false
    else
        return (a_data:getQid() < b_data:getQid())
    end
end

-------------------------------------
-- function cellCreateCB
-------------------------------------
function UI_StoryDungeonEventQuest:cellCreateCB(ui, data)
    -- 보상 받기 버튼
	local function click_rewardBtn()
		ui:click_rewardBtn(self)
	end

	ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)
    -- 바로가기 버튼
	local function click_questLinkBtn()
		ui:click_questLinkBtn(self)
	end
	ui.vars['questLinkBtn']:registerScriptTapHandler(click_questLinkBtn)
end

-------------------------------------
-- function click_receiveBtn
-------------------------------------
function UI_StoryDungeonEventQuest:click_receiveBtn()
    local function refresh_cb()
        self:refresh()
    end
    
    g_mandragoraQuest:request_clearLastReward(refresh_cb)
end

-------------------------------------
-- function open
-------------------------------------
function UI_StoryDungeonEventQuest.open(season_id)
    local ui = UI_StoryDungeonEventQuest(season_id)
end