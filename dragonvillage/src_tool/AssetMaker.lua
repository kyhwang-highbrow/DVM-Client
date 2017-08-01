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

    -- assets dirtory 만듬
    self:makeAssets()

    -- 암호화
    self:encryptSrcAndData()
    
    -- mirroring
    self:mirroring()

    -- 암호화 파일을 지운다.
    self:deleteEncrypt()

    stopwatch:stop()
    stopwatch:print()
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
-- function mirroring
-- @brief 
-------------------------------------
function AssetMaker:mirroring()
    cclog('##### AssetMaker:mirroring')

    MirrorDirectory('ps', string.format('%s\\%s', TARGET_PATH, 'ps'))
    MirrorDirectory('data_dat', string.format('%s\\%s', TARGET_PATH, 'data_dat'))
    MirrorDirectory('res', string.format('%s\\%s', TARGET_PATH, 'res'))
    MirrorDirectory('translate', string.format('%s\\%s', TARGET_PATH, 'translate'))
    MirrorDirectory('sound', string.format('%s\\%s', TARGET_PATH, 'sound'))
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