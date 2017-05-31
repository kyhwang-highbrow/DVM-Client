csv = require 'perpleLib/lua_csv'
require 'perpleLib/StringUtils'
require 'TableGradeInfo'
require 'lfs'
require 'pl/data'
require 'perpleLib/dkjson'

--------------------------------------------------------


g_dataRoot = '../data/'
g_t_invalidData = {}
g_table_dragon = nil
g_table_monster = nil


------------------------------------
-- function installAndImport
-- @brief Ư�� ������ ��ü ���� ������ ����Ʈ ��ȯ
------------------------------------
function installAndImport(package)
    local function requireFunction(package)
        require(package)
    end
    isLoaded = pcall(requireFunction, package)
    if (not isLoaded) then
        --LuaRocks? �� �Ἥ pip�� ���� ������ �� �ʿ䰡 ���� �� ����.
    end
    --package �Ű������� �̸��� ���� ���������� load�� ����� �����ؾ���.
end

--installAndImport('slack')


------------------------------------
-- function initGlobalVar
------------------------------------
function initGlobalVar()
    g_table_dragon = makeDictCSV('../data/table_dragon.csv', 'did')
    g_table_monster =  makeDictCSV('../data/table_monster.csv', 'mid') 
end

------------------------------------
-- function validateData
-- @brief data ���� ����
------------------------------------
function validateData()
    -- ��ü ���� ��� ã��
    local filePathList = getAllFilePath(g_dataRoot)
    
    -- ��ü ���� ����Ʈ �ڷ� ���� (��ųʸ�ȭ)
    local tableData = makeDictAllData(filePathList)

    -- ���� ����
    validateData_Dragon(tableData)
    validateData_Stage(tableData)
    validateData_Skill()
end


------------------------------------------------------------------------
-- 1. ��ü ���� ��� ã��

------------------------------------
-- function getAllFilePath
-- @brief Ư�� ������ ��ü ���� ������ ����Ʈ ��ȯ
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
-- 2. ��ü ���� ����ȭ

------------------------------------
-- function makeDictAllData
-- @brief ���� ��� ����Ʈ�� �޾Ƽ� �� ������ ��ųʸ�ȭ �� ��ųʸ� ��ȯ
------------------------------------
function makeDictAllData(filePathList)
    local tableData = {}

    for _, filePath in ipairs(filePathList) do
        local lData = nil
        
        if (string.sub(filePath, -4, -1) == '.csv') then
            local lData = makeListCSV(filePath)
        elseif (string.sub(filePath, -4, -1) == 'txt') then
            local lData = makeDataTXT(filePath)
        end

        tableData[filePath] = lData
    end
    return tableData
end

------------------------------------
-- function makeListCSV
-- @brief csv�� ����Ʈ�� ��ȯ
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

        for _, value in ipairs(ParseCSVLine(line)) do -- �� ���� �Ľ�
            t_row[l_header[idx]] = value
            idx = idx + 1
        end

        table.insert(l_csv, t_row) -- �� ���� �����͸� ��ü csv ���� �����Ϳ� �߰�
        line = file:read()
    end

    return l_csv

end

------------------------------------
-- function makeDictCSV
-- @brief csv�� Ư�� ���� ã�Ƽ� Ű�� �ϴ� ��ųʸ��� ��ȯ
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

        for _, value in ipairs(ParseCSVLine(line)) do -- �� ���� �Ľ�
            t_row[l_header[idx]] = value
            idx = idx + 1
        end

        local real_key = t_row[key]
        t_csv[real_key]= t_row

        line = file:read()
    end

    return t_csv
end

--json parsing �ʿ�
------------------------------------
-- function makeDataTxt
------------------------------------


--TEST �ʿ�
------------------------------------
-- function validataData_Dragon
------------------------------------
function validateData_Dragon(t_Data)

     for filePath, l_data in pairs(t_Data) do

        if (find(filePath, 'table_dragon') ~= nil) then

            for _, t_row in pairs(l_data) do
                checkCSVRow(t_row, 'did', g_table_dragon, filePath)
                checkCSVRow(t_row, 'base_did', g_table_dragon, filePath)
            end

        end

     end

end
--TEST �ʿ�
------------------------------------
-- function checkCSVRow
------------------------------------
 function checkCSVRow(t_row, key, table, filePath)
    local didStr = t_row[key]
    if(didStr) then
        if(find(didStr, ',') ~= nil) then
            local l_did = split(didStr, ',')
            for did in pairs(l_did) do
                checkDictHasKey(table, did, filePath)
            end
        else
            checkDictHasKey(table, didStr, filePath)
        end
    end
 end
 --TEST �ʿ�
------------------------------------
-- function validateData_Stage`
-- @brief �巡�� ���̺� ���� ���̺� did ����
------------------------------------
function validateData_Stage(table_data) 
    for filePath, t_data in ipairs(table_data) do
        if ((find(filePath, 'stage_') ~= nil) and endswith(filePath, '.txt')) then
            checkStageScript(t_data, filePath)
        end
    end
end

--Test    �ʿ�
------------------------------------
-- function checkStageScript
------------------------------------
function checkStageScript(t_data, filePath)
    for _, t_wave in pairs(t_data['wave']) do
        for _, summonInfo in pairs(t_wave['wave']) do
             for _, script in pairs(summon_info) do
                local monster_id = split(script, ';')[0]
                if (find(monster_id, 'RandomDragon') == nil) then
                    checkDictHasKey(g_table_monster, monster_id, filePath) 
                end
             end
        end
    end
end
--TEST �ʿ�
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
    checkSkillTable(t_dragon_skill, g_table_dragon, l_skill_column)

    -- 2. monster
    checkSkillTable(t_monster_skill, g_table_monster, l_skill_column)
end

--TODO
------------------------------------
-- function checkSkillTable
------------------------------------
function checkSkillTable(skillTable, charTable, l_skillColumn)
    for _, tChar in ipairs(charTable) do 
        local charName = tChar['t_name']--TODO
    end
end
------------------------------------
-- function checkDictHasKey
-- @brief Ư�� ������ Ư�� Ű���� �����ϴ��� �˻��Ͽ� ������ ���� ���̺� ��Ͽ� ����Ѵ�.
------------------------------------
function checkDictHasKey(table, key, filePath)
    local key = strip(key)
    if (not table.get(key)) then
        local tempDict = {}
        tempDict['path'] = string.gsub(filePath, g_dataRoot, "")
        tempDict['info'] = key
        table.insert(g_t_invalidData, tempDict)
    end
end

------------------------------------------------------------------------
-- 3. ���� ��� ����Ʈ ( ��� + ���� )

--TODO
------------------------------------
-- function makeInvalidStr
-- @brief ������ �ִ� ���̺� ����� ���ڰ� ��µ� �ؽ�Ʈ�� �����.
------------------------------------
function makeInvalidStr()
    table_str = "@hkkang @wjung @jykim\n"
    table_str = table_str.."##�߸��� ������ ���##\n"
    for _, tempDict in ipairs(g_t_invalidData) do
        text = tempDict['path']..'\t'..tempDict['info']
        
    end  
end

--TEST�ʿ�
------------------------------------
-- function sendInvalidTableListBySlack
-- @brief �������� ���
------------------------------------
function sendInvalidTableListBySlack()
    local attachemntsDict = {}
    attachmentsDict['title'] = '[DV_BOT] TABLE VALIDATION'
    attachmentsDict['title_link'] = 'https://drive.google.com/open?id=0Bzybp2XzPNq0flpmdEstcDJYOTdPbXFWcFpkWktZY0NxdnpyUHF1VENFX29jbnJLSGRvcFE'
    attachmentsDict['fallback'] = "[DV_BOT] ���̺� ���� �߰� !!"
    attachmentsDict['text'] = makeInvalidStr()
    print (makeInvalidStr())

    --attachments_dict['pretext'] = "pretext - python slack api TEST"
    --attachments_dict['mrkdwn_in'] = ["text", "pretext"]  # ��ũ�ٿ��� �����ų ���ڵ��� �����մϴ�.

    -- jykim : U1QEY8938
    -- wjung : U386T6HD5
    -- hkkang : U1QPKAS2F


    local token = 'xoxp-4049551466-60623372247-67908400245-53f29cbca3'
    local slack = Slack.GetTokenInstance(token)

    local attachments = attachmentsDict

    slack:Message('C1RUT070B', '�����', nil, attachments, false)
end
