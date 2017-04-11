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

    -- 개발 스테이지의 경우 1난이도 1챕터로 간주
    if (stage_id == DEV_STAGE_ID) then
        return makeAdventureChapterID(1, 1)
    end

    local game_mode = g_stageData:getGameMode(stage_id)

    -- 모험 모드
    if (game_mode ~= GAME_MODE_ADVENTURE) then
        return nil
    end

    local difficulty, chapter, stage = parseAdventureID(stage_id)
    local chapter_id = makeAdventureChapterID(difficulty, chapter)
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

-------------------------------------
-- function decideDropItem
-------------------------------------
function TableDropIngame:decideDropItem(chapter_id)
    local t_table = self:get(chapter_id)
    
    local sum_random = SumRandom()
    sum_random:addItem(t_table['cash_weight'], 'cash')
    sum_random:addItem(t_table['gold_weight'], 'gold')
    sum_random:addItem(t_table['lactea_weight'], 'lactea')
    sum_random:addItem(t_table['amethyst_weight'] or 0, 'amethyst')

    local item_type = sum_random:getRandomValue()

    local min_cnt = t_table[item_type .. '_min']
    local max_cnt = t_table[item_type .. '_max']
    local item_count = math_random(min_cnt, max_cnt)

    return item_type, item_count
end