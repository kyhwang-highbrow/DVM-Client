require 'LuaStandAlone'

--require 'slack'

-------------------------------------
-- class DataTableValidator
-------------------------------------
DataTableValidator = class({
    m_dataRoot = '',
    m_numOfInvalidData = 'number',

    m_lInvalidNA = 'table',
    m_tInvalidDragon = 'table',
    m_tInvalidMonster = 'table',
    m_tInvalidSkill = 'table',
    m_tDragon = 'table',
    m_tMonster = 'table',
    
    })
------------------------------------
-- function init
------------------------------------
function DataTableValidator:init()
    self.m_dataRoot = '..\\data\\'
    self.m_numOfInvalidData = 0

    self.m_lInvalidNA = {}
    self.m_tInvalidDragon = {}
    self.m_tInvalidMonster = {}
    self.m_tInvalidSkill = {}
    self.m_tDragon = self:makeDictCSV((self.m_dataRoot .. 'table_dragon.csv'), 'did')
    self.m_tMonster =  self:makeDictCSV((self.m_dataRoot .. 'table_monster.csv'), 'mid') 
end

------------------------------------
-- function validateData
-- @brief data 검증 시작. 전체 파일의 경로를 찾아 로드한 뒤, 파일들을 전부 사전화한다. 그 후 파일 검증을 시작. 결과에 따라 슬랙에 쏴줌.
------------------------------------
function DataTableValidator:validateData()
    print("########### TABLE VALIDATION START ##########\n")
    -- 1. 전체 파일 경로 찾기
    print("\nFile Loading...\n\n")
    local file_path_list = pl.dir.getallfiles(pl.path.abspath(self.m_dataRoot))
    
    -- 2. 전체 파일 리스트 자료 정리 (딕셔너리화)
    local t_data = self:makeDictAllData(file_path_list)

    -- 3. 파일 검증 시작
    self:validateData_NA(t_data)
    print("N/A Vliadation Finished\n")

    self:validateData_Dragon(t_data)
    print("Dragon Table Validation Finished\n")

    self:validateData_Stage(t_data)
    print("Stage Table Validation Finished\n")

    self:validateData_Skill()
    print("Skill Table Validation Finished\n")

    print("########### TABLE VALIDATION END ###########\n\n\n\n\n\n")

    -- 에러가 존재한다면
    if (self.m_numOfInvalidData > 0 ) then
        ccdump(self:makeInvalidStr())
        os.exit(101)
    end
end


------------------------------------------------------------------------
-- 2. 전체 파일 구조화

------------------------------------
-- function makeDictAllData
-- @brief 파일을 읽고 사전화
-- @param   l_file_path  :   table, key = number, value = 파일 경로 리스트
-- @return  t_data       :   table, key = file_path, value = 사전화된 파일 내용
------------------------------------
function DataTableValidator:makeDictAllData(l_file_path)
    local t_data = {}

    for _, file_path in ipairs(l_file_path) do
        local l_data = nil
        local relative_path = pl.path.relpath(getFileName(file_path), lfs.currentdir() .. self.m_dataRoot)

        -- 파일 확장자로 구분하여 로드.
        if (getFileExtension(file_path) == '.csv') then
            l_data = TABLE:loadCSVTable(relative_path)

        elseif (getFileExtension(file_path) == '.txt') then
            l_data = TABLE:loadJsonTable(relative_path)

        end

        t_data[file_path] = l_data
    end

    return t_data
end

------------------------------------
-- function makeDictCSV
-- @brief csv를 특정 값을 찾아서 키로 하는 딕셔너리로 반환
-- @param   file_path : string, 파일 경로
--          key       : string, 키
-- @return  t_csv     : table,  key = param 'key', value = csv 파일 내용
------------------------------------
function DataTableValidator:makeDictCSV(file_path, key)
    local target_file = io.open(file_path, "r")
    local t_csv = {}
    local l_header = {}
    local line = target_file:read()
    -- 첫 줄은 column명이므로 header에 저장.
    for _, value in ipairs(ParseCSVLine(line)) do
        table.insert(l_header, value)
    end

    line = target_file:read()
    -- 데이터 저장
    while(line ~= nil) do
        local t_row = {}
        -- 한 줄을 파싱
        for idx, value in ipairs(ParseCSVLine(line)) do
            if (l_header[idx]) then
                t_row[l_header[idx]] = value
            end
        end
        local real_key = t_row[key]
        t_csv[real_key]= t_row
        line = target_file:read()
    end
    return t_csv
end

------------------------------------
-- function validateData_NA
-- @brief 전체 테이블에서 '#N/A' 문자열을 찾는다.
------------------------------------
function DataTableValidator:validateData_NA(t_data)
    for file_path, l_data in pairs(t_data) do
        if (getFileExtension(file_path) == '.csv') then
            for id, t_row in pairs(l_data) do
                for column, context in pairs(t_row) do
                    if (not pl.stringx.startswith(column, 'r_')) then
                        if (string.find(context, '#N/A')) then
                            table.insert(self.m_lInvalidNA, {
                                ['path'] = file_path,
                                ['id'] = id,
                                ['column'] = column
                            })
                            self.m_numOfInvalidData = self.m_numOfInvalidData + 1
                        end
                    end
                end
            end
        end
    end
end

------------------------------------
-- function validataData_Dragon
-- @brief   dragon 데이터을 검증한다.
-- @param   t_data  : table,    key = file path, value = data list
------------------------------------
function DataTableValidator:validateData_Dragon(t_data)
     for file_path, table_data in pairs(t_data) do
        if (find(file_path, 'table_dragon') ~= nil) then
            for _, t_row in pairs(table_data) do
                self:checkCSVRow(t_row, 'did', self.m_tDragon, file_path)
                self:checkCSVRow(t_row, 'base_did', self.m_tDragon, file_path)
            end
        end
     end
end

------------------------------------
-- function checkCSVRow
-- @brief   CSV의 한 Row를 검사한다.
-- @param   t_row       :   table,  key = csv 파일의 key, value = csv 파일의 각 행의 value
--          key         :   key,    찾을 key
--          t           :   table,  t_row[key]가 존재하는지 찾을 대상 table
--          file_path   :   string, file Path 
------------------------------------
function DataTableValidator:checkCSVRow(t_row, key, t, file_path)

    local did_str = t_row[key]
    if(did_str) then
        if(find(did_str, ',') ~= nil) then
            local l_did = pl.stringx.split(did_str, ',')
            for _, did in pairs(l_did) do
                self:checkDictHasKey(t, did, file_path, 0)
            end
        else
            self:checkDictHasKey(t, did_str, file_path, 0)
        end
    end
 end

------------------------------------
-- function validateData_Stage
-- @brief   stage 테이블을 검증한다.
-- @param   table_data  :   table, 검증할 데이터가 담긴 테이블. key = file path, value = key의 이름을 가진 file의 data가 담긴 table
------------------------------------
function DataTableValidator:validateData_Stage(table_data)
    for file_path, t_data in pairs(table_data) do
        if ((find(file_path, 'stage_') ~= nil) and (getFileExtension(file_path) == '.txt')) then
            self:checkStageScript(t_data, file_path)
        end
    end
end

------------------------------------
-- function checkStageScript
-- @brief   stage 데이터를 검증한다.
-- @param   t_data      :   table, 검증할 파일의 데이터가 담긴 테이블 key = csv 파일의 key, value = 한 행의 value
--          file_path   :   string, file path
------------------------------------
function DataTableValidator:checkStageScript(t_data, file_path)
    for _, t_wave in pairs(t_data['wave']) do
        for _, summon_info in pairs(t_wave['wave']) do
             for _, script in pairs(summon_info) do
                local monster_id = pl.stringx.split(script, ';')[1]
                if (find(monster_id, 'RandomDragon') == nil) then
                    if (math.floor(monster_id / 10000) == 12) then
                        self:checkDictHasKey(self.m_tDragon, monster_id, file_path, 1)
                    else
                        self:checkDictHasKey(self.m_tMonster, monster_id, file_path, 1)
                    end
                end
             end
        end
    end
end

------------------------------------
-- function validateData_Skill
-- @brief   skill 테이블을 검증한다.
------------------------------------
function DataTableValidator:validateData_Skill()
    t_dragon_skill = self:makeDictCSV('..//data//table_dragon_skill.csv', 'sid')
    t_monster_skill = self:makeDictCSV('..//data//table_monster_skill.csv', 'sid')

    t_skill_column = {'skill_basic', 'skill_active'}

    for i = 1, 10 do 
        table.insert(t_skill_column, 'skill_'.. tostring(i))
    end

    -- 1. dragon skill validation 
    self:checkSkillTable(t_dragon_skill, self.m_tDragon, t_skill_column)

    -- 2. monster skill validation
    self:checkSkillTable(t_monster_skill, self.m_tMonster, t_skill_column)
end


------------------------------------
-- function checkSkillTable
-- @brief 캐릭터의 스킬이 존재하는 스킬인지 검사
-- @param   t_skill         :   table,      유효성 검사할 테이블
--          t_char          :   table,      검사할 특정 스킬을 가진 캐릭터가 있는지 봐야 할 대상.
--          t_skill_column  :   table,      skill_column 이름을 value로 가지는 테이블.
------------------------------------
function DataTableValidator:checkSkillTable(t_skill, t_char, t_skill_column)
    
    for key_char, _ in pairs(t_char) do 
        local char_name = t_char[key_char]['t_name']
        for _, skill_column in pairs(t_skill_column) do
            id_skill = t_char[key_char][skill_column]
            
            -- 비어있는 스킬 ID는 존재하는 데이터가 아니므로 예외처리. 존재하는 데이터만 체크
            if (id_skill ~= nil and id_skill ~= '') then 
                self:checkDictHasKey(t_skill, id_skill, char_name, 2)
            end

        end

    end
end

------------------------------------
-- function checkDictHasKey
-- @brief   특정 사전에 특정 키값이 존재하는지 검사하여 없으면 에러 테이블 목록에 등록한다.
-- @param   t           : table,    key = csv파일의 key. value = csv파일의 value
--          key         : string,   찾을 key
--          file_path   : string,   파일 경로
--          tableType   : number,   0 -> 드래곤 테이블인 경우.
--                                  1 -> 스테이지 테이블인 경우.
--                                  그 외 -> 스킬 테이블인 경우. 
------------------------------------
function DataTableValidator:checkDictHasKey(t, key, file_path, tableType)
    if (t[pl.stringx.strip(tostring(key))] == nil) then
        local t_temp_dict = {}
        -- 파일 이름과 잘못된 키 값을 저장
        local str = pl.stringx.split(file_path, '\\')
        t_temp_dict['path'] = str[#str]
        t_temp_dict['info'] = key
        if(tableType == 0) then
            table.insert(self.m_tInvalidDragon, t_temp_dict)
        elseif(tableType == 1) then
            table.insert(self.m_tInvalidMonster, t_temp_dict)
        else
            table.insert(self.m_tInvalidSkill, t_temp_dict)
        end

        self.m_numOfInvalidData = self.m_numOfInvalidData + 1
    end
end


------------------------------------------------------------------------
-- 3. 검증 결과 리포트 ( 출력 + 슬랙 )


------------------------------------
-- function makeInvalidStr
-- @brief 오류가 있는 테이블을 출력될 텍스트로 만든다.
-- @return str      : string,   formatting된 string
------------------------------------
function DataTableValidator:makeInvalidStr()
    local t_str = {}

    do
        local context_str = ''
        for _, t_temp in ipairs(self.m_lInvalidNA) do
            context_str = context_str .. string.format('path : %s / id : %s / column : %s\n', t_temp['path'], t_temp['id'], t_temp['column'])
        end
        t_str['na'] = '## N/A LIST \n' .. context_str
    end
    
    do
        local context_str = ''
        for _, t_temp_dict in ipairs(self.m_tInvalidDragon) do
            context_str = context_str .. t_temp_dict['path'] .. '\t : \t' .. t_temp_dict['info'] .. '\n'
        end
        t_str['dragon'] = '## Dragon that do not exist ID\n' .. context_str
    end

    do
        local context_str = ''
        for _, t_temp_dict in ipairs(self.m_tInvalidMonster) do
            context_str = context_str .. t_temp_dict['path'] .. '\t : \t' .. t_temp_dict['info'] .. '\n'
        end
        t_str['monster'] = '## Monster that do not exist ID\n' .. context_str
    end

    do    
        local context_str = ''
        for _, t_temp_dict in ipairs(self.m_tInvalidSkill) do
            context_str = context_str .. t_temp_dict['path'] .. '\t : \t' .. t_temp_dict['info'] .. '\n'
        end
        t_str['skill'] = '## Skill that do not exist\n' .. context_str
    end

    return t_str
end

------------------------------------
-- function sendToSlack
-- @brief 슬랙으로 전송.
-- @return text     : string, 슬랙으로 전송된 메시지.
------------------------------------
function DataTableValidator:sendToSlack()
    -- lua slack api 참고

    local slack = Slack.GetInstance('xoxp-4049551466-60623372247-67908400245-53f29cbca3')

    local channel = 'C1RUT070B'
    local text =        '[DV_BOT] TABLE VALIDATION\n' ..
                        'https://drive.google.com/open?id=0Bzybp2XzPNq0flpmdEstcDJYOTdPbXFWcFpkWktZY0NxdnpyUHF1VENFX29jbnJLSGRvcFE' .. '\n' ..
                        '[DV_BOT] 테이블 오류 발견 !!\n' ..
                        self:makeInvalidStr()
    print(text)
    --slack:Send(slack:Message(text, channel, '드빌봇'))

    return text

end


-- lua class 파일 자체에서 실행되도록 함
if (arg[1] == 'run') then
    DataTableValidator():validateData()
end