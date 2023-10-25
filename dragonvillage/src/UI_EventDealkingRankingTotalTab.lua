local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())
local SCORE_OFFSET_GAP = 20

-------------------------------------
-- class UI_EventDealkingRankingTotalTab
-------------------------------------
UI_EventDealkingRankingTotalTab = class(PARENT,{
    m_rewardTableView = 'UIC_TableView',
    m_structRankReward = 'StructRankReward',

    m_ownerUI = 'UI_EventDealkingRankingPopup', -- 현재 검색 타입에 대해 받아올 때 필요
    m_bossType = 'number', -- 보스 타입 (0 전체, 1 단일, 2 다중)
    m_searchType = 'string', -- 검색 타입 (world, clan, friend)
    ------------------------------------------------
    m_tRankData = 'table', -- 전체 랭크 정보
    m_rankOffset = 'number', -- 오프셋
    ------------------------------------------------
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventDealkingRankingTotalTab:init(owner_ui)
    local vars = self:load('event_dealking_rank_popup_all.ui')

    self.m_ownerUI = owner_ui
    self.m_searchType = owner_ui.m_rankType
    self.m_bossType = owner_ui.m_bossType
    self.m_tRankData = {}
    self.m_rankOffset = 1

end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventDealkingRankingTotalTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
        self:initButton()
        self.m_searchType = self.m_ownerUI.m_rankType

        self:refreshRank(self.m_searchType)
    end

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealkingRankingTotalTab:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventDealkingRankingTotalTab:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventDealkingRankingTotalTab:refresh()
end


-------------------------------------
-- function makeRankTableView
-------------------------------------
function UI_EventDealkingRankingTotalTab:makeRankTableView(data)
    local vars = self.vars
    local rank_node = vars['rankListNode']
    local rank_data = data
    local my_rank_data = data['total_my_info'] 

    vars['infoLabel']:setString(Str('종합 랭킹은 속성 점수를 합산하여 결정됩니다.'))

    local make_my_rank_cb = function()
        local my_data = my_rank_data or {}
        local me_rank = UI_EventDealkingRankingTotalTabRankingListItem(my_data)
        vars['rankMeNode']:addChild(me_rank.root)
        me_rank.vars['meSprite']:setVisible(true)
    end
    
    local l_rank_list = rank_data['total_list'] or {}
    
    -- 이전 랭킹 버튼 누른 후 콜백
    local function func_prev_cb(offset)
        self.m_rankOffset = offset
        self:request_EventDealkingTotalRanking()
    end

    -- 다음 랭킹 버튼 누른 후 콜백
    local function func_next_cb(offset)
        self.m_rankOffset = offset
        self:request_EventDealkingTotalRanking()
    end

    local uid = g_userData:get('uid')
    local create_cb = function(ui, data)
        if (data['uid'] == uid) then
            ui.vars['meSprite']:setVisible(true)
        end
    end
    
    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_EventDealkingRankingTotalTabRankingListItem, create_cb)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr(Str('랭킹 정보가 없습니다.'))
    rank_list:setMyRank(make_my_rank_cb)
    rank_list:setOffset(self.m_rankOffset)
    rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, SCORE_OFFSET_GAP)
    rank_list:makeRankList(rank_node)

    
    local idx = 0
    for i,v in ipairs(l_rank_list) do
		 if (v['uid'] == uid) then
             idx = i
             break
         end
    end

   -- 최상위 랭킹일 경우에는 포커싱을 1위에 함
   if (self.m_searchType == 'world') and (self.m_rankOffset == 1) then
        idx = 1
   end

   rank_list.m_rankTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
   rank_list.m_rankTableView:relocateContainerFromIndex(idx)
end


-------------------------------------
-- function makeRewardTableView
-------------------------------------
function UI_EventDealkingRankingTotalTab:makeRewardTableView()
    local vars = self.vars
    local node = vars['reawardNode']

    local my_all_ranking_info = g_eventDealkingData:getMyRankInfo(self.m_bossType)
    if my_all_ranking_info == nil then
        return
    end

    local myRankInfo = my_all_ranking_info['total']
    if myRankInfo == nil then
        return
    end

    -- 최조 한 번만 생성
    if (self.m_rewardTableView) then
        return
    end

    -- 랭킹 보상 테이블
    local table_event_rank = g_eventDealkingData.m_tRewardInfo
    local struct_rank_reward = StructRankReward(table_event_rank, true)
    local l_event_rank = struct_rank_reward:getRankRewardList()
    self.m_structRankReward = struct_rank_reward

    local my_rank = myRankInfo['rank'] or 0
    local my_ratio = myRankInfo['rate'] or 0

    local create_func = function(ui, data)
        self:createRewardFunc(ui, data, myRankInfo)
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 60 + 5)
    table_view:setCellUIClass(UI_EventDealkingRankingTotalTabRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_event_rank)

    table_view:update(0) -- 맨 처음 각 아이템별 위치값을 계산해줌
    table_view:relocateContainerFromIndex(idx) -- 해당하는 보상에 포커싱

    self.m_rewardTableView = table_view
    local reward_data, ind = self.m_structRankReward:getPossibleReward(my_rank, my_ratio)

    self.m_rewardTableView:update(0) -- 인덱스 포커싱을 위해 한번의 계산이 필요하다고 한다.
    self.m_rewardTableView:relocateContainerFromIndex(ind)
end

-------------------------------------
-- function createRewardFunc
-------------------------------------
function UI_EventDealkingRankingTotalTab:createRewardFunc(ui, data, my_info)
    local vars = ui.vars
    local my_data = my_info or {}

    local my_rank = my_data['rank'] or 0
    local my_ratio = my_data['rate'] or 0

    local reward_data, ind = self.m_structRankReward:getPossibleReward(my_rank, my_ratio)
    if (reward_data) then
        if (data['rank_id'] == reward_data['rank_id']) then
            vars['meSprite']:setVisible(true)
        end
    end
end



-------------------------------------
-- function request_EventDealkingTotalRanking
-------------------------------------
function UI_EventDealkingRankingTotalTab:request_EventDealkingTotalRanking()
    
    local type = 'total'

    local function success_cb(ret)
        -- 밑바닥 유저를 위한 예외처리
        -- 마침 현재 페이지에 20명이 차있어서 다음 페이지 버튼 클릭이 가능한 상태
        -- 이전에 저장된 오프셋이 1보다 큰 값을 가질 때
        -- 내 랭킹 조회 혹은 페이징을 통한 행위가 있었다고 판단
        if (self.m_rankOffset > 1) then

            -- 랭킹 리스트가 비어있는지 확인한다
            local l_rank_list = ret['total_list'] or {}

            -- 비어있으면 리스트 업뎃을 안하고 팝업만 띄워주자
            if (l_rank_list and #l_rank_list <= 0) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
                return
            end        
        end

        -- 랭킹 테이블 다시 만듬
        self:makeRankTableView(ret)
        self:makeRewardTableView()

        self.m_rankOffset = tonumber(ret['total_offset'])
    end  

    local searchType = (self.m_searchType == 'my' or self.m_searchType == 'top') and 'world' or self.m_searchType

    g_eventDealkingData:request_EventDealkingRanking(self.m_bossType, type, searchType, self.m_rankOffset, SCORE_OFFSET_GAP, success_cb, nil)
end

-------------------------------------
-- function refreshRank
-------------------------------------
function UI_EventDealkingRankingTotalTab:refreshRank(type) -- 다음/이전 버튼 눌렀을 경우 offset계산되어서 param으로 줌
    
    self.m_searchType = type
    self.m_rankOffset = (type == 'my') and -1 or 1

    self:request_EventDealkingTotalRanking()
end



-- tableview cell class
local CELL_PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_EventDealkingRankingTotalTabRankingListItem
-------------------------------------
UI_EventDealkingRankingTotalTabRankingListItem = class(CELL_PARENT,{
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventDealkingRankingTotalTabRankingListItem:init(m_rankInfo)
    local vars = self:load('event_incarnation_of_sins_rank_popup_all_item_02.ui')
    self.m_rankInfo = m_rankInfo

    -- 닉네임 정보가 없다면, 다음/이전 버튼 데이터
    if (not self.m_rankInfo['nick']) then
        return    
    end

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealkingRankingTotalTabRankingListItem:initUI()
    local vars = self.vars
    local t_rank_info = StructUserInfoArena:create_forRanking(self.m_rankInfo)

    -- 점수 표시
    local score = tonumber(self.m_rankInfo['score'])

    if (score < 0) then
        score = '-'
    else
        score = comma_value(score)
    end

    vars['scoreLabel']:setString(score)

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(self.m_rankInfo['nick'])

    -- 순위 표시
    local rankStr = tostring(comma_value(self.m_rankInfo['rank']))
    if (self.m_rankInfo['rank'] < 0) then
        rankStr = '-'
    end

    vars['rankingLabel']:setString(rankStr)


    do -- 리더 드래곤 아이콘
        local ui = t_rank_info:getLeaderDragonCard()
        if ui then
            ui.root:setSwallowTouch(false)
            vars['profileNode']:addChild(ui.root)
            
			ui.vars['clickBtn']:registerScriptTapHandler(function() 
				local is_visit = true
				UI_UserInfoDetailPopup:open(t_rank_info, is_visit, nil)
			end)
        end
    end

    local struct_clan = t_rank_info:getStructClan()
    if (struct_clan) then
        -- 클랜 이름
        local clan_name = struct_clan:getClanName()
        vars['clanLabel']:setString(clan_name)
        
        -- 클랜 마크
        local icon = struct_clan:makeClanMarkIcon()
        if (icon) then
            vars['markNode']:addChild(icon)
        end
    else
        vars['clanLabel']:setVisible(false)
    end

    vars['itemMenu']:setSwallowTouch(false)
end




-- tableview cell class
local CELL_PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_EventDealkingRankingTotalTabRewardListItem
-------------------------------------
UI_EventDealkingRankingTotalTabRewardListItem = class(CELL_PARENT,{
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventDealkingRankingTotalTabRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('event_incarnation_of_sins_rank_popup_all_item_01.ui')
    
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealkingRankingTotalTabRewardListItem:initUI()
    local vars = self.vars
    local t_data = self.m_rewardInfo
    local l_reward = g_itemData:parsePackageItemStr(self.m_rewardInfo['reward'])

    for i = 1, #l_reward do
        local item_id = l_reward[i]['item_id']
        local cnt = l_reward[i]['count']
        
        local item_card = UI_ItemCard(item_id, cnt)
        item_card.root:setScale(0.62)
        item_card.root:setSwallowTouch(false)
        -- itemNode 는 좌 -> 우 1,2,3,4,5 총 5개를 갖는다
        -- 리워드가 5개 미만일 때 총 슬롯과 리워드 차이만큼
        -- 앞칸을 비워서 우측정렬을 실현
        local insert_idx = i + ( 5 - #l_reward )

        -- 혹시라도 인덱스 벗어나는 일이 있으면 멈추자.
        if (insert_idx < 1 or insert_idx > 5) then
            break
        end

        if vars['itemNode' .. insert_idx] then 
            vars['itemNode' .. insert_idx]:addChild(item_card.root)
        end
    end

    local rank_str = StructRankReward.getRankName(t_data) 
    vars['rankLabel']:setString(rank_str)
end