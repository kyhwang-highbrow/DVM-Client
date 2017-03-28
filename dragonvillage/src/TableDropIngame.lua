local PARENT = TableClass

-------------------------------------
-- class TableDropIngame
-------------------------------------
TableDropIngame = class(PARENT, {
    })

local THIS = TableDropIngame

-------------------------------------
-- function init
-------------------------------------
function TableDropIngame:init()
    self.m_tableName = 'table_drop_ingame'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function makeChapterIDFromStageID
-------------------------------------
function TableDropIngame:makeChapterIDFromStageID(stage_id)
    local game_mode = g_stageData:getGameMode(stage_id)

    -- 모험 모드
    if (game_mode ~= GAME_MODE_ADVENTURE) then
        return nil
    end

    local difficulty, chapter, stage = parseAdventureID(stage_id)
    local chapter_id = (difficulty * 100) + chapter
    return chapter_id
end

-------------------------------------
-- function getDropIngameTable
-------------------------------------
function TableDropIngame:getDropIngameTable(chapter_id)
    if (self == THIS) then
        self = THIS()
    end
    return self:get(chapter_id)
end

-------------------------------------
-- function getDropItemCount
-------------------------------------
function TableDropIngame:getDropItemCount(chapter_id)
    local t_table = self:get(chapter_id)
    local drop_item_count = math_random(t_table['item_min'], t_table['item_max'])
    return drop_item_count
end