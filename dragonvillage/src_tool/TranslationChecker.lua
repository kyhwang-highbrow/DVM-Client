require 'LuaStandAlone'

-------------------------------------
-- class TranslationChecker
-------------------------------------
TranslationChecker = class({
    
    })

-------------------------------------
-- function init
-------------------------------------
function TranslationChecker:init()
end

-------------------------------------
-- function run
-------------------------------------
function TranslationChecker:run(target_path)
    print("languages load check begin!!")
    local lfs = require("lfs")
    local folderPath = '../translate'
    local file_cnt = 0

    for file in lfs.dir(folderPath) do
        if file ~= "." and file ~= ".." then
            -- 파일 경로 생성
            local filePath = folderPath .. "/" .. file
            -- 파일인지 확인            
            local attr = lfs.attributes(filePath)
            if attr.mode == "file" then
                if string.find(file,'checkLua') == nil then
                    -- 파일이면 require
                    local moduleName = file:gsub("%.lua$", "") -- 파일 확장자 제거               
                    --require(folderPath .. '/' .. moduleName)
                    local success, module = pcall(require, folderPath .. '/' .. moduleName)
                    if not success then
                        cclog(module)
                        print(string.format('## {%s} language require error !!', moduleName))
                        os.exit(101)
                    end

                    file_cnt = file_cnt + 1
                end
            end
        end
    end

    print(string.format('## {%d} language files load check perfect !!', file_cnt))
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    TranslationChecker():run()
end