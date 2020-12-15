local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventIncarnationOfSinsRankingTotalTab
-------------------------------------
UI_EventIncarnationOfSinsRankingTotalTab = class(PARENT,{
    m_rewardTableView = 'UIC_TableView',
    m_structRankReward = 'StructRankReward',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:init(owner_ui)
    local vars = self:load('event_incarnation_of_sins_rank_popup_all.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
        self:initButton()
    end

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:refresh()
    local vars = self.vars
end

-------------------------------------
-- function makeRewardTableView
-------------------------------------
function UI_ArenaRankPopup:makeRewardTableView(my_info)
    local vars = self.vars
    local node = vars['rewardNode']
    
    -- 최조 한 번만 생성
    if (self.m_rewardTableView) then
        return
    end

    -- 콜로세움 랭킹 보상 테이블
    -- TODO 랭킹 받아오기
    local table_arena_rank = TABLE:get('table_arena_rank')
    local struct_rank_reward = StructRankReward(table_arena_rank)
    local l_arena_rank = struct_rank_reward:getRankRewardList()
    self.m_structRankReward = struct_rank_reward

    -- TODO 랭킹 받아오기
    local table_arena = TABLE:get('table_arena')
	local create_func = function(ui, data)
        -- 티어 아이콘/ 티어 이름
		local tier_id = data['tier_id']
        if (tier_id) then
            local tier = table_arena[tier_id]['tier']
            local tier_icon = StructUserInfoArena:makeTierIcon(tier)
            local tier_name = StructUserInfoArena:getTierName(tier) or ''
            ui.vars['tierLabel']:setString(tier_name)
            if (tier_icon) then
                ui.vars['tierNode']:addChild(tier_icon)
            end
        end
		self:createRewardFunc(ui, data, my_info)
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 55 + 5)
    table_view:setCellUIClass(UI_ArenaRankingRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_arena_rank)

    self.m_rewardTableView = table_view
end

-------------------------------------
-- function makeArenaRankTableView
-------------------------------------
function UI_ArenaRankPopup:makeArenaRankTableView(data)
    local vars = self.vars
    local rank_node = vars['rankListNode']
    local rank_data = data

    local make_my_rank_cb = function()
        local my_data = rank_data['my_info'] or {}
        local me_rank = UI_ArenaRankingListItem(my_data)
        vars['rankMeNode']:addChild(me_rank.root)
        me_rank.vars['meSprite']:setVisible(true)
    end
    
    local l_rank_list = rank_data['list'] or {}
    
    -- 이전 랭킹 버튼 누른 후 콜백
    local function func_prev_cb(offset)
        self:requestRank(offset)
    end

    -- 다음 랭킹 버튼 누른 후 콜백
    local function func_next_cb(offset)
        self:requestRank(offset)
    end

    local uid = g_userData:get('uid')
    local create_cb = function(ui, data)
        if (data['uid'] == uid) then
            ui.vars['meSprite']:setVisible(true)
        end
    end
    
    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_ArenaRankingListItem, create_cb)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr('랭킹 정보가 없습니다')
    rank_list:setMyRank(make_my_rank_cb)
    rank_list:setOffset(self.m_rankOffset)
    rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, RANK_OFFSET_GAP)
    rank_list:makeRankList(rank_node)
    
    local idx = 0
    for i,v in ipairs(l_rank_list) do
		 if (v['uid'] == uid) then
             idx = i
             break
         end
     end

   -- 최상위 랭킹일 경우에는 포커싱을 1위에 함
   if (self.m_rankType == 'world') and (self.m_rankOffset == 1) then
        idx = 1
   end

   rank_list.m_rankTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
   rank_list.m_rankTableView:relocateContainerFromIndex(idx)
end

-------------------------------------
-- function makeRewardTableView
-------------------------------------
function UI_ArenaRankPopup:makeRewardTableView(my_info)
    local vars = self.vars
    local node = vars['reawardNode']
    
    -- 최조 한 번만 생성
    if (self.m_rewardTableView) then
        return
    end

    -- 콜로세움 랭킹 보상 테이블
    local table_arena_rank = TABLE:get('table_arena_rank')
    local struct_rank_reward = StructRankReward(table_arena_rank)
    local l_arena_rank = struct_rank_reward:getRankRewardList()
    self.m_structRankReward = struct_rank_reward


    local table_arena = TABLE:get('table_arena')
	local create_func = function(ui, data)
        -- 티어 아이콘/ 티어 이름
		local tier_id = data['tier_id']
        if (tier_id) then
            local tier = table_arena[tier_id]['tier']
            local tier_icon = StructUserInfoArena:makeTierIcon(tier)
            local tier_name = StructUserInfoArena:getTierName(tier) or ''
            ui.vars['tierLabel']:setString(tier_name)
            if (tier_icon) then
                ui.vars['tierNode']:addChild(tier_icon)
            end
        end
		self:createRewardFunc(ui, data, my_info)
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 55 + 5)
    table_view:setCellUIClass(UI_ArenaRankingRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_arena_rank)

    self.m_rewardTableView = table_view
end

-------------------------------------
-- function requestRank
-------------------------------------
function UI_EventIncarnationOfSinsRankingPopup:requestRank(_offset) -- 다음/이전 버튼 눌렀을 경우 offset계산되어서 param으로 줌
    local function finish_cb(ret)
        -- 랭킹 테이블 다시 만듬
        self:makeArenaRankTableView(ret)
		self:makeRewardTableView(ret['my_info'])
        
		if (ret['my_info']) then
            -- 자신이 받을 보상에 포커싱
            self:onFocusMyReward(ret['my_info'])
        end
    end

    -- 랭킹 데이터 요청
    local rank_type = self.m_rankType
    self.m_rankOffset = _offset
	local rank_cnt = 20

    -- attr = earth, water, fire, light, dark 
    -- all : 모든 속성 리스트 
    -- null : 전체 순위 20개씩 보여줌
    -- offset : 1 , 21 , 41 ...
    -- limit : 몇개를 보여줄지, 생략시 default 20개
    --g_eventIncarnationOfSinsData:request_eventIncarnationOfSinsRank(self.m_rankOffset, rank_type, finish_cb, fail_cb, rank_cnt)
end