require 'LuaStandAlone'
require 'pl'

-- constant table file name string
local TABLE_NAME_EVOLUTION = 'table_dragon_evolution'
local TABLE_NAME_PHRASE = 'table_dragon_phrase'
local TABLE_NAME_DRAGON = 'table_dragon'
local TABLE_NAME_SKILL  = 'table_dragon_skill'
local TABLE_NAME_SKILL_MODIFY = 'table_dragon_skill_modify'


-------------------------------------
-- class DragonValidator
-------------------------------------
DragonValidator = class({
    m_str = 'string',
    })

------------------------------------
-- function init
------------------------------------
function DragonValidator:init()
    self.m_str = ''
end

------------------------------------
-- function validateData
-- validate -> write file
------------------------------------
function DragonValidator:validateData(did)
    
    print("########### TABLE VALIDATION START ##########\n")

    -- validation start
    self:validateData_Dragon(did)
    print("Dragon Table Validation Finished\n")

    -- make output file
    self:makeOutputFile(did)

end

------------------------------------
-- function validataData_Dragon
-- @brief   validation process
------------------------------------
function DragonValidator:validateData_Dragon(did)
    self.m_str = self.m_str .. 'DID,TABLE_NAME,NOT_EXIST\n' 
    local search = tonumber(did) or nil
    -- load tables
    local table_dragon = TABLE:get('dragon')
    local table_dragon_phrase = TABLE:get('table_dragon_phrase')
    local table_dragon_evolution = TABLE:get('dragon_evolution')
    local table_skill = TABLE:get('dragon_skill')
    local table_skill_modify = TABLE:get('dragon_skill_modify')

    print('TABLE LOADING....\n')

    -- 1. if search ID
    if (search) then
        table_dragon = { [search] = table_dragon[search] }
        table_dragon_phrase = { [search] = table_dragon_phrase[search] }
        table_dragon_evolution = { [search] = table_dragon_evolution[search] }

        if (not table_dragon[search]) then
            self.m_str = self.m_str .. search .. ',table_dragon,NOT EXIST\n'
            return 
        end

        if (not table_dragon_phrase[search]) then
            self.m_str = self.m_str .. search .. ',table_dragon_phrase,NOT EXIST\n'
            return 
        end

        if (not table_dragon_evolution[search]) then 
            self.m_str = self.m_str .. search .. ',table_dragon_evolution,NOT EXIST\n'
            return 
        end
    end

    -- 2. dragon, skill, skill_modify table validation
    for did, v in pairs(table_dragon) do
        -- 1-1. dragon table validation
        self:validateDragonTable(v)
        
        -- monster id -> 18xxxx    
        local is_dragon = self:isDragon(did)
       
        -- 1-2. skill table validation
        --      skill modify table validation
        self:validateAllSkills(v, table_skill, table_skill_modify, is_dragon)
       
    end

    -- 2. phrase table validation
    for _, v in pairs(table_dragon_phrase) do
        self:validatePhrase(v)
    end

    -- 3. evolution table validation
    for k, v in pairs(table_dragon_evolution) do
        local is_dragon = self:isDragon(k)
        if (is_dragon) then
            self:validateEvolution(v)
        end
    end

    print(self.m_str)
end

------------------------------------
-- function validateDragonTable
-- @brief   validate 'table_dragon'
------------------------------------
function DragonValidator:validateDragonTable(values)
    -- res, icon validate
    local did = values['did']
    for i = 1, 3 do
        local file_name = DragonValidator:getDragonResName(values['res'], i, values['attr']):gsub('%.spine', '%.atlas')

        if (not LuaBridge:isFileExist(file_name)) then
            file_name = '\'' .. file_name .. '\''
            self:makeReportString(did, TABLE_NAME_DRAGON, file_name)
        end

        local icon_file_name = DragonValidator:getDragonResName(values['icon'], i, values['attr'])

        if (not LuaBridge:isFileExist(icon_file_name)) then
            icon_file_name = '\'' .. icon_file_name .. '\''
            self:makeReportString(did, TABLE_NAME_DRAGON, icon_file_name)
        end
    end
end

------------------------------------
-- function validatePhrase
-- @brief   validate 'table_dragon_phrase'
------------------------------------
function DragonValidator:validatePhrase(values) 
    for k, v in pairs(values) do
        if (k == 'party_in_induce' or k == 'mail_message' or k == 'lactea_sorrow' or
            k == 'lactea_bye' or k == 'lactea_farewell') then
        else
            if (v == '' or v == nil) then
                local str = '\'' .. k .. '\''
                self:makeReportString(values['did'], TABLE_NAME_PHRASE, str)
            end
        end
    end
end

------------------------------------
-- function validateEvolution
-- @brief   validate 'table_dragon_evolution'
------------------------------------
function DragonValidator:validateEvolution(values)
    local table_name = TABLE_NAME_EVOLUTION
    for k, v in pairs(values) do
        if (v == '' or v == nil) then
            local str = '\'' .. k .. '\''
            self:makeReportString(values['did'], TABLE_NAME_EVOLUTION, str)
        end
    end
end

------------------------------------
-- function validateSkill
-- @brief   validate 'table_dragon_skill'
------------------------------------
function DragonValidator:validateSkill(values, dragon_table, did)
       
    -- if invalid skill 
    if (not values) then
        return false
    end

    -- res_icon, res1, res2
    for i = 1, 2 do
        local res = 'res_'..i
        if (values[res] ~= '' and values[res] ~= nil) then
            local file_name = self:getDragonResName(values[res], nil, dragon_table['attr'])
            if (pl.stringx.endswith(file_name, '.spine')) then
                file_name = file_name:gsub('.spine', '.atlas')
            end
            if (not LuaBridge:isFileExist(file_name)) then
                local str =  'Skill id : ' .. values['sid'] .. ' - ' .. '\'' .. file_name .. '\''
                self:makeReportString(did, TABLE_NAME_SKILL, str)
            end
        end
    end

    if (values['res_icon'] ~= '' and values['res_icon'] ~= nil) then
        if (values['sid'] < 200100) then
        else
            if (not LuaBridge:isFileExist(values['res_icon'])) then
                local str = 'Skill id : ' .. values['sid'] .. ' - ' .. '\'' .. values['res_icon'] .. '\''
                self:makeReportString(did, TABLE_NAME_SKILL, str)
            end
        end
    end

    -- other values
    for k, v in pairs(values) do
        if (v == '' or v == nil) then
            if (self:isNotDeprecate(k)) then
                local str =  'Skill id : ' .. values['sid'] .. ' - ' .. 'column ' .. '\'' .. k .. '\''
                self:makeReportString(did, TABLE_NAME_SKILL, str)
            end
        else
            if (k == 't_desc') then
                -- desc_X value
                for i = 1, 5 do
                    if (v:find('{' .. i ..'}')) then
                        local desc_string = values['desc_'..i]
                        if (desc_string == '' or desc_string == nil) then
                            local str = 'Skill id : ' .. values['sid'] .. ' - ' .. '\'' .. 'desc_' .. i .. '\'' 
                            self:makeReportString(did, TABLE_NAME_SKILL, str)
                        end
                    end
                end
            end
        end
    end

    return true
end

-------------------------------------
-- function validateAllSkills
-- @brief   validate 'table_dragin_skill' & 'table_dragon_skill_modify'
-------------------------------------
function DragonValidator:validateAllSkills(dragon, t_skill, t_skill_modify, is_dragon)
    
    local did = dragon['did']

    -- 1. table_dragon_skill validation
    local skill_name = {'skill_basic', 'skill_1', 'skill_active', 'skill_2', 'skill_3'}

    -- if true, check that skill is valid in modify table

    for i = 1, 5 do
        
        if (i < 3) then     -- skill_basic, skill_1 (common)
            if (not self:validateSkill(t_skill[dragon[skill_name[i]]], dragon, did)) then
                 self:makeReportString(did, TABLE_NAME_SKILL, 'invalid ' .. skill_name[i])
            end
       
        else                -- skill_active, skill_2, skill_3 (only dragon not monster)
            if (not is_dragon and self:validateSkill(t_skill[dragon[skill_name[i]]], dragon, did)) then
                self:makeReportString(did, TABLE_NAME_SKILL, 'invalid ' .. skill_name[i])
            end
        end
    end
    
    -- leader skill
    if (is_dragon and dragon['skill_leader'] ~= '' and dragon['skill_leader'] ~= nil) then
        if (not self:validateSkill(t_skill[dragon['skill_leader']], dragon, did)) then
            self:makeReportString(did, TABLE_NAME_SKILL, 'invalid ' .. 'skill_leader')
        end
    end


    -- 2. table_dragon_skill_modify validation
    -- common 
    self:validateSkillModify(dragon['skill_1'], t_skill_modify, did)

    -- dragon only
    if (is_dragon) then
        self:validateSkillModify(dragon['skill_active'], t_skill_modify, did)
    end


end
    
------------------------------------
-- function validateSkillModify
-- @brief   validate 'table_dragon_skill_modify'
------------------------------------
function DragonValidator:validateSkillModify(skill_id, table_dragon_skill_modify, did)
    local is_exist = false
    if (skill_id == '') then
        return nil
    end
    for k, v in pairs(table_dragon_skill_modify) do
        local is_valid_row = (tostring(k):sub(1, 6) == tostring(skill_id))
        if (is_valid_row) then
            for k2, v2 in pairs(v) do
                if (v2 == '#N\A') then
                    local str = 'slid : ' .. k .. ' - Row - ' .. '\'' .. k2 .. '\''
                    self:makeReportString(did, TABLE_NAME_SKILL_MODIFY, str)
                end
            end
            
            if (not is_exist and is_valid_row) then
                is_exist = true
            end

        end
    end

    if (not is_exist) then
        local str = 'sid : ' .. '\'' .. skill_id .. '\''
        self:makeReportString(did, TABLE_NAME_SKILL_MODIFY, str)
    end
end 

-------------------------------------
-- function getDragonResName
-- @brief   replace @ -> attributes, # -> evolution
-------------------------------------
function DragonValidator:getDragonResName(res_name, evolution, attr)
	local res_name = res_name
	
	if evolution then 
		res_name = string.gsub(res_name, '#', '0' .. evolution)
	end
	if attr then 
		res_name = string.gsub(res_name, '@', attr)
	end
    
    return res_name
end

-------------------------------------
-- function isDragon
-- @brief   recognize that did is dragon's id.
-------------------------------------
function DragonValidator:isDragon(did)
    return string.sub(did, 2, 2) ~= '8'
end

-------------------------------------
-- function makeOututFile
-------------------------------------
function DragonValidator:makeOutputFile(did)
    local str = '..\\bat\\output\\DragonValidationReport'
    if (did) then
        str = str .. tostring(did)
    end
    str = str .. '.csv'
    if(pl.file.write(str, self.m_str)) then
        print(str .. ' CREATED\n\n\n\n')
    end
end

-------------------------------------
-- function isNotDeprecate
-- @brief   recognize that column is not deprecate
-------------------------------------
function DragonValidator:isNotDeprecate(k)
    return (k == 'r_d_name' or k == 'motion_type' or k == 'dir' or k == 'chance_type' or 
            k == 'target_type' or k == 'target_count' or k == 'r_s_name' or
            k == 'hit' or k == 't_desc' or
            k == 'skill_form' or k == 'skill_type' or k == 't_name')
end

-------------------------------------
-- function makeReportString
-- @brief   make err string to report csv format
-------------------------------------
function DragonValidator:makeReportString(did, table_name, str)
    self.m_str = self.m_str .. did .. ',' .. table_name .. ',' .. str .. '\n'
end


-- can be executed in this lua class
if (arg[1] == 'run') then
    print('Input Dragon ID (id or \'all\') : ')
    local arg2 = io.read()
    if (arg2 == 'all' or arg2 == nil) then
        DragonValidator():validateData()
    else
        DragonValidator():validateData(arg2)
    end
end

