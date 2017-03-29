local PARENT = TableClass

-------------------------------------
-- class TableDragonSkillEnhance
-------------------------------------
TableDragonSkillEnhance = class(PARENT, {
    })

local THIS = TableDragonSkillEnhance

-------------------------------------
-- function init
-------------------------------------
function TableDragonSkillEnhance:init()
    self.m_tableName = 'table_dragon_skill_enhance'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonSkillEnhanceReqGold
-------------------------------------
function TableDragonSkillEnhance:getDragonSkillEnhanceReqGold(skill_lv)
    if (self == THIS) then
        self = THIS()
    end

    if (skill_lv <= 0) then
        return 0
    end

    local t_table = self:get(skill_lv)
    if (not t_table) then
        error('skill_lv : ' .. skill_lv)
    end

    local req_gold = t_table['req_gold']

    if (not req_gold) or (req_gold == '') then
        req_gold = 0
    end

    return req_gold
end