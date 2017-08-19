local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

local RANK_SHOW_CNT = 30 -- 한번에 보여주는 랭커 수

-------------------------------------
-- class UI_Colosseum
-------------------------------------
UI_Colosseum = class(PARENT, {
        m_weekRankTableView = 'UIC_TableView',
        m_topRankTableView = 'UIC_TableView',
        m_friendRankTableView = 'UIC_TableView',

        m_weekRankOffset = 'number', -- 서버에 랭킹 리스트 요청용
        m_topRankOffset = 'number', -- 서버에 랭킹 리스트 요청용

        m_rankOffset = 'number',
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Colosseum:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Colosseum'
    self.m_titleStr = Str('콜로세움')
	self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'honor'
end

-------------------------------------
-- function init
-------------------------------------
function UI_Colosseum:init()
    SoundMgr:playBGM('bgm_lobby')
    self.m_rankOffset = 1 -- 최상위 랭크를 받겠다는 뜻

    local vars = self:load_keepZOrder('colosseum_scene_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Colosseum')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 보상 안내 팝업
    local function finich_cb()
		if (g_colosseumData.m_tSeasonRewardInfo) then
            local info = g_colosseumData.m_tSeasonRewardInfo
            local t_ret = g_colosseumData.m_tRet

            UI_ColosseumRankingRewardPopup(info, t_ret)

            g_colosseumData.m_tSeasonRewardInfo = nil
            g_colosseumData.m_tRet = nil
		end
    end

    self:sceneFadeInAction(nil, finich_cb)

    -- @ TUTORIAL
    TutorialManager.getInstance():startTutorial(TUTORIAL.COLOSSEUM, self)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Colosseum:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Colosseum:initUI()
    local vars = self.vars

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)

    -- 유료 새로고침
    local cash = 10
    vars['cashLabel']:setString(comma_value(cash))

    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Colosseum:initButton()
    local vars = self.vars
    vars['winBuffDetailBtn']:registerScriptTapHandler(function() self:click_winBuffDetailBtn() end)
    vars['rankDetailBtn']:registerScriptTapHandler(function() self:click_rankDetailBtn() end)
    vars['rewardInfoBtn']:registerScriptTapHandler(function() self:click_rewardInfoBtn() end)
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    vars['defDeckBtn']:registerScriptTapHandler(function() self:click_defDeckBtn() end)

    if (vars['testModeBtn']) then
        if (isTestMode()) then
            vars['testModeBtn']:registerScriptTapHandler(function() self:click_testModeBtn() end)
            vars['testModeBtn']:setVisible(true)
        else
            vars['testModeBtn']:setVisible(false)
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Colosseum:refresh()
    local vars = self.vars

    do
        local struct_user_info = g_colosseumData:getPlayerColosseumUserInfo()

        -- 티어 아이콘
        vars['tierIconNode']:removeAllChildren()
        local icon = struct_user_info:makeTierIcon(nil, 'big')
        vars['tierIconNode']:addChild(icon)

        -- 티어 이름
        local tier_name = struct_user_info:getTierName()
        vars['tierLabel']:setString(tier_name)


        -- 순위, 점수, 승률, 연승
        local str = struct_user_info:getRankText() .. '\n'
            .. struct_user_info:getRPText()  .. '\n'
            .. struct_user_info:getWinRateText()  .. '\n'
            .. struct_user_info:getWinstreakText()
        vars['rankingLabel']:setString(str)

        -- 연승 버프
        local buff_str = g_colosseumData:getStraightBuffText()
        vars['winBuffLabel']:setString(buff_str)
    end
end

-------------------------------------
-- function click_winBuffDetailBtn
-- @breif 연승 버프 안내 팝업
-------------------------------------
function UI_Colosseum:click_winBuffDetailBtn()
	UI_ColosseumBuffInfoPopup()
end

-------------------------------------
-- function click_rankDetailBtn
-- @brief 콜로세움 랭킹 정보 팝업 (최고 순위 기록 시즌, 현재 시즌)
-------------------------------------
function UI_Colosseum:click_rankDetailBtn()
	UI_ColosseumRankInfoPopup()
end

-------------------------------------
-- function click_rewardInfoBtn
-- @brief 콜로세움 보상 정보 팝업
-------------------------------------
function UI_Colosseum:click_rewardInfoBtn()
    UI_ColosseumRewardInfoPopup()
end

-------------------------------------
-- function click_refreshBtn
-- @brief 공격전 대상 리스트 갱신 버튼
-------------------------------------
function UI_Colosseum:click_refreshBtn()
    
    local function ok_cb()
        local function finish_cb()
            self:init_atkTab()
        end

        local fail_cb = nil

        g_colosseumData:request_atkListRefresh(finish_cb, fail_cb)
    end

    if (not g_colosseumData:isFreeRefresh()) then
        UI_ConfirmPopup('cash', 10, '새로고침을 하시겠습니까?', ok_cb)
    else
        ok_cb()
    end
end

-------------------------------------
-- function refresh_combatPower
-- @brief
-------------------------------------
function UI_Colosseum:refresh_combatPower(type)
    local vars = self.vars
    local type = type or 'all'

    if (type == 'all') or (type == 'atk') then
        local combat_power = g_colosseumData.m_playerUserInfo:getAtkDeckCombatPower(true)
        vars['powerLabel']:setString(Str('공격 전투력 : {1}', comma_value(combat_power)))
    end

    if (type == 'all') or (type == 'def') then
        local combat_power = g_colosseumData.m_playerUserInfo:getDefDeckCombatPower(true)
        vars['powerLabel']:setString(Str('방어 전투력 : {1}', comma_value(combat_power)))
    end
end

-------------------------------------
-- function click_defDeckBtn
-- @brief 방어 덱 설정 버튼
-------------------------------------
function UI_Colosseum:click_defDeckBtn()
    local vars = self.vars
    local with_friend = nil
    local ui = UI_ColosseumDeckSettings(COLOSSEUM_STAGE_ID, with_friend, 'def')

    local function close_cb()
        self:refresh_combatPower('def')
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_testModeBtn
-- @brief 테스트 모드로 진입
-------------------------------------
function UI_Colosseum:click_testModeBtn()
    local combat_power = g_colosseumData.m_playerUserInfo:getDefDeckCombatPower(true)
    if (combat_power == 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 방어 덱이 설정되지 않았습니다.'))
        return
    end

    UI_ColosseumReadyForDev()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Colosseum:initTab()
    local vars = self.vars
    self:addTab('atk_tab', vars['atkBtn'], vars['atkListNode'], vars['refreshBtn'], vars['powerLabel'])
    self:addTab('def_tab', vars['defBtn'], vars['defListNode'], vars['powerLabel'], vars['defDeckBtn'])
    self:addTab('ranking_tab', vars['rankingBtn'], vars['rankingListNode'], vars['myRankingListNode'])

    self:setTab('atk_tab')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Colosseum:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    local vars = self.vars
    if (tab == 'atk_tab') then
        self:refresh_combatPower('atk')

    elseif (tab == 'def_tab') then
        self:refresh_combatPower('def')
        self:request_matchHistory()

    elseif (tab == 'ranking_tab') then
        self:request_Rank()
    end

    if (not first) then
        return
    end

    if (tab == 'atk_tab') then
        self:init_atkTab()
    end
end

-------------------------------------
-- function init_weekRankTableView
-------------------------------------
function UI_Colosseum:init_atkTab()
    local node = self.vars['atkListNode']
    node:removeAllChildren()

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 150 + 5)
    table_view:setCellUIClass(UI_ColosseumAttackListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 정렬은??
    local l_item_list = g_colosseumData.m_matchList
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    --table_view_td:makeDefaultEmptyDescLabel(Str('보유한 드래곤이 없습니다.'))

    -- 정렬
    --g_colosseumRankData:sortColosseumRank(table_view.m_itemList)
    --self.m_weekRankTableView = table_view
end

-------------------------------------
-- function update_weekRankTableView
-------------------------------------
function UI_Colosseum:update_weekRankTableView(target_offset)
    local function finish_cb(ret, rank_list)
        self.m_weekRankOffset = ret['offset']

        if (1 < self.m_weekRankOffset) then
            local prev_data = {m_rank = 'prev'}
            rank_list['prev'] = prev_data
        end

        local next_data = {m_rank = 'next'}
        rank_list['next'] = next_data

        self.m_weekRankTableView:mergeItemList(rank_list)
        g_colosseumRankData:sortColosseumRank(self.m_weekRankTableView.m_itemList)
    end

    g_colosseumRankData:request_rankManual(target_offset, finish_cb)
end

-------------------------------------
-- function init_topRankTableView
-------------------------------------
function UI_Colosseum:init_topRankTableView()
    local node = self.vars['topRankTableViewNode']
    --node:removeAllChildren()

    local l_item_list = g_colosseumRankData.m_lTopRank

    if (self.m_topRankOffset > 1) then
        local prev_data = {m_rank = 'prev'}
        l_item_list['prev'] = prev_data
    end

    if (#l_item_list > 0) then
        local next_data = {m_rank = 'next'}
        l_item_list['next'] = next_data
    end

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_previousButton()
            self:update_topRankTableView(self.m_topRankOffset - 30)
        end
        ui.vars['previousButton']:registerScriptTapHandler(click_previousButton)

        local function click_nextButton()
            self:update_topRankTableView(self.m_topRankOffset + 30)
        end
        ui.vars['nextButton']:registerScriptTapHandler(click_nextButton)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(840, 100 + 5)
    table_view:setCellUIClass(UI_ColosseumRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    --table_view_td:makeDefaultEmptyDescLabel(Str('보유한 드래곤이 없습니다.'))

    -- 정렬
    g_colosseumRankData:sortColosseumRank(table_view.m_itemList)
    self.m_topRankTableView = table_view
end

-------------------------------------
-- function update_topRankTableView
-------------------------------------
function UI_Colosseum:update_topRankTableView(target_offset)
    local function finish_cb(ret, rank_list)
        self.m_topRankOffset = ret['offset']

        if (1 < self.m_topRankOffset) then
            local prev_data = {m_rank = 'prev'}
            rank_list['prev'] = prev_data
        end

        local next_data = {m_rank = 'next'}
        rank_list['next'] = next_data

        self.m_topRankTableView:mergeItemList(rank_list)
        g_colosseumRankData:sortColosseumRank(self.m_topRankTableView.m_itemList)
    end

    g_colosseumRankData:request_rankManual(target_offset, finish_cb)
end

-------------------------------------
-- function update
-------------------------------------
function UI_Colosseum:update(dt)
    local vars = self.vars
    local str = g_colosseumData:getColosseumStatusText()
    vars['timeLabel']:setString(str)

    local str = g_colosseumData:getRefreshStatusText()
    vars['refreshTimeLabel']:setString(str)


    do -- 연승 버프
        local str, active = g_colosseumData:getStraightTimeText()
        if active then
            local text = g_colosseumData:getStraightBuffText()
            vars['winBuffLabel']:setString(text)
            vars['winBuffTimeLabel']:setString(str)
        else
            vars['winBuffLabel']:setString(Str('연승 버프 없음'))
            vars['winBuffTimeLabel']:setString('')
        end

    end
end

-------------------------------------
-- function request_Rank
-------------------------------------
function UI_Colosseum:request_Rank()
    local function finish_cb()
        self.m_rankOffset = g_colosseumData.m_nGlobalOffset
        self:init_rankTableView()
    end
    local offset = self.m_rankOffset
    g_colosseumData:request_colosseumRank(offset, finish_cb)
end

-------------------------------------
-- function init_rankTableView
-------------------------------------
function UI_Colosseum:init_rankTableView()
    local vars = self.vars
    local node = vars['rankingListNode']
    local my_node = vars['myRankingListNode']

    node:removeAllChildren()
    my_node:removeAllChildren()
    
	do-- 내 순위
        local ui = UI_ColosseumRankListItem(g_colosseumData.m_playerUserInfo)
        my_node:addChild(ui.root)
	end

    local l_item_list = g_colosseumData.m_lGlobalRank

    if (1 < self.m_rankOffset) then
        local prev_data = { m_tag = 'prev' }
        l_item_list['prev'] = prev_data
    end

    local next_data = { m_tag = 'next' }
    l_item_list['next'] = next_data
    
    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_rankOffset = self.m_rankOffset - RANK_SHOW_CNT
        self.m_rankOffset = math_max(self.m_rankOffset, 0)
        self:request_Rank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        local add_offset = #g_colosseumData.m_lGlobalRank
        if (add_offset < RANK_SHOW_CNT) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_rankOffset = self.m_rankOffset + add_offset
        self:request_Rank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 120 + 5)
    table_view:setCellUIClass(UI_ColosseumRankListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    do-- 테이블 뷰 정렬
        local function sort_func(a, b)
            local a_data = a['data']
            local b_data = b['data']

            -- 이전, 다음 버튼 정렬
            if (a_data.m_tag == 'prev') then
                return true
            elseif (b_data.m_tag == 'prev') then
                return false
            elseif (a_data.m_tag == 'next') then
                return false
            elseif (b_data.m_tag == 'next') then
                return true
            end

            -- 랭킹으로 선별
            local a_rank = a_data.m_rank
            local b_rank = b_data.m_rank
            --if (a_rank ~= b_rank) then
                return a_rank < b_rank
            --end
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))   
end


-------------------------------------
-- function request_matchHistory
-------------------------------------
function UI_Colosseum:request_matchHistory()
    local function finish_cb()
        self:init_historyTableView()
    end
    g_colosseumData:request_colosseumDefHistory(finish_cb)
end

-------------------------------------
-- function init_historyTableView
-- @brief
-------------------------------------
function UI_Colosseum:init_historyTableView()
    local vars = self.vars
    local node = vars['defListNode']

    node:removeAllChildren()

    local l_item_list = g_colosseumData.m_matchHistory
    
    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(720, 150 + 5)
    table_view:setCellUIClass(UI_ColosseumHistoryListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    do-- 테이블 뷰 정렬
        local function sort_func(a, b)
            local a_data = a['data']
            local b_data = b['data']

            -- 매치 시간으로
            local a_value = a_data.m_matchTime
            local b_value = b_data.m_matchTime
            --if (a_value ~= b_value) then
                return a_value > b_value
            --end
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    table_view:makeDefaultEmptyDescLabel(Str('방어 내역이 없습니다.'))   
end


--@CHECK
UI:checkCompileError(UI_Colosseum)
