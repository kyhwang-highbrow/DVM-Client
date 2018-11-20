-------------------------------------
-- class SceneRuneGuardianDungeon
-------------------------------------
SceneRuneGuardianDungeon = class(PerpleScene, {
        m_startStageID = 'number',
        m_bReady = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneRuneGuardianDungeon:init(start_stage_id, is_ready)
    self.m_startStageID = start_stage_id

    self.m_bReady = is_ready or false
	self.m_sceneName = 'SceneRuneGuardianDungeon'
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneRuneGuardianDungeon:onEnter()
    PerpleScene.onEnter(self)

    local stage_id = self.m_startStageID
    
    UI_RuneGuardianDungeonScene()

    if stage_id then
        UI_ReadySceneNew(stage_id)
    end
end