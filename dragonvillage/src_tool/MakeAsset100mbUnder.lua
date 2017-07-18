require 'LuaTool'
require 'TableLoadingGuide'

TARGET_PATH = 'proj.android_latest\\assets'
-------------------------------------
-- class MakeAsset100mbUnder
-------------------------------------
MakeAsset100mbUnder = class({
                     
    })

-------------------------------------
-- function init
-------------------------------------
function MakeAsset100mbUnder:init()
    cclog('##### MakeAsset100mbUnder:init')
    -- diretory를 루트로 이동
    lfs.chdir('..')
    cclog(lfs.currentdir())

    -- 기존 assets 삭제
    self:deleteAssets()
    -- assets 만듬
    self:makeAssets()
    -- 암호화
    self:encryptSrcAndData()
    -- 전부 복사
    self:copyAll()
    -- 구동을 위해 필요한 데이터 수집
    --self:makeListForOpertaion()
    -- 100MB만 남기고 지움
    self:removeFor100MB()
    -- 암호화 파일을 지운다.
    self:deleteEncrypt()
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
    local curr_path = lfs.currentdir()
    local ecncrypt_path_src = 'python/xor.py'
    local ecncrypt_path_data = 'python/xor_data.py'
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

    -- file
    --os.execute('robocopy' .. ' ' .. config .. ' ' .. new_path)
    --pl_copy('../entry_main.json', TARGET_PATH)
    --pl_copy('../entry_patch.json', TARGET_PATH)
    --pl_copy('../fixed_constant.lua', TARGET_PATH)

    -- directory
    os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'ps', TARGET_PATH, 'ps'))
    os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'data_dat', TARGET_PATH, 'data_dat'))
    os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'res', TARGET_PATH, 'res'))
    --os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'sound', new_path, 'sound'))
    --os.execute(string.format('robocopy "%s" "%s\\%s" /E', 'translate', new_path, 'translates'))
end

-------------------------------------
-- function makeListForOpertaion
-------------------------------------
function MakeAsset100mbUnder:makeListForOpertaion()
    cclog('##### MakeAsset100mbUnder:makeListForOpertaion')
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


MakeAsset100mbUnder()