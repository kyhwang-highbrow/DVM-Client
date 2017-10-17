require 'LuaStandAlone'

-------------------------------------
-- class AssetRemover_100MB
-------------------------------------
AssetRemover_100MB = class({     
    })

-------------------------------------
-- function init
-------------------------------------
function AssetRemover_100MB:init()
end

-------------------------------------
-- function run
-------------------------------------
function AssetRemover_100MB:run()
    cclog('## AssetRemover_100MB:run')

    local stopwatch = Stopwatch()
    stopwatch:start()

    -- diretory를 루트로 이동
    util.changeDir('..')

    -- 삭제
    self:removeFor100MB()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function removeFor100MB
-- @brief 100mb 이하로 만들기 위해 패치 받는 동안은 없어도 되는 것들 삭제
-------------------------------------
function AssetRemover_100MB:removeFor100MB()
    cclog('## AssetRemover_100MB:removeFor100MB')

    util.removeDirectory(TARGET_PATH .. '\\sound', 'leave')

    util.removeDirectory(TARGET_PATH .. '\\res\\bg')
    util.removeDirectory(TARGET_PATH .. '\\res\\effect')
    util.removeDirectory(TARGET_PATH .. '\\res\\lobby')
    util.removeDirectory(TARGET_PATH .. '\\res\\scene')
    util.removeDirectory(TARGET_PATH .. '\\res\\missile')
    util.removeDirectory(TARGET_PATH .. '\\res\\character\\tamer')
    util.removeDirectory(TARGET_PATH .. '\\res\\character\\npc')
    util.removeDirectory(TARGET_PATH .. '\\res\\character\\monster')
    self:removeNotUseDragonRes()
end



-------------------------------------
-- function removeNotUseDragonRes
-- @brief 패치 시 필요없는 드래곤 리소스 삭제
-------------------------------------
function AssetRemover_100MB:removeNotUseDragonRes()
    cclog('## AssetRemover_100MB:removeNotUseDragonRes')
    
    local t_loading_dragon_res = util.makeGuideDragonTable()

    local dragon_res_path = TARGET_PATH .. '\\res\\character\\dragon'

    for file in lfs.dir(dragon_res_path) do
        if (file ~= ".") and (file ~= "..") then
            if not (t_loading_dragon_res[file]) then
                -- 디렉토리 삭제
                util.removeDirectory(dragon_res_path .. '\\' .. file)
            end
        end
    end
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    AssetRemover_100MB():run()
end