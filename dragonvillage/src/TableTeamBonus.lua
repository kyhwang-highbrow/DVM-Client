local PARENT = TableClass

-------------------------------------
-- class TableTeamBonus
-------------------------------------
TableTeamBonus = class(PARENT, {
    })

local THIS = TableTeamBonus

-------------------------------------
-- function init
-------------------------------------
function TableTeamBonus:init()
    self.m_tableName = 'team_bonus'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getName
-------------------------------------
function TableTeamBonus:getName(key)
	if (not key) or (key == '') then return end

    local t_teambonus = self:get(key)
    return t_teambonus['t_name']
end

-------------------------------------
-- function getDesc
-------------------------------------
function TableTeamBonus:getDesc(key)
	if (not key) or (key == '') then return end

    local t_teambonus = self:get(key)
    
    -- TODO: 팀보너스 설명
    --local desc = DragonSkillCore.getSimpleSkillDesc(t_skill)
    return desc
end