-------------------------------------
-- class ScenarioViewingHistory
-------------------------------------
ScenarioViewingHistory = class({
        m_rootTable = 'table',
        m_playingScenario = 'UI_ScenarioPlayer',
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

        if #content > 0 then
            self.m_rootTable = json_decode(content)
        end
        f:close()
    else
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
-- function playScenario
-------------------------------------
function ScenarioViewingHistory:playScenario(scenario_name)
    local setting = 'first'
    local play = false

    local path = 'data/scenario/' .. scenario_name .. '.csv'

    if (not LuaBridge:isFileExist(path)) then
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
        local ui = UI_ScenarioPlayer(scenario_name)
        self.m_playingScenario = ui
        return ui
    end
end