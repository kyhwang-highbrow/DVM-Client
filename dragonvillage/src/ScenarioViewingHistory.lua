-------------------------------------
-- class ScenarioViewingHistory
-------------------------------------
ScenarioViewingHistory = class({
        m_rootTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ScenarioViewingHistory:init()
    self.m_rootTable = nil
end

-------------------------------------
-- function getInstance
-------------------------------------
function ScenarioViewingHistory:getInstance()
    if g_scenarioViewingHistory then
        return g_scenarioViewingHistory
    end
    
    g_scenarioViewingHistory = ScenarioViewingHistory()
    g_scenarioViewingHistory:loadScenarioViewingHistoryFile()

    return g_scenarioViewingHistory
end

-------------------------------------
-- function getScenarioViewingHistorySaveFileName
-------------------------------------
function ScenarioViewingHistory:getScenarioViewingHistorySaveFileName()
    local file = 'scenario_viewing_history.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadScenarioViewingHistoryFile
-------------------------------------
function ScenarioViewingHistory:loadScenarioViewingHistoryFile()
    local f = io.open(self:getScenarioViewingHistorySaveFileName(), 'r')

    if f then
        local content = f:read('*all')
        f:close()

        if (#content > 0) then
            self.m_rootTable = json_decode(content)
            return
        end
    end

    do -- 초기화
        self.m_rootTable = self:makeDefaultScenarioViewingHistory()
        self:saveScenarioViewingHistoryFile()
    end
end

-------------------------------------
-- function makeDefaultScenarioViewingHistory
-------------------------------------
function ScenarioViewingHistory:makeDefaultScenarioViewingHistory()
    local root_table = {}
    return root_table
end

-------------------------------------
-- function saveScenarioViewingHistoryFile
-------------------------------------
function ScenarioViewingHistory:saveScenarioViewingHistoryFile()
    local f = io.open(self:getScenarioViewingHistorySaveFileName(),'w')
    if (not f) then
        return false
    end

    -- cclog(luadump(self.m_rootTable))
    local content = dkjson.encode(self.m_rootTable, {indent=true})
    f:write(content)
    f:close()

    return true
end

-------------------------------------
-- function clearScenarioViewingHistoryFile
-------------------------------------
function ScenarioViewingHistory:clearScenarioViewingHistoryFile()
    os.remove(self:getScenarioViewingHistorySaveFileName())
end


-------------------------------------
-- function addViewed
-------------------------------------
function ScenarioViewingHistory:addViewed(scenario_name)
    self.m_rootTable[scenario_name] = true
    self:saveScenarioViewingHistoryFile()
end

-------------------------------------
-- function isViewed
-------------------------------------
function ScenarioViewingHistory:isViewed(scenario_name)
    if self.m_rootTable[scenario_name] then
        return true
    else
        return false
    end
end

-------------------------------------
-- function checkIntroScenario
-------------------------------------
function ScenarioViewingHistory:checkIntroScenario(finish_cb)
    local tid = g_userData:get('start_tamer')
    local tamer_name = TableTamer():getTamerType(tid) or 'goni'
    local intro_start_name = 'scenario_intro_start_'..tamer_name

    -- 로컬데이터가 있다면 패스
    if (self:isViewed(intro_start_name)) then
        finish_cb()
    end

    local check_tutorial 
    local play_intro_start
    local play_intro_fight

    play_intro_start = function()
        local ui = self:playScenario(intro_start_name)
        ui:setReplaceSceneCB(play_intro_fight)
        ui:next()
    end

    play_intro_fight = function()
        local scene = SceneGameIntro()
        scene:runScene()
    end

    -- 같은 계정으로 다른 기기에 접속한 경우 서버에서 준 튜토리얼 정보로 검사
    check_tutorial = function(ret)
        local is_viewd = ret['tutorial']

        if (not is_viewd) then
            play_intro_start()
        else
            self:addViewed(intro_start_name)
            finish_cb()
        end
    end

    g_tutorialData:request_tutorialInfo(TUTORIAL_INTRO_FIGHT, check_tutorial, finish_cb)
end

-------------------------------------
-- function playScenario
-------------------------------------
function ScenarioViewingHistory:playScenario(scenario_name)
    local setting = 'first'
    local play = false

    if (not TABLE:isFileExist('scenario/'..scenario_name, '.csv')) then
        return 
    end 

    -- 설정 정보가 있으면 받아옴
    if g_localData then
        setting = g_localData:get('scenario_playback_rules')
    end

    -- 설정 정보에 따라 재생 여부 결정
    if (setting == 'off') then
        play = false

    elseif (setting == 'always') then
        play = true
        
    elseif (setting == 'first') then
        if (not self:isViewed(scenario_name)) then
            play = true
        end
    end

    -- 시청 기록에 등록
    self:addViewed(scenario_name)

    -- 재생
    if play then
        -- 자동 전투 중 시나리오 플레이된다면 해제시켜줌
        if (g_autoPlaySetting:isAutoPlay()) then
            g_autoPlaySetting:setAutoPlay(false)
        end

        local ui = UI_ScenarioPlayer(scenario_name)
        return ui
    end
end

-------------------------------------
-- function playScenario
-------------------------------------
function ScenarioViewingHistory:playTutorial(scenario_name, tar_ui)
    if (not TABLE:isFileExist('scenario/'..scenario_name, '.csv')) then
        return 
    end 

    if (self:isViewed(scenario_name)) then
        return
    end    

    -- 튜토리얼 기록에 등록
    self:addViewed(scenario_name)

    -- 시작
    TutorialManager.getInstance():startTutorial(scenario_name, tar_ui)
end