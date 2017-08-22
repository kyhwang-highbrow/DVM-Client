local PARENT = TableClass

-------------------------------------
-- class TableStageData
-------------------------------------
TableStageData = class(PARENT, {
    })

local THIS = TableStageData

-------------------------------------
-- function init
-------------------------------------
function TableStageData:init()
    self.m_tableName = 'stage_data'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getStageBuff
-------------------------------------
function TableStageData:getStageBuff(stage_id, is_enemy)
    if (self == THIS) then
        self = THIS()
    end

    local key
    if (is_enemy) then
        key = 'enemy'
    else
        key = 'user'
    end

    local str = self:getValue(tonumber(stage_id), 'buff_' .. key)
    if (str == nil or str == 'x' or str == '') then return end

    local l_ret = {}
    local make_data = function(str)
        local ret = {}
        local l_str = self:seperate(str, ';')

        ret['condition_type'] = l_str[1]
        ret['condition_value'] = l_str[2]
        ret['buff_type'] = l_str[3]
        ret['buff_value'] = tonumber(l_str[4])

        return ret
    end

    if (string.find(str, ',')) then
        local l_str = self:seperate(str, ',')

        for i, str in ipairs(l_str) do
            local data = make_data(str)
            table.insert(l_ret, data)
        end
    else
        local data = make_data(str)
        table.insert(l_ret, data)
    end

    return l_ret
end

-------------------------------------
-- function getStageAttr
-------------------------------------
function TableStageData:getStageAttr(stage_id)
    if (self == THIS) then
        self = THIS()
    end

    local attr = self:getValue(stage_id, 'attr')
    return attr
end

-------------------------------------
-- function getStageLevel
-------------------------------------
function TableStageData:getStageLevel(stage_id)
    if (self == THIS) then
        self = THIS()
    end

    local level = self:getValue(stage_id, 'level') or 0
    return level + 1
end