local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ScenarioReplay
-------------------------------------
UI_ScenarioReplay = class(PARENT,{
        m_map_table_view = '',
    })

local PLIST_PATH = 'res/ui/a2d/sc_thumb/sc_thumb.plist'

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioReplay:init()
    cc.SpriteFrameCache:getInstance():addSpriteFrames(PLIST_PATH)
    local vars = self:load('scenario_replay.ui')
    UIManager:open(self, UIManager.SCENE)
    self.m_map_table_view = {}

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ScenarioReplay')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ScenarioReplay:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ScenarioReplay'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('시나리오 다시보기') 
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ScenarioReplay:initUI()
    self:initTab()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ScenarioReplay:initTab()
    local vars = self.vars
    -- 프롤로그
    self:addTabWithLabel('prologue', vars['prologueTabBtn'], vars['prologueTabLabel'], vars['prologueNode'])

    -- 1 ~ 12챕터 시나리오
    for idx = 1, 12 do
        local key = string.format('chapter_%d', idx)
        local tar_node = self:getTargetNode(idx)
        self:addTabWithLabel(key, vars['chapterTabBtn'..idx], vars['chapterTabLabel'..idx], tar_node)
    end

    self:setTab('prologue')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ScenarioReplay:onChangeTab(tab, first)
    local vars = self.vars
    local list_node 
    local chapter_no 

    -- 노드 하나에 재생성하면 퍼포먼스가 안좋음
    if (tab == 'prologue') then
        list_node = vars['prologueNode']
        chapter_no = 'prologue'
    else
        local idx = string.gsub(tab, 'chapter_', '')
        list_node = self:getTargetNode(idx)
        chapter_no = idx
    end

    -- 최초 진입 아닌경우 애니메이션만 재생
    if (not first) then
        local table_view = self.m_map_table_view[chapter_no]
        if (table_view) then
            local item_map = table_view.m_itemMap
            for _, v in pairs(item_map) do
                local ui = v['ui']
                if (ui) then
                    doAllChildren(ui.root, function(node) node:setCascadeOpacityEnabled(true) end)
					ui.root:setOpacity(0)
					local scale_to = cc.FadeIn:create(0.5)
					local action = cc.EaseInOut:create(scale_to, 2)
					ui.root:runAction(action)
                end
            end
        end

        return
    end

    -- 해당 챕터 시나리오 아이템 생성
    local l_scenario = self:getScenarioList(chapter_no)
    local create_func = function(ui, data)
        local scenario_name = data
        ui.vars['replayMenu']:setSwallowTouch(false)
        ui.vars['replayBtn']:registerScriptTapHandler(function() self:click_replayBtn(scenario_name) end)
    end

    local table_view = UIC_TableViewTD(list_node)
    local width = list_node:getContentSize()['width']
    table_view.m_cellSize = cc.size(width/2, 105)
    table_view.m_nItemPerCell = 2
    table_view:setCellUIClass(UI_ScenarioReplayListItem, create_func)
    table_view:setCellCreateInterval(0)
	table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view:setCellCreatePerTick(3)
    table_view:setItemList(l_scenario)

    self.m_map_table_view[chapter_no] = table_view
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ScenarioReplay:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ScenarioReplay:refresh()
end

-------------------------------------
-- function getTargetNode
-------------------------------------
function UI_ScenarioReplay:getTargetNode(chapter_no)
    local tar_node = self.vars['listNode'..chapter_no]
    return tar_node
end

-------------------------------------
-- function getScenarioList
-------------------------------------
function UI_ScenarioReplay:getScenarioList(chapter_no)
    local l_scenario = {}
    if (chapter_no == 'prologue') then
        table.insert(l_scenario, 'scenario_prologue')
        table.insert(l_scenario, 'scenario_prologue_nightmare_1')
        table.insert(l_scenario, 'scenario_prologue_intro_battle')
        table.insert(l_scenario, 'scenario_prologue_nightmare_2')
    else
        local l_stage = {1, 4, 6, 7} -- 1, 4, 6, 7 스테이지만 시나리오 존재함
        for i, stage in ipairs(l_stage) do

            -- 시작 시나리오
            local s_scenario = string.format('scen_%02d_%02d_s', tonumber(chapter_no), stage)
            if (TABLE:isFileExist('scenario/'..s_scenario, '.csv')) then
                table.insert(l_scenario, s_scenario)
            end

            -- 종료 시나리오
            local e_scenario = string.format('scen_%02d_%02d_e', tonumber(chapter_no), stage)
            if (TABLE:isFileExist('scenario/'..e_scenario, '.csv')) then
                table.insert(l_scenario, e_scenario)
            end
        end
    end

    return l_scenario
end

-------------------------------------
-- function click_replayBtn
-------------------------------------
function UI_ScenarioReplay:click_replayBtn(scenario_name)
    -- 악몽1, 인트로 전투, 악몽2 예외처리
    if (scenario_name == 'scenario_prologue_nightmare_1') then
        scenario_name = 'scenario_intro_start_goni' -- 변수와 파일의 시나리오 이름이 다름
    elseif (scenario_name == 'scenario_prologue_intro_battle') then
        self:runScenarioBattle()
        return
    elseif (scenario_name == 'scenario_prologue_nightmare_2') then
        scenario_name = 'scenario_intro_finish' -- 변수와 파일의 시나리오 이름이 다름
    end

    local ui = UI_ScenarioPlayer(scenario_name)
    ui:next()
    -- 보고 온 후 타이틀 bgm 다시 재생
    ui:setCloseCB(function()
        SoundMgr:playBGM('bgm_lobby')
    end)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ScenarioReplay:click_exitBtn()
    cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(PLIST_PATH)
    self:close()
end

-------------------------------------
-- function runScenarioBattle
-------------------------------------
function UI_ScenarioReplay:runScenarioBattle()
    local scene = SceneGameIntro()
    scene:setReplayMode(true)
    scene:runScene()
    scene:setNextCB(function()
        local function close_cb()
            UINavigatorDefinition:goTo('lobby')
        end 
        local scene = SceneCommon(UI_ScenarioReplay, close_cb)
        scene:runScene() 
    end)
end

--@CHECK
UI:checkCompileError(UI_ScenarioReplay)
