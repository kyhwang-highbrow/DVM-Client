require 'LuaStandAlone'

-------------------------------------
-- class AssetMaker_ApkExpansion
-------------------------------------
AssetMaker_ApkExpansion = class({     
    })

-------------------------------------
-- function init
-------------------------------------
function AssetMaker_ApkExpansion:init()
end

-------------------------------------
-- function run
-------------------------------------
function AssetMaker_ApkExpansion:run()
    cclog('## AssetMaker_ApkExpansion:run')

    local stopwatch = Stopwatch()
    stopwatch:start()

    -- diretory를 루트로 이동
    util.changeDir('..')
 
    -- 일단 폴더 삭제
    util.removeDirectory(ASSETS_PATH_EXPANSION)

    -- expansion 디렉토리 생성
    util.makeDirectory(ASSETS_PATH_EXPANSION)

    -- 이동
    self:moveToExpansion()

    -- 압축
	-- android app bundle & play asset delivery 를 사용하기 때문에 obb 압축 안함
    -- self:compress()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function moveToExpansion
-- @brief 100mb 이하로 만들기 위해 패치 받는 동안은 없어도 되는 것들 이동 (obb로 만든다)
-------------------------------------
function AssetMaker_ApkExpansion:moveToExpansion()
    cclog('## AssetMaker_ApkExpansion:moveToExpansion')

    -- 파일 이동
    self:move('\\sound')
    self:move('\\res\\bg')
    self:move('\\res\\effect')
    self:move('\\res\\item')
    self:move('\\res\\indicator')
    self:move('\\res\\clan_lobby')
    self:move('\\res\\lobby')
    self:move('\\res\\scene')
    self:move('\\res\\missile')
    self:move('\\res\\character')
    self:move('\\res\\ui\\a2d')
    self:move('\\res\\ui\\event')
    self:move('\\res\\ui\\package')
    self:move('\\res\\ui\\icons')

    self:checkAssetsUnder100MB()
end

-------------------------------------
-- function move
-- @brief assets 경로에서 akp_expansion 경로로 이동
-------------------------------------
function AssetMaker_ApkExpansion:move(dir)
    cclog('## AssetMaker_ApkExpansion:move - ' .. dir)
    util.moveDirectory(ASSETS_PATH .. dir, ASSETS_PATH_EXPANSION .. dir)
end

-------------------------------------
-- function checkAssetsUnder100MB
-- @brief asstes 폴더가 기준 사이즈에 부합한지 확인한다.
-------------------------------------
function AssetMaker_ApkExpansion:checkAssetsUnder100MB()
    cclog('## AssetMaker_ApkExpansion:checkAssetsUnder100MB')

    local assets_size = util.getDirectorySize(ASSETS_PATH)
    cclog('## ../assets/100mb directory size : ' .. string.format('%.2fMB', assets_size/MB_TO_BYTE))

    -- 기준 사이즈에 부합한지 비교한다.
    if (assets_size > UNDER_100MB) then
        cclog('\n\n')
        cclog('## ASSETS OVER 100MB !!')
        cclog('\n\n')
        error('check AssetMaker_ApkExpansion:moveToExpansion()')
    end
end

-------------------------------------
-- function compress
-- @brief expansion 압축 파일 생성
-------------------------------------
function AssetMaker_ApkExpansion:compress()
    cclog('## AssetMaker_ApkExpansion:compress')

    util.changeDir(ASSETS_PATH_EXPANSION)

    local version_code = 00
    local package_name = 'com.perplelab.dragonvillagem.kr'
    local obb_path = string.format(OBB_FORMAT, version_code, package_name)

    -- -r : recurse into directories
    -- -n : don't compress these suffixes
    -- -q : quiet operation
    os.execute(string.format('..\\..\\..\\..\\res\\tools\\zip\\zip.exe -rqn ".mp3;.ogg" %s *', obb_path))
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    AssetMaker_ApkExpansion():run()
end