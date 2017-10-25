-------------------------------------
-- class UI_AncientTowerRank
-------------------------------------
UI_AncientTowerRank = class({
        m_uiScene = 'UI_AncientTower',

        m_rewardInfo = 'table',
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
    self.m_rankOffset = 1
    self.m_rewardInfo = {}

	self:initUI()
    self:initButton()
end

UI_AncientTowerRank.RANKING = 'rankingList'
UI_AncientTowerRank.REWARD = 'rewardList'

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
    radio_button:addButtonAuto(UI_AncientTowerRank.RANKING, vars)
    radio_button:addButtonAuto(UI_AncientTowerRank.REWARD, vars)
    radio_button:setChangeCB(function() self:onChangeOption() end)
    self.m_typeRadioButton = radio_button

    vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end)
end

-------------------------------------
-- function onChangeOption
-------------------------------------
function UI_AncientTowerRank:onChangeOption()
    local vars = self.m_uiScene.vars
    local type = self.m_typeRadioButton.m_selectedButton
    vars['rewardListNode']:setVisible(type == UI_AncientTowerRank.REWARD)
    vars['rankingListNode']:setVisible(type == UI_AncientTowerRank.RANKING)
    vars['rankingMeNode']:setVisible(type == UI_AncientTowerRank.RANKING)

    local shop_btn = self.m_uiScene.vars['shopBtn']
    if (type == UI_AncientTowerRank.RANKING) then
        shop_btn:setVisible(false)

        if (self.m_rankTableView) then return end
        self:request_Rank()

    elseif (type == UI_AncientTowerRank.REWARD) then
        shop_btn:setVisible(true)

        if (self.m_rewardTableView) then return end
        local function finish_cb(ret)
            self.m_rewardInfo = ret['table_ancient_rank']
            self:init_rewardTableView()
        end

        g_ancientTowerData:request_ancientTowerSeasonRankInfo(finish_cb)
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
    my_node:removeAllChildren()

    -- 내 순위
	do
        local ui = UI_AncientTowerRankListItem(g_ancientTowerData.m_playerUserInfo)
        my_node:addChild(ui.root)
	end

    local l_item_list = g_ancientTowerData.m_lGlobalRank

    if (self.m_rankOffset > 1) then
        local prev_data = { m_tag = 'prev' }
        l_item_list['prev'] = prev_data
    end

    if (#l_item_list > 0) then
        local next_data = { m_tag = 'next' }
        l_item_list['next'] = next_data
    end

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

    do -- 테이블 뷰 정렬
        local function sort_func(a, b)
            local a_data = a['data']
            local b_data = b['data']

            -- 이전, 다음 버튼 정렬
            if (a_data.m_tag == 'prev') then
                return true
            elseif (b_data.m_tag == 'prev') then
                return false
            elseif (a_data.m_tag == 'next') then
                return false
            elseif (b_data.m_tag == 'next') then
                return true
            end

            -- 랭킹으로 선별
            local a_rank = a_data.m_rank
            local b_rank = b_data.m_rank 
            return a_rank < b_rank
            
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))   
end

-------------------------------------
-- function init_rewardTableView
-------------------------------------
function UI_AncientTowerRank:init_rewardTableView()
    local node = self.m_uiScene.vars['rewardListNode']

    local l_item_list = self.m_rewardInfo

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 160 + 5)
    table_view:setCellUIClass(UI_AncientTowerRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_rewardTableView = table_view

    table_view:makeDefaultEmptyDescLabel(Str('보상 정보가 없습니다.'))  
end

-------------------------------------
-- function click_shopBtn
-------------------------------------
function UI_AncientTowerRank:click_shopBtn()
    local ui_shop_popup = UI_Shop()
    ui_shop_popup:setTab('ancient')
end