local RANK_OFFSET_GAP = 20


-------------------------------------
-- class UI_ArenaRankClanPopup
-------------------------------------
UI_ArenaRankClanPopup = class({
    m_rankOffset = 'number',
    m_rankType = 'string',

    m_rewardTableView = 'UIC_TableView',
    m_structRankReward = 'StructRankReward',

	vars = 'UI_ArenaRankPopup-vars',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaRankClanPopup:init(owner_ui_vars)
    self.vars = owner_ui_vars
    
    self.m_rankOffset = 1
    self.m_rankType = 'world'

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaRankClanPopup:initUI()
    local vars = self.vars

    self:make_UIC_SortList()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaRankClanPopup:initButton()
    local vars = self.vars
    vars['clancoinShopBtn']:registerScriptTapHandler(function() UINavigator:goTo('shop', 'clancoin') end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaRankClanPopup:refresh()
end

-------------------------------------
-- function makeArenaRankTableView
-------------------------------------
function UI_ArenaRankClanPopup:makeArenaRankTableView(data)
    local vars = self.vars
    local rank_node = vars['clanListNode']
    local rank_data = data

    local make_my_rank_cb = function()
        local my_data = g_clanRankData:getMyRankData(CLAN_RANK['AREN'])
        if (my_data) then
            local me_rank = UI_AncientTowerClanRankListItem(my_data)
            vars['clanMeNode']:addChild(me_rank.root)
            me_rank.vars['meSprite']:setVisible(true)
        end
    end
    
    local l_rank_list = g_clanRankData:getRankData(CLAN_RANK['AREN']) or {}
    -- 이전 랭킹 버튼 누른 후 콜백
    local function func_prev_cb(offset)
        self:requestRank(offset)
    end

    -- 다음 랭킹 버튼 누른 후 콜백
    local function func_next_cb(offset)
        self:requestRank(offset)
    end

    -- 클랜이 있다면
    local struct_clan = g_clanData:getClanStruct()
    local clan_id = nil
    if (struct_clan) then
        clan_id = struct_clan:getClanObjectID()
        local create_cb = function(ui, data)
            if (data['id'] == clan_id) then
                ui.vars['meSprite']:setVisible(true)
            end
        end
	else
        make_my_rank_cb = nil
    end

    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_AncientTowerClanRankListItem, create_cb)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr(Str('랭킹 정보가 없습니다'))
    rank_list:setMyRank(make_my_rank_cb)
    rank_list:setOffset(self.m_rankOffset)
    rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, RANK_OFFSET_GAP)
    rank_list:makeRankList(rank_node)

    
    local idx = 0
    for i,v in ipairs(l_rank_list) do
        if (v['id']) and (clan_id) then
            if (v['id'] == clan_id) then
                idx = i
                break
            end
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
-- function requestRank
-------------------------------------
function UI_ArenaRankClanPopup:requestRank(_offset) -- 다음/이전 버튼 눌렀을 경우 offset계산되어서 param으로 줌
    local function finish_cb(ret)
        -- 랭킹 테이블 다시 만듬
        self:makeArenaRankTableView()
		self:makeRewardTableView()
        if (ret['my_claninfo']) then
            -- 자신이 받을 보상에 포커싱
            self:onFocusMyReward(ret['my_claninfo'])
        end
    end

    -- 랭킹 데이터 요청
    local rank_type = self.m_rankType
    self.m_rankOffset = _offset
    g_clanRankData:request_getRank('arena', self.m_rankOffset, finish_cb)
end

-------------------------------------
-- function makeRewardTableView
-------------------------------------
function UI_ArenaRankClanPopup:makeRewardTableView(ret)
    local vars = self.vars
    local node = vars['clanRewardNode']
    
    -- 최조 한 번만 생성
    if (self.m_rewardTableView) then
        return
    end

	-- 아레나 보상 정보만 빼온다.
    local t_item_list = {}
    for rank_id, t_data in pairs(TABLE:get('table_clan_reward')) do
        if (t_data['category'] == CLAN_RANK['AREN']) then
            local rank_id = t_data['rank_id'] 
		    t_item_list[rank_id] = t_data
        end
    end

    -- 콜로세움 랭킹 보상 테이블
    local struct_rank_reward = StructRankReward(t_item_list)
    local l_arena_rank = struct_rank_reward:getRankRewardList()
    self.m_structRankReward = struct_rank_reward

	local create_func = function(ui, data)
		self:createClanRewardFunc(ui, data)
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 50 + 5)
    table_view:setCellUIClass(UI_ArenaRankClanRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_arena_rank)

    self.m_rewardTableView = table_view
end

-------------------------------------
-- function createClanRewardFunc
-------------------------------------
function UI_ArenaRankClanPopup:createClanRewardFunc(ui, data)
	local t_reward_info = data
    local vars = ui.vars

    local my_data = g_clanRankData:getMyRankData(CLAN_RANK['AREN'])
    if (not my_data) then
        return
    end

    local my_rank = my_data['rank'] 
    
    if (my_rank == -1) then
        return
    end

    -- 받을 수 있는 포상에 하이라이트
    local rank_type = nil
    local rank_value = 1
        
    local rank_min = tonumber(t_reward_info['rank_min'])
    local rank_max = tonumber(t_reward_info['rank_max'])

    local ratio_min = tonumber(t_reward_info['ratio_min'])
    local ratio_max = tonumber(t_reward_info['ratio_max'])

    -- 순위 필터
    if (rank_min and rank_max) then
        if (rank_min <= my_rank) and (my_rank <= rank_max) then
            vars['meSprite']:setVisible(true)
            return
        end
    end
end

-------------------------------------
-- function onFocusMyReward
-------------------------------------
function UI_ArenaRankClanPopup:onFocusMyReward(my_info)
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
function UI_ArenaRankClanPopup:onChangeRankingType(type)
    if (g_clanData) then
        if (type == 'my' and g_clanData:isClanGuest()) then
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
    end

    self:requestRank(self.m_rankOffset)
end

-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_ArenaRankClanPopup:make_UIC_SortList()
    local vars = self.vars

    -- 내 순위 필터
    local button = vars['clanRankListBtn']
    local label = vars['rankLabel2']

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


    uic:addSortType('my', Str('내 클랜 랭킹'))
    uic:addSortType('top', Str('최상위 클랜 랭킹'))

    uic:setSortChangeCB(function(sort_type) self:onChangeRankingType(sort_type) end)
	
	-- 클랜에 가입되지 않은 경우 최상위 클랜 랭킹 선
    local focus_tab = 'my'
    if (g_clanData) then
        if (g_clanData:isClanGuest()) then
            focus_tab = 'top'
            
            vars['clanRankListBtn']:setEnabled(false)
        end
    end
    uic:setSelectSortType(focus_tab)
end
