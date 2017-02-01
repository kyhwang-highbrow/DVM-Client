require 'perpleLib/StringUtils'
require 'perpleLib/csv'
require 'perpleLib/json'
require 'perpleLib/dkjson'
require 'lib/utils'

TABLE = {
}
--require 'Table_Preload'

-------------------------------------
-- table TableInfo
-------------------------------------
local TableInfo = {
        --                 테이블명,                         키,             toString여부
        user_level          = {'table_user_level',          'ulv',          false},
        dragon              = {'table_dragon',              'did',          false},
        dragon_skill        = {'table_dragon_skill',        'sid',          false},
        dragon_skill_modify = {'table_dragon_skill_modify', 'slid',         false},
        monster           = {'table_monster',               'mid',          false},
        monster_skill     = {'table_monster_skill',         'sid',          false},
        tamer             = {'table_tamer',                 'tid',          false},
        tamer_skill       = {'table_tamer_skill',           'sid',          false},
        skill_target      = {'table_skill_target',          'type',         false},
        drop              = {'table_drop',                  'stage',        false},
        stage_desc        = {'table_stage_desc',            'stage',        false},
        exp_dragon        = {'table_dragon_exp',            'lv_d',         false},
        exp_tamer         = {'table_exp_tamer',             'lv_t',         false},
        item              = {'table_item',                  'item',         false},
        fruit             = {'table_fruit',                 'fid',          false},
        friendship        = {'table_dragon_friendship',     'friendship',   false},
        friendbuff        = {'table_dragon_friendbuff',     'rarity',       false},

        item_sort_by_type = {'table_item',                  'full_type',    false},
        shop              = {'table_shop',                  'product_id',   false},
        gacha             = {'table_dragon_gacha',          'did',          false},
        first_reward      = {'table_first_reward',          'stage',        false},
        attribute         = {'table_attribute',             'attr_id',      false},
        status            = {'table_status',                'type',         false},
        status_effect     = {'table_status_effect',         'name',         false},
        formation         = {'table_formation',             'fmid',         false},

		quest			  = {'table_quest',					'qid',			false},

        -- 드래곤 관리 관련
        grade_info           = {'table_dragon_grade_info',  'grade',        false},
        dragon_evolution     = {'table_dragon_evolution',    'did',          false},
        evolution_item       = {'table_dragon_evolution_item',        'item_id',      false},
        friendship_variables = {'table_dragon_friendship_variables',  'vari',         false},
        dragon_train_info    = {'table_dragon_train_info',  'grade',        false},
        dragon_train_status  = {'table_dragon_train_status','lsid',         false},
        rune                 = {'table_rune',               'rid',          false},
        rune_grade           = {'table_rune_grade',         'grade',        false},
        rune_status          = {'table_rune_status',        'vid',          false},
        rune_naming_rule     = {'table_rune_naming_rule',   'key',          false},
        rune_exp             = {'table_rune_exp',           'rune_lv',      false},
        rune_set             = {'table_rune_set',           'set',          false},        
    }

-------------------------------------
-- function getCSVHeader
-------------------------------------
function TABLE:getCSVHeader(csv)
    local header = {}
    for i=1,#csv do
        header[i] = string.match(csv[i], '[A-Za-z%d_-]+')
    end
    return header
end

-------------------------------------
-- function loadCSVTable
-------------------------------------
function TABLE:loadCSVTable(filename, tablename, key, toString)
    local content = TABLE:loadTableFile(filename, '.csv')
    if content == nil then
        cclog('ksj failed to load table file(' .. filename .. ')')
        return
    end

    local header = {}
    local tables = {}

    for _,line in ipairs(seperate(content,'\n')) do
        local csv = {}
        local t = {}
        local v1, v2
        csv = ParseCSVLine(line)
        if _ == 1 then
            header = self:getCSVHeader(csv)
            if not key then key = header[1] end
        else
            if csv[1] == nil then break end

            -- 테이블에 nil값이 포함된 경우 예외처리
            local find_nil = false
            for i=1,#header do
                v1 = trim(tostring(csv[i]))
                v2 = string.match(v1, '%d+[.]?%d*')
                if v2 then v2 = tostring(tonumber(v2)) end
                if v1 == v2 then
                    t[header[i]] = tonumber(v2)
                else
                    t[header[i]] = string.gsub(v1, '\\n', '\n')
                end

                -- nil값 포함
                if t[header[i]] == nil then
                    find_nil = true
                    break
                end
            end

            -- nil값 포함
            if find_nil then
                break
            end

            if toString then
                tables[tostring(t[key])] = t
            else
                tables[t[key]] = t
            end

        end
    end

    TABLE[tablename] = tables
end

-------------------------------------
-- function loadTableFile
-------------------------------------
function TABLE:loadTableFile(filename, extension)
    local content

    -- 윈도우가 아닐 경우 data_dat에서 테이블 로드
    if isWin32() == false then
        local dat_path = 'data_dat/' .. filename .. '.dat'
        if cc.FileUtils:getInstance():isFileExist(dat_path) then
            content = PerpUtils:GetEncrypedFileData(dat_path)
        end
    end

    -- data에서 파일 로드
    if not content then
        local path = 'data/' .. filename .. extension
        if cc.FileUtils:getInstance():isFileExist(path) then
            local filePath = cc.FileUtils:getInstance():fullPathForFilename(path)
            if (filePath ~= path) then
                content = cc.FileUtils:getInstance():getStringFromFile(filePath)
            end
        end
    end

    -- data에서 파일 로드 실패 시 data_dat에서 파일 로드
    if not content then
        local dat_path = 'data_dat/' .. filename .. '.dat'
        if cc.FileUtils:getInstance():isFileExist(dat_path) then
            content = PerpUtils:GetEncrypedFileData(dat_path)
        end
    end

    return content
end

-------------------------------------
-- function loadJsonTable
-------------------------------------
function TABLE:loadJsonTable(filename)
    local content = TABLE:loadTableFile(filename, '.txt')
    return json.decode(content)
end

-------------------------------------
-- function get
-------------------------------------
function TABLE:get(name)
    return self[name]
end

-------------------------------------
-- function makeCol
-- @brief 윈도우에서만 실행
--        csv파일들의 MD5를 col.csv에 저장하는 함수
-------------------------------------
function TABLE:makeCol()
    local writable_path = cc.FileUtils:getInstance():getWritablePath()
    local path = writable_path .. '../../data/col.csv'

    local f = io.open(path, 'w')
    f:write('key,hash\n')

    --for i,v in ipairs(SecTable) do
    for i,v in pairs(TableInfo) do
        if i ~= 'col' then
            local name = v[1]
            local path = cc.FileUtils:getInstance():fullPathForFilename('data_dat/' .. name .. '.dat')
            local md5 = getMd5(path)
            f:write(name .. ',' .. md5 .. '\n')
        end
    end
    f:close()

    TABLE:loadCSVTable('col', 'col', 'key', true)
end

-------------------------------------
-- function init
-------------------------------------
function TABLE:init()
    for k,v in pairs(TableInfo) do
        TABLE:loadCSVTable(v[1], k, v[2], v[3])
    end
end