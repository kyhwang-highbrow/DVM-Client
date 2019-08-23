local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())
local L_TAB = {'adventure', 'dungeon', 'competiton', 'clan'}

local L_TAB_CONTENTS = {}
L_TAB_CONTENTS['adventure'] = {'adventure', 'exploration'}
L_TAB_CONTENTS['dungeon'] = {'nest_tree', 'nest_evo_stone', 'ancient_ruin', 'nest_nightmare', 'secret_relation'}
L_TAB_CONTENTS['competition'] = {'ancient', 'attr_tower', 'colosseum', 'challenge_mode', 'grand_arena'}
L_TAB_CONTENTS['clan'] = {'clan_raid', 'rune_gurdian'}



-------------------------------------
-- class UI_BattleMenu
-------------------------------------
UI_BattleMenu = class(PARENT, {
        m_lAdventureBtnUI = '',
        m_lDungeonBtnUI = '',
        m_lCompetitionBtnUI = '',
        m_lClanBtnUI = '',

        m_tNotiSprite = '',
        m_menuName = 'string',
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
    local vars = self.vars

    local btn_list = {}
    for _, tab_name in ipairs(L_TAB) do
        local content_cnt = self:getContentCntByType(tab_name)
        if (content_cnt > 0) then
            table.insert(btn_list, tab_name .. "Btn")
        end
    end

    vars['firstMenu']:setVisible(false)
    vars['longMenu']:setVisible(false)
    vars['shortMenu']:setVisible(false)

    -- 탭 갯수에 따라 사용하는 메뉴가 다름
    local menu_name = 'long'
    if (#btn_list == 2) then
        menu_name = 'first'
    elseif (#btn_list == 3) then
        menu_name = 'long'
    elseif (#btn_list == 4) then
        menu_name = 'short'
    end

    for i,v in pairs(btn_list) do
        vars[v] = vars[menu_name .. v]
    end
        
    vars[menu_name .. 'Menu']:setVisible(true)

    self.m_menuName = menu_name
    -- 탭 초기화
    self:initTab(menu_name)
end

-------------------------------------
-- function getContentCntByType
-------------------------------------
function UI_BattleMenu:getContentCntByType(content_name)
    if (not L_TAB_CONTENTS[content_name]) then
        return 0
    end

    local l_contens = L_TAB_CONTENTS[content_name]
    local cnt = 0
    for i, v in ipairs(l_contens) do
        if (not g_contentLockData:isContentLock(content_name)) then
            cnt = cnt + 1
        end
    end
    return cnt
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
        if (g_highlightData:isHighlightExploration() or g_hotTimeData:isHighlightHotTime() or g_hotTimeData:isActiveEvent('event_advent')) then
            t_noti['adventure'] = true
        end
    end
    if (not t_noti['dungeon']) then
        if (g_secretDungeonData:isSecretDungeonExist()) then
            t_noti['dungeon'] = true
        end
    end

    -- 노티관련 처리해야함***********************************
    -- UIHelper:autoNoti(t_noti, self.m_tNotiSprite, 'Btn', self.vars)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_BattleMenu:initTab(menu_name)
    local vars = self.vars

    -- 탭 별 배경 투명하게 처리
    vars['adventureBg']:setOpacity(0)
    vars['dungeonBg']:setOpacity(0)
    vars['competitionBg']:setOpacity(0)
    vars['clanBg']:setOpacity(0)

    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['adventureBg']:setScale(scr_size.width / 1280)
    vars['dungeonBg']:setScale(scr_size.width / 1280)
    vars['competitionBg']:setScale(scr_size.width / 1280)
    vars['clanBg']:setScale(scr_size.width / 1280)

    -- 탭 초기화
    self:addTab('adventure', vars[menu_name .. '_adventureBtn'], vars['adventureMenu'])
    self:addTab('dungeon', vars[menu_name .. '_dungeonBtn'], vars['dungeonMenu'])
    
    if (menu_name == 'long') then
        self:addTab('competition', vars[menu_name .. '_competitionBtn'], vars['competitionMenu'])
    end
    
    if (menu_name == 'short') then
        self:addTab('competition', vars[menu_name .. '_competitionBtn'], vars['competitionMenu'])
        self:addTab('clan', vars[menu_name .. '_clanBtn'], vars['clanMenu'])
    end

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
        if (string.match(tab, 'adventure')) then
            self:initAdventureTab() 

        elseif (string.match(tab, 'dungeon')) then
            self:initDungeonTab() 

        elseif (string.match(tab, 'competition')) then
            self:initCompetitionTab() 
        
        elseif (string.match(tab, 'clan')) then
            self:initClanTab() 
        end
    end

    if (string.match(tab, 'adventure')) then
        -- tutorial 실행중이라면
        if (not TutorialManager.getInstance():isDoing()) then
            self:runBtnAppearAction(self.m_lAdventureBtnUI)
        end

    elseif (string.match(tab, 'dungeon')) then
        self:runBtnAppearAction(self.m_lDungeonBtnUI)

    elseif (string.match(tab, 'competition')) then
        self:runBtnAppearAction(self.m_lCompetitionBtnUI)

    elseif (string.match(tab, 'clan')) then
        self:runBtnAppearAction(self.m_lClanBtnUI)
    end
end


-------------------------------------
-- function initAdventureTab
-- @brief 모험 초기화
-------------------------------------
function UI_BattleMenu:initAdventureTab()
    local vars = self.vars

    -- 메뉴 아이템 x축 간격
    local interval_x = 208
    local l_btn_ui = {}
    local pos_y = 80
    -- 모험
    local ui = UI_BattleMenuItem_Adventure('adventure')
    ui.root:setPosition(-interval_x, -94)
    vars['adventureMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=-interval_x, ['y']=-pos_y})

    -- tutorial 실행중이라면
    if TutorialManager.getInstance():isDoing() then
        vars['tutorialAdventureBtn'] = ui.vars['enterBtn']
    end

    -- 탐험
    local ui = UI_BattleMenuItem_Adventure('exploation')
    ui.root:setPosition(interval_x, -pos_y)
    vars['adventureMenu']:addChild(ui.root)
    table.insert(l_btn_ui, {['ui']=ui, ['x']=interval_x, ['y']=-pos_y})

    self.m_lAdventureBtnUI = l_btn_ui
end

-------------------------------------
-- function initDungeonTab
-- @brief 던전 초기화
-------------------------------------
function UI_BattleMenu:initDungeonTab()
    local vars = self.vars
    -- 메뉴 아이템 x축 간격
    local interval_x = 208

    local l_btn_ui = {}
    local l_item = {}
    table.insert(l_item, 'nest_tree') -- 거목 던전
    table.insert(l_item, 'nest_evo_stone') -- 진화재료 던전

    -- 고대 유적 던전은 열린 경우에만 노출 (악몽던전 앞에)
    if (g_ancientRuinData:isOpenAncientRuin()) then
        table.insert(l_item, 'ancient_ruin') -- 고대 유적 던전
    end

    table.insert(l_item, 'nest_nightmare') -- 악몽 던전
    table.insert(l_item, 'secret_relation') -- 인연 던전

    -- 스크롤 뷰로 변경됨
    -- 테이블 뷰로 생성할 경우 테이블 뷰 액션과 꼬임.
    local scroll_node = vars['dungeonNode']
    local size = scroll_node:getContentSize()
    local target_size = cc.size(interval_x * #l_item, size.height)
    local scroll_view = cc.ScrollView:create()
    scroll_view:setNormalSize(size)
    scroll_view:setContentSize(target_size)
    scroll_view:setDockPoint(ZERO_POINT)
    scroll_view:setAnchorPoint(ZERO_POINT)
    scroll_view:setPosition(ZERO_POINT)
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    scroll_node:addChild(scroll_view)

    -- 메뉴 아이템 시작점
    local pos_y = -6
    for idx, target in ipairs(l_item) do
        local ui = UI_BattleMenuItem_Dungeon(target)
        local pos_x = -size.width/2 + interval_x * (idx - 1)
        ui.root:setPosition(pos_x, pos_y)
        ui.root:setSwallowTouch(false)
        scroll_view:addChild(ui.root)
        table.insert(l_btn_ui, {['ui']=ui, ['x']=pos_x, ['y']=pos_y})
    end

    -- 중앙포지션 설정
    local container_node = scroll_view:getContainer()
    local center_pos = size.width - (interval_x * #l_item) + interval_x/2
    container_node:setPositionX(center_pos)    
    
    -- 스크롤 x (후에 추가되면 풀어주자)
    scroll_view:setTouchEnabled(false)

    self.m_lDungeonBtnUI = l_btn_ui
end

-------------------------------------
-- function initCompetitionTab
-- @brief 경쟁 초기화
-------------------------------------
function UI_BattleMenu:initCompetitionTab()
    local vars = self.vars
    -- 메뉴 아이템 x축 간격
    local interval_x = 415
    local pos_y = -80

    local l_content_str = {}
    do -- 콘텐츠 리스트 생성
        -- 고대의 탑
        table.insert(l_content_str, 'ancient')

        -- 시험의 탑
        if g_attrTowerData:isContentOpen() then
            table.insert(l_content_str, 'attr_tower') 
        end

        -- 콜로세움
        table.insert(l_content_str, 'colosseum')

        -- 챌린지 모드 정규화
        table.insert(l_content_str, 'challenge_mode') 

        -- 그랜드 콜로세움 (이벤트 PvP 10대10)
        if (g_grandArena:isActive_grandArena()) then
            table.insert(l_content_str, 'grand_arena') 
        end
    end

    -- 리스트 갯수에 따라 interval_x 간격 조절
    local list_count = table.count(l_content_str)
    if (list_count == 4) then
        interval_x = 285
    elseif (list_count >= 5) then
        interval_x = 208
    end

    local l_btn_ui = {}
    do -- 콘텐츠 리스트 UI 생성
        local l_pos = getSortPosList(interval_x, table.count(l_content_str))
        for i,v in ipairs(l_content_str) do
            local ui = UI_BattleMenuItem_Competition(v, list_count)
            local pos_x = l_pos[i]
            ui.root:setPosition(pos_x, pos_y)
            vars['competitionMenu']:addChild(ui.root)
            table.insert(l_btn_ui, {['ui']=ui, ['x']=pos_x, ['y']=pos_y})
        end
    end

    self.m_lCompetitionBtnUI = l_btn_ui
end

-------------------------------------
-- function initClanTab
-- @brief 클랜 탭 초기화
-------------------------------------
function UI_BattleMenu:initClanTab()
    local vars = self.vars
    -- 메뉴 아이템 x축 간격
    local interval_x = 416
    local pos_y = -80

    local l_content_str = {}
    do -- 콘텐츠 리스트 생성
        table.insert(l_content_str, 'clan_raid') -- 클랜 던전
        table.insert(l_content_str, 'rune_guardian') -- 룬 수호자 (세트별 룬 파밍 던전)
    end

    -- 3개 초과이면 얇은 모드
    local is_thin = (3 < table.count(l_content_str))
    if is_thin then
        interval_x = 285
    end

    local l_btn_ui = {}
    do -- 콘텐츠 리스트 UI 생성
        local l_pos = getSortPosList(interval_x, table.count(l_content_str))
        for i,v in ipairs(l_content_str) do
            local ui = UI_BattleMenuItem_Clan(v, is_thin)
            local pos_x = l_pos[i]
            ui.root:setPosition(pos_x, pos_y)
            vars['clanMenu']:addChild(ui.root)
            table.insert(l_btn_ui, {['ui']=ui, ['x']=pos_x, ['y']=pos_y})
        end
    end

    self.m_lClanBtnUI = l_btn_ui
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
            ui.root:setPositionX(x + MAX_RESOLUTION_X) -- 화면 오른쪽에서 등장하는 액션 (최대 넓이 위치를 더해줌)
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
    if (string.match(tab, 'adventure')) then
        self:runBtnAppearAction(self.m_lAdventureBtnUI, true) -- param : l_btn_ui, immediately

    elseif (tstring.match(tab, 'dungeon')) then
        self:runBtnAppearAction(self.m_lDungeonBtnUI, true) -- param : l_btn_ui, immediately

    elseif (string.match(tab, 'competition')) then
        self:runBtnAppearAction(self.m_lCompetitionBtnUI, true) -- param : l_btn_ui, immediately
    end
end

-------------------------------------
-- function scrollViewDidScroll
-------------------------------------
function UI_BattleMenu:scrollViewDidScroll()
    
end

--@CHECK
UI:checkCompileError(UI_BattleMenu)
