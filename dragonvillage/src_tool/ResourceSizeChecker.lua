require 'LuaStandAlone'
require 'pl'
require 'math'
------------------------------------
-- class ResourceSizeChecker
------------------------------------
ResourceSizeChecker = class({
    m_root = 'string',
    m_str = 'string',

    m_table_dragon = 'table',
    m_table_dragon_type_rarity = 'table',

    })

------------------------------------
-- function init
------------------------------------
function ResourceSizeChecker:init()
    self.m_root = ''
    self.m_str = ''

    self.m_table_dragon = TABLE:get('dragon')
    self.m_table_dragon_type_rarity = {}
end

------------------------------------
-- function checkData
------------------------------------
function ResourceSizeChecker:checkData(root)
    self.m_root = root
    self.m_str = 'evolution,rarity,count,avg_size\n'

    self:makeNameRarityDict()

    local t_ret = {}
    for i = 1, 3 do
        table.insert(t_ret, {['rarity'] = 'common', ['evolution'] = i, ['count'] = 0, ['avg_size'] = 0})
        table.insert(t_ret, {['rarity'] = 'rare', ['evolution'] = i, ['count'] = 0, ['avg_size'] = 0})
        table.insert(t_ret, {['rarity'] = 'hero', ['evolution'] = i, ['count'] = 0, ['avg_size'] = 0})
        table.insert(t_ret, {['rarity'] = 'legend', ['evolution'] = i, ['count'] = 0, ['avg_size'] = 0})
    end

    local dragon_root = self.m_root .. '\\res\\character\\dragon'
    dragon_root = pl.path.abspath(dragon_root, 'D:\\')

    local file_count = 0
    local total_size = 0

    -- file size check
    for _, dir_name in ipairs(pl.dir.getdirectories(dragon_root)) do
        local size = 0
        
        
        for _, v in ipairs(pl.dir.getallfiles(dir_name)) do

            local f = assert(io.open(v, 'r'))
            size = size + f:seek('end')
            io.close(f)
        end
        if (size ~= 0) then
            file_count = file_count + 1
            total_size = total_size + size
            local idx = self:makeIdx(self:getDragonRarity(dir_name), self:getEvolution(dir_name))
            if (idx) then
                t_ret[idx]['avg_size'] = t_ret[idx]['avg_size'] + size
                t_ret[idx]['count'] = t_ret[idx]['count'] + 1
            end
        end
    end


    for _, v in ipairs(t_ret) do
        v['avg_size'] = tostring(math.floor(v['avg_size'] / v['count'] / 1024 / 1024 / .001) * .001) .. ' MB'
    end

    total_size = total_size / 1024 / 1024
    avg = math.floor(total_size / file_count / .001) * .001
    print('total ' .. file_count .. ' dragon res')
    print('total ' .. total_size .. 'MB')
    print('avg   ' .. avg .. 'MB/dragon')
    

    for _, v in ipairs(t_ret) do
        self.m_str = self.m_str .. v['evolution'] .. ',' .. v['rarity'] .. ',' .. v['count'] .. ',' .. v['avg_size'] .. '\n'
    end
    self:makeOutputFile()

end

------------------------------------
-- function getDragonRarity
------------------------------------
function ResourceSizeChecker:getDragonRarity(dir_name) 
    local dragon_name = pl.stringx.split(dir_name, '\\')
    dragon_name = dragon_name[#dragon_name]

    dragon_name = dragon_name:sub(1, dragon_name:find('_') - 1)
    return self.m_table_dragon_type_rarity[dragon_name]
end

------------------------------------
-- function makeNameRarityDict
------------------------------------
function ResourceSizeChecker:makeNameRarityDict()
    for k, v in pairs(self.m_table_dragon) do
        if (self.m_table_dragon_type_rarity[v['type']]  == nil) then
            self.m_table_dragon_type_rarity[v['type']] = v['rarity']
        end
    end
end

------------------------------------
-- function getEvolution
------------------------------------
function ResourceSizeChecker:getEvolution(dir_name)
    return dir_name:sub(-2, -1)
end

------------------------------------
-- function makeIdx
------------------------------------
function ResourceSizeChecker:makeIdx(rarity, evolution)
    if (not tonumber(evolution)) then return end
    local base = 0
    local add = (tonumber(evolution) - 1) * 4
    if ( rarity == 'common' ) then
        base = 1
    elseif (rarity == 'rare') then
        base = 2
    elseif (rarity == 'hero') then
        base = 3
    elseif (rarity == 'legend') then
        base = 4
    else 
        return nil
    end

    return base + add
end

------------------------------------
-- function makeOutputFile
------------------------------------
function ResourceSizeChecker:makeOutputFile()
    local str = '..\\bat\\output\\FileSizeReport.csv'
    if (pl.file.write(str, self.m_str)) then
        print('\n' .. str .. ' CREATED\n\n\n\n')
    end
end


if (arg[1] == 'run') then
    print('Drag \'res\' folder here -> ')
    local root = io.read()
    ResourceSizeChecker():checkData(root)
end

