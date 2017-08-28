require 'LuaStandAlone'

require 'TableLoadingGuide'
require 'TableDragon'

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
    self:compress()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function moveToExpansion
-- @brief 100mb 이하로 만들기 위해 패치 받는 동안은 없어도 되는 것들 삭제
-------------------------------------
function AssetMaker_ApkExpansion:moveToExpansion()
    cclog('## AssetMaker_ApkExpansion:moveToExpansion')

    -- 파일 이동
    self:move('\\sound')
    self:move('\\res\\bg')
    self:move('\\res\\effect')
    self:move('\\res\\lobby')
    self:move('\\res\\scene')
    self:move('\\res\\missile')
    self:move('\\res\\character\\tamer')
    self:move('\\res\\character\\npc')
    self:move('\\res\\character\\monster')
    self:move('\\res\\ui\\event')
    self:move('\\res\\ui\\package')
    self:moveDragonRes()
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
-- function moveDragonRes
-- @brief 패치 시 필요한 드래곤은 남기고 나머지는 이동
-------------------------------------
function AssetMaker_ApkExpansion:moveDragonRes()
    cclog('## AssetMaker_ApkExpansion:moveNotUseDragonRes')
    
    -- 패치에서 사용하는 드래곤 가져옴
    local t_loading_dragon_res = self:makeGuideDragonTable()

    -- 리소스 경로
    local dragon_path = '\\res\\character\\dragon'

    -- robocopy 커맨드에 넣기 위해 제외할 폴더명 문자열로 변경
    local exception_list_str = ''
    for res, _ in pairs(t_loading_dragon_res) do
        exception_list_str = string.format('%s %s', exception_list_str, res)
    end

    -- robocopy move
    os.execute(string.format('robocopy "%s" "%s" /MOVE /E /NFL /NDL /NJH /NJS /XD .svn %s', ASSETS_PATH .. dragon_path, ASSETS_PATH_EXPANSION .. dragon_path, exception_list_str))
end


-------------------------------------
-- function makeGuideDragonTable
-- @brief 패치 시 필요한 드래곤 리소스 추출
-------------------------------------
function AssetMaker_ApkExpansion:makeGuideDragonTable()
    cclog('## AssetMaker_ApkExpansion:makeGuideDragonTable')
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
-- function checkAssetsUnder100MB
-- @brief asstes 폴더가 기준 사이즈에 부합한지 확인한다.
-------------------------------------
function AssetMaker_ApkExpansion:checkAssetsUnder100MB()
    cclog('## AssetMaker_ApkExpansion:checkAssetsUnder100MB')

    local assets_size = util.getDirectorySize(ASSETS_PATH)
    cclog('## ../assets/100mb directory size : ' .. string.format('%.2fMB', assets_size/MB_TO_BYTE))

    -- 기준 사이즈에 부합한지 비교한다.
    if (assets_size > UNDER_100MB) then
        error('## ASSETS OVER 100MB !!')
    end
end

-------------------------------------
-- function compress
-- @brief expansion 압축 파일 생성
-------------------------------------
function AssetMaker_ApkExpansion:compress()
    cclog('## AssetMaker_ApkExpansion:compress')

    util.changeDir(ASSETS_PATH_EXPANSION)

    local version_code = 11
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