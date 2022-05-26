local PARENT = class(UI, ITabUI:getCloneTable())

local RANK_OFFSET_GAP = 20


-------------------------------------
-- class UI_ArenaRankPopup
-------------------------------------
UI_ArenaRankPopup = class(PARENT,{
    m_rankOffset = 'number',
    m_rankType = 'string',

    m_rewardTableView = 'UIC_TableView',
    m_structRankReward = 'StructRankReward',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaRankPopup:init()
    local vars = self:load('arena_rank_popup.ui')
    local ui_res = 'arena_rank_popup.ui'
    if (g_arenaData:isStartClanWarContents()) then
        ui_res = 'arena_rank_popup_new.ui'
    end
    local vars = self:load(ui_res)

    UIManager:open(self, UIManager.POPUP)
    
    self.m_rankOffset = 1
    self.m_rankType = 'world'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaRankPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	
    self:addTabAuto('userRank', vars, vars['userRankTabMenu'])
    self:addTabAuto('clanRank', vars, vars['clanRankTabMenu'])

    self:setTab('userRank')
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaRankPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaRankPopup:initButton()
    local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['valorShopBtn']:registerScriptTapHandler(function() UINavigator:goTo('shop', 'valor') end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ArenaRankPopup:onChangeTab(tab, first)
	if (tab == 'userRank') and (first) then
	    self:make_UIC_SortList()
	elseif (tab == 'clanRank') and (first) then
        UI_ArenaRankClanPopup(self.vars)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaRankPopup:refresh()
end

-------------------------------------
-- function makeArenaRankTableView
-------------------------------------
function UI_ArenaRankPopup:makeArenaRankTableView(data)
    local vars = self.vars
    local rank_node = vars['userListNode']
    local rank_data = data

    local make_my_rank_cb = function()
        local my_data = rank_data['my_info'] or {}
        local me_rank = UI_ArenaRankingListItem(my_data)
        vars['userMeNode']:addChild(me_rank.root)
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
    rank_list:setEmptyStr(Str('랭킹 정보가 없습니다'))
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
-- function requestRank
-------------------------------------
function UI_ArenaRankPopup:requestRank(_offset) -- 다음/이전 버튼 눌렀을 경우 offset계산되어서 param으로 줌
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
    g_arenaData:request_arenaRank(self.m_rankOffset, rank_type, finish_cb, fail_cb, rank_cnt)
end

-------------------------------------
-- function makeRewardTableView
-------------------------------------
function UI_ArenaRankPopup:makeRewardTableView(my_info)
    local vars = self.vars
    local node = vars['userRewardNode']
    
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
-- function createRewardFunc
-------------------------------------
function UI_ArenaRankPopup:createRewardFunc(ui, data, my_info)
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
-- function onFocusMyReward
-------------------------------------
function UI_ArenaRankPopup:onFocusMyReward(my_info)
    local my_data = my_info or {}

    local my_rank = my_data['rank'] or 0
    local my_ratio = my_data['rate'] or 0
    local reward_data, ind = self.m_structRankReward:getPossibleReward(my_rank, my_ratio)

    if (ind) then
        self.m_rewardTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
        self.m_rewardTableView:relocateContainerFromIndex(ind)
    end
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_ArenaRankPopup:onChangeRankingType(type)
    if (g_clanData) then
        if (type == 'clan' and g_clanData:isClanGuest()) then
            local msg = Str('소속된 클랜이 없습니다.')
            UIManager:toastNotificationRed(msg)
            return
        end
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

    self:requestRank(self.m_rankOffset)
end

-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_ArenaRankPopup:make_UIC_SortList()
    local vars = self.vars

    -- 내 순위 필터
    local button = vars['userRankBtn']
    local label = vars['rankLabel1']

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
    uic:setSelectSortType('top')
end
