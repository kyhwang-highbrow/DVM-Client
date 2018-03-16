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
    if (not t_teambonus) then
        error('no t_teambonus : ' .. key)
    end

    local desc
    
    for i = 1, 3 do
        local str

        if (t_teambonus['skill_type'] == 'skill') then
            local skill_id = t_teambonus['skill_' .. i]
            if (skill_id and skill_id ~= '') then
                str = TableDragonSkill():getSkillDesc(skill_id)
            end

        elseif (t_teambonus['skill_type'] == 'option') then
            local option = t_teambonus['skill_' .. i]
            local value = t_teambonus['value_' .. i]
            if (option and option ~= '') then
                str = TableOption():getOptionDesc(option, value) 
            end
        end

        if (str) then
            if (not desc) then
                desc = str
            else
                desc = desc .. '\n' .. str
            end
        end
    end

    return desc
end