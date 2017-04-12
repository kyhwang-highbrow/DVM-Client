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
        dragon_type         = {'table_dragon_type',         'type',         false},
        dragon_skill        = {'table_dragon_skill',        'sid',          false},
        monster				= {'table_monster',             'mid',          false},
        monster_hit_pos		= {'table_monster_hit_pos',     'mid',          false},
        monster_skill     = {'table_monster_skill',         'sid',          false},
        tamer             = {'table_tamer',                 'tid',          false},
        tamer_skill       = {'table_tamer_skill',           'sid',          false},
        drop              = {'table_drop',                  'stage',        false},
        stage_desc        = {'table_stage_desc',            'stage',        false},
        secret_dungeon    = {'table_secret_dungeon',        'stage',        false},
        dragon_exp        = {'table_dragon_exp',            'eid',          false},
        exp_tamer         = {'table_exp_tamer',             'lv_t',         false},
        item              = {'table_item',                  'item',         false},
        fruit             = {'table_fruit',                 'fid',          false},
        friendbuff        = {'table_dragon_friendbuff',     'rarity',       false},

        item_sort_by_type = {'table_item',                  'full_type',    false},
        shop              = {'table_shop',                  'product_id',   false},
        first_reward      = {'table_first_reward',          'stage_id',        false},
        attribute         = {'table_attribute',             'attr_id',      false},
        status            = {'table_status',                'type',         false},
        status_effect     = {'table_status_effect',         'name',         false},
        formation         = {'table_formation',             'fmid',         false},

		quest			  = {'table_quest',					'qid',			false},
        colosseum_reward  = {'table_colosseum_reward',		'tier',			false},
        stage_mission     = {'table_stage_mission',		    'key',			false},
        calendar          = {'table_calendar',		        'month',		false},
        table_option      = {'table_option',		        'option',		false},

        -- 드래곤 관리 관련
        grade_info           = {'table_dragon_grade_info',    'grade',        false},
        dragon_evolution     = {'table_dragon_evolution',     'did',          false},
        evolution_info       = {'table_dragon_evolution_info','evolution',    false},
        enemy_move           = {'table_enemy_move',           'type',         true},
        evolution_item       = {'table_dragon_evolution_item','item_id',      false},
        dragon_train_info    = {'table_dragon_train_info',  'grade',        false},
        table_rune_set       = {'table_rune_set',           'set_id',       false},
        dragon_unit          = {'table_dragon_unit',        'unit_id',      false},
    }

-------------------------------------
-- table TableInfo_fromServer
-------------------------------------
local TableInfo_fromServer = {
        -- ['csv 테이블 이름'] = {'테이블 약어', 'key'},
        ['table_rune_enhance'] = {'table_rune_enhance', 'rune_lv'},
        ['table_rune_grade'] = {'table_rune_grade', 'grade'},
        ['table_rune_mopt_status'] = {'table_rune_mopt_status', 'vid'},
        ['table_drop_ingame'] = {'table_drop_ingame', 'chapter_id'}, -- 인게임에서 아이템 드랍을 관리하는 테이블
        ['table_dragon_skill_enhance'] = {'table_dragon_skill_enhance', 'lv'},
        ['table_stamina_info'] = {'table_stamina_info', 'stamina_type'},
        ['table_dragon_research'] = {'table_dragon_research', 'lv'},

        --  친밀도
        ['table_dragon_friendship'] = {'table_dragon_friendship', 'friendship'},
        ['table_dragon_friendship_variables'] = {'table_dragon_friendship_variables', 'var'},

        -- 아이템 관련
        ['table_item_rand'] = {'table_item_rand', 'rand_item_id'},
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

    for _,line in ipairs(seperate(content,'\r\n')) do
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
function TABLE:loadJsonTable(filename, extention, remove_comment)
	local extention = extention or '.txt'
    local content = TABLE:loadTableFile(filename, extention)
    return json_decode(content, remove_comment)
end

-------------------------------------
-- function setServerTable
-------------------------------------
function TABLE:setServerTable(table_name, table_data)
	if (not TableInfo_fromServer[table_name]) then
        error('table_name : ' .. table_name)
    end

    local t_table_info = TableInfo_fromServer[table_name]
    local tablename = t_table_info[1]
    local tablekey = t_table_info[2]

    local tables = {}

    for i,v in pairs(table_data) do
        tables[v[tablekey]] = v
    end

    TABLE[tablename] = tables
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
-- function backupServerTable
-------------------------------------
function TABLE:backupServerTable()
    local t_ret = {}
    for i,v in pairs(TableInfo_fromServer) do
        t_ret[i] = self[i]
    end
    return t_ret
end

-------------------------------------
-- function init
-------------------------------------
function TABLE:init()
    for k,v in pairs(TableInfo) do
        TABLE:loadCSVTable(v[1], k, v[2], v[3])
    end

    TableGradeInfo:initGlobal()
end