local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_IllusionRank
-------------------------------------
UI_IllusionRank = class(PARENT, {
        m_rankType = 'string',
        m_rankOffset = 'number',

        m_rewardTableView = 'UIC_TableView',
     })
local OFFSET_GAP = 30
local RANK_OFFSET_GAP = 20
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
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_IllusionRank:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['exchangeShopBtn']:registerScriptTapHandler(function() self:click_exchangeShop() end)
end

-------------------------------------
-- function initRank
-- @brief
-------------------------------------
function UI_IllusionRank:initRank()
    local vars = self.vars
    local rank_node = vars['rankListNode']
    local rank_data = g_illusionDungeonData.m_lIllusionRank

    local make_my_rank_cb = function()
        local my_data = rank_data['my_info'] or {}
        local me_rank = UI_IllusionRankListItem(my_data, true)
        vars['meRankNode']:addChild(me_rank.root)
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
        print( next_ind + 1)
        self.m_rankOffset = next_ind + 1
        self:requestRank()
    end

    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_IllusionRankListItem, nil)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr('랭킹 정보가 없습니다')
    rank_list:setMyRank(make_my_rank_cb)
    rank_list:setOffset(self.m_rankOffset)
    rank_list:makeRankMoveBtn(click_prevBtn, click_nextBtn, RANK_OFFSET_GAP)
    rank_list:makeRankList(rank_node)
    rank_list:setFocus('rank', rank_data['my_info']['rank'])
end

-------------------------------------
-- function initReward
-- @brief
-------------------------------------
function UI_IllusionRank:initReward()
    local vars = self.vars
    local rank_node = vars['rewardNode']
    
    local l_rank_list = g_illusionDungeonData.m_lIllusionRankReward
    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_IllusionRewardListItem, nil)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr('랭킹 정보가 없습니다')
    rank_list:makeRankList(rank_node)
    self.m_rewardTableView = rank_list.m_rankTableView
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
    uic:setSelectSortType('top')
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

    self:requestRank()
end

-------------------------------------
-- function requestRank
-------------------------------------
function UI_IllusionRank:requestRank()
    local function finish_cb()
        self:initRank()
        self:initReward()

        -- 받을 수 있는 보상에 포커싱
        local rank_data = g_illusionDungeonData.m_lIllusionRank
        local my_rank = rank_data['my_info']['rank']
        local my_score = rank_data['my_info']['score']
        local l_rank_list = g_illusionDungeonData.m_lIllusionRankReward
        local reward_data, ind = self.getPossibleReward_score(my_rank, my_score, l_rank_list)

        if (reward_data) then
            self.m_rewardTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
            self.m_rewardTableView:relocateContainerFromIndex(ind)
        end
    end
    local rank_type = self.m_rankType
    local offset = self.m_rankOffset
    g_illusionDungeonData:request_illusionRankInfo(rank_type, offset, finish_cb)
end

-------------------------------------
-- function getPossibleReward_score
-------------------------------------
function UI_IllusionRank.getPossibleReward_score(my_rank, my_score, l_rank_list)    
    -- 한번도 플레이 하지 않은 경우
    if (my_rank == -1) then
        return nil
    end

    for i,data in ipairs(l_rank_list) do

        local rank_min = tonumber(data['table']['rank_min'])
        local rank_max = tonumber(data['table']['rank_max'])
        local score_min = tonumber(data['table']['score_min'])

        -- 순위 필터
        if (rank_min and rank_max) then
            if (rank_min <= my_rank) and (my_rank <= rank_max) then
                if (my_score >= score_min) then
                    return data, i
                end
            end
        -- 점수 필터
        elseif (score_min) then
            if (my_score >= score_min) then
                return data, i
            end
        end
    end

    -- 마지막 보상 리턴
    local last_ind = #l_rank_list
    return l_rank_list[last_ind], last_ind
end

-------------------------------------
-- function click_exchangeShop
-------------------------------------
function UI_IllusionRank:click_exchangeShop()
    UI_IllusionShop()
end










local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_IllusionRewardListItem
-------------------------------------
UI_IllusionRewardListItem = class(PARENT, {
        m_rankInfo = 'table',
        --[[
              "table":{
                "tier_id":12,
                "ratio_min":"",
                "rank_min":2,
                "ratio_max":"",
                "rank_id":2,
                "score_min":7000,
                "week":1,
                "rank_max":2,
                "reward":"cash;3900,gold;700000"
              }
            },{
        --]]
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionRewardListItem:init(t_rankInfo)
    local vars = self:load('event_dungeon_ranking_reward_item.ui')
    self.m_rankInfo = t_rankInfo['table']

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionRewardListItem:initUI()
    local vars = self.vars
    local data = self.m_rankInfo

    -- 초기화
    vars['rewardLabel1']:setString('')
    vars['rewardLabel2']:setString('')

    -- 랭킹 보상
    local rank_name = self:getRankName()
    self.vars['rankLabel']:setString(rank_name)

    -- 랭킹 보상 아이템
    local l_reward = TableClass:seperate(data['reward'], ',', true)
    for i = 1, #l_reward do
        local l_str = seperate(l_reward[i], ';')
        local item_type = l_str[1]
        local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)

        local icon = IconHelper:getItemIcon(id)

        local table_item = TABLE:get('item')
        local t_item = table_item[id]
        vars['rewardNode'..i]:addChild(icon)

        local name = TableItem:getItemName(id)
        local cnt = l_str[2]
        vars['rewardLabel'..i]:setString(Str('{1}', comma_value(cnt)))
    end

    -- 받을 수 있는 보상에 포커싱
    local rank_data = g_illusionDungeonData.m_lIllusionRank
    local my_rank = rank_data['my_info']['rank']
    local my_score = rank_data['my_info']['score']

    if (my_score < 7000) then
        if (data['rank_min'] ~= '' or data['rank_max'] ~= '') then
            vars['lockSprite']:setVisible(true)
        end
    end

    local l_rank_list = g_illusionDungeonData.m_lIllusionRankReward
    local t_reward, idx = UI_IllusionRank.getPossibleReward_score(my_rank, my_score, l_rank_list)

    if (t_reward) then
        if (t_reward['table']['reward'] == data['reward']) then
            vars['meSprite']:setVisible(true)
        end
    end

end

-------------------------------------
-- function getRankName
-------------------------------------
function UI_IllusionRewardListItem:getRankName()
    local data = self.m_rankInfo
    local rank_min = data['rank_min']
    local rank_max = data['rank_max']
    local rank_str = ''
    if (rank_min ~= '' and rank_max  ~= '') then
        if (rank_min == rank_max) then
            rank_str = Str('{1}위', rank_min)
        else
            rank_str = Str('{1}위~{2}위', rank_min, rank_max)
        end
        return rank_str
    end

    local score_min = data['score_min']
    if (score_min ~= '') then
        rank_str = Str('{1}점 이상', score_min)
    end

    return rank_str
end
