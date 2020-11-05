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
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanGuest:init()
    local res = 'clan_01.ui'
	-- 2019년 12월 2일 이후부터는 true 
	-- 따라서 항상 clan_01_new.ui 사용한다고 볼 수 있음
    if (g_arenaData:isStartClanWarContents()) then
        res = 'clan_01_new.ui'
    end
    local vars = self:load_keepZOrder(res)
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

    local function finich_cb()
        -- @ TUTORIAL : clan guest
        TutorialManager.getInstance():startTutorial(TUTORIAL.CLAN_GUEST, self)
    end

    self:sceneFadeInAction(nil, finich_cb)
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

    -- npc 일러스트
    local res = 'res/character/npc/narvi/narvi.json'
	vars['npcNode']:removeAllChildren(true)
    local animator = MakeAnimator(res)
    if (animator.m_node) then
        animator:changeAni('idle', true)
        vars['npcNode']:addChild(animator.m_node)
    end

    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanGuest:initButton()
    local vars = self.vars
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

    -- 클랜 랭킹
    local rank_tab = UI_ClanGuestTabRank(self, 'rank')
    self:addTabWithTabUIAndLabel('rank', vars['rankTabBtn'], vars['rankTabLabel'], rank_tab)

    self:setTab('join')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanGuest:onChangeTab(tab, first)
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanGuest:update(dt)
    local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_ClanGuest)
