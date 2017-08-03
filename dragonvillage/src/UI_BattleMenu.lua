local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_BattleMenu
-------------------------------------
UI_BattleMenu = class(PARENT, {
     })

local THIS = UI_BattleMenu

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_BattleMenu:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_BattleMenu'
    self.m_bVisible = true
    self.m_titleStr = Str('전투')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenu:init()
    local vars = self:load('battle_menu.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BattleMenu')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_BattleMenu:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenu:initUI()
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BattleMenu:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BattleMenu:refresh()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_BattleMenu:initTab()
    local vars = self.vars

    -- 탭 별 배경 투명하게 처리
    vars['adventureBg']:setOpacity(0)
    vars['dungeonBg']:setOpacity(0)
    vars['competitionBg']:setOpacity(0)

    -- 탭 초기화
    self:addTab('adventure', vars['adventureBtn'], vars['adventureMenu'])
    self:addTab('dungeon', vars['dungeonBtn'], vars['dungeonMenu'])
    self:addTab('competition', vars['competitionBtn'], vars['competitionMenu'])

    -- 최초 탭 설정
    self:setTab('adventure')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_BattleMenu:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    local duration = 0.5

    local vars = self.vars

    -- 이전 탭의 배경 fade out
    if self.m_prevTab and vars[self.m_prevTab .. 'Bg'] then
        local node = vars[self.m_prevTab .. 'Bg']
        node:stopAllActions()
        local action = cc.Sequence:create(cc.FadeOut:create(duration), cc.Hide:create())
        node:runAction(action)
    end

    -- 현태 탭의 배경 fade in
    if tab and vars[tab .. 'Bg'] then
        
        local node = vars[tab .. 'Bg']
        node:stopAllActions()
        node:setVisible(true)

        if (not self.m_prevTab) then
            node:setOpacity(255)
        else
            local action = cc.FadeIn:create(duration)
            node:runAction(action)
        end
    end

    -- 버튼들 초기화 (최초에만 실행)
    if first then
        if (tab == 'adventure') then
            self:initAdventureTab() 

        elseif (tab == 'dungeon') then
            self:initDungeonTab() 

        elseif (tab == 'competition') then
            self:initCompetitionTab() 
        end
    end
end

-------------------------------------
-- function initAdventureTab
-- @brief 모험 초기화
-------------------------------------
function UI_BattleMenu:initAdventureTab()
    local vars = self.vars

    -- 모험
    local ui = UI_BattleMenuItem()
    ui.root:setPosition(-184, -94)
    vars['adventureMenu']:addChild(ui.root)

    -- 탐험
    local ui = UI_BattleMenuItem()
    ui.root:setPosition(184, -94)
    vars['adventureMenu']:addChild(ui.root)
end

-------------------------------------
-- function initDungeonTab
-- @brief 던전 초기화
-------------------------------------
function UI_BattleMenu:initDungeonTab()
    local vars = self.vars

    -- 거대용 던전
    local ui = UI_BattleMenuItem()
    ui.root:setPosition(-472, -94)
    vars['dungeonMenu']:addChild(ui.root)

    -- 거목 던전
    local ui = UI_BattleMenuItem()
    ui.root:setPosition(-158, -94)
    vars['dungeonMenu']:addChild(ui.root)

    -- 악몽 던전
    local ui = UI_BattleMenuItem()
    ui.root:setPosition(158, -94)
    vars['dungeonMenu']:addChild(ui.root)

    -- 인연 던전
    local ui = UI_BattleMenuItem()
    ui.root:setPosition(472, -94)
    vars['dungeonMenu']:addChild(ui.root)
end

-------------------------------------
-- function initCompetitionTab
-- @brief 경쟁 초기화
-------------------------------------
function UI_BattleMenu:initCompetitionTab()
    local vars = self.vars

    -- 콜로세움
    local ui = UI_BattleMenuItem()
    ui.root:setPosition(-184, -94)
    vars['competitionMenu']:addChild(ui.root)

    -- 고대의 탑
    local ui = UI_BattleMenuItem()
    ui.root:setPosition(184, -94)
    vars['competitionMenu']:addChild(ui.root)
end


--@CHECK
UI:checkCompileError(UI_BattleMenu)
