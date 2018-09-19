local PARENT = UI

local OFFSET_GAP = 30 -- 한번에 보여주는 랭커 수

-------------------------------------
-- class UI_ChallengeModeRankingPopup
-------------------------------------
UI_ChallengeModeRankingPopup = class(PARENT,{
        m_rankTableView = 'UIC_TableView',
        m_rankOffset = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeRankingPopup:init()
    self.m_uiName = 'UI_ChallengeModeRankingPopup'
    self.m_rankOffset = 1
    local vars = self:load('challenge_mode_ranking_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChallengeModeRankingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
    self:request_rank()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeModeRankingPopup:initUI()
    local vars = self.vars

    self:makeRankRewardTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModeRankingPopup:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeModeRankingPopup:refresh()
    self:refresh_playerUserInfo()
end

-------------------------------------
-- function refresh_playerUserInfo
-------------------------------------
function UI_ChallengeModeRankingPopup:refresh_playerUserInfo()
    local vars = self.vars

    -- 플레이어 정보 받아옴
    local struct_user_info = g_challengeMode:getPlayerArenaUserInfo()
    local ui = UI_ChallengeModeRankingListItem(struct_user_info)
    vars['rankingMeNode']:removeAllChildren()
    vars['rankingMeNode']:addChild(ui.root)
end

-------------------------------------
-- function request_rank
-------------------------------------
function UI_ChallengeModeRankingPopup:request_rank()
    local function finish_cb()
        self.m_rankOffset = g_challengeMode.m_nGlobalOffset
        self:makeRankTableView()
        self:refresh_playerUserInfo()
    end
    local offset = self.m_rankOffset
    g_challengeMode:request_challengeModeRanking(offset, finish_cb)
end

-------------------------------------
-- function makeRankTableView
-------------------------------------
function UI_ChallengeModeRankingPopup:makeRankTableView()
    local vars = self.vars
    local node = vars['rankingListNode']
    node:removeAllChildren()

    local l_item_list = g_challengeMode.m_lGlobalRank

    if (1 < self.m_rankOffset) then
        local prev_data = { m_tag = 'prev' }
        l_item_list['prev'] = prev_data
    end

    local next_data = { m_tag = 'next' }
    l_item_list['next'] = next_data
    
    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_rankOffset = self.m_rankOffset - OFFSET_GAP
        self.m_rankOffset = math_max(self.m_rankOffset, 0)
        self:request_rank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local add_offset = #g_challengeMode.m_lGlobalRank
        if (add_offset < OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_rankOffset = self.m_rankOffset + add_offset
        self:request_rank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(550, 75 + 5)
    table_view:setCellUIClass(UI_ChallengeModeRankingListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    do-- 테이블 뷰 정렬
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
    self.m_rankTableView = table_view
end


-------------------------------------
-- function makeRankRewardTableView
-- @brief 보상 정보 테이블 뷰 생성
-------------------------------------
function UI_ChallengeModeRankingPopup:makeRankRewardTableView()
    local node = self.vars['rankRewardNode']

    local l_item_list = g_challengeMode.m_challengeRewardTable or {}

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(550, 75 + 5)
    table_view:setCellUIClass(UI_ChallengeModeRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    --self.m_rewardTableView = table_view

    table_view:makeDefaultEmptyDescLabel(Str('보상 정보가 없습니다.'))  
end

--@CHECK
UI:checkCompileError(UI_ChallengeModeRankingPopup)
