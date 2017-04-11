local PARENT = TableClass

-------------------------------------
-- class TableDragonResearch
-------------------------------------
TableDragonResearch = class(PARENT, {
    })

local THIS = TableDragonResearch

-------------------------------------
-- function init
-------------------------------------
function TableDragonResearch:init()
    self.m_tableName = 'table_dragon_research'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonResearchPrice
-------------------------------------
function TableDragonResearch:getDragonResearchPrice(research_lv)
    if (self == THIS) then
        self = THIS()
    end

    local price = self:getValue(research_lv, 'price')
    return price or 0
end

-------------------------------------
-- function getDragonResearchStatus
-------------------------------------
function TableDragonResearch:getDragonResearchStatus(dragon_type, research_lv)
    if (self == THIS) then
        self = THIS()
    end

    local base_did = TableDragonType:getBaseDid(dragon_type)

    if (not base_did) then
        return 0, 0, 0
    end

    local table_dragon  = TableDragon()

    local atk_max = table_dragon:getMaxStatus(base_did, 'atk')
    local def_max = table_dragon:getMaxStatus(base_did, 'def')
    local hp_max = table_dragon:getMaxStatus(base_did, 'hp')

    local atk_rate = self:getValue(research_lv, 'atk') / 100
    local def_rate = self:getValue(research_lv, 'def') / 100
    local hp_rate = self:getValue(research_lv, 'hp') / 100

    local atk = (atk_max * atk_rate)
    local def = (def_max * def_rate)
    local hp = (hp_max * hp_rate)

    return atk, def, hp
end

-------------------------------------
-- function getDesc
-------------------------------------
function TableDragonResearch:getDesc(research_lv, type_name)
    if (self == THIS) then
        self = THIS()
    end

    local desc = self:getValue(research_lv, 't_desc') or 'none'
    desc = Str(desc, type_name)
    return desc
end
