local PARENT = UI

local OFFSET_GAP = 30 -- 한번에 보여주는 랭커 수

------------------------------------- 
-- class UI_EventLFBagRankingPopup
-------------------------------------
UI_EventLFBagRankingPopup = class(PARENT,{
        m_rankTableView = 'UIC_TableView',
        m_rankType = 'string',
        m_rankFullType = 'string',
        m_rankOffset = 'number',

        m_rewardTableView = '',
        m_selectedUI = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBagRankingPopup:init(use_for_inner_ui)
    self.m_rankOffset = 1
    local vars = self:load('event_lucky_fortune_bag_ranking_popup.ui')

    if (use_for_inner_ui) then
        -- nothing to do
    else
        UIManager:open(self, UIManager.SCENE)
	    -- backkey 지정
	    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventLFBagRankingPopup')
    end


    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventLFBagRankingPopup:initUI()
    local vars = self.vars

    -- 보상 테이블뷰
    self:makeRankRewardTableView()

    -- 랭킹 테이블뷰 생성됨
    self:make_UIC_SortList()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventLFBagRankingPopup:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBagRankingPopup:refresh()
    self:refresh_playerUserInfo()
end

-------------------------------------
-- function refresh_playerUserInfo
-------------------------------------
function UI_EventLFBagRankingPopup:refresh_playerUserInfo()
    local vars = self.vars

    -- 플레이어 정보 받아옴
    local struct_user_info = g_eventLFBagData.m_myRanking
    local ui = UI_EventLFBagRankingListItem(struct_user_info)
    vars['userMeNode']:removeAllChildren()
    vars['userMeNode']:addChild(ui.root)

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
function UI_EventLFBagRankingPopup:request_rank()
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
function UI_EventLFBagRankingPopup:makeRankTableView()
    local vars = self.vars
    local node = vars['userListNode']
    node:removeAllChildren()

    local l_item_list = g_eventLFBagData.m_lGlobalRank

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
        self:request_rank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local add_offset = #g_eventLFBagData.m_lGlobalRank
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
function UI_EventLFBagRankingPopup:makeRankRewardTableView()
    local node = self.vars['userRewardNode']

    local l_item_list = TableEventLFBagRank().m_orgTable

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(500, 65 + 5)
    table_view:setCellUIClass(self.makeCellUIRankReward)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list, true)
    table_view:makeDefaultEmptyDescLabel(Str('보상 정보가 없습니다.'))
    self.m_rewardTableView = table_view
end

-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_EventLFBagRankingPopup:make_UIC_SortList()
    local vars = self.vars
    local button = vars['rankingBtn']
    local label = vars['rankingLabel']

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()

    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)


    uic:addSortType('my', Str('내 랭킹'))
    uic:addSortType('top', Str('최상위 랭킹'))
    uic:addSortType('friend', Str('친구 랭킹'))
    uic:addSortType('clan', Str('클랜원 랭킹'))

    uic:setSortChangeCB(function(sort_type) self:onChangeRankingType(sort_type) end)
    uic:setSelectSortType('my')
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_EventLFBagRankingPopup:onChangeRankingType(type)

    if (type == 'clan' and g_clanData:isClanGuest()) then
        local msg = Str('소속된 클랜이 없습니다.')
        UIManager:toastNotificationRed(msg)
        return
    end

    if (type == 'my') then
        self.m_rankType = 'world'
        self.m_rankOffset = -1

    elseif (type == 'top') then
        self.m_rankType = 'world'
        self.m_rankOffset = 1

    elseif (type == 'friend') then
        self.m_rankType = 'friend'
        self.m_rankOffset = 1

    elseif (type == 'clan') then
        self.m_rankType = 'clan'
        self.m_rankOffset = 1

    end

    self:request_rank()
end

--@CHECK
UI:checkCompileError(UI_EventLFBagRankingPopup)





















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
function UI_EventLFBagRankingPopup.makeCellUIRankReward(t_reward_info)
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
        local card_ui = MakeItemCard(t_item)
        card_ui.root:setScale(100/150)
        vars['itemNode' .. i]:addChild(card_ui.root)
    end

    return ui
end