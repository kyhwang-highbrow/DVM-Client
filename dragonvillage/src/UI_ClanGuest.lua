local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanGuest
-------------------------------------
UI_ClanGuest = class(PARENT, {
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanGuest:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanGuest'
    self.m_titleStr = Str('클랜')
	--self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clan_coin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanGuest:init()
    local vars = self:load('clan_01.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_uiName = 'UI_ClanGuest'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanGuest')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 보상 안내 팝업
    local function finich_cb()
    end

    self:sceneFadeInAction(nil, finich_cb)

    -- @ TUTORIAL
    --TutorialManager.getInstance():startTutorial(TUTORIAL.CLAN_GUEST, self)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanGuest:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanGuest:initUI()
    local vars = self.vars

    --[[
    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    --]]

    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanGuest:initButton()
    local vars = self.vars
    --vars['winBuffDetailBtn']:registerScriptTapHandler(function() self:click_winBuffDetailBtn() end)
    --vars['rankDetailBtn']:registerScriptTapHandler(function() self:click_rankDetailBtn() end)
    --vars['rewardInfoBtn']:registerScriptTapHandler(function() self:click_rewardInfoBtn() end)
    --vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    --vars['defDeckBtn']:registerScriptTapHandler(function() self:click_defDeckBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanGuest:refresh()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanGuest:initTab()
    local vars = self.vars

    -- 클랜 가입
    local join_tab = UI_ClanGuestTabJoin(self, 'join')
    self:addTabWithTabUIAndLabel('join', vars['joinTabBtn'], vars['joinTabLabel'], join_tab)

    -- 가입 대기
    local request_tab = UI_ClanGuestTabRequest(self, 'request')
    self:addTabWithTabUIAndLabel('request', vars['requestTabBtn'], vars['requestTabLabel'], request_tab)

    -- 클랜 창설
    local found_tab = UI_ClanGuestTabFound(self, 'found')
    self:addTabWithTabUIAndLabel('found', vars['foundTabBtn'], vars['foundTabLabel'], found_tab)

    self:setTab('join')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanGuest:onChangeTab(tab, first)
    --[[
    PARENT.onChangeTab(self, tab, first)

    local vars = self.vars
    if (tab == UI_ClanGuest.ATK) then
        self:refresh_combatPower('atk')

    elseif (tab == UI_ClanGuest.DEF) then
        self:refresh_combatPower('def')
        self:request_matchHistory()

    elseif (tab == UI_ClanGuest.RANKING) then
        self:request_Rank()
    end

    if (not first) then
        return
    end

    if (tab == UI_ClanGuest.ATK) then
        self:init_atkTab()
    end
    --]]
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanGuest:update(dt)
    local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_ClanGuest)
