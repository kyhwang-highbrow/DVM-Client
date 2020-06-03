local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

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
        m_bClosedTag = 'boolean', -- 시즌이 종료되어 처리를 했는지 여부
     })

UI_Colosseum.ATK = 'atk'
UI_Colosseum.DEF = 'def'
UI_Colosseum.RANKING = 'ranking'
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
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_Colosseum:init()
    self.m_rankOffset = 1 -- 최상위 랭크를 받겠다는 뜻
    self.m_bClosedTag = false

    local vars = self:load_keepZOrder('colosseum_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_uiName = 'UI_Colosseum'
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
        local ui

        -- 시즌 보상 팝업 (보상이 있다면)
		if (g_colosseumData.m_tSeasonRewardInfo) then
            local t_info = g_colosseumData.m_tSeasonRewardInfo
            local is_clan = false

            ui = UI_ColosseumRankingRewardPopup(t_info, is_clan)

            g_colosseumData.m_tSeasonRewardInfo = nil
		end

        -- 클랜 보상 팝업 (보상이 있다면)
        if (g_colosseumData.m_tClanRewardInfo) then
            local t_info = g_colosseumData.m_tClanRewardInfo
            local is_clan = true

            if (ui) then
                ui:setCloseCB(function()
                    UI_ColosseumRankingRewardPopup(t_info, is_clan)
                end)
            else
                UI_ColosseumRankingRewardPopup(t_info, is_clan)
            end

            g_colosseumData.m_tClanRewardInfo = nil
        end
    end

    self:sceneFadeInAction(nil, finich_cb)

    -- @ TUTORIAL : colosseum
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
        if (IS_TEST_MODE()) then
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

    local struct_user_info = g_colosseumData:getPlayerColosseumUserInfo()
    do
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
    end

	-- 주간 승수 보상
	local curr_win = struct_user_info:getWinCnt()
	local temp
	if curr_win > 20 then
		temp = 4
	else
		temp = math_floor(curr_win/5)
	end
	vars['rewardVisual']:changeAni('reward_' .. temp, true)
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
        UI_ConfirmPopup('cash', 10, Str('새로고침을 하시겠습니까?'), ok_cb)
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
    local ui = UI_ColosseumDeckSettings(COLOSSEUM_STAGE_ID, 'def')

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
    self:addTabAuto(UI_Colosseum['ATK'], vars, vars['atkListNode'], vars['refreshBtn'], vars['powerLabel'])
    self:addTabAuto(UI_Colosseum['DEF'], vars, vars['defListNode'], vars['powerLabel'], vars['defDeckBtn'])

    --self:addTabAuto(UI_Colosseum['RANKING'], vars, vars['rankingListNode'], vars['myRankingListNode'])
    
    -- 클랜 랭킹
    local tab_ui = UI_ColosseumTabRank(self, 'rank')
    self:addTabWithTabUIAndLabel(UI_Colosseum['RANKING'], vars['rankingTabBtn'], vars['rankingTabLabel'], tab_ui)


    self:setTab(UI_Colosseum['ATK'])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Colosseum:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    local vars = self.vars
    if (tab == UI_Colosseum.ATK) then
        self:refresh_combatPower('atk')

    elseif (tab == UI_Colosseum.DEF) then
        self:refresh_combatPower('def')
        self:request_matchHistory()
    end

    if (not first) then
        return
    end

    if (tab == UI_Colosseum.ATK) then
        self:init_atkTab()
    end
end

-------------------------------------
-- function init_atkTab
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

    local l_item_list = g_colosseumData.m_matchList
    table_view:setItemList(l_item_list)

    -- 상대방 방어덱의 전투력이 낮은 순으로 정렬
    local function sort_func(a, b)
        -- StructUserInfoColosseum
        local a_data = a['data']
        local b_data = b['data']

        -- 리그 포인트를 얻어옴
        local a_rp = a_data:getRP()
        local b_rp = b_data:getRP()

        return a_rp < b_rp
    end
    table.sort(table_view.m_itemList, sort_func)
end

-------------------------------------
-- function update
-------------------------------------
function UI_Colosseum:update(dt)
    local vars = self.vars

    -- UI내에서 시즌이 종료되는 경우 예외처리
    if self.m_bClosedTag then
        return

    elseif (not g_colosseumData:isOpenColosseum()) then
        local function ok_cb()
            -- 로비로 이동
            UINavigator:goTo('lobby')
        end
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 시즌이 종료되었습니다.'), ok_cb)
        self.m_bClosedTag = true
        return
    end

    local str = g_colosseumData:getColosseumStatusText()
    vars['timeLabel']:setString(str)

    if (g_colosseumData:isFreeRefresh()) then
        -- 무료 새로고침
        local str = Str('무료')
        vars['cashLabel']:setString(str)
        vars['refreshTimeLabel']:setString('')
    else
        -- 유료 새로고침
        local cash = 10
        vars['cashLabel']:setString(comma_value(cash))
        local str = g_colosseumData:getRefreshStatusText()
        vars['refreshTimeLabel']:setString(str)
    end
   
    do -- 연승 버프
        local str, active = g_colosseumData:getStraightTimeText()
        if active then
            local title = g_colosseumData:getStraightBuffTitle()
            local text = g_colosseumData:getStraightBuffText()
            vars['buffLabel1']:setString(title)
            vars['buffLabel2']:setString(str)
            vars['buffLabel3']:setString(text)
        else
            vars['buffLabel1']:setString(Str('연승 버프'))
            vars['buffLabel2']:setString(Str('연승 버프 없음'))
            vars['buffLabel3']:setString('')
        end

    end
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
