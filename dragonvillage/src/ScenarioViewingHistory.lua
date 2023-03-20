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
    local ret_json, success_load = LoadLocalSaveJson(self:getScenarioViewingHistorySaveFileName())

    if (success_load == true) then
        self.m_rootTable = ret_json
        return
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
    return SaveLocalSaveJson(self:getScenarioViewingHistorySaveFileName(), self.m_rootTable)
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
-- function playScenario
-------------------------------------
function ScenarioViewingHistory:playScenario(scenario_name, is_force_play)
    -- 벤치마크 도중에는 재생하지 않도록 수정
    if (g_benchmarkMgr and g_benchmarkMgr:isActive()) then
        return
    end

    local setting = 'first'
    local play = false

    if (not TABLE:isFileExist('scenario/'..scenario_name, '.csv')) then
        return 
    end 

    -- 설정 정보가 있으면 받아옴
    if g_settingData then
        setting = g_settingData:get('scenario_playback_rules')
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

    -- 강제 재생 처리
    if is_force_play == true then
        play = true
    end

    -- 시청 기록에 등록
    self:addViewed(scenario_name)

    -- 재생
    if play then
        local ui = UI_ScenarioPlayer(scenario_name)
        return ui
    end
end