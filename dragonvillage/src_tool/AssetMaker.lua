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
    self.targetPath = target_path
    
    local stopwatch = Stopwatch()
    stopwatch:start()
    
    cclog('## AssetMaker:run')
    cclog('\n-------------------------------------------')
    cclog('## Target Path : ' .. target_path)

    -- diretory를 루트로 이동
    util.changeDir('..')
    cclog('-------------------------------------------\n')

    -- assets dirtory 만듬
    util.makeDirectory(self.targetPath)

    -- 암호화
    self:encryptSrcAndData()
    
    -- mirroring
    self:mirroring()

    -- 패치 번역 파일 제거
    self:deletePatchTranslation()

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
    cclog('## AssetMaker:mirror - ' .. dir)
    util.mirrorDirectory(dir, string.format('%s\\%s', self.targetPath, dir))
end

-------------------------------------
-- function deletePatchTranslation
-- @brief 패치 번역파일이 존재하는 경우 삭제함
-------------------------------------
function AssetMaker:deletePatchTranslation()
    cclog('## AssetMaker:deletePatchTranslation')

    local function removeIfPatchTranslation(path, file)
        -- _build가 들어가지 않은 lang_ 파일 모두 삭제
        if string.find(file, 'lang_') and not string.find(file, '_build') then
            -- 영어는 예외, 빌트인
            if string.find(file, 'lang_en') == nil then
                cclog('## AssetMaker:deletePatchTranslation - ' .. string.format('%s\\%s', path, file))
                os.remove(string.format('%s\\%s', path, file))
            end
        end
    end

    util.iterateDirectory(string.format('%s\\%s', self.targetPath, 'translate'), removeIfPatchTranslation)
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