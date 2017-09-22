local PARENT = TableClass

-------------------------------------
-- class TableForestStuffLevelInfo
-------------------------------------
TableForestStuffLevelInfo = class(PARENT, {
    })

local THIS = TableForestStuffLevelInfo

local T_STUFF_TABLE = nil

-------------------------------------
-- function init
-------------------------------------
function TableForestStuffLevelInfo:init()
    self.m_tableName = 'table_forest_stuff_info'
    self.m_orgTable = TABLE:get(self.m_tableName)

    if (not T_STUFF_TABLE) then
        self:makeFilteredTable()
    end
end

-------------------------------------
-- function init
-------------------------------------
function TableForestStuffLevelInfo:makeFilteredTable()
    local l_key = {'nest', 'chest', 'table', 'well', 'bookshelf', 'extension'}
    T_STUFF_TABLE = {}
    for _, key in ipairs(l_key) do
        T_STUFF_TABLE[key] = self:filterList('stuff_type', key)
    end
end

-------------------------------------
-- function getOpenLevel
-------------------------------------
function TableForestStuffLevelInfo:getOpenLevel(stuff_type)
    if (self == THIS) then
        self = THIS()
    end

    if (not stuff_type) then
        return 0
    end

    return T_STUFF_TABLE[stuff_type][1]['open_lv']
end

-------------------------------------
-- function getDragonMaxCnt
-------------------------------------
function TableForestStuffLevelInfo:getDragonMaxCnt(lv)
    if (self == THIS) then
        self = THIS()
    end
    if (not lv) then
        return nil
    end

    local t_extension = T_STUFF_TABLE['extension']
    if (not t_extension[lv]) then
        return nil
    end
        
    return t_extension[lv]['dragon_cnt']
end

-------------------------------------
-- function getStuffTable
-------------------------------------
function TableForestStuffLevelInfo:getStuffTable(stuff_type)
    if (self == THIS) then
        self = THIS()
    end

    if (not stuff_type) then
        return nil
    end

    return T_STUFF_TABLE[stuff_type]
end

-------------------------------------
-- function getStuffOptionDesc
-------------------------------------
function TableForestStuffLevelInfo:getStuffOptionDesc(stuff_type, lv)
    if (self == THIS) then
        self = THIS()
    end

    if (not stuff_type) then
        return ''
    end
    if (not lv) then
        return ''
    end

    local t_stuff_level_info = T_STUFF_TABLE[stuff_type][lv]
    if (not t_stuff_level_info) then
        return
    end

    local reward_1 = t_stuff_level_info['reward_1']
    local reward_2 = t_stuff_level_info['reward_2']

    -- 쿨타임
    local cool = t_stuff_level_info['cooltime']

    -- 1번 보상 상세
    local t_reward = plSplit(reward_1, ';')
    local item_id = tonumber(t_reward[1])
    local item_name = TableItem:getItemName(item_id)
    local item_cnt = t_reward[2]

    -- 보상이 하나인 경우
    if (reward_2 == '') then
        local template = '{@item_name}{1}분{@DESC}마다 {@count}{2} {3}개{@DESC} 획득'
        return Str(template, cool, item_name, item_cnt)
    -- 2개인 경우 : 갯수는 빼버린다.
    else
        -- 2번 보상 상세
        local t_reward_2 = plSplit(reward_2, ';')
        local item_id_2 = tonumber(t_reward_2[1])
        local item_name_2 = TableItem:getItemName(item_id_2)

        local template = '{@item_name}{1}분{@DESC}마다 {@count}{2} {@DESC}또는 {@count}{3}{@DESC} 획득'
        return Str(template, cool, item_name, item_name_2)
    end
end