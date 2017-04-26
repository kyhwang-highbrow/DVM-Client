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
    self.m_tableName = 'table_req_gold'
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

    local req_gold = t_table['dragon_skill']

    if (not req_gold) or (req_gold == '') then
        req_gold = 0
    end

    return req_gold
end

-------------------------------------
-- function getDragonSkillEnhanceReqGold
-------------------------------------
function TableDragonSkillEnhance:getReqGold(key, skill_lv)
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

    local req_gold = t_table[key]

    if (not req_gold) or (req_gold == '') then
        req_gold = 0
    end

    return req_gold
end

-------------------------------------
-- function getReqGold_dragonSkill
-------------------------------------
function TableDragonSkillEnhance:getReqGold_dragonSkill(skill_lv)
	return self:getReqGold('dragon_skill', skill_lv)
end

-------------------------------------
-- function getReqGold_tamerSkill
-------------------------------------
function TableDragonSkillEnhance:getReqGold_tamerSkill(skill_lv)
	return self:getReqGold('tamer_skill', skill_lv)
end

-------------------------------------
-- function getReqGold_formation
-------------------------------------
function TableDragonSkillEnhance:getReqGold_formation(skill_lv)
	return self:getReqGold('formation', skill_lv)
end