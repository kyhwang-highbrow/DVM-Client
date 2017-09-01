local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_BattleMenu
-------------------------------------
UI_BattleMenu = class(PARENT, {
        m_lAdventureBtnUI = '',
        m_lDungeonBtnUI = '',
        m_lCompetitionBtnUI = '',

        m_tNotiSprite = '',
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
    self.m_uiBgm = 'bgm_lobby'
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

    self.m_tNotiSprite = {}

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()

    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
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
-- function update
-------------------------------------
function UI_BattleMenu:update(dt)
    local t_noti = {}

    -- noti update
    do
        if (self.m_lAdventureBtnUI) then
            for i, v in pairs(self.m_lAdventureBtnUI) do
                if (v['ui']:refresh()) then
                    t_noti['adventure'] = true
                end 
            end
        end
        if (self.m_lDungeonBtnUI) then
            for i, v in pairs(self.m_lDungeonBtnUI) do
                if (v['ui']:refresh()) then
                    t_noti['dungeon'] = true
                end
            end
        end
    end

    -- tab noti (없을 경우에만 한번 더 검사)
    if (not t_noti['adventure']) then
        if (g_highlightData:isHighlightExploration()) then
            t_noti['adventure'] = true
        end
    end
    if (not t_noti['dungeon']) then
        if (g_secretDungeonData:isSecretDungeonExist()) then
            t_noti['dungeon'] = true
        end
    end
    UIHelper:autoNoti(t_noti, self.m_tNotiSprite, 'Btn', self.vars)
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

    if (tab == 'adventure') then
        -- tutorial 실행중이라면
        if (not TutorialManager.getInstance():isDoing()) then
            self:runBtnAppearAction(self.m_lAdventureBtnUI)
        end

    elseif (tab == 'dungeon') then
        self:runBtnAppearAction(self.m_lDungeonBtnUI)

    elseif (tab == 'competition') then
        self:runBtnAppearAction(self.m_lCompetitionBtnUI)
    end
end


-------------------------------------
-- function initAdventureTab
-- @brief 모험 초기화
-------------------------------------
function UI_BattleMenu:initAdventureTab()
    local vars = self.vars

    local l_btn_ui = {}

    -- 모험
    local ui = UI_BattleMenuItem('adventure')
    ui.root:setPosition(-184, -94)
    vars['adventureMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=-184, ['y']=-94})

    -- tutorial 실행중이라면
    if TutorialManager.getInstance():isDoing() then
        vars['tutorialAdventureBtn'] = ui.vars['enterBtn']
    end

    -- 탐험
    local ui = UI_BattleMenuItem('exploation')
    ui.root:setPosition(184, -94)
    vars['adventureMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=184, ['y']=-94})

    self.m_lAdventureBtnUI = l_btn_ui
end

-------------------------------------
-- function initDungeonTab
-- @brief 던전 초기화
-------------------------------------
function UI_BattleMenu:initDungeonTab()
    local vars = self.vars

    local l_btn_ui = {}

    -- 거목 던전
    local ui = UI_BattleMenuItem('nest_tree')
    ui.root:setPosition(-472, -94)
    vars['dungeonMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=-472, ['y']=-94})

    -- 진화재료 던전
    local ui = UI_BattleMenuItem('nest_evo_stone')
    ui.root:setPosition(-158, -94)
    vars['dungeonMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=-158, ['y']=-94})

    -- 악몽 던전
    local ui = UI_BattleMenuItem('nest_nightmare')
    ui.root:setPosition(158, -94)
    vars['dungeonMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=158, ['y']=-94})

    -- 인연 던전
    local ui = UI_BattleMenuItem('secret_relation')
    ui.root:setPosition(472, -94)
    vars['dungeonMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=472, ['y']=-94})

    self.m_lDungeonBtnUI = l_btn_ui
end

-------------------------------------
-- function initCompetitionTab
-- @brief 경쟁 초기화
-------------------------------------
function UI_BattleMenu:initCompetitionTab()
    local vars = self.vars

    local l_btn_ui = {}

    -- 고대의 탑
    local ui = UI_BattleMenuItem('ancient')
    ui.root:setPosition(-184, -94)
    vars['competitionMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=-184, ['y']=-94})

    -- 콜로세움
    local ui = UI_BattleMenuItem('colosseum')
    ui.root:setPosition(184, -94)
    vars['competitionMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=184, ['y']=-94})

    self.m_lCompetitionBtnUI = l_btn_ui
end

-------------------------------------
-- function runBtnAppearAction
-- @brief 모험 초기화
-------------------------------------
function UI_BattleMenu:runBtnAppearAction(l_btn_ui, immediately)
    for i,t_data in pairs(l_btn_ui) do
        local x = t_data['x']
        local y = t_data['y']

        local ui = t_data['ui']
        ui.root:stopAllActions()

        if immediately then
            ui.root:setPosition(x, y)
        else
            ui.root:setPositionX(x + 1280)
            local move_to = cc.MoveTo:create(0.5, cc.p(x, y))
            local ease_in_out = cc.EaseInOut:create(move_to, 2)
            local action = cc.Sequence:create(cc.DelayTime:create((i-1) * 0.05), ease_in_out)
            ui.root:runAction(action)
        end       
    end
end

-------------------------------------
-- function resetButtonsPosition
-- @brief
-------------------------------------
function UI_BattleMenu:resetButtonsPosition()
    local tab = self.m_currTab
    if (tab == 'adventure') then
        self:runBtnAppearAction(self.m_lAdventureBtnUI, true) -- param : l_btn_ui, immediately

    elseif (tab == 'dungeon') then
        self:runBtnAppearAction(self.m_lDungeonBtnUI, true) -- param : l_btn_ui, immediately

    elseif (tab == 'competition') then
        self:runBtnAppearAction(self.m_lCompetitionBtnUI, true) -- param : l_btn_ui, immediately
    end
end

--@CHECK
UI:checkCompileError(UI_BattleMenu)
