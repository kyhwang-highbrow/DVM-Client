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
    if (game_mode ~= GAME_MODE_ADVENTURE) and (game_mode ~= GAME_MODE_INTRO) then
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
-- function getDropItemType
-- @brief 해당 챕터에서 드랍되는 아이템 리스트 문자열 반환
-------------------------------------
function TableDropIngame:getDropItemType(chapter_id)
    local t_table = self:get(chapter_id)
    local t_type = {'cash', 'gold', 'amethyst'}
    local str = ''

    for _, v in ipairs(t_type) do
        local key = string.format('%s_weight', v)
        if (t_table[key] > 0) then
            str = (str == '') and v or str .. ';' .. v
        end
    end
    
    return str
end

-------------------------------------
-- function decideDropItem
-------------------------------------
function TableDropIngame:decideDropItem(chapter_id, drop_item_max)
    local t_table = self:get(chapter_id)

    local t_type = {'cash', 'gold', 'amethyst'}
    local sum_random = SumRandom()

    -- 최대 획득 재화 체크
    if (drop_item_max) then

        local function check_max(type)
            if (drop_item_max[type] and drop_item_max[type] > 0) then
                local key = string.format('%s_weight', type)
                sum_random:addItem(t_table[key], type)
            end
        end

        check_max('cash')
        check_max('gold')
        check_max('amethyst')

    else
        sum_random:addItem(t_table['cash_weight'], 'cash')
        sum_random:addItem(t_table['gold_weight'], 'gold')
        sum_random:addItem(t_table['amethyst_weight'] or 0, 'amethyst')
    end

    local item_type = sum_random:getRandomValue()
    local min_cnt = t_table[item_type .. '_min']
    local max_cnt = t_table[item_type .. '_max']
    local item_count = math_random(min_cnt, max_cnt)

    return item_type, item_count
end