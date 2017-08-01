
require 'LuaTool'
require 'LuaGlobal'
require 'TableLoadingGuide'
require 'TableDragon'

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
    cclog('##### AssetMaker:run')

    local stopwatch = Stopwatch()
    stopwatch:start()

    -- diretory를 루트로 이동
    lfs.chdir('..')
    cclog(lfs.currentdir())

    self:removeFor100MB()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function removeFor100MB
-- @brief 100mb 이하로 만들기 위해 패치 받는 동안은 없어도 되는 것들 삭제
-------------------------------------
function AssetRemover_100MB:removeFor100MB()
    cclog('##### AssetRemover_100MB:removeFor100MB')

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
-- function makeDragonTableForOpertaion
-- @brief 패치 시 필요한 드래곤 리소스 추출
-------------------------------------
function AssetRemover_100MB:makeDragonTableForOpertaion()
    cclog('##### AssetRemover_100MB:makeDragonTableForOpertaion')
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
function AssetRemover_100MB:removeNotUseDragonRes()
    cclog('##### AssetRemover_100MB:removeNotUseDragonRes')
    
    local t_loading_dragon_res = self:makeDragonTableForOpertaion()
    ccdump(t_loading_dragon_res)

    local dragon_res_path = TARGET_PATH .. '\\res\\character\\dragon'

    for file in lfs.dir(dragon_res_path) do
        if (file ~= ".") and (file ~= "..") then
            if not (t_loading_dragon_res[file]) then
                -- 디렉토리 삭제
                RemoveDirectory(dragon_res_path .. '\\' .. file)
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