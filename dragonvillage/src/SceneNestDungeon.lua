-------------------------------------
-- class SceneNestDungeon
-------------------------------------
SceneNestDungeon = class(PerpleScene, {
        m_startStageID = 'number',
		m_dungeonType = 'string',
        m_bReady = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneNestDungeon:init(start_stage_id, dungeon_type, is_ready)
    -- @TODO sgkim 넘어온 stage_id가 오픈되어있는지 검증할 필요가 있음
    self.m_startStageID = start_stage_id

	self.m_dungeonType = dungeon_type or g_nestDungeonData:getDungeonMode(start_stage_id)
    self.m_bReady = is_ready or false
	self.m_sceneName = 'SceneNestDungeon'
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneNestDungeon:onEnter()
    PerpleScene.onEnter(self)

    if self.m_startStageID then
        local stage_id = self.m_startStageID
        UI_NestDungeonScene(stage_id, self.m_dungeonType)

        if (self.m_bReady) then
            UI_ReadyScene(stage_id)
        end
    else
        UI_NestDungeonScene(nil, self.m_dungeonType)
    end
end