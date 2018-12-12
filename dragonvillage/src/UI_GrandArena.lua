local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_GrandArena
-------------------------------------
UI_GrandArena = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GrandArena:init()
    local vars = self:load_keepZOrder('grand_arena_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_GrandArena')

    self:initUI()
    self:initButton()
    self:refresh()
    --self:refresh_playerRank()

    self:sceneFadeInAction(function() self:appearDone() end)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_GrandArena:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_GrandArena'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('그랜드 콜로세움')
    self.m_staminaType = 'grand_arena'
    self.m_subCurrency = 'valor'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GrandArena:initUI()
    local vars = self.vars

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    --self:initTab()

    -- 프리시즌 (연습전)
    local grand_arena_state = g_grandArena:getGrandArenaState()
    if (grand_arena_state == ServerData_GrandArena.STATE['PRESEASON']) then
        vars['reserveNode']:setVisible(true)
        vars['reservePeriodLabel']:setVisible(true)
        vars['officialPeriodLabel']:setVisible(false)

        vars['rankingBtn']:setVisible(false)
    else
        vars['reserveNode']:setVisible(false)
        vars['reservePeriodLabel']:setVisible(false)
        vars['officialPeriodLabel']:setVisible(true)

        vars['rankingBtn']:setVisible(true)

        self:initTab()
    end
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_GrandArena:initTab()
    local vars = self.vars
    local l_tab_name = {}
    table.insert(l_tab_name, 'top_rank')
    table.insert(l_tab_name, 'defense')
    table.insert(l_tab_name, 'offense')

    for _,tab_name in pairs(l_tab_name) do
        self:addTabAuto(tab_name, vars, vars[tab_name .. 'TabMenu'])
    end

    self:setTab('top_rank')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_GrandArena:onChangeTab(tab, first)

    if (tab == 'top_rank') then
        if (first == true) then
            local function finish_cb()
                self:makeRankTableView()
            end
            local rank_type = 'top'
            local offset = 1
            g_grandArena:request_grandArenaRanking(rank_type, offset, finish_cb)
        end
    elseif (tab == 'defense') then
        if (first == true) then
            local function finish_cb()
                self:makeHistoryTableView('def')
            end
            g_grandArena:request_grandArenaHistory('def', finish_cb, nil) -- param : type, finish_cb, fail_cb
        end
    elseif (tab == 'offense') then
        if (first == true) then
            local function finish_cb()
                self:makeHistoryTableView('atk')
            end 
            g_grandArena:request_grandArenaHistory('atk', finish_cb, nil) -- param : type, finish_cb, fail_cb
        end
    end
end

-------------------------------------
-- function makeRankTableView
-------------------------------------
function UI_GrandArena:makeRankTableView()
    local vars = self.vars
    local node = vars['rankingListNode']
    node:removeAllChildren()

    local l_item_list = g_grandArena.m_lGlobalRank

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(550, 90 + 5)
    table_view:setCellUIClass(UI_GrandArenaSceneRankingListItem, create_func)
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
            local a_rank = conditionalOperator((0 < a_data.m_rank), a_data.m_rank, 9999999)
            local b_rank = conditionalOperator((0 < b_data.m_rank), b_data.m_rank, 9999999)
            return a_rank < b_rank
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    table_view:makeDefaultEmptyDescLabel(Str('랭킹 정보가 없습니다.'))   
end

-------------------------------------
-- function makeHistoryTableView
-------------------------------------
function UI_GrandArena:makeHistoryTableView(type) -- type = atk, def
    local vars = self.vars
    local node
 
    local l_item_list
    -- 코드 예쁘게 고칠 예정
    if (type == 'atk') then
        l_item_list = g_grandArena.m_matchAtkHistory
        node = vars['offenseTabMenu']
    elseif (type == 'def') then
        l_item_list = g_grandArena.m_matchDefHistory
        node = vars['defenseTabMenu']
    end
    node:removeAllChildren()

    if (not l_item_list) then
        return
    end

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(790, 150)
    table_view:setCellUIClass(UI_GrandArenaHistoryListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
end

-------------------------------------
-- function appearDone
-- @brief UI전환 종료 시점
-------------------------------------
function UI_GrandArena:appearDone()

    -- 시즌 보상이 있을 경우 팝업
    if g_grandArena.m_tSeasonRewardInfo then
        local t_data = g_grandArena.m_tSeasonRewardInfo
        g_grandArena.m_tSeasonRewardInfo = nil
        UI_GrandArenaRankingRewardPopup(t_data)
        return
    end
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_GrandArena:refresh()
    local vars = self.vars

    local struct_user_info = g_grandArena:getPlayerGrandArenaUserInfo()
    do
        -- 티어 아이콘
        vars['tierIconNode']:removeAllChildren()
        local icon = struct_user_info:makeTierIcon(nil, 'big')
        vars['tierIconNode']:addChild(icon)

        -- 티어 이름
        local tier_name = struct_user_info:getTierName()
        vars['tierLabel']:setString(tier_name)

        -- 순위, 점수, 승률
        local str = struct_user_info:getGrandArena_RankText(true) .. '\n'
            .. struct_user_info:getRPText()  .. '\n'
            .. struct_user_info:getWinRateText()  .. '\n'
        vars['rankingLabel']:setString(str)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GrandArena:initButton()
    local vars = self.vars
    vars['rankingBtn']:registerScriptTapHandler(function() self:click_rankingBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
end

-------------------------------------
-- function click_rankingBtn
-- @brief 랭킹 버튼
-------------------------------------
function UI_GrandArena:click_rankingBtn()
    UI_GrandArenaRankingPopup()
end

-------------------------------------
-- function click_infoBtn
-- @brief 도움말 버튼
-------------------------------------
function UI_GrandArena:click_infoBtn()
    UI_HelpGrandArena()
end

-------------------------------------
-- function click_startBtn
-- @brief 전투 준비 버튼
-------------------------------------
function UI_GrandArena:click_startBtn()

    local stage_id = GRAND_ARENA_STAGE_ID

    --local struct_deck_setting_ui_config = StructDeckSettingUIConfig()
    --UI_DeckSetting(struct_deck_setting_ui_config)
    UI_GrandArenaDeckSettings(stage_id)


    --local scene = SceneGameEventArena(nil, ARENA_STAGE_ID, 'stage_colosseum', true)
    --scene:runScene()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_GrandArena:click_exitBtn()
	self:close()
end

-------------------------------------
-- function update
-------------------------------------
function UI_GrandArena:update(dt)
    local vars = self.vars

    local str = g_grandArena:getGrandArenaStatusText()
    vars['timeLabel']:setString(str)
end

--@CHECK
UI:checkCompileError(UI_GrandArena)