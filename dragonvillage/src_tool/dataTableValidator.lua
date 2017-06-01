require 'perpleLib/csv'
require 'perpleLib/StringUtils'
require 'TableGradeInfo'
require 'lfs'
require 'pl/data'
require 'perpleLib/dkjson'

--------------------------------------------------------


g_dataRoot = '../data/'
g_invalidDataTable = {}
g_dragonTable = nil
g_monsterTable = nil


------------------------------------
-- function initGlobalVar
------------------------------------
function initGlobalVar()
    g_dragonTable = makeDictCSV(g_dataRoot .. 'table_dragon.csv', 'did')
    g_monsterTable =  makeDictCSV(g_dataRoot .. 'table_monster.csv', 'mid') 
end



------------------------------------
-- function validateData
-- @brief data 검증 시작. 전체 파일의 경로를 찾아 로드한 뒤, 파일들을 전부 딕셔너리화한다. 그 후 파일 검증을 시작.
------------------------------------
function validateData()
    -- 전체 파일 경로 찾기
    local filePathList = getAllFilePath(g_dataRoot)
    
    -- 전체 파일 리스트 자료 정리 (딕셔너리화)
    local tableData = makeDictAllData(filePathList)

    -- 파일 검증 시작
    validateData_Dragon(tableData)

    print("Dragon Table Validation Finished")
    validateData_Stage(tableData)
    print("Stage Table Validation Finished")

    validateData_Skill()
    print("Skill Table Validation Finished")

    ccdump(makeInvalidStr())
end


------------------------------------------------------------------------
-- 1. 전체 파일 경로 찾기

------------------------------------
-- function getAllFilePath
-- @brief 특정 폴더의 전체 파일 절대경로 리스트 반환
------------------------------------
function getAllFilePath(path)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('dir "'..path..'" /a-d /b /s')
    for dir in pfile:lines() do
        table.insert(t, dir)  
    end

    pfile:close()
    return t
end

------------------------------------------------------------------------
-- 2. 전체 파일 구조화

------------------------------------
-- function makeDictAllData
-- @brief 파일 경로 리스트를 받아서 각 파일을 딕셔너리화 한 딕셔너리 반환
------------------------------------
function makeDictAllData(filePathList)
    local tableData = {}
    for _, filePath in ipairs(filePathList) do
        local lData = nil
        
        if (getFileExtension(filePath) == '.csv') then
            lData = TABLE:loadCSVTable(pl.path.relpath(getFileName(filePath), lfs.currentdir() .. g_dataRoot))
        elseif (getFileExtension(filePath) == '.txt') then
            lData = TABLE:loadJsonTable(pl.path.relpath(getFileName(filePath), lfs.currentdir() .. g_dataRoot))
        end
        tableData[filePath] = lData
    end

    return tableData
end

------------------------------------
-- function makeListCSV
-- @brief csv를 리스트로 반환
------------------------------------
function makeListCSV(filePath) 
    local file = io.open(filePath, "r")
    local l_csv = {}
    local l_header = {}
    line = file:read()
    
    for _, item in ipairs(ParseCSVLine(line)) do
        table.insert(l_header, item)
    end

    line = file:read()
    
    while(line ~= nil) do
        idx = 1
        local t_row = {}

        for _, value in ipairs(ParseCSVLine(line)) do
            t_row[l_header[idx]] = value
            idx = idx + 1
        end

        table.insert(l_csv, t_row)
        line = file:read()
    end

    return l_csv

end

------------------------------------
-- function makeDictCSV
-- @brief csv를 특정 값을 찾아서 키로 하는 딕셔너리로 반환
------------------------------------
function makeDictCSV(filePath, key)
    local file = io.open(filePath, "r")
    local t_csv = {}
    local l_header = {}
    local line = file:read()
    
    for _, value in ipairs(ParseCSVLine(line)) do
        table.insert(l_header, value)
    end
    line = file:read()
    
    while(line ~= nil) do
        idx = 1
        local t_row = {}

        for _, value in ipairs(ParseCSVLine(line)) do -- 한 줄을 파싱
            t_row[l_header[idx]] = value
            idx = idx + 1
        end

        local real_key = t_row[key]
        t_csv[real_key]= t_row

        line = file:read()
    end

    return t_csv
end

------------------------------------
-- function validataData_Dragon
------------------------------------
function validateData_Dragon(t_Data)
    
     for filePath, l_data in pairs(t_Data) do
      
        if (find(filePath, 'table_dragon') ~= nil) then
            print(filePath)
            for _, t_row in pairs(l_data) do
                checkCSVRow(t_row, 'did', g_dragonTable, filePath)
                checkCSVRow(t_row, 'base_did', g_dragonTable, filePath)
            end
            print(filePath .. "  validated")
        end

     end

end

------------------------------------
-- function checkCSVRow
------------------------------------
function checkCSVRow(t_row, key, table, filePath)
    local didStr = t_row[key]
    if(didStr) then
        if(find(didStr, ',') ~= nil) then
            local l_did = pl.stringx.split(didStr, ',')
            for _, did in pairs(l_did) do
                checkDictHasKey(table, did, filePath)
            end
        else
            checkDictHasKey(table, didStr, filePath)
        end
    end
 end

------------------------------------
-- function validateData_Stage`
-- @brief 드래곤 테이블 관련 테이블 did 검증
------------------------------------
function validateData_Stage(table_data)
    for filePath, t_data in pairs(table_data) do
        if ((find(filePath, 'stage_') ~= nil) and (getFileExtension(filePath) == '.txt')) then
            checkStageScript(t_data, filePath)
        end
    end
end

------------------------------------
-- function checkStageScript
------------------------------------
function checkStageScript(t_data, filePath)
    for _, t_wave in pairs(t_data['wave']) do
        for _, summonInfo in pairs(t_wave['wave']) do
             for _, script in pairs(summonInfo) do
                local monster_id = pl.stringx.split(script, ';')[1]
                if (find(monster_id, 'RandomDragon') == nil) then
                    checkDictHasKey(g_monsterTable, monster_id, filePath) 
                end
             end
        end
    end
end

------------------------------------
-- function validateData_Skill
------------------------------------
function validateData_Skill()
    t_dragon_skill = makeDictCSV('..//data//table_dragon_skill.csv', 'sid')
    t_monster_skill = makeDictCSV('..//data//table_monster_skill.csv', 'sid')

    l_skill_column = {'skill_basic', 'skill_active'}

    for i = 1, 10 do 
        table.insert(l_skill_column, 'skill_'.. tostring(i))
    end

    -- 1. dragon
    checkSkillTable(t_dragon_skill, g_dragonTable, l_skill_column)

    -- 2. monster
    checkSkillTable(t_monster_skill, g_monsterTable, l_skill_column)
end


------------------------------------
-- function checkSkillTable
-- @brief 캐릭터의 스킬이 존재하는 스킬인지 검사
------------------------------------
function checkSkillTable(skillTable, charTable, l_skillColumn)
    
    for t_char, _ in pairs(charTable) do 
        local charName = charTable[t_char]['t_name']
        for _, skillColumn in pairs(l_skillColumn) do
            skillID = charTable[t_char][skillColumn]
            
            if (skillID ~= nil and skillID ~= '') then
                checkDictHasKey(skillTable, skillID, charName)
            end

        end

    end
end

------------------------------------
-- function checkDictHasKey
-- @brief 특정 사전에 특정 키값이 존재하는지 검사하여 없으면 에러 테이블 목록에 등록한다.
------------------------------------
function checkDictHasKey(t, key, filePath)
    if (t[pl.stringx.strip(tostring(key))] == nil) then
        local tempDict = {}
        tempDict['path'] = string.gsub(filePath, g_dataRoot, "")
        tempDict['info'] = key
        table.insert(g_invalidDataTable, tempDict)
    end
end


------------------------------------------------------------------------
-- 3. 검증 결과 리포트 ( 출력 + 슬랙 )


------------------------------------
-- function makeInvalidStr
-- @brief 오류가 있는 테이블 목록을 예쁘게 출력될 텍스트로 만든다.
------------------------------------
function makeInvalidStr()
    table_str = "@hkkang @wjung @jykim\n"
    table_str = table_str.."##잘못된 데이터 목록##\n"
    for _, tempDict in ipairs(g_invalidDataTable) do
        text = tempDict['path']..'\t'..tempDict['info']
        
    end  
end

--TEST필요
------------------------------------
-- function sendInvalidTableListBySlack
-- @brief 슬랙으로 쏜다
------------------------------------
function sendInvalidTableListBySlack()
    local attachemntsDict = {}
    attachmentsDict['title'] = '[DV_BOT] TABLE VALIDATION'
    attachmentsDict['title_link'] = 'https://drive.google.com/open?id=0Bzybp2XzPNq0flpmdEstcDJYOTdPbXFWcFpkWktZY0NxdnpyUHF1VENFX29jbnJLSGRvcFE'
    attachmentsDict['fallback'] = "[DV_BOT] 테이블 오류 발견 !!"
    attachmentsDict['text'] = makeInvalidStr()
    print (makeInvalidStr())

    --attachments_dict['pretext'] = "pretext - python slack api TEST"
    --attachments_dict['mrkdwn_in'] = ["text", "pretext"]  # 마크다운을 적용시킬 인자들을 선택합니다.

    -- jykim : U1QEY8938
    -- wjung : U386T6HD5
    -- hkkang : U1QPKAS2F


    local token = 'xoxp-4049551466-60623372247-67908400245-53f29cbca3'
    local slack = Slack.GetTokenInstance(token)

    local attachments = attachmentsDict

    slack:Message('C1RUT070B', '드빌봇', nil, attachments, false)
end

