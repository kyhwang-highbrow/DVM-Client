local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaidRankingPopup
-------------------------------------
UI_ClanRaidRankingPopup = class(PARENT,{
        m_rank_data = 'table',
        m_offset = 'number',
        m_rank_list = 'UIC_RankList',
        m_rank_reward_list = 'UIC_RankList',
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
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanRaidRankingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    
    self:initUI()
    self:initRankReward()
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
-- function initTableView
-------------------------------------
function UI_ClanRaidRankingPopup:initRank()
    local vars = self.vars
	local node = vars['rankListNode']
    local offset = self.m_offset
    local rank_type = CLAN_RANK['RAID']
    
    self.m_rank_data = g_clanRankData:getRankData(rank_type)
	local l_rank_list = self.m_rank_data

    local cb_func = function()
       self:initRank()
       self:focusInRankReward()
    end

    local click_func = function(offset)
        g_clanRankData:request_getRank(rank_type, offset, cb_func)
    end

    
    if (not self.m_rank_list) then
        self.m_rank_list = UIC_RankingList()                                    -- step0. (필수)랭킹 UI 컴포넌트 생성
    end

    self.m_rank_list:setRankUIClass(_UI_ClanRaidRankListItem, nil)              -- step1. (필수)셸 UI 설정  
    self.m_rank_list:setRankList(l_rank_list)                                   -- step2. (필수)리스트 설정
    self.m_rank_list:setOffset(offset)                                          -- step3. (선택)몇 랭킹부터 보여줄 것인가 (1 이면 최상위 랭킹 부터, -1이면 내 랭킹 부터)
    self.m_rank_list:makeRankMoveBtn(click_func, click_func, CLAN_OFFSET_GAP)   -- step4. (선택)이전, 다음 버튼 사용할 것인가 (눌렀을 때 콜백 함수, )
    self.m_rank_list:setEmptyStr('')                                            -- step5. (선택)랭킹이 없을 때, 메세지 설정
    
    
    local make_my_rank_cb = function()
        self:makeMyRank()
    end
    self.m_rank_list:setMyRank(make_my_rank_cb)                                 -- step6. (선택)내 랭킹 만드는 콜백 함수
    self.m_rank_list:makeRankList(node)                                         -- step7. (필수)실제로 랭킹 생성

    local focus_value = g_clanData.m_structClan:getClanObjectID()
    self.m_rank_list:setFocus('id', focus_value)                                -- step8. (선택)해당 리스트에서 (type : id) focus_value 값에 포커싱, 하이라이트(vars['mySprite']가 있다면)
end

-------------------------------------
-- function initRankReward
-------------------------------------
function UI_ClanRaidRankingPopup:initRankReward()
    local vars = self.vars
	local node = vars['reawardNode']
	local l_rank_list = g_clanRaidData:getRankRewardList()

    local reward_rank_list = UIC_RankingList()                                  -- step0. (필수)랭킹 UI 컴포넌트 생성
    reward_rank_list:setRankUIClass(_UI_ClanRaidRewardListItem, nil)            -- step1. (필수)셸 UI 설정  
    reward_rank_list:setRankList(l_rank_list)                                   -- step2. (필수)리스트 설정
    reward_rank_list:setOffset(-1)                                              -- step5. (선택)몇 랭킹부터 보여줄 것인가 (1 이면 최상위 랭킹 부터, -1이면 내 랭킹 부터)
    reward_rank_list:makeRankList(node)                                         -- step7. (필수)실제로 랭킹 생성
    self.m_rank_reward_list = reward_rank_list
end

-------------------------------------
-- function initRankReward
-------------------------------------
function UI_ClanRaidRankingPopup:focusInRankReward()

    local idx = nil
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
    end

    if (rank_type) then
        self.m_rank_reward_list:setFocus(rank_type, rank_value)                              -- step8. (선택)해당 리스트에서 (type : id) focus_value 값에 포커싱, 하이라이트(vars['mySprite']가 있다면)
    end

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
    uic:setSelectSortType('my')
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
       self:focusInRankReward()
    end

    local rank_type = CLAN_RANK['RAID']
    g_clanRankData:request_getRank(rank_type, self.m_offset, cb_func)
end















local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanRaidRankingPopup
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
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, '_UI_ClanRaidRewardListItem')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function _UI_ClanRaidRewardListItem
-------------------------------------
function _UI_ClanRaidRewardListItem:initUI()
    local vars = self.vars
    local data = self.m_data

    if (not data) then
        return
    end

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

    vars['rankLabel']:setString(rank_str)
    
    local reward_cnt = string.match(data['reward'], '%d+')       
    -- 개인 보상 최대 퍼센트
    local personal_max_percent = 0.06
    local personal_cnt = math_floor(reward_cnt * personal_max_percent)
    vars['rewardLabel1']:setString(comma_value(reward_cnt))
    vars['rewardLabel2']:setString(comma_value(personal_cnt))
    local num_clan_exp = tonumber(data['clan_exp'])
    vars['rewardLabel3']:setString(comma_value(num_clan_exp))
end

local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanRaidRankingPopup
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
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, '_UI_ClanRaidRankListItem')
    
    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function _UI_ClanRaidRankListItem
-------------------------------------
function _UI_ClanRaidRankListItem:initUI()
    local data = self.m_data
    local vars = self.vars

    if (not data) then
        return ui
    end
    
    if (data['rank'] == 'prev') then
        return ui
    end

    if (data['rank'] == 'next') then
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
    
    -- 등수 
    local clan_rank = struct_clan_rank:getRank()
    local rank = clan_rank < 0 and '-' or string.format('%d', clan_rank)
    vars['rankLabel']:setString(rank)

    -- 진행중 단계
    local lv = struct_clan_rank['cdlv'] or 1
    vars['bossLabel']:setString(string.format('Lv.%d', lv))

    -- 정보 보기 버튼
    vars['infoBtn']:registerScriptTapHandler(function()
        local clan_object_id = struct_clan_rank:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)
end

--@CHECK
UI:checkCompileError(UI_ClanRaidRankingPopup)

