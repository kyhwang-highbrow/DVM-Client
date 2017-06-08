require 'perpleLib/csv'
require 'perpleLib/StringUtils'
require 'TableGradeInfo'
require 'lfs'
require 'perpleLib/dkjson'
require 'lib/net'
require 'slack'
--------------------------------------------------------

DataTableValidator = class({
    m_dataRoot = '',
    m_numOfInvalidData = 'number',

    m_tInvalidDragon = 'table',
    m_tInvalidMonster = 'table',
    m_tInvalidSkill = 'table',
    m_tDragon = 'table',
    m_tMonster = 'table',
    
    })
------------------------------------
-- function initGlobalVar
------------------------------------
function DataTableValidator:init()
    self.m_dataRoot = '..\\data\\'
    self.m_numOfInvalidData = 0

    self.m_tInvalidDragon = {}
    self.m_tInvalidMonster = {}
    self.m_tInvalidSkill = {}
    self.m_tDragon = self:makeDictCSV((self.m_dataRoot .. '..\\data\\table_dragon.csv'), 'did')
    self.m_tMonster =  self:makeDictCSV((self.m_dataRoot .. '..\\data\\table_monster.csv'), 'mid') 
end

function DataTableValidator:getNumOfInvalidData() 
    return self.m_numOfInvalidData
end

------------------------------------
-- function validateData
-- @brief data 검증 시작. 전체 파일의 경로를 찾아 로드한 뒤, 파일들을 전부 사전화한다. 그 후 파일 검증을 시작.
------------------------------------
function DataTableValidator:validateData()
    print("########### TABLE VALIDATION START ##########\n")
    -- 1. 전체 파일 경로 찾기
    print("\nFile Loading...\n\n")
    local filePathList = self:getAllFilePath(self.m_dataRoot)
    
    -- 2. 전체 파일 리스트 자료 정리 (딕셔너리화)
    local tableData = self:makeDictAllData(filePathList)


    -- 3. 파일 검증 시작
    self:validateData_Dragon(tableData)
    print("Dragon Table Validation Finished\n")

    self:validateData_Stage(tableData)
    print("Stage Table Validation Finished\n")

    self:validateData_Skill()
    print("Skill Table Validation Finished\n")

    print("########### TABLE VALIDATION END ###########\n\n\n\n\n\n")
end


------------------------------------------------------------------------
-- 1. 전체 파일 경로 찾기

------------------------------------
-- function getAllFilePath
-- @brief 특정 폴더의 전체 파일 절대경로 리스트 반환
-- @param 파일 최상위 경로
-- @return 경로 내의 파일들의 절대경로 리스트
------------------------------------
function DataTableValidator:getAllFilePath(path)
    local t = {}
    local pfile = pl.dir.getallfiles(pl.path.abspath(self.m_dataRoot))

    for _, dir in ipairs(pfile) do
        table.insert(t, dir)  
    end
    return t
end

------------------------------------------------------------------------
-- 2. 전체 파일 구조화

------------------------------------
-- function makeDictAllData
-- @brief 파일을 읽고 사전화
-- @param 파일 경로 리스트
-- @return 사전화된 파일 내용
------------------------------------
function DataTableValidator:makeDictAllData(filePathList)
    local tableData = {}

    for _, filePath in ipairs(filePathList) do
        local lData = nil
        local relativePath = pl.path.relpath(getFileName(filePath), lfs.currentdir() .. self.m_dataRoot)

        -- 파일 확장자로 구분하여 로드.
        if (getFileExtension(filePath) == '.csv') then
            lData = TABLE:loadCSVTable(relativePath)

        elseif (getFileExtension(filePath) == '.txt') then
            lData = TABLE:loadJsonTable(relativePath)

        end

        tableData[filePath] = lData
    end

    return tableData
end

------------------------------------
-- function makeDictCSV
-- @brief csv를 특정 값을 찾아서 키로 하는 딕셔너리로 반환
-- @param 파일 경로, 키
-- @return param 'key' 를 키로 하는 딕셔너리
------------------------------------
function DataTableValidator:makeDictCSV(filePath, key)
    local target_file = io.open(filePath, "r")
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
        idx = 1
        local t_row = {}
        for _, value in ipairs(ParseCSVLine(line)) do -- 한 줄을 파싱
            t_row[l_header[idx]] = value
            idx = idx + 1
        end
        local real_key = t_row[key]
        t_csv[real_key]= t_row
        line = target_file:read()
    end
    return t_csv
end

------------------------------------
-- function validataData_Dragon
-- @param table데이터
------------------------------------
function DataTableValidator:validateData_Dragon(t_Data)
     for filePath, l_data in pairs(t_Data) do
        if (find(filePath, 'table_dragon') ~= nil) then
            for _, t_row in pairs(l_data) do
                self:checkCSVRow(t_row, 'did', self.m_tDragon, filePath)
                self:checkCSVRow(t_row, 'base_did', self.m_tDragon, filePath)
            end
        end
     end
end

------------------------------------
-- function checkCSVRow
-- @param   t_row       -> csv 파일의 한 행의 table
--          key         -> 찾을 key
--          table       -> t_row[key]가 존재하는지 찾을 대상 table
--          filePath    -> file Path 
------------------------------------
function DataTableValidator:checkCSVRow(t_row, key, table, filePath)
    local didStr = t_row[key]
    if(didStr) then
        if(find(didStr, ',') ~= nil) then
            local l_did = pl.stringx.split(didStr, ',')
            for _, did in pairs(l_did) do
                self:checkDictHasKey(table, did, filePath, 0)
            end
        else
            self:checkDictHasKey(table, didStr, filePath, 0)
        end
    end
 end

------------------------------------
-- function validateData_Stage`
-- @brief 드래곤 테이블 관련 테이블 did 검증
------------------------------------
function DataTableValidator:validateData_Stage(table_data)
    for filePath, t_data in pairs(table_data) do
        if ((find(filePath, 'stage_') ~= nil) and (getFileExtension(filePath) == '.txt')) then
            self:checkStageScript(t_data, filePath)
        end
    end
end

------------------------------------
-- function checkStageScript
------------------------------------
function DataTableValidator:checkStageScript(t_data, filePath)
    for _, t_wave in pairs(t_data['wave']) do
        for _, summonInfo in pairs(t_wave['wave']) do
             for _, script in pairs(summonInfo) do
                local monster_id = pl.stringx.split(script, ';')[1]
                if (find(monster_id, 'RandomDragon') == nil) then
                    self:checkDictHasKey(self.m_tMonster, monster_id, filePath, 1) 
                end
             end
        end
    end
end

------------------------------------
-- function validateData_Skill
------------------------------------
function DataTableValidator:validateData_Skill()
    t_dragon_skill = self:makeDictCSV('..//data//table_dragon_skill.csv', 'sid')
    t_monster_skill = self:makeDictCSV('..//data//table_monster_skill.csv', 'sid')

    l_skill_column = {'skill_basic', 'skill_active'}

    for i = 1, 10 do 
        table.insert(l_skill_column, 'skill_'.. tostring(i))
    end

    -- 1. dragon skill validation 
    self:checkSkillTable(t_dragon_skill, self.m_tDragon, l_skill_column)

    -- 2. monster skill validation
    self:checkSkillTable(t_monster_skill, self.m_tMonster, l_skill_column)
end


------------------------------------
-- function checkSkillTable
-- @brief 캐릭터의 스킬이 존재하는 스킬인지 검사
-- @param   skillTable      -> 유효성 검사할 테이블
--          charTable       -> charTable[][skillColumn]이 존재하는지 유효성을 검사할 수 있는 대상 테이블. 즉, 검사할 특정 스킬을 가진 캐릭터가 있는지 봐야 할 대상.
--          l_skillColumn   -> skillColumn 이름
------------------------------------
function DataTableValidator:checkSkillTable(skillTable, charTable, l_skillColumn)
    
    for t_char, _ in pairs(charTable) do 
        local charName = charTable[t_char]['t_name']
        for _, skillColumn in pairs(l_skillColumn) do
            skillID = charTable[t_char][skillColumn]
            
            -- 비어있는 스킬 ID는 존재하는 데이터가 아니므로 예외처리. 존재하는 데이터만 체크
            if (skillID ~= nil and skillID ~= '') then 
                self:checkDictHasKey(skillTable, skillID, charName, 2)
            end

        end

    end
end

------------------------------------
-- function checkDictHasKey
-- @brief 특정 사전에 특정 키값이 존재하는지 검사하여 없으면 에러 테이블 목록에 등록한다.
-- @param t : 테이블
-- @param key : 키
-- @param filePath : 파일 경로
-- @param tableType :   0 -> 드래곤 테이블인 경우.
--                      1 -> 스테이지 테이블인 경우.
--                      그 외 -> 스킬 테이블인 경우. 
------------------------------------
function DataTableValidator:checkDictHasKey(t, key, filePath, tableType)
    if (t[pl.stringx.strip(tostring(key))] == nil) then
        local tempDict = {}
        -- 파일 이름과 잘못된 키 값을 저장
        local str = pl.stringx.split(filePath, '\\')
        tempDict['path'] = str[#str]
        tempDict['info'] = key
        if(tableType == 0) then
            table.insert(self.m_tInvalidDragon, tempDict)
        elseif(tableType == 1) then
            
            table.insert(self.m_tInvalidMonster, tempDict)
        else
            table.insert(self.m_tInvalidSkill, tempDict)
        end

        self.m_numOfInvalidData = self.m_numOfInvalidData + 1
    end
end


------------------------------------------------------------------------
-- 3. 검증 결과 리포트 ( 출력 + 슬랙 )


------------------------------------
-- function makeInvalidStr
-- @brief 오류가 있는 테이블을 출력될 텍스트로 만든다.
-- @return formatting된 string
------------------------------------
function DataTableValidator:makeInvalidStr()
    --table_str = "@hkkang @wjung @jykim\n"
    local flag_dragonID = false
    local flag_monsterID = true
    local flag_skillID = true
    local table_str = '## 존재하지 않는 드래곤 ID\n'

    for _, tempDict in ipairs(self.m_tInvalidDragon) do
        table_str = table_str .. tempDict['path'] .. '\t : \t' .. tempDict['info'] .. '\n'
    end

    table_str = table_str .. '\n## 존재하지 않는 몬스터 ID\n'

    for _, tempDict in ipairs(self.m_tInvalidMonster) do
        table_str = table_str .. tempDict['path'] .. '\t : \t' .. tempDict['info'] .. '\n'
    end
    
    table_str = table_str .. '\n## 존재하지 않는 스킬 ID\n'

    for _, tempDict in ipairs(self.m_tInvalidSkill) do
        table_str = table_str .. tempDict['path'] .. '\t : \t' .. tempDict['info'] .. '\n'
    end
    return table_str
end

--TEST필요
------------------------------------
-- function sendInvalidTableListBySlack
-- @brief 슬랙으로 전송.
-- @return 슬랙으로 전송된 메시지.
------------------------------------
function DataTableValidator:sendInvalidTableListBySlack()
    -- lua slack api 참고

    local slack = Slack.GetInstance('xoxp-4049551466-60623372247-67908400245-53f29cbca3')

    local channel = 'C1RUT070B'
    local text =        '[DV_BOT] TABLE VALIDATION\n' ..
                        'https://drive.google.com/open?id=0Bzybp2XzPNq0flpmdEstcDJYOTdPbXFWcFpkWktZY0NxdnpyUHF1VENFX29jbnJLSGRvcFE' .. '\n' ..
                        '[DV_BOT] 테이블 오류 발견 !!\n' ..
                        self:makeInvalidStr()

    slack:Send(slack:Message(text, channel, '드빌봇'))

    return text

end

