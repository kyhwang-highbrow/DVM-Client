require 'LuaStandAlone'

require 'TableDragon'

-------------------------------------
-- class RemoveUnreleasedRes
-------------------------------------
RemoveUnreleasedRes = class({     
    })

-------------------------------------
-- function init
-------------------------------------
function RemoveUnreleasedRes:init()
end

-------------------------------------
-- function run
-------------------------------------
function RemoveUnreleasedRes:run()
    cclog('## RemoveUnreleasedRes:run')

    local stopwatch = Stopwatch()
    stopwatch:start()

    -- diretory를 루트로 이동
    util.changeDir('..')

    -- 삭제
    self:removeDragonRes()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function removeDragonRes
-- @brief 출시 안 한 드래곤 리소스 삭제
-------------------------------------
function RemoveUnreleasedRes:removeDragonRes()
    cclog('## RemoveUnreleasedRes:removeDragonRes')
    
    local dragon_res_path = 'res\\character\\dragon'
    local table_dragon = TableDragon()

    
    for file in lfs.dir(dragon_res_path) do
		if (file ~= ".") and (file ~= "..") then
            if not (self:findTargetDragon(table_dragon, file)) then
                -- 디렉토리 삭제
                util.removeDirectory(dragon_res_path .. '\\' .. file)
                cclog('delete', file)
            end
        end
    end
end

-------------------------------------
-- function findTargetDragon
-- @brief 해당 리소스의 드래곤을 찾는다
-------------------------------------
function RemoveUnreleasedRes:findTargetDragon(table_dragon, file_name)
    -- 슬라임은 통과
    if (string.find(file_name, 'slime')) then
        return true
    -- 더미 드래곤 통과
    elseif (file_name == 'developing_dragon') then
        return true
    end

    local exclude_name_list = {'instria', 'oberon', 'envy', 'deathlock'}

    -- 파일 이름으로 드래곤 타입과 속성 파싱
    local dragon_type, attr, _ = string.match(file_name, '(.+)_(%a+)_(%d+)')
	
	-- 속성 베리가 합쳐진 경우(애니메이션 파일을 공통으로 사용하는 경우)
	if (attr == 'all') then
		local dragon_res_path = 'res\\character\\dragon\\' .. file_name .. '\\'
        for _, ex_name in ipairs(exclude_name_list) do
            if string.find(file_name, ex_name) ~= nil then
                return true
            end
        end
		
		for file in lfs.dir(dragon_res_path) do
			if (file ~= ".") and (file ~= "..") then
				if (not self:findTargetDragon(table_dragon, file)) then
					-- 디렉토리 삭제
					util.removeDirectory(dragon_res_path .. '\\' .. file)
					cclog('delete', file)
				end
			end
		end
		
		return true
	else
		local l_dragon_list = table_dragon:filterList('type', dragon_type)
		for i, t_dragon in ipairs(l_dragon_list) do
			if (t_dragon['attr'] == attr) then
				return (t_dragon['test'] ~= 0)
			end
		end
	end
	
    return false
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    RemoveUnreleasedRes():run()
end