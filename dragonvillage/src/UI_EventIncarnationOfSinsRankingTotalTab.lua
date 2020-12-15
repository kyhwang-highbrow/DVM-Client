local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())
local SCORE_OFFSET_GAP = 20

-------------------------------------
-- class UI_EventIncarnationOfSinsRankingTotalTab
-------------------------------------
UI_EventIncarnationOfSinsRankingTotalTab = class(PARENT,{
    m_rewardTableView = 'UIC_TableView',
    m_structRankReward = 'StructRankReward',

    m_ownerUI = 'UI_EventIncarnationOfSinsRankingPopup', -- 현재 검색 타입에 대해 받아올 때 필요
    m_searchType = 'string', -- 검색 타입 (world, clan, friend)
    ------------------------------------------------
    m_tRankData = 'table', -- 전체 랭크 정보
    m_rankOffset = 'number', -- 오프셋
    ------------------------------------------------
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:init(owner_ui)
    local vars = self:load('event_incarnation_of_sins_rank_popup_all.ui')

    self.m_ownerUI = owner_ui
    self.m_searchType = owner_ui.m_rankType
    self.m_tRankData = {}
    self.m_rankOffset = 1

end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
        self:initButton()
        self.m_searchType = self.m_ownerUI.m_rankType
        self:request_EventIncarnationOfSinsAttrRanking('all')
    end

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:refresh()
end


-------------------------------------
-- function makeRankTableView
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:makeRankTableView(data)
    local vars = self.vars
    local rank_node = vars['rankListNode']
    local rank_data = data
    local my_rank_data = data['total_my_info'] -- g_eventIncarnationOfSinsData.m_tMyRankInfo['total']


    local make_my_rank_cb = function()
        local my_data = my_rank_data or {}
        local me_rank = UI_EventIncarnationOfSinsRankingTotalTabRankingListItem(my_data)
        vars['rankMeNode']:addChild(me_rank.root)
        me_rank.vars['meSprite']:setVisible(true)
    end
    
    local l_rank_list = rank_data['total_list'] or {}
    
    -- 이전 랭킹 버튼 누른 후 콜백
    local function func_prev_cb(offset)
        self:refreshRank(offset)
    end

    -- 다음 랭킹 버튼 누른 후 콜백
    local function func_next_cb(offset)
        self:refreshRank(offset)
    end

    local uid = g_userData:get('uid')
    local create_cb = function(ui, data)
        if (data['uid'] == uid) then
            ui.vars['meSprite']:setVisible(true)
        end
    end
    
    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_EventIncarnationOfSinsRankingTotalTabRankingListItem, create_cb)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr('랭킹 정보가 없습니다')
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
function UI_EventIncarnationOfSinsRankingTotalTab:makeRewardTableView(my_info)
    local vars = self.vars
    local node = vars['userRewardNode']
    
    -- 최조 한 번만 생성
    if (self.m_rewardTableView) then
        return
    end

    -- 랭킹 보상 테이블
    -- 서버로부터 랭킹 보상 테이블을 받아야 함
    local table_rank = ''
    local l_rank = struct_rank_reward:getRankRewardList()
    local struct_rank_reward = StructRankReward(table_rank)
    self.m_structRankReward = struct_rank_reward

    -- 보상테이블 가져온다.
    local table_rank = ''
	local create_func = function(ui, data)
        -- 티어 아이콘/ 티어 이름
		local tier_id = data['tier_id']
        if (tier_id) then
            local tier = table_rank[tier_id]['tier']
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
    table_view:setCellUIClass(UI_EventIncarnationOfSinsRankingTotalTabRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_arena_rank)

    self.m_rewardTableView = table_view
end





-------------------------------------
-- function request_EventIncarnationOfSinsAttrRanking
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:request_EventIncarnationOfSinsAttrRanking(attr_type)
    local attr_type = 'total'
    
    local function success_cb(ret)
        -- 랭킹 테이블 다시 만듬
        self:makeRankTableView(ret)
        --self:makeRewardTableView(ret['my_info'])

        -- TODO 리스트에 그려주기
    end  
    
    local function fail_cb(ret)
    end

    local offset = self.m_rankOffset

    local search_type = self.m_searchType
    local limit = SCORE_OFFSET_GAP

    g_eventIncarnationOfSinsData:request_EventIncarnationOfSinsAttrRanking(attr_type, search_type, offset, limit, success_cb, fail_cb)
end

-------------------------------------
-- function refreshRank
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTab:refreshRank(type) -- 다음/이전 버튼 눌렀을 경우 offset계산되어서 param으로 줌
    local type = (type == 'top' or type == 'my') and 'world' or type
    local offset = (type == 'top') and 1 or -1

    self.m_searchType = type

    self:request_EventIncarnationOfSinsAttrRanking('all')
end








-- tableview cell class
local CELL_PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_EventIncarnationOfSinsRankingAttributeTabListItem
-------------------------------------
UI_EventIncarnationOfSinsRankingTotalTabRankingListItem = class(CELL_PARENT,{
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTabRankingListItem:init(m_rankInfo)
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
function UI_EventIncarnationOfSinsRankingTotalTabRankingListItem:initUI()
    local vars = self.vars
    local t_rank_info = StructUserInfoArena:create_forRanking(self.m_rankInfo)

    -- 점수 표시
    vars['scoreLabel']:setString(self.m_rankInfo['rp'])

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(self.m_rankInfo['nick'])

    -- 순위 표시
    local rankStr = self.m_rankInfo['rank']
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



-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaRankingListItem:initButton()
    local vars = self.vars
    
    local t_rank_info = self.m_rankInfo
    local t_clan_info = t_rank_info['clan_info']
    if (t_clan_info) then
	    vars['clanBtn']:registerScriptTapHandler(function()
            g_clanData:requestClanInfoDetailPopup(t_clan_info['id'])
        end)
    end
end




-- tableview cell class
local CELL_PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_EventIncarnationOfSinsRankingAttributeTabListItem
-------------------------------------
UI_EventIncarnationOfSinsRankingTotalTabRewardListItem = class(CELL_PARENT,{
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTabRewardListItem:init(t_data)
    local vars = self:load('event_incarnation_of_sins_rank_popup_all_item_01.ui')
    self.m_rewardInfo = t_data

    self:initUI()
end



-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingTotalTabRewardListItem:initUI()
    local vars = self.vars
    local t_data = self.m_rewardInfo
    local l_reward = TableClass:seperate(t_data['reward'], ',', true)

    for i = 1, #l_reward do
        local l_str = seperate(l_reward[i], ';')
        local item_id = TableItem:getItemIDFromItemType(l_str[1]) -- 아이템 아이콘
        local icon = IconHelper:getItemIcon(item_id) 

        local cnt = l_str[2] -- 아이콘 수량
        
        if (icon and cnt) then
			icon:setScale(0.4)
		    vars['rewardLabel' .. i]:setString(comma_value(cnt))
            vars['rewardNode' .. i]:addChild(icon)
        end
    end

    local rank_str = StructRankReward.getRankName(t_data) 
    vars['rankLabel']:setString(rank_str)
end