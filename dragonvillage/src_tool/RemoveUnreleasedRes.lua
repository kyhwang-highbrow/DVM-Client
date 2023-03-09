require 'LuaStandAlone'

require 'TableDragon'
require 'TableDragonSkin'

-------------------------------------
-- class RemoveUnreleasedRes
-------------------------------------
RemoveUnreleasedRes = class({
    m_mapDragonSkinAttrListMap = '', -- did 마다 존재하는 속성 리스트
})

-------------------------------------
-- function init
-------------------------------------
function RemoveUnreleasedRes:init()
    
end

-------------------------------------
-- function makeSkinAttrListMap
-- @brief   스킨(=드래곤 코스튬)의 경우 다른 속성으로 접근할 수 있기 때문에 
--          스킨의 데이터도 추가로 읽어서 속성이 존재하면 예외 처리
-------------------------------------
function RemoveUnreleasedRes:makeSkinAttrListMap()
    local t_skin_inst = TableDragonSkin()
    local t_skin = t_skin_inst.m_orgTable
    local map = {}
    for _, t_data in pairs(t_skin) do
        local did = t_data['did']
        local attr = t_data['attribute']

        if map[did] == nil then
            map[did] = {}
        end

        table.insert(map[did], attr)
    end

    self.m_mapDragonSkinAttrListMap = map
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

    -- attr 리스트 맵 생성
    self:makeSkinAttrListMap()

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

    -- 파일 이름으로 드래곤 키네임과 속성 파싱
    local dragon_type, attr, _ = string.match(file_name, '(.+)_(%a+)_(%d+)')
    local skin_attr_map = self.m_mapDragonSkinAttrListMap
	
	-- 속성 베리가 합쳐진 경우(애니메이션 파일을 공통으로 사용하는 경우)
	if (attr == 'all') then
		local dragon_res_path = 'res\\character\\dragon\\' .. file_name .. '\\'
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
            local did = t_dragon['did']
            local l_skin_attr = skin_attr_map[did]

            -- 스킨의 데이터도 추가로 읽어서 속성이 존재하면 예외 처리
            if l_skin_attr ~= nil then
                if table.find(l_skin_attr, attr) ~= nil then
                    return true
                end
            end
            
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