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
    -- @TODO sgkim 넘어온 stage_id가 오픈되어있는지 검증할 필요가 있음
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
        UI_ReadyScene(dungeon_id)
    else
        UI_SecretDungeonScene()
    end
end