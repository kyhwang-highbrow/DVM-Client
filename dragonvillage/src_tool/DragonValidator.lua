require 'LuaStandAlone'
require 'pl'

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
-- @brief 
------------------------------------
function DragonValidator:validateData(did)
    
    print("########### TABLE VALIDATION START ##########\n")

    -- 1. validation start
    self:validateData_Dragon(did)
    print("Dragon Table Validation Finished\n")
    self:makeOutputFile(did)

end

------------------------------------
-- function validataData_Dragon
-- @brief   validate dragon data
------------------------------------
function DragonValidator:validateData_Dragon(did)
    self.m_str = self.m_str .. 'DID,TABLE_NAME,REPORT\n' 
    local search = tonumber(did) or nil
    -- 1. load tables
    local table_dragon = TABLE:get('dragon')
    local table_dragon_phrase = TABLE:get('table_dragon_phrase')
    local table_dragon_evolution = TABLE:get('dragon_evolution')
    local table_skill = TABLE:get('dragon_skill')
    local table_dragon_skill_modify = TABLE:get('dragon_skill_modify')

    print('TABLE LOADING....\n')

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
        local is_dragon = (string.sub(did, 2, 2) == '2')
       
        -- 1-2. dragon skill table validation
        do
            -- common
            self:validateSkill(table_skill[v['skill_basic']], v)
            self:validateSkill(table_skill[v['skill_1']], v)
        
            -- dragon only
            if (is_dragon) then
                self:validateSkill(table_skill[v['skill_active']], v)
                self:validateSkill(table_skill[v['skill_2']], v)
                self:validateSkill(table_skill[v['skill_3']], v)
                -- when dragon has leader skill
                if (v['skill_leader'] ~= '' and v['skill_leader'] ~= nil) then
                    self:validateSkill(table_skill[v['skill_leader']], v)
                end
            end
        end

        -- 1-3. dragon skill modify table validation
        do
            self:validateSkillModify(table_skill[v['skill_basic']], table_dragon_skill_modify, did)
            self:validateSkillModify(table_skill[v['skill_1']], table_dragon_skill_modify, did)
            if (is_dragon) then
                self:validateSkillModify(table_skill[v['skill_active']], table_dragon_skill_modify, did)
                self:validateSkillModify(table_skill[v['skill_2']], table_dragon_skill_modify, did)
                self:validateSkillModify(table_skill[v['skill_3']], table_dragon_skill_modify, did)
            end
            if (v['skill_leader'] ~= '' and v['skill_leader'] ~= nil) then
                    self:validateSkillModify(table_skill[v['skill_leader']], table_dragon_skill_modify, did)
            end
            
        end
    end

    -- 2. phrase table validation
    for _, v in pairs(table_dragon_phrase) do
        self:validatePhrase(v)
    end

    -- 3. evolution table validation
    for k, v in pairs(table_dragon_evolution) do
        if (string.sub(k, 2, 2) ~= '8') then
            self:validateEvolution(v)
        end
    end

    print(self.m_str)
end

------------------------------------
-- function validateDragonTable
------------------------------------
function DragonValidator:validateDragonTable(values)
    -- res, icon validate
    for i = 1, 3 do
        local file_name = DragonValidator:getDragonResName(values['res'], i, values['attr']):gsub('%.spine', '%.atlas')
        if (not LuaBridge:isFileExist(file_name)) then
            self.m_str = self.m_str .. values['did'] .. ',table_dragon,' .. '\'' .. file_name .. '\'' .. ' NOT EXIST\n' 
        end
        if (not LuaBridge:isFileExist(DragonValidator:getDragonResName(values['icon'], i, values['attr']))) then
            self.m_str = self.m_str .. values['did'] .. ',table_dragon,' .. '\'' .. DragonValidator:getDragonResName(values['icon'], i, values['attr']) .. '\'' .. ' NOT EXIST\n'
        end
    end
end

------------------------------------
-- function validatePhrase
------------------------------------
function DragonValidator:validatePhrase(values) 
    for k, v in pairs(values) do
        if (k == 'party_in_induce' or k == 'mail_message' or k == 'lactea_sorrow' or
            k == 'lactea_bye' or k == 'lactea_farewell') then
        else
            if (v == '' or v == nil) then
                self.m_str = self.m_str .. values['did'] .. ',table_dragon_phrase,' .. '\'' .. k .. '\' NOT EXIST\n'
            end
        end
    end
end

------------------------------------
-- function validateEvolution
------------------------------------
function DragonValidator:validateEvolution(values)
    for k, v in pairs(values) do
        if (v == '' or v == nil) then
            self.m_str = self.m_str .. values['did'] .. ',table_dragon_evolution' .. '\'' .. k .. '\' NOT EXIST\n'
        end
    end
end

------------------------------------
-- function validateSkill
------------------------------------
function DragonValidator:validateSkill(values, dragon_table)
        
    -- res_icon, res1, res2
    for i = 1, 2 do
        local res = 'res_'..i
        if (values[res] ~= '' and values[res] ~= nil) then
            local file_name = self:getDragonResName(values[res], nil, dragon_table['attr'])
            if (pl.stringx.endswith(file_name, '.spine')) then
                file_name = file_name:gsub('.spine', '.atlas')
            end
            if (not LuaBridge:isFileExist(file_name)) then
                self.m_str = self.m_str .. dragon_table['did'] .. ',table_dragon_skill,' .. 'Skill id : ' .. values['sid'] .. ' - ' .. '\'' .. file_name .. '\'' .. ' NOT EXIST\n'
            end
        end
    end

    if (values['res_icon'] ~= '' and values['res_icon'] ~= nil) then
        if (values['sid'] < 200100) then
        else
            if (not LuaBridge:isFileExist(values['res_icon'])) then
                self.m_str = self.m_str .. dragon_table['did'] .. ',table_dragon_skill,' .. 'Skill id : ' .. values['sid'] .. ' - ' .. '\'' .. values['res_icon'] .. '\'' .. ' NOT EXIST\n'
            end
        end
    end

    -- other values
    for k, v in pairs(values) do
        if (v == '' or v == nil) then
            if (k == 'r_d_name' or k == 'motion_type' or k == 'dir' or k == 'chance_type' or 
                k == 'target_type' or k == 'target_count' or k == 'r_s_name' or
                k == 'hit' or k == 't_desc' or
                k == 'skill_form' or k == 'skill_type' or k == 't_name') then
                self.m_str = self.m_str .. dragon_table['did'] .. ',table_dragon_skill,' .. 'Skill id : ' .. values['sid'] .. ' - ' .. '\'' .. k .. '\'' .. ' NOT EXIST\n'
            end
        else
            if (k == 't_desc') then
                -- desc_X value
                for i = 1, 5 do
                    if (v:find('{' .. i ..'}')) then
                        local desc_string = values['desc_'..i]
                        if (desc_string == '' or desc_string == nil) then
                            self.m_str = self.m_str .. dragon_table['did'] .. ',table_dragon_skill,' .. 'Skill id : ' .. values['sid'] .. ' - ' .. '\'' .. 'desc_' .. i .. '\'' .. ' NOT EXIST\n'
                        end
                    end
                end
            end
        end
    end
end

------------------------------------
-- function validateSkillModify
------------------------------------
function DragonValidator:validateSkillModify(skill_id, table_dragon_skill_modify, did)
    for k, v in pairs(table_dragon_skill_modify) do
        if (v == '#N\A') then
            self.m_str = self.m_str.. did .. ',table_dragon_skill_modify,' .. 'Skill id : ' .. skill_id .. ' - ' .. '\'' .. k .. '\'' .. ' NOT EXIST\n'
        end
    end
end 

-------------------------------------
-- function getDragonResName
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