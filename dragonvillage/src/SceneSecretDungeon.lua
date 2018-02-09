-------------------------------------
-- class SceneSecretDungeon
-------------------------------------
SceneSecretDungeon = class(PerpleScene, {
        m_startDungeonID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneSecretDungeon:init(dungeon_id)
    self.m_startDungeonID = dungeon_id
    self.m_sceneName = 'SceneSecretDungeon'
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneSecretDungeon:onEnter()
    PerpleScene.onEnter(self)

    if self.m_startDungeonID then
        local dungeon_id = self.m_startDungeonID
        UI_SecretDungeonScene(dungeon_id)
        UI_ReadySceneNew(dungeon_id)
    else
        UI_SecretDungeonScene()
    end
end