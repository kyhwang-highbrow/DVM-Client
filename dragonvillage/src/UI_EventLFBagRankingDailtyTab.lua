local PARENT = UI_IndivisualTab

local OFFSET_GAP = 30 -- 한번에 보여주는 랭커 수

------------------------------------- 
-- class UI_EventLFBagRankingDailtyTab
-------------------------------------
UI_EventLFBagRankingDailtyTab = class(PARENT,{
        m_rankTableView = 'UIC_TableView',
        m_rankType = 'string',
        m_rankFullType = 'string',
        m_rankOffset = 'number',
        
        m_ownerUI = 'UI_EventIncarnationOfSinsRankingPopup', -- 현재 검색 타입에 대해 받아올 때 필요

        m_rewardTableView = '',
        m_selectedUI = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBagRankingDailtyTab:init(owner_ui)
    self.m_rankOffset = 1
    local vars = self:load('event_lucky_bag_ranking_popup_daily.ui')

    self.m_ownerUI = owner_ui
    self.m_rankType = owner_ui.m_rankType
end

-------------------------------------
-- function setParentAndInit
-------------------------------------
function UI_EventLFBagRankingDailtyTab:setParentAndInit(parent_node)
    -- 룬을 출력하는 TableView(runeTableViewNode)가 relative size의 영향을 받는다.
    -- UI가 생성되고 부모 노드에 addChild가 된 후에 해당 노드의 크기가 결정되므로 외부에서 호출하도록 한다.
    -- setTab -> onChangeTab -> initTableView 의 순서로 TableView가 생성됨.
    --self:setTab(1, true)
    
    parent_node:addChild(self.root)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventLFBagRankingDailtyTab:initUI()
    local vars = self.vars

    -- 보상 테이블뷰
    self:makeRankRewardTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventLFBagRankingDailtyTab:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBagRankingDailtyTab:refresh()
    --self:refresh_playerUserInfo()
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_EventLFBagRankingDailtyTab:onExitTab()

end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventLFBagRankingDailtyTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
        self:initButton()
        self.m_rankType = self.m_ownerUI.m_rankType

        self:refreshRank(self.m_rankType)
    end

    self:refresh()
end

-------------------------------------
-- function refreshRank
-------------------------------------
function UI_EventLFBagRankingDailtyTab:refreshRank(type, offset) -- 다음/이전 버튼 눌렀을 경우 offset계산되어서 param으로 줌
    
    self.m_rankType = type
    if (not offset) then
        self.m_rankOffset = (type == 'my') and -1 or 1
    end
    

    local function finish_cb()
        self.m_rankOffset = g_eventLFBagData.m_nGlobalOffset
        self:makeRankTableView()
        self:refresh_playerUserInfo()
    end

    local rank_type = self.m_rankType
    local offset = self.m_rankOffset
    g_eventLFBagData:request_eventLFBagRank(rank_type, offset, 'today', finish_cb)
end

-------------------------------------
-- function refresh_playerUserInfo
-------------------------------------
function UI_EventLFBagRankingDailtyTab:refresh_playerUserInfo()
    local vars = self.vars

    -- 플레이어 정보 받아옴
    local struct_user_info = g_eventLFBagData.m_myRanking
    local ui = UI_EventLFBagRankingListItem(struct_user_info)
    vars['rankMeNode']:removeAllChildren()
    vars['rankMeNode']:addChild(ui.root)

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
function UI_EventLFBagRankingDailtyTab:request_rank()
    local function finish_cb()
        self.m_rankOffset = g_eventLFBagData.m_nGlobalOffset
        self:makeRankTableView()
        self:refresh_playerUserInfo()
    end
    local rank_type = self.m_rankType
    local offset = self.m_rankOffset
    g_eventLFBagData:request_eventLFBagRank(rank_type, offset, finish_cb)
end

-------------------------------------
-- function makeRankTableView
-------------------------------------
function UI_EventLFBagRankingDailtyTab:makeRankTableView()
    local vars = self.vars
    local node = vars['rankListNode']
    node:removeAllChildren()

    local l_item_list = g_eventLFBagData.m_lGlobalRank

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
    table_view:setCellUIClass(UI_EventLFBagRankingListItem, create_func)
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
function UI_EventLFBagRankingDailtyTab:makeRankRewardTableView()
    if (self.m_rewardTableView) then return end

    local node = self.vars['rewardNode']

    --local l_item_list = TableEventLFBagRank():getRankRewardList()
    local l_item_list = g_eventLFBagData:getDailyRankRewardList()

    if (l_item_list == nil) then return end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(500, 65 + 5)
    table_view:setCellUIClass(self.makeCellUIRankReward)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list, true)
    table_view:makeDefaultEmptyDescLabel(Str('보상 정보가 없습니다.'))

    table_view:update(0) -- 맨 처음 각 아이템별 위치값을 계산해줌
    table_view:relocateContainerFromIndex(idx) -- 해당하는 보상에 포커싱

    self.m_rewardTableView = table_view
end

--@CHECK
UI:checkCompileError(UI_EventLFBagRankingDailtyTab)





















local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_EventLFBagRankingListItem
-------------------------------------
UI_EventLFBagRankingListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBagRankingListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('event_lucky_fortune_bag_ranking_popup_item_02.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventLFBagRankingListItem:initUI()
    local vars = self.vars
    local struct_rank = self.m_rankInfo
    local rank = struct_rank.m_rank

    local tag = struct_rank.m_tag

    -- 다음 랭킹 보기 
    if (tag == 'next') then
        vars['nextBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return
    end

    -- 이전 랭킹 보기 
    if (tag == 'prev') then
        vars['prevBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return
    end

    -- 점수 표시
    local score_str = struct_rank:getScoreStr()
    vars['scoreLabel']:setString(score_str)
    -- 순위 표시
    local rank_str = struct_rank:getRankStr()
    vars['rankingLabel']:setString(rank_str)

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(struct_rank:getUserText())

    do -- 리더 드래곤 아이콘
        local ui = struct_rank:getLeaderDragonCard()
        if ui then
            vars['profileNode']:addChild(ui.root)
            
			ui.vars['clickBtn']:registerScriptTapHandler(function() 
				local is_visit = true
				UI_UserInfoDetailPopup:open(struct_rank, is_visit, nil)
			end)
        end
    end

    do -- 내 순위 UI일 경우
        local uid = g_userData:get('uid')
        local is_my_rank = (uid == struct_rank.m_uid)
        vars['meSprite']:setVisible(is_my_rank)
    end

    -- 공통의 정보
    self:initRankInfo(vars, struct_rank)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventLFBagRankingListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBagRankingListItem:refresh()
end











-------------------------------------
-- function makeCellUIRankReward
-------------------------------------
function UI_EventLFBagRankingDailtyTab.makeCellUIRankReward(t_reward_info)
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