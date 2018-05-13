local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Arena
-------------------------------------
UI_Arena = class(PARENT, {
        m_weekRankTableView = 'UIC_TableView',
        m_topRankTableView = 'UIC_TableView',
        m_friendRankTableView = 'UIC_TableView',

        m_weekRankOffset = 'number', -- 서버에 랭킹 리스트 요청용
        m_topRankOffset = 'number', -- 서버에 랭킹 리스트 요청용

        m_rankOffset = 'number',
        m_bClosedTag = 'boolean', -- 시즌이 종료되어 처리를 했는지 여부
     })

-- 탭 자동 등록을 위해 UI 네이밍과 맞춰줌  
UI_Arena.RANKING = 'ranking'
UI_Arena.HISTORY = 'history'

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Arena:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Arena'
    self.m_titleStr = Str('콜로세움')
	self.m_staminaType = 'arena'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'honor'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_Arena:init()
    self.m_rankOffset = 1 -- 최상위 랭크를 받겠다는 뜻
    self.m_bClosedTag = false

    local vars = self:load_keepZOrder('arena_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_uiName = 'UI_Arena'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Arena')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 보상 안내 팝업
--    local function finich_cb()
--        local ui

--        -- 시즌 보상 팝업 (보상이 있다면)
--		if (g_colosseumData.m_tSeasonRewardInfo) then
--            local t_info = g_colosseumData.m_tSeasonRewardInfo
--            local is_clan = false

--            ui = UI_ArenaRankingRewardPopup(t_info, is_clan)

--            g_colosseumData.m_tSeasonRewardInfo = nil
--		end

--        -- 클랜 보상 팝업 (보상이 있다면)
--        if (g_colosseumData.m_tClanRewardInfo) then
--            local t_info = g_colosseumData.m_tClanRewardInfo
--            local is_clan = true

--            if (ui) then
--                ui:setCloseCB(function()
--                    UI_ArenaRankingRewardPopup(t_info, is_clan)
--                end)
--            else
--                UI_ArenaRankingRewardPopup(t_info, is_clan)
--            end

--            g_colosseumData.m_tClanRewardInfo = nil
--        end
--    end

--    self:sceneFadeInAction(nil, finich_cb)

    -- @ TUTORIAL : colosseum
--    TutorialManager.getInstance():startTutorial(TUTORIAL.COLOSSEUM, self)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Arena:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Arena:initUI()
    local vars = self.vars

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Arena:initButton()
    local vars = self.vars
--    vars['winBuffDetailBtn']:registerScriptTapHandler(function() self:click_winBuffDetailBtn() end)
--    vars['rankDetailBtn']:registerScriptTapHandler(function() self:click_rankDetailBtn() end)
--    vars['rewardInfoBtn']:registerScriptTapHandler(function() self:click_rewardInfoBtn() end)
--    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
--    vars['defDeckBtn']:registerScriptTapHandler(function() self:click_defDeckBtn() end)

--    if (vars['testModeBtn']) then
--        if (IS_TEST_MODE()) then
--            vars['testModeBtn']:registerScriptTapHandler(function() self:click_testModeBtn() end)
--            vars['testModeBtn']:setVisible(true)
--        else
--            vars['testModeBtn']:setVisible(false)
--        end
--    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Arena:refresh()
    local vars = self.vars

--    local struct_user_info = g_colosseumData:getPlayerColosseumUserInfo()
--    do
--        -- 티어 아이콘
--        vars['tierIconNode']:removeAllChildren()
--        local icon = struct_user_info:makeTierIcon(nil, 'big')
--        vars['tierIconNode']:addChild(icon)

--        -- 티어 이름
--        local tier_name = struct_user_info:getTierName()
--        vars['tierLabel']:setString(tier_name)

--        -- 순위, 점수, 승률, 연승
--        local str = struct_user_info:getRankText() .. '\n'
--            .. struct_user_info:getRPText()  .. '\n'
--            .. struct_user_info:getWinRateText()  .. '\n'
--            .. struct_user_info:getWinstreakText()
--        vars['rankingLabel']:setString(str)
--    end

--	-- 주간 승수 보상
--	local curr_win = struct_user_info:getWinCnt()
--	local temp
--	if curr_win > 20 then
--		temp = 4
--	else
--		temp = math_floor(curr_win/5)
--	end
--	vars['rewardVisual']:changeAni('reward_' .. temp, true)
end

-------------------------------------
-- function click_winBuffDetailBtn
-- @breif 연승 버프 안내 팝업
-------------------------------------
function UI_Arena:click_winBuffDetailBtn()
	UI_ArenaBuffInfoPopup()
end

-------------------------------------
-- function click_rankDetailBtn
-- @brief 콜로세움 랭킹 정보 팝업 (최고 순위 기록 시즌, 현재 시즌)
-------------------------------------
function UI_Arena:click_rankDetailBtn()
	UI_ArenaRankInfoPopup()
end

-------------------------------------
-- function click_rewardInfoBtn
-- @brief 콜로세움 보상 정보 팝업
-------------------------------------
function UI_Arena:click_rewardInfoBtn()
    UI_ArenaRewardInfoPopup()
end

-------------------------------------
-- function click_refreshBtn
-- @brief 공격전 대상 리스트 갱신 버튼
-------------------------------------
function UI_Arena:click_refreshBtn()
    
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
function UI_Arena:refresh_combatPower(type)
    local vars = self.vars
    local type = type or 'all'

--    if (type == 'all') or (type == 'atk') then
--        local combat_power = g_colosseumData.m_playerUserInfo:getAtkDeckCombatPower(true)
--        vars['powerLabel']:setString(Str('공격 전투력 : {1}', comma_value(combat_power)))
--    end

--    if (type == 'all') or (type == 'def') then
--        local combat_power = g_colosseumData.m_playerUserInfo:getDefDeckCombatPower(true)
--        vars['powerLabel']:setString(Str('방어 전투력 : {1}', comma_value(combat_power)))
--    end
end

-------------------------------------
-- function click_defDeckBtn
-- @brief 방어 덱 설정 버튼
-------------------------------------
function UI_Arena:click_defDeckBtn()
    local vars = self.vars
    local ui = UI_ArenaDeckSettings(COLOSSEUM_STAGE_ID, 'def')

    local function close_cb()
        self:refresh_combatPower('def')
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_testModeBtn
-- @brief 테스트 모드로 진입
-------------------------------------
function UI_Arena:click_testModeBtn()
    local combat_power = g_colosseumData.m_playerUserInfo:getDefDeckCombatPower(true)
    if (combat_power == 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 방어 덱이 설정되지 않았습니다.'))
        return
    end

    UI_ArenaReadyForDev()
end

-------------------------------------
-- function initTab
-- @brief 랭킹, 기록 탭
-------------------------------------
function UI_Arena:initTab()
    local vars = self.vars
    self:addTabAuto(UI_Arena.RANKING, vars, vars['rankingMenu'])
    self:addTabAuto(UI_Arena.HISTORY, vars, vars['historyMenu'])
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)

    self:setTab(UI_Arena.RANKING)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Arena:onChangeTab(tab, first)
    if (not first) then
        return
    end

    if (tab == UI_Arena.RANKING) then
        UI_ArenaTabRank(self)

    elseif (tab == UI_Arena.HISTORY) then
        UI_ArenaTabHistory(self)
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_Arena:update(dt)
    if true then
        return
    end

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

--@CHECK
UI:checkCompileError(UI_Arena)
