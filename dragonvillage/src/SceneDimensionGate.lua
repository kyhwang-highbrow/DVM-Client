-------------------------------------
-- class SceneDimensionGate
-------------------------------------
SceneDimensionGate = class(PerpleScene, {
    m_targetStageID = 'number',
    m_bReady = 'boolean',
})

-------------------------------------
-- function init
-------------------------------------
function SceneDimensionGate:init(target_stage_id, is_ready)
    self.m_targetStageID = target_stage_id
    self.m_bReady = is_ready or false
    self.m_sceneName = 'SceneDimensionGate'
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneDimensionGate:onEnter()
    PerpleScene.onEnter(self)

    if self.m_targetStageID then
        local stage_id = self.m_targetStageID

        --if(self.m_bReady)

        -- 빠른 시작 반복 시 backkey 를 위한 UI 지정
        -- TODO : Check whether UI_DimensionGateScene is repeatedly overlapped every time user play by using quick start.
        UI_DimensionGateScene(stage_id)

        if (self.m_bReady) then
            UI_ReadySceneNew(stage_id)
        end

    else
        UI_DimensionGateScene(nil)
    end
end