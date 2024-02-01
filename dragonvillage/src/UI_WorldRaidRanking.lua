local PARENT = UI
-------------------------------------
--- @class UI_WorldRaidRanking
-------------------------------------
UI_WorldRaidRanking = class(PARENT, {
    m_rewardTableView = 'UIC_TableView',
    m_rewardScoreTableView = 'UIC_TableView',

    m_structRankReward = 'StructRankReward',
    m_worldRaidId = 'number',

    m_ownerUI = 'UI_WorldRaidRanking', -- 현재 검색 타입에 대해 받아올 때 필요
    m_bossType = 'number', -- 보스 타입 (0 전체, 1 단일, 2 다중)


    m_tRankData = 'table', -- 전체 랭크 정보
    m_rankOffset = 'number', -- 오프셋
})

local SCORE_OFFSET_GAP = 20
-------------------------------------
--- @function init
-------------------------------------
function UI_WorldRaidRanking:init(world_raid_id)
    self.m_worldRaidId = world_raid_id
    self.m_rankOffset = 1
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

    self:makeRankTableView()
    self:makeRewardTableView()
    self:makeScoreRewardTableView()

    self:refreshRanking()

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
-- function refreshRanking
-------------------------------------
function UI_WorldRaidRanking:refreshRanking()
    if g_worldRaidData:isExpiredRankingUpdate() == true then
        local success_cb = function(ret)            
            local curr_rank_list = g_worldRaidData:getCurrentRankingList()
            local curr_my_rank =g_worldRaidData:getCurrentMyRanking()
            self:makeRankTableView(curr_my_rank, curr_rank_list)
        end

        g_worldRaidData:request_WorldRaidRanking(self.m_worldRaidId, 'world', 1, 20, success_cb)
    end
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
function UI_WorldRaidRanking:makeRankTableView(my_rank, ranking_list)
    local vars = self.vars
    local rank_node = vars['userListNode']
    --local rank_data = data
    local my_rank_data = my_rank or g_worldRaidData:getCurrentMyRanking()

    local make_my_rank_cb = function()        
        local me_rank = UI_WorldRaidRankingListItem(my_rank_data)
        vars['userMeNode']:addChild(me_rank.root)
        me_rank.vars['meSprite']:setVisible(true)
    end
    
    local l_rank_list = ranking_list or g_worldRaidData:getCurrentRankingList()
    
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
    rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, SCORE_OFFSET_GAP)
    rank_list:makeRankList(rank_node, cc.size(550, (55 + 5)))
    
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
        self:makeRankTableView(ret['my_rank'], ret['list'])
        self:makeRewardTableView()
        self.m_rankOffset = tonumber(ret['total_offset'])
    end

    g_worldRaidData:request_WorldRaidRanking(self.m_worldRaidId, searchType, self.m_rankOffset, 0, success_cb, nil)
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
function UI_WorldRaidRanking:makeRewardTableView()
    local vars = self.vars
    local node = vars['userRewardNode']

    -- 랭킹 보상 테이블
    local table_event_rank = g_worldRaidData:getTableWorldRaidRank()    
    local struct_rank_reward = StructRankReward(table_event_rank, true)
    local l_event_rank = struct_rank_reward:getRankRewardList() or {}
    --self.m_structRankReward = struct_rank_reward

    -- 내랭킹
    local my_rank = g_worldRaidData:getCurrentMyRanking()
    local rank = my_rank['rank'] or 0
    local ratio = my_rank['rate'] or 0

    -- 등수 프레임
    for idx = 1, 5 do
        local str = string.format('rankNode%d', idx)
        local t_rank = l_event_rank[idx]

        local str_visual = string.format('effect%dVisual', idx)
        vars[str_visual]:setVisible(idx == rank)

        local l_reward_data = g_itemData:parsePackageItemStr(t_rank['sh_reward'])
        local frame_icon = IconHelper:getItemIcon(l_reward_data[1]['item_id'])

        --vars[str]:removeAllChildren()
        vars[str]:addChild(frame_icon)
    end

    -- local create_func = function(ui, data)
    --     self:createRewardFunc(ui, data, my_rank)
	-- end

    -- -- 테이블 뷰 인스턴스 생성
    -- local table_view = UIC_TableView(node)
    -- table_view.m_defaultCellSize = cc.size(640, 52)
    -- table_view:setCellUIClass(UI_WorldRaidRankingRewardItem, create_func)
    -- table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- table_view:setItemList(l_event_rank)
    -- table_view:update(0) -- 맨 처음 각 아이템별 위치값을 계산해줌
    -- table_view:relocateContainerFromIndex(1) -- 해당하는 보상에 포커싱

    -- self.m_rewardTableView = table_view
    -- local reward_data, ind = self.m_structRankReward:getPossibleReward(rank, ratio)

    -- self.m_rewardTableView:update(0) -- 인덱스 포커싱을 위해 한번의 계산이 필요하다고 한다.
    -- self.m_rewardTableView:relocateContainerFromIndex(ind)
end

-------------------------------------
--- @function makeScoreRewardTableView
-------------------------------------
function UI_WorldRaidRanking:makeScoreRewardTableView()
    local vars = self.vars
    local node = vars['userScoreRewardNode']

    -- 최조 한 번만 생성
    if (self.m_rewardScoreTableView) then
        return
    end

    -- 랭킹 보상 테이블
    local table_event_rank = g_worldRaidData:getTableWorldRaidScoreReward()
    local create_func = function(ui, data)
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 52)
    table_view:setCellUIClass(UI_WorldRaidRankingScoreRewardItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(table_event_rank)
    table_view:update(0) -- 맨 처음 각 아이템별 위치값을 계산해줌
    table_view:relocateContainerFromIndex(1) -- 해당하는 보상에 포커싱

    self.m_rewardTableView = table_view
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
--- @function open
-------------------------------------
function UI_WorldRaidRanking.open(world_raid_id)
    local ui = UI_WorldRaidRanking(world_raid_id)
    return ui
end

--@CHECK
UI:checkCompileError(UI_WorldRaidRanking)