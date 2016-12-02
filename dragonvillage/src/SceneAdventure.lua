-------------------------------------
-- class SceneAdventure
-------------------------------------
SceneAdventure = class(PerpleScene, {
        m_startStageID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneAdventure:init(start_stage_id)
    -- @TODO sgkim 넘어온 stage_id가 오픈되어있는지 검증할 필요가 있음
    self.m_startStageID = start_stage_id
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneAdventure:onEnter()
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_title')
    
    if self.m_startStageID then
        local stage_id = self.m_startStageID
        UI_AdventureSceneNew(stage_id)
        UI_ReadyScene(stage_id)
    else
        UI_AdventureSceneNew()
    end
end