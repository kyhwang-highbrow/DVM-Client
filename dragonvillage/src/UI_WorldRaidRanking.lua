local PARENT = UI
-------------------------------------
--- @class UI_WorldRaidRanking
-------------------------------------
UI_WorldRaidRanking = class(PARENT, {
    m_rewardTableView = 'UIC_TableView',
    m_structRankReward = 'StructRankReward',

    m_ownerUI = 'UI_WorldRaidRanking', -- 현재 검색 타입에 대해 받아올 때 필요
    m_bossType = 'number', -- 보스 타입 (0 전체, 1 단일, 2 다중)


    m_tRankData = 'table', -- 전체 랭크 정보
    m_rankOffset = 'number', -- 오프셋
})

-------------------------------------
--- @function init
-------------------------------------
function UI_WorldRaidRanking:init()
    local vars = self:load('world_raid_ranking_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_WorldRaidRanking')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()    
    self:refresh()

    self:makeRankTableView({})
    self:makeRewardTableView({})

    -- self:update()
    -- self.root:scheduleUpdateWithPriorityLua(function () self:update() end, 1)

    -- 보상 안내 팝업
    local function finich_cb()
        self:checkEnterEvent()
    end

    self:sceneFadeInAction(nil, finich_cb)
end

-------------------------------------
--- @function checkEnterEvent
-------------------------------------
function UI_WorldRaidRanking:checkEnterEvent()
end

-------------------------------------
--- @function initUI
-------------------------------------
function UI_WorldRaidRanking:initUI()
    local vars = self.vars
end

-------------------------------------
--- @function initButton
-------------------------------------
function UI_WorldRaidRanking:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
--- @function refresh
-------------------------------------
function UI_WorldRaidRanking:refresh()
end

-------------------------------------
--- @function makeRankTableView
-------------------------------------
function UI_WorldRaidRanking:makeRankTableView(data)
    local vars = self.vars
    local rank_node = vars['userListNode']
    local rank_data = data
    local my_rank_data = data['total_my_info'] or g_worldRaidData:getCurrentMyRanking()

    local make_my_rank_cb = function()        
        local me_rank = UI_WorldRaidRankingListItem(my_rank_data)
        vars['userMeNode']:addChild(me_rank.root)
        me_rank.vars['meSprite']:setVisible(true)
    end
    
    local l_rank_list = rank_data['total_list'] or g_worldRaidData:getCurrentRankingList()
    
    -- 이전 랭킹 버튼 누른 후 콜백
    local function func_prev_cb(offset)
        self.m_rankOffset = offset
        self:request_total_ranking()
    end

    -- 다음 랭킹 버튼 누른 후 콜백
    local function func_next_cb(offset)
        self.m_rankOffset = offset
        self:request_total_ranking()
    end

    local uid = g_userData:get('uid')
    local create_cb = function(ui, data)
        if (data['uid'] == uid) then
            ui.vars['meSprite']:setVisible(true)
        end
    end
    
    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_WorldRaidRankingListItem, create_cb)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr(Str('랭킹 정보가 없습니다.'))
    rank_list:setMyRank(make_my_rank_cb)
    rank_list:setOffset(self.m_rankOffset)
    --rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, 0)
    rank_list:makeRankList(rank_node)

    
    local idx = 0
    for i,v in ipairs(l_rank_list) do
		 if (v['uid'] == uid) then
             idx = i
             break
         end
    end

   -- 최상위 랭킹일 경우에는 포커싱을 1위에 함
   if (self.m_rankOffset == 1) then
        idx = 1
   end

   rank_list.m_rankTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
   rank_list.m_rankTableView:relocateContainerFromIndex(idx)
end

-------------------------------------
--- @function request_total_ranking
-------------------------------------
function UI_WorldRaidRanking:request_total_ranking()
    local searchType = 'world' 

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
        self:makeRewardTableView(ret)
        self.m_rankOffset = tonumber(ret['total_offset'])
    end

    g_worldRaidData:request_WorldRaidRanking(searchType, self.m_rankOffset, 0, success_cb, nil)
end


-------------------------------------
-- function createRewardFunc
-------------------------------------
function UI_WorldRaidRanking:createRewardFunc(ui, data, my_info)
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
--- @function makeRewardTableView
-------------------------------------
function UI_WorldRaidRanking:makeRewardTableView(ret)
    local vars = self.vars
    local node = vars['userRewardNode']

    -- 최조 한 번만 생성
    if (self.m_rewardTableView) then
        return
    end

    -- 내랭킹
    local my_rank = g_worldRaidData:getCurrentMyRanking()

    -- 랭킹 보상 테이블
    local table_event_rank = self:getRewardTable(ret)
    cclog('#table_event_rank', #table_event_rank)
    local struct_rank_reward = StructRankReward(table_event_rank, true)
    local l_event_rank = struct_rank_reward:getRankRewardList() or {}
    self.m_structRankReward = struct_rank_reward

    local rank = my_rank['rank'] or 0
    local ratio = my_rank['rate'] or 0

    local create_func = function(ui, data)
        self:createRewardFunc(ui, data, my_rank)
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 60 + 5)
    table_view:setCellUIClass(UI_WorldRaidRankingRewardItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_event_rank)
    table_view:update(0) -- 맨 처음 각 아이템별 위치값을 계산해줌
    table_view:relocateContainerFromIndex(1) -- 해당하는 보상에 포커싱

    self.m_rewardTableView = table_view
    local reward_data, ind = self.m_structRankReward:getPossibleReward(rank, ratio)

    self.m_rewardTableView:update(0) -- 인덱스 포커싱을 위해 한번의 계산이 필요하다고 한다.
    self.m_rewardTableView:relocateContainerFromIndex(ind)
end

-------------------------------------
--- @function refresh
-------------------------------------
function UI_WorldRaidRanking:update()
    local vars = self.vars
    local str = g_worldRaidData:getRemainTimeString()
    vars['timeLabel']:setString(str)
end

-------------------------------------
--- @function click_closeBtn
-------------------------------------
function UI_WorldRaidRanking:click_closeBtn()
    self:close()
end

-------------------------------------
--- @function getRewardTable
-------------------------------------
function UI_WorldRaidRanking:getRewardTable(ret)
    local table_rank = 
    { 
        {
            rank_min = 1,
            ratio_max = "",
            rank_max = 1,
            version = "s_20231102",
            rank_id = 1,
            ratio_min = "",
            reward = "779265;1,cash;30000,700651;7"
        }, {
            rank_min = 2,
            ratio_max = "",
            rank_max = 2,
            version = "s_20231102",
            rank_id = 2,
            ratio_min = "",
            reward = "703042;1,cash;30000,700651;7"
        }, {
            rank_min = 3,
            ratio_max = "",
            rank_max = 3,
            version = "s_20231102",
            rank_id = 3,
            ratio_min = "",
            reward = "703042;1,cash;26000,700651;6"
        }, {
            rank_min = 4,
            ratio_max = "",
            rank_max = 4,
            version = "s_20231102",
            rank_id = 4,
            ratio_min = "",
            reward = "703042;1,cash;23000,700651;5"
        }, {
            rank_min = 5,
            ratio_max = "",
            rank_max = 5,
            version = "s_20231102",
            rank_id = 5,
            ratio_min = "",
            reward = "703042;1,cash;21000,700651;4"
        }, {
            rank_min = 6,
            ratio_max = "",
            rank_max = 10,
            version = "s_20231102",
            rank_id = 6,
            ratio_min = "",
            reward = "703041;2,cash;20000,700651;4"
        }, {
            rank_min = 11,
            ratio_max = "",
            rank_max = 20,
            version = "s_20231102",
            rank_id = 7,
            ratio_min = "",
            reward = "703041;1,cash;20000,700651;3"
        }, {
            rank_min = 21,
            ratio_max = "",
            rank_max = 30,
            version = "s_20231102",
            rank_id = 8,
            ratio_min = "",
            reward = "703041;1,cash;17000,700651;3"
        }, {
            rank_min = 31,
            ratio_max = "",
            rank_max = 40,
            version = "s_20231102",
            rank_id = 9,
            ratio_min = "",
            reward = "703041;1,cash;15000,700651;2"
        }, {
            rank_min = 41,
            ratio_max = "",
            rank_max = 50,
            version = "s_20231102",
            rank_id = 10,
            ratio_min = "",
            reward = "703041;1,cash;13000,700651;2"
        }, {
            rank_min = 51,
            ratio_max = "",
            rank_max = 100,
            version = "s_20231102",
            rank_id = 11,
            ratio_min = "",
            reward = "703001;1,cash;12000,700651;2"
        }, {
            rank_min = 101,
            ratio_max = "",
            rank_max = 150,
            version = "s_20231102",
            rank_id = 12,
            ratio_min = "",
            reward = "703001;1,cash;11000,700651;2"
        }, {
            rank_min = 151,
            ratio_max = "",
            rank_max = 200,
            version = "s_20231102",
            rank_id = 13,
            ratio_min = "",
            reward = "703001;1,cash;10000,700651;2"
        }, {
            rank_min = 201,
            ratio_max = "",
            rank_max = 250,
            version = "s_20231102",
            rank_id = 14,
            ratio_min = "",
            reward = "703001;1,cash;9000,700651;2"
        }, {
            rank_min = 251,
            ratio_max = "",
            rank_max = 300,
            version = "s_20231102",
            rank_id = 15,
            ratio_min = "",
            reward = "703001;1,cash;8000,700651;2"
        }, {
            rank_min = "",
            ratio_max = 5,
            rank_max = "",
            version = "s_20231102",
            rank_id = 16,
            ratio_min = 0,
            reward = "703005;1,cash;6000,700651;2"
        }, {
            rank_min = "",
            ratio_max = 10,
            rank_max = "",
            version = "s_20231102",
            rank_id = 17,
            ratio_min = 5,
            reward = "703005;1,cash;5000,700651;1"
        }, {
            rank_min = "",
            ratio_max = 20,
            rank_max = "",
            version = "s_20231102",
            rank_id = 18,
            ratio_min = 10,
            reward = "703005;1,cash;4000,700651;1"
        }, {
            rank_min = "",
            ratio_max = 30,
            rank_max = "",
            version = "s_20231102",
            rank_id = 19,
            ratio_min = 20,
            reward = "703005;1,cash;3000,700651;1"
        }, {
            rank_min = "",
            ratio_max = 40,
            rank_max = "",
            version = "s_20231102",
            rank_id = 20,
            ratio_min = 30,
            reward = "703005;1,cash;2000,700651;1"
        }, {
            rank_min = "",
            ratio_max = 50,
            rank_max = "",
            version = "s_20231102",
            rank_id = 21,
            ratio_min = 40,
            reward = "cash;1000,700651;1"
        }, {
            rank_min = "",
            ratio_max = 100,
            rank_max = "",
            version = "s_20231102",
            rank_id = 22,
            ratio_min = 50,
            reward = "700651;1"
        } 
    }    
    return table_rank
end


--@CHECK
UI:checkCompileError(UI_WorldRaidRanking)







