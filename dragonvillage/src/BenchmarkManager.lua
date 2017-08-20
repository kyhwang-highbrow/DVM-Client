-------------------------------------
-- class BenchmarkManager
-------------------------------------
BenchmarkManager = class({
        m_lStageID = '',
        m_currIdx = '',
        m_bActive = '',

        m_waveTime = '',
        m_lastWaveTime = '',
    })

-------------------------------------
-- function init
-------------------------------------
function BenchmarkManager:init()
    self.m_bActive = false
    self.m_waveTime = 30
    self.m_lastWaveTime = 60
end

-------------------------------------
-- function getInstance
-------------------------------------
function BenchmarkManager:getInstance()
    if (not g_benchmarkMgr) then
        g_benchmarkMgr = BenchmarkManager()
    end
    return g_benchmarkMgr
end

-------------------------------------
-- function release
-------------------------------------
function BenchmarkManager:release()
    g_benchmarkMgr = nil
end

-------------------------------------
-- function setStageIDList
-------------------------------------
function BenchmarkManager:setStageIDList(...)
    local args = {...}
    self.m_lStageID = args
    self.m_currIdx = 0
end

-------------------------------------
-- function startStage
-------------------------------------
function BenchmarkManager:startStage()
    self.m_currIdx = self.m_currIdx + 1
    local stage_id = self.m_lStageID[self.m_currIdx]

    if stage_id then
        self:runGameScene(stage_id)
        return true
    else
        self.m_bActive = false
        return false
    end
end

-------------------------------------
-- function isActive
-------------------------------------
function BenchmarkManager:isActive()
    return self.m_bActive
end

-------------------------------------
-- function runGameScene
-------------------------------------
function BenchmarkManager:runGameScene(stage_id)

    -- 밴치마크가 활성화되어있다면 즉시 활성화시킴
    g_autoPlaySetting:set('quick_mode', true)
    g_autoPlaySetting:set('auto_mode', true)

    self.m_bActive = true
    local stage_name = 'stage_' .. stage_id
    local scene = SceneGame(nil, stage_id, stage_name)
    scene:runScene()

    -- 아군, 적군 무적
    -- 1.5배속
    -- 자동 플레이
    -- 웨이브당 n초 지속
    -- n초 후 웨이브 종료
    -- 보스 패턴은 모두 쓰도록 변경
end

-------------------------------------
-- function finishStage
-------------------------------------
function BenchmarkManager:finishStage()
    local stage_id = self.m_lStageID[self.m_currIdx]
    ccdump(stage_id)

    if self:startStage() then

    else
        local function ok_cb()
            local scene = SceneLobby()
            scene:runScene()
        end
        MakeSimplePopup(POPUP_TYPE.OK, '벤치마크 종료!!', ok_cb)
    end
end