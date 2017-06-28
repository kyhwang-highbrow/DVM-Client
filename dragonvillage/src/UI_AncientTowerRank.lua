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

local RANK_SHOW_CNT = 20 -- 한번에 보여주는 랭커 수

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerRank:init(ui_scene)
    self.m_uiScene = ui_scene
    self.m_rankOffset = 0

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
    radio_button:addButton('rank', vars['rankingListBtn'])
    radio_button:addButton('reward', vars['rewardListBtn'])
    radio_button:setChangeCB(function() self:onChangeOption() end)
    self.m_typeRadioButton = radio_button
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

    if (type == 'rank') then
        if (self.m_rankTableView) then return end
        self:request_Rank()

    elseif (type == 'reward') then
        if (self.m_rewardTableView) then return end
        self:init_rewardTableView()
    end
end

-------------------------------------
-- function request_Rank
-------------------------------------
function UI_AncientTowerRank:request_Rank()
    local function finish_cb()
        self.m_rankOffset = g_ancientTowerData.m_nGlobalOffset
        self:init_rankTableView()
    end
    local offset = self.m_rankOffset
    g_ancientTowerData:request_ancientTowerRank(offset, finish_cb)
end

-------------------------------------
-- function init_rankTableView
-------------------------------------
function UI_AncientTowerRank:init_rankTableView()
    local node      = self.m_uiScene.vars['rankingListNode']
    local my_node   = self.m_uiScene.vars['rankingMeNode']

    node:removeAllChildren()

    -- 내 순위
	do
		local t_my_rank = g_ancientTowerData.m_myRank
        t_my_rank['score'] = math_max(t_my_rank['score'], 0)
        
        local ui = UI_AncientTowerRankListItem(t_my_rank)
        my_node:addChild(ui.root)
	end

    local l_item_list = g_ancientTowerData.m_lGlobalRank

    if (0 < self.m_rankOffset) then
        local prev_data = { rank = 'prev' }
        l_item_list['prev'] = prev_data
    end

    local next_data = { rank = 'next' }
    l_item_list['next'] = next_data
    
    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_rankOffset = self.m_rankOffset - RANK_SHOW_CNT
        self.m_rankOffset = math_max(self.m_rankOffset, 0)
        self:request_Rank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local add_offset = #g_ancientTowerData.m_lGlobalRank
        if (add_offset < RANK_SHOW_CNT) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_rankOffset = self.m_rankOffset + add_offset
        self:request_Rank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 100 + 5)
    table_view:setCellUIClass(UI_AncientTowerRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_rankTableView = table_view

    -- 테이블 뷰 정렬
    g_ancientTowerData:sortAncientRank(table_view.m_itemList)

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

