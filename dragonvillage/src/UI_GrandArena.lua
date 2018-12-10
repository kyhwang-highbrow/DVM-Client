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
    self:initTab()
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
-- function appearDone
-- @brief UI전환 종료 시점
-------------------------------------
function UI_GrandArena:appearDone()
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
        vars['tierLabel1']:setString(tier_name)

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