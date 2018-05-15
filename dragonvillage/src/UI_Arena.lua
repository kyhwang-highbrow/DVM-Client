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
UI_Arena['RANK'] = 'ranking'
UI_Arena['HISTORY'] = 'history'

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
    local function finich_cb()
--        local ui

--        -- 시즌 보상 팝업 (보상이 있다면)
--		if (g_arenaData.m_tSeasonRewardInfo) then
--            local t_info = g_arenaData.m_tSeasonRewardInfo
--            local is_clan = false

--            ui = UI_ArenaRankingRewardPopup(t_info, is_clan)

--            g_arenaData.m_tSeasonRewardInfo = nil
--		end

--        -- 클랜 보상 팝업 (보상이 있다면)
--        if (g_arenaData.m_tClanRewardInfo) then
--            local t_info = g_arenaData.m_tClanRewardInfo
--            local is_clan = true

--            if (ui) then
--                ui:setCloseCB(function()
--                    UI_ArenaRankingRewardPopup(t_info, is_clan)
--                end)
--            else
--                UI_ArenaRankingRewardPopup(t_info, is_clan)
--            end

--            g_arenaData.m_tClanRewardInfo = nil
--        end
    end

    self:sceneFadeInAction(nil, finich_cb)

    -- @ TUTORIAL : colosseum (튜토리얼 후에 처리)
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
    vars['testModeBtn']:setVisible(false)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['rewardInfoBtn']:registerScriptTapHandler(function() self:click_rewardInfoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Arena:refresh()
    local vars = self.vars

    local struct_user_info = g_arenaData:getPlayerArenaUserInfo()
    do
        -- 티어 아이콘
        vars['tierIconNode']:removeAllChildren()
        local icon = struct_user_info:makeTierIcon(nil, 'big')
        vars['tierIconNode']:addChild(icon)

        -- 티어 이름
        local tier_name = struct_user_info:getTierName()
        vars['tierLabel']:setString(tier_name)

        -- 순위, 점수, 승률
        local str = struct_user_info:getRankText() .. '\n'
            .. struct_user_info:getRPText()  .. '\n'
            .. struct_user_info:getWinRateText()  .. '\n'
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
-- function click_startBtn
-- @brief 출전 덱 설정 버튼
-------------------------------------
function UI_Arena:click_startBtn()
    UI_ArenaDeckSettings(ARENA_STAGE_ID, 'atk')
end

-------------------------------------
-- function click_testModeBtn
-- @brief 테스트 모드로 진입
-------------------------------------
function UI_Arena:click_testModeBtn()
    local combat_power = g_arenaData.m_playerUserInfo:getDefDeckCombatPower(true)
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
    self:addTabAuto(UI_Arena['RANK'], vars, vars['rankingMenu'])
    self:addTabAuto(UI_Arena['HISTORY'], vars, vars['historyMenu'])
    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)

    self:setTab(UI_Arena['RANK'])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Arena:onChangeTab(tab, first)
    if (not first) then
        return
    end

    if (tab == UI_Arena['RANK']) then
        UI_ArenaTabRank(self)

    elseif (tab == UI_Arena['HISTORY']) then
        UI_ArenaTabHistory(self)
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_Arena:update(dt)
    local vars = self.vars

    -- UI내에서 시즌이 종료되는 경우 예외처리
    if self.m_bClosedTag then
        return

    elseif (not g_arenaData:isOpenArena()) then
        local function ok_cb()
            -- 로비로 이동
            UINavigator:goTo('lobby')
        end
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 시즌이 종료되었습니다.'), ok_cb)
        self.m_bClosedTag = true
        return
    end

    local str = g_arenaData:getArenaStatusText()
    vars['timeLabel']:setString(str)
end

--@CHECK
UI:checkCompileError(UI_Arena)
