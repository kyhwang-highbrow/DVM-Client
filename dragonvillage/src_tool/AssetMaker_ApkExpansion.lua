
require 'LuaTool'
require 'LuaGlobal'

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
    self:moveForExpansion()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function moveForExpansion
-- @brief 100mb 이하로 만들기 위해 패치 받는 동안은 없어도 되는 것들 삭제
-------------------------------------
function AssetMaker_ApkExpansion:moveForExpansion()
    cclog('## AssetMaker_ApkExpansion:moveForExpansion')

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
    self:moveDragonRes()
end

-------------------------------------
-- function move
-- @brief assets 경로에서 akp_expansion 경로로 이동
-------------------------------------
function AssetMaker_ApkExpansion:move(dir)
    util.moveDirectory(ASSETS_PATH .. dir, ASSETS_PATH_EXPANSION .. dir)
end

-------------------------------------
-- function moveDragonRes
-- @brief 패치 시 필요한 드래곤은 남기고 나머지는 이동
-------------------------------------
function AssetMaker_ApkExpansion:moveDragonRes()
    cclog('## AssetMaker_ApkExpansion:moveNotUseDragonRes')
    
    local t_loading_dragon_res = util.makeGuideDragonTable()

    local dragon_path = '\\res\\character\\dragon'

    
    -- local full_path = ASSETS_PATH .. dragon_path
    -- for file in lfs.dir(full_path) do
    --     if (file ~= ".") and (file ~= "..") then
    --         if not (t_loading_dragon_res[file]) then
    --             -- 디렉토리 이동
    --             self:move(dragon_path .. '\\' .. file)
    --         end
    --     end
    -- end

    local exception_list_str = ''
    for res, _ in pairs(t_loading_dragon_res) do
        exception_list_str = string.format('%s %s', exception_list_str, res)
    end
    os.execute(string.format('robocopy "%s" "%s" /MOVE /E /XD .svn %s', ASSETS_PATH .. dragon_path, ASSETS_PATH_EXPANSION .. dragon_path, exception_list_str))
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    AssetMaker_ApkExpansion():run()
end