-------------------------------------
-- class SceneNestDungeon
-------------------------------------
SceneNestDungeon = class(PerpleScene, {
        m_startStageID = 'number',
		m_dungeonType = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneNestDungeon:init(start_stage_id, dungeon_type)
    -- @TODO sgkim 넘어온 stage_id가 오픈되어있는지 검증할 필요가 있음
    self.m_startStageID = start_stage_id

	self.m_dungeonType = dungeon_type
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneNestDungeon:onEnter()
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_title')
    
    if self.m_startStageID then
        local stage_id = self.m_startStageID
        UI_NestDungeonScene(stage_id, self.m_dungeonType)
        UI_ReadyScene(stage_id)
    else
        UI_NestDungeonScene(nil, self.m_dungeonType)
    end
end