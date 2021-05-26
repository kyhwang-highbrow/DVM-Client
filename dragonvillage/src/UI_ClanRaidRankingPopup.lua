local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaidRankingPopup
-------------------------------------
UI_ClanRaidRankingPopup = class(PARENT,{
        m_rank_data = 'table',
        m_offset = 'number',
        m_rank_list = 'UIC_TableView',
        m_rank_reward = 'UIC_TableView',
    })

local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidRankingPopup:init()
    local vars = self:load('clan_raid_rank_popup.ui')
    UIManager:open(self, UIManager.SCENE)
    self.m_offset = -1
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end , 'UI_ClanRaidRankingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidRankingPopup:initUI()
    local vars = self.vars

    self:addTabAuto('lastRank', vars, vars['lastRank' .. 'TabMenu'])
    self:addTabAuto('nowRank', vars, vars['nowRank' .. 'TabMenu'])

    self:setTab('nowRank')
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
    self:make_UIC_SortList()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidRankingPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidRankingPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanRaidRankingPopup:onChangeTab(tab, first)
    local vars = self.vars
    if (tab == 'lastRank') and (first) then
        UI_ClanRaidLastRankingTab(vars)
    end
end

-------------------------------------
-- function initRank
-------------------------------------
function UI_ClanRaidRankingPopup:initRank()
    local vars = self.vars
	local node = vars['rankListNode']
    local offset = self.m_offset
    local rank_type = CLAN_RANK['RAID']
    node:removeAllChildren()
    
	local l_item_list = clone(g_clanRankData:getRankData(rank_type)) or {}

    -- 내 랭킹에 포커스
    local struct_clan_rank = g_clanRankData:getMyRankData(rank_type)
    local my_rank = struct_clan_rank:getRank()
    local index = 1
    for ind, data in ipairs(l_item_list) do
        if (tonumber(data['rank']) == tonumber(my_rank)) then
            index = ind
            break
        end
    end

    if (self.m_offset == 1) then
        index = 1
    end


    -- 내 순위라면 offset을 첫 번 째 랭킹으로 
    if (self.m_offset == -1) then
        if (l_item_list[1]) then
            self.m_offset = l_item_list[1]['rank']
        end
    end

    local cb_func = function()
       self:initRank()
       self:focusInRankReward()
    end
    
    if (1 < self.m_offset) then
        local prev_data = { rank = 'prev' }
        table.insert(l_item_list, prev_data)
    end

    if (#l_item_list > 0) then
        local next_data = { rank = 'next' }
        table.insert(l_item_list, next_data)
    end

    -- 이전 랭킹 보기
    local click_prevBtn = function()
        -- 랭킹 리스트 중 가장 첫 번째 랭킹 - CLAN_OFFSET_GAP 부터 랭킹 데이터 가져옴
        self.m_offset = g_clanRankData:getRankData(rank_type)[1]['rank'] - CLAN_OFFSET_GAP
        self.m_offset = math_max(self.m_offset, 0)
        g_clanRankData:request_getRank(rank_type, self.m_offset, cb_func)
    end

    -- 다음 랭킹 보기
    local click_nextBtn = function()
        -- 랭킹 리스트 중 가장 마지막 랭킹 + 1 부터 랭킹 데이터 가져옴
        local cnt = #g_clanRankData:getRankData(rank_type)
        if (cnt < CLAN_OFFSET_GAP-1) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
       
        local next_ind = g_clanRankData:getRankData(rank_type)[cnt]['rank']
        self.m_offset = next_ind + 1
        g_clanRankData:request_getRank(rank_type, self.m_offset, cb_func)
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)     
    end
    

    local function sort_func(a, b)
        local a_data = a
        local b_data = b

        -- 이전, 다음 버튼 정렬
        if (a_data.rank == 'prev') then
            return true
        elseif (b_data.rank == 'prev') then
            return false
        elseif (a_data.rank == 'next') then
            return false
        elseif (b_data.rank == 'next') then
            return true
        end

        -- 랭킹으로 선별
        local a_rank = a_data.rank
        local b_rank = b_data.rank
        return a_rank < b_rank
    end

    table.sort(l_item_list, sort_func)


    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(552, 52)
    table_view:setCellUIClass(_UI_ClanRaidRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list, false)
    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))

    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(index)

    -- 내 랭킹
    self:makeMyRank()
end

-------------------------------------
-- function initRankReward
-------------------------------------
function UI_ClanRaidRankingPopup:initRankReward()
    local vars = self.vars
	local node = vars['reawardNode']
	local l_rank_list = g_clanRaidData:getRankRewardList() or {}

    if (not self.m_rank_reward) then
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(552, 52)
        table_view:setCellUIClass(_UI_ClanRaidRewardListItem)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank_list, false)
        self.m_rank_reward = table_view
    end

end

-------------------------------------
-- function focusInRankReward
-------------------------------------
function UI_ClanRaidRankingPopup:focusInRankReward()

    local idx = 1
    local ui = nil
    local struct_clan_rank = g_clanRankData:getMyRankData(CLAN_RANK['RAID'])
    local l_rank_list = g_clanRaidData:getRankRewardList()
    local my_rank = struct_clan_rank:getRank()
    local my_rank_rate = struct_clan_rank:getClanRate()
    local rank_type = nil
    local rank_value = 1
    for i,data in ipairs(l_rank_list) do
        
        local rank_min = tonumber(data['rank_min'])
        local rank_max = tonumber(data['rank_max'])

        local ratio_min = tonumber(data['ratio_min'])
        local ratio_max = tonumber(data['ratio_max'])

        -- 순위 필터
        if (rank_min and rank_max) then
            if (rank_min <= my_rank) and (my_rank <= rank_max) then
                rank_type = 'rank_min'
                rank_value = rank_min
                break
            end

        -- 비율 필터
        elseif (ratio_min and ratio_max) then
            if (ratio_min < my_rank_rate) and (my_rank_rate <= ratio_max) then
                rank_type = 'ratio_min'
                rank_value = ratio_min
                break
            end
        end

        idx = idx + 1
    end

    self.m_rank_reward:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    self.m_rank_reward:relocateContainerFromIndex(idx)

end

-------------------------------------
-- function makeMyRank
-------------------------------------
function UI_ClanRaidRankingPopup:makeMyRank()
    local node = self.vars['rankMeNode']
    node:removeAllChildren()

    local rank_type = CLAN_RANK['RAID']
    local my_rank = g_clanRankData:getMyRankData(rank_type)
    local ui = _UI_ClanRaidRankListItem(my_rank)
    ui.vars['mySprite']:setVisible(true)
    node:addChild(ui.root)
end

-------------------------------------
-- function make_UIC_SortList
-- @brief
-------------------------------------
function UI_ClanRaidRankingPopup:make_UIC_SortList()
    local vars = self.vars
    local button = vars['rankBtn1']
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


    uic:addSortType('my', Str('내 클랜 랭킹'))
    uic:addSortType('top', Str('최상위 클랜 랭킹'))

    uic:setSortChangeCB(function(sort_type) self:onChangeRankingType(sort_type) end)
    uic:setSelectSortType('top')
end

-------------------------------------
-- function onChangeRankingType
-- @brief
-------------------------------------
function UI_ClanRaidRankingPopup:onChangeRankingType(type)
    local l_attr = getAttrTextList() 
    if (type == 'my') then
        for i,v in pairs(l_attr) do
            self.m_offset = -1
        end
    elseif (type == 'top') then
        for i,v in pairs(l_attr) do
            self.m_offset = 1
        end
    end

    local cb_func = function()
       self:initRank()
       self:initRankReward()
       self:focusInRankReward()
    end

    local rank_type = CLAN_RANK['RAID']
    g_clanRankData:request_getRank(rank_type, self.m_offset, cb_func)
end















local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class _UI_ClanRaidRewardListItem
-------------------------------------
_UI_ClanRaidRewardListItem = class(PARENT,{
        m_data = 'table'
    })

-------------------------------------
-- function init
-------------------------------------
function _UI_ClanRaidRewardListItem:init(data)
    local vars = self:load('clan_raid_rank_popup_item_01.ui')
    self.m_data = data

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function _UI_ClanRaidRewardListItem:initUI()
    local vars = self.vars
    local data = self.m_data

    if (not data) then
        return
    end

    -- 순위 이름
    local rank_str
    if (data['rank_min'] ~= data['rank_max']) then
        rank_str = Str('{1}~{2}위 ', data['rank_min'], data['rank_max'])
    else
        if(data['ratio_max'] ~= '') then
            rank_str = Str('{1}위 미만', data['ratio_max'])
        else
            rank_str = Str('{1}위', data['rank_min'])
        end
    end

    -- 랭킹
    vars['rankLabel']:setString(rank_str)
    
    -- 클랜 보상
    local reward_cnt = string.match(data['reward'], '%d+')         
    local personal_max_percent = 0.06 -- 개인 보상 최대 퍼센트
    local personal_cnt = math_floor(reward_cnt * personal_max_percent)
    vars['rewardLabel1']:setString(comma_value(reward_cnt))
    vars['rewardLabel2']:setString(comma_value(personal_cnt))
    
    -- 클랜 경험치
    local num_clan_exp = tonumber(data['clan_exp'])
    vars['rewardLabel3']:setString(comma_value(num_clan_exp))


    -- 내 클랜 보상에 하이라이트
    local struct_clan_rank = g_clanRankData:getMyRankData(CLAN_RANK['RAID'])
    local my_rank = struct_clan_rank:getRank()
    if (my_rank == -1) then
        return
    end
    local my_rank_rate = struct_clan_rank:getClanRate()
    local rank_type = nil
    local rank_value = 1
        
    local rank_min = tonumber(data['rank_min'])
    local rank_max = tonumber(data['rank_max'])

    local ratio_min = tonumber(data['ratio_min'])
    local ratio_max = tonumber(data['ratio_max'])


    -- 순위 필터
    if (rank_min and rank_max) then
        if (rank_min <= my_rank) and (my_rank <= rank_max) then
            vars['meSprite']:setVisible(true)
            return
        end
    end

    -- 100위 밖
    if (not rank_min) then
        if (my_rank > 100) then
            vars['meSprite']:setVisible(true)
        end
    end

end







local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class _UI_ClanRaidRankListItem
-------------------------------------
_UI_ClanRaidRankListItem = class(PARENT,{
        m_data = 'table'
    })

-------------------------------------
-- function init
-------------------------------------
function _UI_ClanRaidRankListItem:init(data)
    local vars = self:load('clan_raid_scene_item_03.ui')
    self.m_data = data
    
    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function _UI_ClanRaidRankListItem:initUI()
    local data = self.m_data
    local vars = self.vars

    if (not data) then
        return ui
    end

    if (data['rank'] == 'prev') then
        vars['prevBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return ui
    end

    if (data['rank'] == 'next') then
        vars['nextBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return ui
    end

    local struct_clan_rank = StructClanRank(data)

    -- 클랜 마크
    local icon = struct_clan_rank:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan_rank:getClanLvWithName()
    vars['clanLabel']:setString(clan_name)

    -- 점수
    local clan_score = struct_clan_rank:getClanScore()
    vars['scoreLabel']:setString(clan_score)
    
    -- 진행중 단계
    local lv = struct_clan_rank['cdlv'] or 1
    vars['bossLabel']:setString(string.format('Lv.%d', lv))

    -- 정보 보기 버튼
    vars['infoBtn']:registerScriptTapHandler(function()
        local clan_object_id = struct_clan_rank:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)

    
    local focus_value = g_clanData.m_structClan:getClanObjectID()
    if (data['id'] == focus_value) then
        vars['mySprite']:setVisible(true)
    end

      -- 순위 등락 표시
    local cur_rank = struct_clan_rank:getRank()
    local gap_str = ''
    local last_rank = struct_clan_rank:getLastRank()
    -- 순위/지난 순위가 있을 경우에만 표
    if (cur_rank ~= -1) and (last_rank ~= -1) then
        local dis_rank = last_rank - cur_rank
        gap_str = descChangedValue(dis_rank)
    end
    
    -- 등수 
    local clan_rank = struct_clan_rank:getRank()
    local rank = clan_rank < 0 and '-' or string.format('%d', clan_rank)
    
    -- 등락이 있다면, 순위라벨에 줄바꿈 추가해서 한 칸 올려줌
    if (gap_str ~= '') then
        rank = rank .. '\n'
    end
    vars['rankLabel']:setString(rank)
    vars['rankDifferentLabel']:setVisible(true)
    vars['rankDifferentLabel']:setString(gap_str)
end

--@CHECK
UI:checkCompileError(UI_ClanRaidRankingPopup)

