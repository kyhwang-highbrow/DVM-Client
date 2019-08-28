local PARENT = class(UI, ITabUI:getCloneTable())

local RANK_OFFSET_GAP = 20

-------------------------------------
-- class UI_HallOfFameRank
-------------------------------------
UI_HallOfFameRank = class(PARENT,{
	m_tableView_book = 'TableView',
	m_tableView_quest = 'TableView',

    m_rankOffset = 'number',
    m_rankType = 'string',

    m_hallOfFameRankData = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameRank:init()
    local vars = self:load('hall_of_fame_rank_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    self.m_rankOffset = 1
    self.m_rankType = 'world'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HallOfFameRank')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameRank:initUI()
    local vars = self.vars

	self:addTabAuto('hall_of_fame', vars, vars['hall_of_fameTabMenu'])
    self:addTabAuto('quest', vars, vars['questTabMenu'])
	self:addTabAuto('book', vars, vars['bookTabMenu'])
    self:setTab('hall_of_fame')

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameRank:initButton()
    local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameRank:onChangeTab(tab, first)
	if (tab == 'hall_of_fame') then
	    -- 최초 생성만 실행
	    if (first) then
            self:make_UIC_SortList()
        end
    else
        -- 최초 생성만 실행
	    if (first) then
            local function cb_func()
			    self:makeTableViewRanking(tab)
			    self:refresh()
		    end
		    g_rankData:request_getRank(tab, nil, cb_func)
	    end
    end
end

-------------------------------------
-- function makeTableViewRanking
-------------------------------------
function UI_HallOfFameRank:makeTableViewRanking(tab)
	local vars = self.vars
	local node = vars[tab .. 'ListNode']
	local l_rank = g_rankData:getRankData(tab)['rank']

	do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(995, 55)
        table_view:setCellUIClass(UI_HallOfFameRankListItem)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank)
    end

	self['m_tableView_' .. tab] = table_view

	local t_my_rank = g_rankData:getRankData(tab)['my_rank']
	local ui = UI_HallOfFameRankListItem(t_my_rank)
	vars[tab .. 'MeNode']:addChild(ui.root)
	ui.vars['meSprite']:setVisible(true)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HallOfFameRank:refresh()
end

-------------------------------------
-- function initFallofFameTableView
-------------------------------------
function UI_HallOfFameRank:initFallofFameTableView(data)
    local vars = self.vars
    local rank_node = vars['hall_of_fameListNode']
    local rank_data = data

    local make_my_rank_cb = function()
        local my_data = rank_data['my_info'] or {}
        local me_rank = UI_HallOfFameRankListItem(my_data)
        vars['hall_of_fameMeNode']:addChild(me_rank.root)
        me_rank.vars['meSprite']:setVisible(true)
    end
    
    local l_rank_list = rank_data['list'] or {}
    
    -- 이전 랭킹 보기
    local function click_prevBtn()
        local prev_ind 
        if (#l_rank_list>0) then
            prev_ind = l_rank_list[1]['rank']
            if (type(prev_ind) == 'string') then
                prev_ind = l_rank_list[2]['rank']
            end
            prev_ind = prev_ind - RANK_OFFSET_GAP -- 가져온 랭킹의 가장 첫 번째 - OFFSET_GAP
        else
            prev_ind = self.m_rankOffset - OFFSET_GAP
        end
        self.m_rankOffset = prev_ind
        self.m_rankOffset = math_max(self.m_rankOffset, 0)
        self:requestRank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local next_ind = l_rank_list[#l_rank_list]['rank'] -- 가져온 랭킹의 가장 마지막 + 1
        if (type(next_ind) == 'string') then
            next_ind = l_rank_list[#l_rank_list-1]['rank']
        end
        if (#l_rank_list < RANK_OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end

        self.m_rankOffset = next_ind + 1
        self:requestRank()
    end

    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_HallOfFameRankListItem)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr('랭킹 정보가 없습니다')
    rank_list:setMyRank(make_my_rank_cb)
    rank_list:setOffset(self.m_rankOffset)
    rank_list:makeRankMoveBtn(click_prevBtn, click_nextBtn, RANK_OFFSET_GAP)
    rank_list:makeRankList(rank_node)
    rank_list:setFocus('rank', rank_data['my_info']['rank'])
end

-------------------------------------
-- function requestRank
-------------------------------------
function UI_HallOfFameRank:requestRank()
    local function finish_cb(ret)
        self:initFallofFameTableView(ret)
    end
    local rank_type = self.m_rankType
    local offset = self.m_rankOffset
    g_rankData:request_HallOfFameRank(rank_type, RANK_OFFSET_GAP, offset, finish_cb)
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_HallOfFameRank:onChangeRankingType(type)
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

    self:requestRank()
end

-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_HallOfFameRank:make_UIC_SortList()
    local vars = self.vars

    -- 내 순위 필터
    local button = vars['sortBtn']
    local label = vars['sortLabel']

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
