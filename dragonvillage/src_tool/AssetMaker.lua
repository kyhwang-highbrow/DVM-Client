require 'LuaTool'
require 'LuaGlobal'

-------------------------------------
-- class AssetMaker
-------------------------------------
AssetMaker = class({     
    })

-------------------------------------
-- function init
-------------------------------------
function AssetMaker:init()
end

-------------------------------------
-- function run
-------------------------------------
function AssetMaker:run()
    cclog('##### AssetMaker:run')

    local stopwatch = Stopwatch()
    stopwatch:start()

    -- diretory를 루트로 이동
    lfs.chdir('..')
    cclog(lfs.currentdir())

    -- 기존 assets 삭제
    --self:deleteAssets()

    -- assets dirtory 만듬
    self:makeAssets()

    -- 암호화
    self:encryptSrcAndData()
    
    -- 전부 복사
    self:copyAll()

    -- 암호화 파일을 지운다.
    self:deleteEncrypt()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function deleteAssets
-------------------------------------
function AssetMaker:deleteAssets()
    cclog('##### AssetMaker:deleteAssets')

    RemoveDirectory(TARGET_PATH .. '\\data_dat')
    RemoveDirectory(TARGET_PATH .. '\\ps')
    RemoveDirectory(TARGET_PATH .. '\\res')
    RemoveDirectory(TARGET_PATH .. '\\sound')
    RemoveDirectory(TARGET_PATH .. '\\translate')
end

-------------------------------------
-- function makeAssets
-------------------------------------
function AssetMaker:makeAssets()
    cclog('##### AssetMaker:makeAssets')

    lfs.mkdir(TARGET_PATH)
end

-------------------------------------
-- function encryptSrcAndData
-- @brief 암호화
-------------------------------------
function AssetMaker:encryptSrcAndData()
    cclog('##### AssetMaker:encryptSrcAndData')
    
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
function AssetMaker:copyAll()
    cclog('##### AssetMaker:copyAll')

    -- robocopy 원본경로 대상경로 [파일 ...] [옵션]

    -- directory (\E 하위 디렉토리 포함 복사)
    -- /NFL : No File List - don't log file names.
    -- /NDL : No Directory List - don't log directory names.
    local robocopy = 'robocopy "%s" "%s\\%s" /E /NFL /NDL'
    os.execute(string.format(robocopy, 'ps', TARGET_PATH, 'ps'))
    os.execute(string.format(robocopy, 'data_dat', TARGET_PATH, 'data_dat'))
    os.execute(string.format(robocopy, 'res', TARGET_PATH, 'res'))
    os.execute(string.format(robocopy, 'translate', TARGET_PATH, 'translate'))
    
    -- sound는 정리하고 추가
    --lfs.mkdir(TARGET_PATH .. '\\sound')
    os.execute(string.format(robocopy, 'sound', TARGET_PATH, 'sound'))
end

-------------------------------------
-- function mirroring
-- @brief 
-------------------------------------
function AssetMaker:mirroring()
    cclog('##### AssetMaker:mirroring')

    -- robocopy 원본경로 대상경로 [파일 ...] [옵션]

    -- directory (\E 하위 디렉토리 포함 복사)
    -- /NFL : No File List - don't log file names.
    -- /NDL : No Directory List - don't log directory names.
    local robocopy = 'robocopy "%s" "%s\\%s" /MIR /NFL /NDL'
    os.execute(string.format(robocopy, 'ps', TARGET_PATH, 'ps'))
    os.execute(string.format(robocopy, 'data_dat', TARGET_PATH, 'data_dat'))
    os.execute(string.format(robocopy, 'res', TARGET_PATH, 'res'))
    os.execute(string.format(robocopy, 'translate', TARGET_PATH, 'translate'))
    
    -- sound는 정리하고 추가
    --lfs.mkdir(TARGET_PATH .. '\\sound')
    os.execute(string.format(robocopy, 'sound', TARGET_PATH, 'sound'))
end

-------------------------------------
-- function deleteEncrypt
-- @brief 암호화 파일 삭제
-------------------------------------
function AssetMaker:deleteEncrypt()
    cclog('##### AssetMaker:deleteEncrypt')

    RemoveDirectory('ps')
    RemoveDirectory('data_dat')
end














-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    AssetMaker():run()
end