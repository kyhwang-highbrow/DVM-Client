local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())
local L_TAB = {'adventure', 'dungeon', 'competition', 'clan'}

local L_TAB_CONTENTS = {}
L_TAB_CONTENTS['adventure'] = {'adventure', 'exploration', 'story_dungeon'}
L_TAB_CONTENTS['dungeon'] = {'nest_tree', 'nest_evo_stone', 'ancient_ruin', 'nest_nightmare', 'dmgate', 'secret_relation'}
L_TAB_CONTENTS['competition'] = {'ancient', 'attr_tower', 'arena_new', 'league_raid', 'grand_arena', 'challenge_mode', 'world_raid'}
L_TAB_CONTENTS['clan'] = {'clan_raid', 'rune_guardian', 'clan_war'}



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
    self.m_subCurrency = 'subjugation_ticket'
end

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenu:init()
    local vars = self:load('battle_menu.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BattleMenu')

    local target_server = CppFunctions:getTargetServer()

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

	-- 탭 종류마다(모험, 던전, 경쟁, 클랜) 열려있는 컨텐츠 갯수 확인
	-- 컨텐츠가 없다면 해당 탭은 보여주지 않음
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
-- @brief 탭 마다 열려있는 컨텐츠 갯수 카운트
-------------------------------------
function UI_BattleMenu:getContentCntByType(tab_name)
    if (not L_TAB_CONTENTS[tab_name]) then
        return 0
    end

    local l_contens = L_TAB_CONTENTS[tab_name]
    local cnt = 0
    for i, content_name in ipairs(l_contens) do
        -- 개편 후 콜로세움 데이터 추가가 당장 어려운 관계로 arena_new는 colosseum과 동일하게 체크
        if (content_name == 'arena_new') then content_name = 'colosseum' end
        
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
	local menu_name = self.m_menuName

    -- noti update
    do
        if (self.m_lAdventureBtnUI) then
            for i, v in pairs(self.m_lAdventureBtnUI) do
                if (v['ui']:refresh()) then
                    t_noti[menu_name .. '_adventure'] = true
                end 
            end
        end
        if (self.m_lDungeonBtnUI) then
            for i, v in pairs(self.m_lDungeonBtnUI) do
                if (v['ui']:refresh()) then
                    t_noti[menu_name .. '_dungeon'] = true
                end
            end
        end
    end

    -- tab noti (없을 경우에만 한번 더 검사)
    if (not t_noti[menu_name .. '_adventure']) then
        if (
            g_highlightData:isHighlightExploration()
            or g_hotTimeData:isHighlightHotTime()
            or g_fevertimeData:isActiveFevertime_adventure()
            or g_hotTimeData:isActiveEvent('event_advent')
        ) then
            t_noti[menu_name .. '_adventure'] = true
        end
    end

    if (not t_noti[menu_name .. '_dungeon']) then
        if (
            g_secretDungeonData:isSecretDungeonExist()
            or g_fevertimeData:isActiveFevertime_dungeonGdItemUp()
            or g_fevertimeData:isActiveFevertime_dungeonGtItemUp()
            or g_fevertimeData:isActiveFevertime_dungeonRuneLegendUp()
            or g_fevertimeData:isActiveFevertime_dungeonRuneUp()
            or g_fevertimeData:isActiveFevertime_dungeonArStDc()
            or g_fevertimeData:isActiveFevertime_dungeonNmStDc()
            or g_fevertimeData:isActiveFevertime_dungeonGtStDc()
            or g_fevertimeData:isActiveFevertime_dungeonGdStDc()            
        ) then
            t_noti[menu_name .. '_dungeon'] = true
        end
    end

    -- noti 표시할 때 주의사항 : 아직 열리지 않은 탭의 경우 노티를 표시하면 안 된다.
    if (menu_name ~= 'first') then
        if (not t_noti[menu_name .. '_competition']) then
            if (g_fevertimeData:isActiveFevertime_pvpHonorUp() or 
                g_fevertimeData:isActiveFevertime_raidUp()) then
                t_noti[menu_name .. '_competition'] = true
            end
        end
    end

    if (menu_name == 'short') then
        if (not t_noti[menu_name .. '_clan']) then
            if (
                g_fevertimeData:isActiveFevertime_dungeonRgStDc()
                or g_fevertimeData:isActiveFevertime_dungeonRuneLegendUp()
                or g_fevertimeData:isActiveFevertime_dungeonRuneUp()
            ) then
                t_noti[menu_name .. '_clan'] = true
            end
        end
    end

    UIHelper:autoNoti(t_noti, self.m_tNotiSprite, 'Btn', self.vars)
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

	-- menu_name : 
	-- 'first' 탭이 2개일 경우
	-- 'long' 탭이 3개일 경우
	-- 'short' 탭이 4개일 경우

    -- 탭 초기화
    self:addTab('adventure', vars[menu_name .. '_adventureBtn'], vars['adventureMenu'])
    self:addTab('dungeon', vars[menu_name .. '_dungeonBtn'], vars['dungeonMenu'])
    
	-- long일 경우 경쟁 탭 하나만 추가 : 탭 3개
    if (menu_name == 'long') then
        self:addTab('competition', vars[menu_name .. '_competitionBtn'], vars['competitionMenu'])
    
	-- short일 경우 경쟁, 클랜 탭 추가 : 탭 4개
	elseif (menu_name == 'short') then
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
        
        elseif (tab == 'clan') then
            self:initClanTab() 
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

    elseif (tab == 'clan') then
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
    local interval_x = 415
    local pos_y = -80
    local l_content_str = {}

    -- 모험
    table.insert(l_content_str, 'adventure')

    -- 탐험
    if (not g_contentLockData:isContentLock('exploration')) then
        table.insert(l_content_str, 'exploration')
    end

    -- 스토리 던전
    if (not g_contentLockData:isContentLock('story_dungeon')) then
        table.insert(l_content_str, 'story_dungeon')
    end

    local l_btn_ui = {}
    do -- 콘텐츠 리스트 UI 생성
        local l_pos = getSortPosList(interval_x, table.count(l_content_str))
        for i,v in ipairs(l_content_str) do
            local ui = UI_BattleMenuItem_Adventure(v, #l_content_str)
            local pos_x = l_pos[i]
            ui.root:setPosition(pos_x, pos_y)
            vars['adventureMenu']:addChild(ui.root)
            table.insert(l_btn_ui, {['ui']=ui, ['x']=pos_x, ['y']=pos_y})

            -- tutorial 실행중이라면
            if TutorialManager.getInstance():isDoing() then
				if (v == 'adventure') then
					vars['tutorialAdventureBtn'] = ui.vars['enterBtn']
				end
			end   
        end
    end

    self.m_lAdventureBtnUI = l_btn_ui
end

-------------------------------------
-- function initDungeonTab
-- @brief 던전 초기화
-------------------------------------
function UI_BattleMenu:initDungeonTab()
    local vars = self.vars
    -- 메뉴 아이템 x축 간격
    local interval_x = 415

    local l_btn_ui = {}
    local l_item = {}

    for _, dungeon_name in ipairs(L_TAB_CONTENTS['dungeon']) do
        if (not g_contentLockData:isContentLock(dungeon_name)) then
            table.insert(l_item, dungeon_name)
        end
    end 
	
	local list_count = table.count(l_item)
    if (list_count == 4) then
        interval_x = 285
    elseif (list_count >= 5) then
        interval_x = 208
    end


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
        local ui = UI_BattleMenuItem_Dungeon(target, #l_item)
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
-- function initTestDungeonTab
-- @brief 던전 초기화
-------------------------------------
function UI_BattleMenu:initTestDungeonTab()
    local tableView = UIC_TableView()

    table_veiw.m_defaultCellSize = cc.size()

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

    local content_list = {}
    -- 개편아레나 아이템 추가여부 확인
    local arenaNewAttached = false

    for _, dungeon_name in ipairs(L_TAB_CONTENTS['competition']) do
        -- 컨텐츠 해금이 된 경우
        if (not g_contentLockData:isContentLock(dungeon_name)) then
            -- 그랜드 콜로세움이 비활성화(핫타임)인 경우
            if (dungeon_name == 'grand_arena') then
                if (g_grandArena:getGrandArenaState() ~= ServerData_GrandArena.STATE['INACTIVE']) then
                    table.insert(content_list, dungeon_name)                        
                end
            -- 그림자 신전이 비활성화(핫타임)인 경우
            elseif (dungeon_name == 'challenge_mode') then
                if (g_challengeMode:getChallengeModeState() ~= ServerData_ChallengeMode.STATE['INACTIVE']) then
                    table.insert(content_list, dungeon_name)
                end
            else
                table.insert(content_list, dungeon_name)
            end
        end
    end 

    -- 리스트 갯수에 따라 interval_x 간격 조절
    local content_num = table.count(content_list)
    if (content_num == 4) then
        interval_x = 285
    elseif (content_num >= 5) then
        interval_x = 208
    end

    local l_btn_ui = {}
    do -- 콘텐츠 리스트 UI 생성
        local l_pos = getSortPosList(interval_x, table.count(content_list))
        for i,v in ipairs(content_list) do
            local ui = UI_BattleMenuItem_Competition(v, content_num)
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
    for _, dungeon_name in ipairs(L_TAB_CONTENTS['clan']) do
        if (not g_contentLockData:isContentLock(dungeon_name)) then
			table.insert(l_content_str, dungeon_name)
		end
    end

    local l_btn_ui = {}
    do -- 콘텐츠 리스트 UI 생성
        local l_pos = getSortPosList(interval_x, table.count(l_content_str))
        for i,v in ipairs(l_content_str) do
            local ui = UI_BattleMenuItem_Clan(v, 2)
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
    if (tab == 'adventure') then
        self:runBtnAppearAction(self.m_lAdventureBtnUI, true) -- param : l_btn_ui, immediately

    elseif (tab == 'dungeon') then
        self:runBtnAppearAction(self.m_lDungeonBtnUI, true) -- param : l_btn_ui, immediately

    elseif (tab == 'competition') then
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
