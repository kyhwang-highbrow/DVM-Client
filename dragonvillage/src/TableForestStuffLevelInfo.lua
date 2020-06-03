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
-- function makeFilteredTable
-------------------------------------
function TableForestStuffLevelInfo:makeFilteredTable()
    local l_key = {'nest', 'chest', 'table', 'well', 'bookshelf', 'extension'}
    T_STUFF_TABLE = {}
    for _, key in ipairs(l_key) do
        local t_stuff = self:filterList('stuff_type', key)
        table.sort(t_stuff, function(a, b)
            return tonumber(a['stuff_lv']) < tonumber(b['stuff_lv'])
        end)
        T_STUFF_TABLE[key] = t_stuff
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

    return T_STUFF_TABLE[stuff_type][1]['extension_lv']
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
        return ''
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
        return Str('{@item_name}{1}분{@DESC}마다 {@count}{2} {3}개{@DESC} 획득', 
			cool, item_name, comma_value(item_cnt))
    -- 2개인 경우 : 갯수는 빼버린다.
    else
        -- 2번 보상 상세
        local t_reward_2 = plSplit(reward_2, ';')
        local item_id_2 = tonumber(t_reward_2[1])
        local item_name_2 = TableItem:getItemName(item_id_2)
        local item_cnt_2 = t_reward_2[2]

        return Str('{@item_name}{1}분{@DESC}마다 {@count}{2} {3}개 {@DESC}또는 {@count}{4} {5}개{@DESC} 획득', 
			cool, item_name, comma_value(item_cnt), item_name_2, comma_value(item_cnt_2))
    end
end

-------------------------------------
-- function getStuffMaxLV
-- @brief 드래곤의 숲 오브젝트 최대 레벨
-------------------------------------
function TableForestStuffLevelInfo:getStuffMaxLV(stuff_type)
    if (self == THIS) then
        self = THIS()
    end

    local l_data = self:filterList('stuff_type', stuff_type)
    local function sort_func(a, b)
        return a['stuff_lv'] > b['stuff_lv']
    end
    table.sort(l_data, sort_func)

    local t_data = l_data[1]
    if (not t_data) then
        return 0
    end

    local max_lv = t_data['stuff_lv'] or 0
    return max_lv
end

-------------------------------------
-- function getExtensionMaxLV
-- @brief 드래곤의 숲 확장 최대 레벨
-------------------------------------
function TableForestStuffLevelInfo:getExtensionMaxLV()
    if (self == THIS) then
        self = THIS()
    end

    return self:getStuffMaxLV('extension')
end

-------------------------------------
-- function getExtensionOpenLV
-------------------------------------
function TableForestStuffLevelInfo:getExtensionOpenLV(curr_extension_lv)
    if (self == THIS) then
        self = THIS()
    end

    local curr_lv = g_userData:get('lv')
    local t_stuff = T_STUFF_TABLE['extension'][curr_extension_lv + 1]
    if (not t_stuff) then
        return 0
    end

    return t_stuff['tamer_lv']
end