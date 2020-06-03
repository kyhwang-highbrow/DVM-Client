local PARENT = TableClass

-------------------------------------
-- class TableReqGold
-------------------------------------
TableReqGold = class(PARENT, {
    })

local THIS = TableReqGold

-------------------------------------
-- function init
-------------------------------------
function TableReqGold:init()
    self.m_tableName = 'table_req_gold'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonSkillEnhanceReqGold
-------------------------------------
function TableReqGold:getDragonSkillEnhanceReqGold(skill_lv)
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
-- function getReqGold
-------------------------------------
function TableReqGold:getReqGold(key, skill_lv)
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
function TableReqGold:getReqGold_dragonSkill(skill_lv)
	return self:getReqGold('dragon_skill', skill_lv)
end

-------------------------------------
-- function getReqGold_tamerSkill
-------------------------------------
function TableReqGold:getReqGold_tamerSkill(skill_lv)
	return self:getReqGold('tamer_skill', skill_lv)
end

-------------------------------------
-- function getReqGold_formation
-------------------------------------
function TableReqGold:getReqGold_formation(skill_lv)
	return self:getReqGold('formation', skill_lv)
end

-------------------------------------
-- function getTotalReqGold
-------------------------------------
function TableReqGold:getTotalReqGold(type, curr_skill_lv, skill_lv)
	local sum = 0
	for i = curr_skill_lv, (skill_lv - 1) do
		sum = sum + self:getReqGold(type, i)
	end

	return sum
end