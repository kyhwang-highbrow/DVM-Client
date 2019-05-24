local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_IllusionRank
-------------------------------------
UI_IllusionRank = class(PARENT, {
        m_rankType = 'string',
        m_rankOffset = 'number',
     })

local RANK_OFFSET = 20
-------------------------------------
-- function init
-------------------------------------
function UI_IllusionRank:init()
    local vars = self:load('event_dungeon_ranking_popup.ui')
    UIManager:open(self, UIManager.SCENE)
    
	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_IllusionRank')
	
	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

    self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionRank:initUI()
    local vars = self.vars

    self:make_UIC_SortList()

    self:initRank()
    self:initReward()

    
end

-------------------------------------
-- function initRank
-- @brief
-------------------------------------
function UI_IllusionRank:initRank()
    local vars = self.vars
    local rank_node = vars['rankListNode']

    local make_my_rank_cb = function()
        local me_rank = UI_IllusionRankListItem()
        vars['meRankNode']:addChild(me_rank.root)
    end
    
    local l_rank_list = {}
    for i=1,20 do
        local temp = {}
        temp['rank'] = i
        table.insert(l_rank_list, temp)
    end

    -- 이전 랭킹 보기
    local function click_prevBtn()
        --self.m_rankOffset = self.m_rankOffset - OFFSET_GAP
        --self.m_rankOffset = math_max(self.m_rankOffset, 0)
        --self:request_Rank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        --local add_offset = #g_ancientTowerData.m_lGlobalRank
        --if (add_offset < OFFSET_GAP) then
        --    MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
        --    return
        --end
        --self.m_rankOffset = self.m_rankOffset + add_offset
        --self:request_Rank()
    end

    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_IllusionRankListItem, nil)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr('랭킹 정보가 없습니다')
    rank_list:setMyRank(make_my_rank_cb)
    rank_list:makeRankMoveBtn(click_prevBtn, click_nextBtn, RANK_OFFSET)
    rank_list:makeRankList(rank_node)
    rank_list:setOffset(1)
    rank_list:setFocus('rank', 1)
end

-------------------------------------
-- function initReward
-- @brief
-------------------------------------
function UI_IllusionRank:initReward()
    local vars = self.vars
    local rank_node = vars['rewardNode']
    
    local l_rank_list = {}
    for i=1,20 do
        local temp = {}
        temp['rank'] = i
        table.insert(l_rank_list, temp)
    end

    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_IllusionRewardListItem, nil)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr('랭킹 정보가 없습니다')
    rank_list:makeRankList(rank_node)
    rank_list:setOffset(1)
    rank_list:setFocus('rank', 1)
end


-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_IllusionRank:make_UIC_SortList()
    local vars = self.vars

    -- 내 순위 필터
    local button = vars['rankListBtn']
    local label = vars['rankListLabel']

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
function UI_IllusionRank:onChangeRankingType(type)
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
    --[[
    --self:request_Rank()
    
    if (self.m_rewardTableView) then 
        return 
    end
    
    -- 보상 테이블 정보는 고대의 탑 들어올 때 받음
    self.m_rewardInfo = g_ancientTowerData.m_rewardTable
    if (self.m_rewardInfo) then
        self:init_rewardTableView()
    end
    --]]
end







local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_IllusionRankListItem
-------------------------------------
UI_IllusionRankListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionRankListItem:init()
    local vars = self:load('event_dungeon_ranking_reward_item.ui')
end












local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_IllusionRewardListItem
-------------------------------------
UI_IllusionRewardListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionRewardListItem:init()
    local vars = self:load('event_dungeon_ranking_reward_item.ui')
end
