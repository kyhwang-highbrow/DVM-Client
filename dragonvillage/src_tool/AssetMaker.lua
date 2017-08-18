require 'LuaStandAlone'

-------------------------------------
-- class AssetMaker
-------------------------------------
AssetMaker = class({   
        targetPath = 'string',  
    })

-------------------------------------
-- function init
-------------------------------------
function AssetMaker:init()
end

-------------------------------------
-- function run
-------------------------------------
function AssetMaker:run(target_path)
    cclog('## AssetMaker:run')
    cclog('## AssetMAker - target path : ' .. target_path)
    
    self.targetPath = target_path
    
    local stopwatch = Stopwatch()
    stopwatch:start()

    -- diretory를 루트로 이동
    util.changeDir('..')

    -- assets dirtory 만듬
    util.makeDirectory(self.targetPath)

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
-- function encryptSrcAndData
-- @brief 암호화
-------------------------------------
function AssetMaker:encryptSrcAndData()
    cclog('## AssetMaker:encryptSrcAndData')
    
    -- 실행할 파일 경로
    local ecncrypt_path_src = 'python\\xor.py'
    local ecncrypt_path_data = 'python\\xor_data.py'
    
    -- 암호화
    os.execute('python ' .. ecncrypt_path_src)
    os.execute('python ' .. ecncrypt_path_data)
end

-------------------------------------
-- function mirroring
-- @brief 
-------------------------------------
function AssetMaker:mirroring()
    cclog('## AssetMaker:mirroring')

    self:mirror('ps')
    self:mirror('data_dat')
    self:mirror('res')
    self:mirror('translate')
    self:mirror('sound')
end

-------------------------------------
-- function mirror
-- @brief 
-------------------------------------
function AssetMaker:mirror(dir)
    cclog('## AssetMaker:mirror : ' .. dir)
    util.mirrorDirectory(dir, string.format('%s\\%s', self.targetPath, dir))
end

-------------------------------------
-- function deleteEncrypt
-- @brief 암호화 파일 삭제
-------------------------------------
function AssetMaker:deleteEncrypt()
    cclog('## AssetMaker:deleteEncrypt')

    util.removeDirectory('ps')
    util.removeDirectory('data_dat')
end


-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    if (arg[2] == 'full') then
        AssetMaker():run(ASSETS_PATH_FULL)
    else
        AssetMaker():run(ASSETS_PATH)
    end
end