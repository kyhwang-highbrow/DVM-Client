local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaidRankingPopup
-------------------------------------
UI_ClanRaidRankingPopup = class(PARENT,{
        m_rank_data = 'table',
        m_offset = 'number',
    })

local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidRankingPopup:init()
    local vars = self:load('clan_raid_rank_popup.ui')
    UIManager:open(self, UIManager.SCENE)
    self.m_offset = 1
    
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
    self:initRankReward()
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
    local rank_type = CLAN_RANK['RAID']
    self.m_rank_data = g_clanRankData:getRankData(rank_type)
	local l_rank_list = self.m_rank_data

    self:initTableView(vars, node, l_rank_list)
end

-------------------------------------
-- function initRankReward
-------------------------------------
function UI_ClanRaidRankingPopup:initRankReward()
    local vars = self.vars
	local node = vars['reawardNode']
	local l_rank_list = g_clanRaidData:getRankRewardList()

    self:initRankTableView(vars, node, l_rank_list, empty_str)
end

-------------------------------------
-- function initRankTableView
-------------------------------------
function UI_ClanRaidRankingPopup:initRankTableView(vars, node, l_rank_list, empty_str)
    
    local func_make_reward = function(data)
        local ui = class(UI, ITableViewCell:getCloneTable())()
	    local vars = ui:load('clan_raid_rank_popup_item_01.ui')
        if (not data) then
            return ui
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

        return ui
    end
   
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(510, 50 + 5)
    table_view:setCellUIClass(func_make_reward)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank_list)
    
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_ClanRaidRankingPopup:initTableView(vars, node, l_rank_list, empty_str)

    -- 이전 보기 추가
    if (1 < self.m_offset) then
        l_rank_list['prev'] = 'prev'
    end

    -- 다음 보기 추가.. 
    if (#l_rank_list > 0) then
        l_rank_list['next'] = 'next'
    end
        
    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_offset = math_max(self.m_offset - CLAN_OFFSET_GAP, 1)
        self:request_clanRank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        if (table.count(l_rank_list) < CLAN_OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_offset = self.m_offset + CLAN_OFFSET_GAP
        self:request_clanRank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        if (data == 'prev') then
            ui.vars['prevBtn']:setVisible(true)
            ui.vars['itemMenu']:setVisible(false)
            ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        elseif (data == 'next') then
            ui.vars['nextBtn']:setVisible(true)
            ui.vars['itemMenu']:setVisible(false)
            ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
        end
    end

	do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(510, 50 + 5)
        table_view:setCellUIClass(self.makeRankCell, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank_list)

        do-- 테이블 뷰 정렬
            local function sort_func(a, b)
                local a_data = a['data']
                local b_data = b['data']

                -- 이전, 다음 버튼 정렬
                if (a_data == 'prev') then
                    return true
                elseif (b_data == 'prev') then
                    return false
                elseif (a_data == 'next') then
                    return false
                elseif (b_data == 'next') then
                    return true
                end

                -- 랭킹으로 선별
                local a_rank = a_data:getRank()
                local b_rank = b_data:getRank()
                return a_rank < b_rank
            end

            table.sort(table_view.m_itemList, sort_func)
        end
        if (not empty_str) then
            -- 정산 문구 분기
            empty_str = ''
            if (g_clanRankData:isSettlingDown()) then
                empty_str = Str('현재 클랜 순위를 정산 중입니다. 잠시만 기다려주세요.')
            else
                empty_str = Str('랭킹 정보가 없습니다.')
            end
        end
        table_view:makeDefaultEmptyDescLabel(empty_str)
        
        local idx = nil
        for i,v in pairs(l_rank_list) do
            if (v['id'] == g_clanData.m_structClan:getClanObjectID()) then
                idx = i
                break
            end
        end

        if idx then
            table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
            table_view:relocateContainerFromIndex(idx)
        end
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
    local ui = self.makeRankCell(my_rank)
    node:addChild(ui.root)
end

-------------------------------------
-- function makeRankCell
-------------------------------------
function UI_ClanRaidRankingPopup.makeRankCell(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('clan_raid_scene_item_03.ui')
    if (not t_data) then
        return ui
    end
    if (t_data == 'next') then
        return ui
    end
    if (t_data == 'prev') then
        return ui
    end

    local struct_clan_rank = t_data

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
    
    -- 내클랜
    if (struct_clan_rank:isMyClan()) then
        vars['mySprite']:setVisible(true)
        vars['infoBtn']:setVisible(false)
    end

    -- 진행중 단계
    local lv = struct_clan_rank['cdlv'] or 1
    vars['bossLabel']:setString(string.format('Lv.%d', lv))

    -- 정보 보기 버튼
    vars['infoBtn']:registerScriptTapHandler(function()
        local clan_object_id = struct_clan_rank:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)

	return ui
end

-------------------------------------
-- function request_clanRank
-------------------------------------
function UI_ClanRaidRankingPopup:request_clanRank(first)
    local rank_type = CLAN_RANK['RAID']
    local offset = self.m_offset
    local cb_func = function()
        self:makeMyRank()
        self:initRank()
    end

    g_clanRankData:request_getRank(rank_type, offset, cb_func)
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
    self:request_clanRank()
end

--@CHECK
UI:checkCompileError(UI_ClanRaidRankingPopup)

