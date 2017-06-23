-------------------------------------
-- class UI_AncientTowerRank
-------------------------------------
UI_AncientTowerRank = class({
        m_uiScene = 'UI_AncientTowerScene',

        m_typeRadioButton = 'UIC_RadioButton',

        m_rankTableView = 'UIC_TableView',  -- 랭크 리스트
        m_rewardTableView = 'UIC_TableView',  -- 보상 리스트

        m_rankOffset = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerRank:init(ui_scene)
    self.m_uiScene = ui_scene
    self.m_rankOffset = 1

	self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerRank:initUI()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerRank:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerRank:initButton()
    local vars = self.m_uiScene.vars

    -- radio button 선언
    local radio_button = UIC_RadioButton()
	radio_button:setChangeCB(function() self:onChangeOption() end)
    radio_button:addButton('rank', vars['rankingListBtn'])
    radio_button:addButton('reward', vars['rewardListBtn'])
	self.m_typeRadioButton = radio_button

    radio_button:setSelectedButton('rank')
end

-------------------------------------
-- function onChangeOption
-------------------------------------
function UI_AncientTowerRank:onChangeOption()
    local vars = self.m_uiScene.vars
    local type = self.m_typeRadioButton.m_selectedButton
    vars['rewardListNode']:setVisible(type == 'reward')
    vars['rankingListNode']:setVisible(type == 'rank')
    vars['rankingMeNode']:setVisible(type == 'rank')

    if type == 'rank' then
        if (self.m_rankTableView) then return end

        local function finish_cb()
            self:init_rankTableView()
        end
        local offset = self.m_rankOffset
        g_ancientTowerData:request_ancientTowerRank(offset, finish_cb)

    elseif type == 'reward' then
        if (self.m_rewardTableView) then return end
        self:init_rewardTableView()
    end
end

-------------------------------------
-- function init_rankTableView
-------------------------------------
function UI_AncientTowerRank:init_rankTableView()
    local node      = self.m_uiScene.vars['rankingListNode']
    local my_node   = self.m_uiScene.vars['rankingMeNode']

    -- 내 순위
	do
		local t_my_rank = g_ancientTowerData.m_myRank
        t_my_rank['score'] = math_max(t_my_rank['score'], 0)
        
        local ui = UI_AncientTowerRankListItem(t_my_rank)
        my_node:addChild(ui.root)
	end

    -- 최초 상위 20명
    local l_item_list = g_ancientTowerData.m_lGlobalRank

    --[[
    if (1 < self.m_rankOffset) then
        local prev_data = {m_rank = 'prev'}
        l_item_list['prev'] = prev_data
    end
    local next_data = {m_rank = 'next'}
    l_item_list['next'] = next_data
    ]]--

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_previousButton()
        end
        --ui.vars['previousButton']:registerScriptTapHandler(click_previousButton)

        local function click_nextButton()
        end
        --ui.vars['nextButton']:registerScriptTapHandler(click_nextButton)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 100 + 5)
    table_view:setCellUIClass(UI_AncientTowerRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_rankTableView = table_view

    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))   
end

-------------------------------------
-- function init_rewardTableView
-------------------------------------
function UI_AncientTowerRank:init_rewardTableView()
    local node = self.m_uiScene.vars['rewardListNode']

    local t_reward = TABLE:get('anc_rank_reward')
    local l_item_list = t_reward

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 160 + 5)
    table_view:setCellUIClass(UI_AncientTowerRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_rewardTableView = table_view

    table_view:makeDefaultEmptyDescLabel(Str('보상 정보가 없습니다.'))  
end

