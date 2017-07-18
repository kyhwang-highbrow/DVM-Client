require 'LuaTool'

require 'TableLoadingGuide'
require 'TableDragon'
require 'socket.core'
require 'StopWatch'

-------------------------------------
-- global variable
-------------------------------------
TARGET_PATH = 'proj.android_latest\\assets'
FRAME_PATH = 'proj.android\\assets'

-------------------------------------
-- class MakeAsset100mbUnder
-------------------------------------
MakeAsset100mbUnder = class({     
    })

-------------------------------------
-- function init
-------------------------------------
function MakeAsset100mbUnder:init()
end

-------------------------------------
-- function init
-------------------------------------
function MakeAsset100mbUnder:run()
    cclog('##### MakeAsset100mbUnder:run')

    local stopwatch = Stopwatch()
    stopwatch:start()

    -- diretory를 루트로 이동
    lfs.chdir('..')
    cclog(lfs.currentdir())

    -- 기존 assets 삭제
    self:deleteAssets()
    -- assets dirtory 만듬
    self:makeAssets()
    -- 암호화
    self:encryptSrcAndData()
    -- 전부 복사
    self:copyAll()
    -- 100MB만 남기고 지움
    self:removeFor100MB()
    -- 암호화 파일을 지운다.
    self:deleteEncrypt()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function deleteAssets
-------------------------------------
function MakeAsset100mbUnder:deleteAssets()
    cclog('##### MakeAsset100mbUnder:deleteAssets')

    RemoveDirectory(TARGET_PATH)
end

-------------------------------------
-- function makeAssets
-------------------------------------
function MakeAsset100mbUnder:makeAssets()
    cclog('##### MakeAsset100mbUnder:makeAssets')

    local b = lfs.mkdir(TARGET_PATH)
    cclog(b, str)
end

-------------------------------------
-- function encryptSrcAndData
-- @brief 암호화
-------------------------------------
function MakeAsset100mbUnder:encryptSrcAndData()
    cclog('##### MakeAsset100mbUnder:encryptSrcAndData')
    
    local ecncrypt_path_src = 'python\\xor.py'
    local ecncrypt_path_data = 'python\\xor_data.py'
    
    -- src 암호화
    os.execute('python ' .. ecncrypt_path_src)
    -- data 암호화
    os.execute('python ' .. ecncrypt_path_data)
end

-------------------------------------
-- function copyAll
-- @brief 전부 혹은 필요한 만큼만 카피
-------------------------------------
function MakeAsset100mbUnder:copyAll()
    cclog('##### MakeAsset100mbUnder:copyAll')

    -- robocopy 원본경로 대상경로 [파일 ...] [옵션]

    -- root의 지정한 파일들을 복사
    os.execute(string.format('robocopy "." "%s" "%s"', TARGET_PATH, 'config.json entry_main.json entry_patch.json fixed_constant.lua'))

    -- proj.android 에서 cocos용 lua파일들 복사
    os.execute(string.format('robocopy "%s" "%s"', FRAME_PATH, TARGET_PATH))

    -- directory (\E 하위 디렉토리 포함 복사)
    os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'ps', TARGET_PATH, 'ps'))
    os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'data_dat', TARGET_PATH, 'data_dat'))
    os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'res', TARGET_PATH, 'res'))
    os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'translate', TARGET_PATH, 'translate'))
    
    -- sound는 정리하고 추가
    lfs.mkdir(TARGET_PATH .. '\\sound')
    --os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'sound', TARGET_PATH, 'sound'))
end

-------------------------------------
-- function removeFor100MB
-- @brief 100mb 이하로 만들기 위해 패치 받는 동안은 없어도 되는 것들 삭제
-------------------------------------
function MakeAsset100mbUnder:removeFor100MB()
    cclog('##### MakeAsset100mbUnder:removeFor100MB')

    RemoveDirectory(TARGET_PATH .. '\\res\\bg')
    RemoveDirectory(TARGET_PATH .. '\\res\\effect')
    RemoveDirectory(TARGET_PATH .. '\\res\\lobby')
    RemoveDirectory(TARGET_PATH .. '\\res\\scene')
    RemoveDirectory(TARGET_PATH .. '\\res\\missile')
    RemoveDirectory(TARGET_PATH .. '\\res\\character\\tamer')
    RemoveDirectory(TARGET_PATH .. '\\res\\character\\npc')
    RemoveDirectory(TARGET_PATH .. '\\res\\character\\monster')
    self:removeNotUseDragonRes()
end

-------------------------------------
-- function deleteEncrypt
-- @brief 암호화 파일 삭제
-------------------------------------
function MakeAsset100mbUnder:deleteEncrypt()
    cclog('##### MakeAsset100mbUnder:deleteEncrypt')

    RemoveDirectory('ps')
    RemoveDirectory('data_dat')
end



-------------------------------------
-- function makeDragonTableForOpertaion
-- @brief 패치 시 필요한 드래곤 리소스 추출
-------------------------------------
function MakeAsset100mbUnder:makeDragonTableForOpertaion()
    cclog('##### MakeAsset100mbUnder:makeDragonTableForOpertaion')
    local l_loading_dragon = {}
    
    -- loading table에서 필요한 드래곤 id 가져온다.
    local table_loading = TableLoadingGuide()
    for i, t_loading in pairs(table_loading.m_orgTable) do
        if (t_loading['did'] ~= '') then
            table.insert(l_loading_dragon, t_loading['did'])
        end
    end

    -- 해당 리소스 네임 추출하여 저장
    local t_res = {}
    local table_dragon = TableDragon()
    local t_dragon, res, dragon_name, attr, evolution, complete_res
    for i, did in pairs(l_loading_dragon) do
        t_dragon = table_dragon:get(did)
        dragon_name = t_dragon['type']
        attr = t_dragon['attr']
        evolution = 3

        res = string.format('%s_%s_%02d', dragon_name, attr, evolution)
        t_res[res] = true
    end

    return t_res
end

-------------------------------------
-- function removeNotUseDragonRes
-- @brief 패치 시 필요없는 드래곤 리소스 삭제
-------------------------------------
function MakeAsset100mbUnder:removeNotUseDragonRes()
    local t_loading_dragon_res = self:makeDragonTableForOpertaion()
    
    print('## NOT REMOVE DRAGON RES')
    ccdump(t_loading_dragon_res)

    local dragon_res_path = TARGET_PATH .. '\\res\\character\\dragon'

    for file in lfs.dir(dragon_res_path) do
        if (file ~= ".") and (file ~= "..") then
            if not (t_loading_dragon_res[file]) then
                -- 디렉토리 삭제
                RemoveDirectory(dragon_res_path .. '\\' .. file)
                print('remove file', file)
            end
        end
    end
end



-- lua class 파일 자체에서 실행되도록 함
if (arg[1] == 'run') then
    MakeAsset100mbUnder():run()
end