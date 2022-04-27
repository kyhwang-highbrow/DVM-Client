

local PARENT = UI_IndivisualTab

------------------------------------- 
-- class UI_EventRouletteRankingTab
-------------------------------------
UI_EventRouletteRankingTab = class(PARENT,{
        m_rankTableView = 'UIC_TableView',
        m_rankType = 'string',
        m_rankFullType = 'string',
        m_rankOffset = 'number',
        
        m_ownerUI = 'UI_EventIncarnationOfSinsRankingPopup', -- 현재 검색 타입에 대해 받아올 때 필요

        m_rewardTableView = '',
        m_selectedUI = '',

        m_parentVars = '',
        m_tabType = '',
    })

local OFFSET_GAP = 30

-------------------------------------
-- function init
-------------------------------------
function UI_EventRouletteRankingTab:init(owner_ui, parent_vars, tab_type)
    self.m_rankOffset = 1
    self.m_parentVars = parent_vars
    self.m_tabType = tab_type

    self.m_ownerUI = owner_ui
    self.m_rankType = owner_ui.m_rankType

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventRouletteRankingTab:initUI()
    local vars = self.m_parentVars

    -- 보상 테이블뷰
    self:makeRankRewardTableView()
end


-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventRouletteRankingTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
        self.m_rankType = self.m_ownerUI.m_rankType

        self:refreshRank(self.m_rankType)
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_EventRouletteRankingTab:onExitTab()

end


-------------------------------------
-- function refreshRank
-------------------------------------
function UI_EventRouletteRankingTab:refreshRank(type, offset) -- 다음/이전 버튼 눌렀을 경우 offset계산되어서 param으로 줌
    self.m_rankType = type
    if (not offset) then
        self.m_rankOffset = (type == 'my') and -1 or 1
    end

    local function finish_cb()
        self.m_rankOffset = g_eventRouletteData.m_nGlobalOffset
        self:makeRankTableView()
        self:refresh_playerUserInfo()
    end

    local rank_type = self.m_rankType
    local offset = self.m_rankOffset
    local tab_type = self.m_tabType == 'total' and 'total' or 'today'
    g_eventRouletteData:request_rouletteRanking(offset, 30, rank_type, tab_type, finish_cb)
end

-------------------------------------
-- function refresh_playerUserInfo
-------------------------------------
function UI_EventRouletteRankingTab:refresh_playerUserInfo()
    local vars = self.m_parentVars

    -- 플레이어 정보 받아옴
    local struct_user_info = g_eventRouletteData.m_myRanking
    local ui = UI_EventRouletteRankingListItem(struct_user_info)
    local my_rank_node_name = 'rankMeNode_' .. self.m_tabType
    vars[my_rank_node_name]:removeAllChildren()
    vars[my_rank_node_name]:addChild(ui.root)

    local rank_str = ui.vars['rankingLabel']:getString()
    local rank_percentage =  math.floor((struct_user_info.m_rankPercent or 0) * 100)

    ui.vars['rankingLabel']:setString(rank_str .. '\n(' .. rank_percentage .. '%)')
    
    if (rank_str == '-') then
        ui.vars['rankingLabel']:setString(rank_str)
    end

    if self.m_selectedUI then
        self.m_selectedUI.vars['meSprite']:setVisible(false)
        self.m_selectedUI = nil
    end

    local rank = struct_user_info.m_rank
    if (not rank) or (rank <= 0) then
        return
    end
    
    local ratio = (struct_user_info.m_rankPercent or 1) * 100

    if (self.m_rewardTableView == nil) then return end

    -- 보상 정보 ?
    local l_item_list = self.m_rewardTableView.m_itemList
    local idx = nil
    local ui = nil
    for i,v in ipairs(l_item_list) do
        local data = v['data']
        local unique_id = v['unique_id']
        local _ui = v['ui']
        
        local rank_min = tonumber(data['rank_min'])
        local rank_max = tonumber(data['rank_max'])

        local ratio_min = tonumber(data['ratio_min'])
        local ratio_max = tonumber(data['ratio_max'])

        -- 순위 필터
        if (rank_min and rank_max) then
            if (rank_min <= rank) and (rank <= rank_max) then
                idx = unique_id
                ui = _ui
                break
            end

        -- 비율 필터
        elseif (ratio_min and ratio_max) then
            if (ratio_min < ratio) and (ratio <= ratio_max) then
                idx = unique_id
                ui = _ui
                break
            end
        end
    end

    if (not idx) then
        return
    end

    self.m_rewardTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    self.m_rewardTableView:relocateContainerFromIndex(idx)

    local t_item = self.m_rewardTableView:getItem(idx)
    local ui = t_item['ui'] or t_item['generated_ui']
    if (ui) then
        self.m_selectedUI = ui
        ui.vars['meSprite']:setVisible(true)
    end
end

-------------------------------------
-- function request_rank
-------------------------------------
function UI_EventRouletteRankingTab:request_rank()
    local function finish_cb()
        self.m_rankOffset = g_eventRouletteData.m_nGlobalOffset
        self:makeRankTableView()
        self:refresh_playerUserInfo()
    end
    local rank_type = self.m_rankType
    local offset = self.m_rankOffset
    g_eventRouletteData:request_rouletteRanking(rank_type, offset, finish_cb)
end

-------------------------------------
-- function makeRankTableView
-------------------------------------
function UI_EventRouletteRankingTab:makeRankTableView()
    local vars = self.m_parentVars
    local node = vars['rankListNode_' .. self.m_tabType]
    node:removeAllChildren()

    local l_item_list = g_eventRouletteData.m_lGlobalRank

    if (1 < self.m_rankOffset) then
        local prev_data = { m_tag = 'prev' }
        l_item_list['prev'] = prev_data
    end

    if (#l_item_list > 0) then
        local next_data = { m_tag = 'next' }
        l_item_list['next'] = next_data
    end

    -- 이전, 다음 버튼은 전체 랭킹에서만 사용
    if (self.m_rankType == 'world') then
        if (1 < self.m_rankOffset) then
            local prev_data = { m_tag = 'prev' }
            l_item_list['prev'] = prev_data
        end

        local next_data = { m_tag = 'next' }
        l_item_list['next'] = next_data
    end
    
    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_rankOffset = self.m_rankOffset - OFFSET_GAP
        self.m_rankOffset = math_max(self.m_rankOffset, 0)
        self:refreshRank(self.m_rankType, self.m_rankOffset)
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local add_offset = #l_item_list
        if (add_offset < OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_rankOffset = self.m_rankOffset + add_offset

        self:refreshRank(self.m_rankType, self.m_rankOffset)
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 55 + 5)
    table_view:setCellUIClass(UI_EventRouletteRankingListItem, create_func)
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
            local a_rank = conditionalOperator((0 < a_data.m_rank), a_data.m_rank, 9999999)
            local b_rank = conditionalOperator((0 < b_data.m_rank), b_data.m_rank, 9999999)
            return a_rank < b_rank
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))   
    self.m_rankTableView = table_view


    do -- 최상위 랭킹의 경우 포커스를 1위에 위치
        if (self.m_rankFullType == 'world_top') then
            self.m_rankTableView:update(0)
            self.m_rankTableView:relocateContainerFromIndex(1)
        -- 내 랭킹의 경우 포커스를 내 랭킹에 위치
        else
            local idx = nil
            for i,v in pairs(table_view.m_itemList) do
                if v['data'] then
                    if (v['data'].m_uid == g_userData:get('uid')) then
                        idx = i
                        break
                    end
                end
            end
            if idx then
                self.m_rankTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
                self.m_rankTableView:relocateContainerFromIndex(idx)
            end
        end
    end
end


-------------------------------------
-- function makeRankRewardTableView
-- @brief 보상 정보 테이블 뷰 생성
-------------------------------------
function UI_EventRouletteRankingTab:makeRankRewardTableView()
    if (self.m_rewardTableView) then return end
    local node = self.m_parentVars['rewardNode_' .. self.m_tabType]
    local l_item_list = self.m_tabType == 'total' and g_eventRouletteData.m_totalRankingRewardList or g_eventRouletteData.m_dailyRankingRewardList

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(500, 65 + 5)
    table_view:setCellUIClass(self.makeCellUIRankReward)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list, true)
    table_view:makeDefaultEmptyDescLabel(Str('보상 정보가 없습니다.'))

    table_view:update(0) -- 맨 처음 각 아이템별 위치값을 계산해줌
    table_view:relocateContainerFromIndex(0) -- 해당하는 보상에 포커싱

    self.m_rewardTableView = table_view
end





-------------------------------------
-- function makeCellUIRankReward
-------------------------------------
function UI_EventRouletteRankingTab.makeCellUIRankReward(t_reward_info)
    local ui = class(UI, ITableViewCell:getCloneTable())()
    local vars = ui:load('event_lucky_fortune_bag_ranking_popup_item_01.ui')
    
    -- 순위
    local rank_str
    if (t_reward_info['rank_min'] ~= t_reward_info['rank_max']) then
        rank_str = Str('{1}~{2}위 ', t_reward_info['rank_min'], t_reward_info['rank_max'])
    else
        if(t_reward_info['ratio_max'] ~= '') then
            rank_str = Str('상위 {1}%', t_reward_info['ratio_max'])
        else
            rank_str = Str('{1}위', t_reward_info['rank_min'])
        end
    end
    vars['rankLabel']:setString(rank_str) 

    -- 보상 정보
    local l_item_list = g_itemData:parsePackageItemStr(t_reward_info['reward'])
    for i, t_item in pairs(l_item_list) do

        -- 라벨 크기 확대 (아이템 숫자가 잘 안보여서 확대)
        local card_ui = MakeItemCard(t_item)
        if (card_ui['vars'] and card_ui['vars']['numberLabel']) then
            card_ui['vars']['numberLabel']:setScale(1.15)
        end

        card_ui.root:setScale(100/150)
        vars['itemNode' .. i]:addChild(card_ui.root)
    end

    return ui
end


