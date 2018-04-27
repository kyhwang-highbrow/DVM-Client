local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ScenarioReplay
-------------------------------------
UI_ScenarioReplay = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioReplay:init()
    local vars = self:load('scenario_replay.ui')
    UIManager:open(self, UIManager.SCENE)

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
    self:addTabWithLabel('prologue', vars['prologueTabBtn'], vars['prologueTabLabel'])
    -- 1 ~ 12챕터 시나리오
    for idx = 1, 12 do
        local key = string.format('chapter_%02d', idx)
        self:addTabWithLabel(key, vars['chapterTabBtn'..idx], vars['chapterTabLabel'..idx])
    end

    self:setTab('prologue')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ScenarioReplay:onChangeTab(tab, first)
    local vars = self.vars
    local list_node = vars['listNode']
    list_node:removeAllChildren()

    -- 해당 챕터 시나리오 아이템 생성
    local l_scenario = self:getScenarioList(tab)

    local create_func = function(ui, data)
        local scenario_name = data
        ui.vars['replayMenu']:setSwallowTouch(false)
        ui.vars['replayBtn']:registerScriptTapHandler(function() self:click_replayBtn(scenario_name) end)
    end

    local table_view = UIC_TableViewTD(list_node)
    table_view.m_cellSize = cc.size(600, 105)
    table_view.m_nItemPerCell = 2
    table_view:setCellUIClass(UI_ScenarioReplayListItem, create_func)
    table_view:setItemList(l_scenario)
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
-- function getScenarioList
-- @param : chapter - prologue or chapter_1 ~ chapter_12
-------------------------------------
function UI_ScenarioReplay:getScenarioList(chapter)
    local l_scenario = {}
    if (chapter == 'prologue') then
        table.insert(l_scenario, 'scenario_prologue')

    else
        local chapter_no = string.gsub(chapter, 'chapter_', '')
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
    local ui = UI_ScenarioPlayer(scenario_name)
    ui:next()
    -- 보고 온 후 타이틀 bgm 다시 재생
    ui:setCloseCB(function()
        SoundMgr:playBGM('bgm_lobby')
    end)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ScenarioReplay:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ScenarioReplay)
