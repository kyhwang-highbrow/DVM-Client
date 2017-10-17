local PARENT = TableClass

-------------------------------------
-- class TableEvolutionItemCombine
-------------------------------------
TableEvolutionItemCombine = class(PARENT, {
    })

local THIS = TableEvolutionItemCombine

-------------------------------------
-- function init
-------------------------------------
function TableEvolutionItemCombine:init()
    self.m_tableName = 'table_item_evolution_combine'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getCombineTargetInfo
-------------------------------------
function TableEvolutionItemCombine:getCombineTargetInfo(origin_id)
    if (self == THIS) then
        self = THIS()
    end

    local l_list = self:filterList('type', 'combine')
    for _, v in ipairs(l_list) do
        if (origin_id == v['origin_item_id']) then
            return v
        end
    end

    return nil
end

-------------------------------------
-- function getDivisionTargetInfo
-------------------------------------
function TableEvolutionItemCombine:getDivisionTargetInfo(origin_id)
    if (self == THIS) then
        self = THIS()
    end

    local l_list = self:filterList('type', 'divide')
    for _, v in ipairs(l_list) do
        if (origin_id == v['origin_item_id']) then
            return v
        end
    end

    return nil
end