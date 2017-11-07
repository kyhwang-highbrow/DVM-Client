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
		dragon_skill_modify = {'table_dragon_skill_modify', 'slid',         false},
        table_dragon_combine= {'table_dragon_combine',      'did',          false},
        monster				= {'table_monster',             'mid',          false},
        monster_hit_pos		= {'table_monster_hit_pos',     'mid',          false},
        monster_skill       = {'table_monster_skill',       'sid',          false},
        tamer               = {'table_tamer',               'tid',          false},
        tamer_skill         = {'table_tamer_skill',         'sid',          false},
        tamer_costume       = {'table_tamer_costume',       'cid',          false},
        drop                = {'table_drop',                'stage',        false},
        stage_data          = {'table_stage_data',          'stage',        false},
        stage_desc          = {'table_stage_desc',          'stage',        false},
        secret_dungeon      = {'table_secret_dungeon',      'stage',        false},
        dragon_exp          = {'table_dragon_exp',          'eid',          false},
        exp_tamer           = {'table_user_level',          'ulv',         false},
        item                = {'table_item',                'item',         false},
        fruit               = {'table_fruit',               'fid',          false},
        friendbuff          = {'table_dragon_friendbuff',   'rarity',       false},

        first_reward        = {'table_first_reward',        'stage_id',     false},
        attribute           = {'table_attribute',           'attr_id',      false},
        status              = {'table_status',              'type',         false},
        status_effect       = {'table_status_effect',       'name',         false},
        formation           = {'table_formation',           'fmid',         false},
        skill_sound         = {'table_skill_sound',         'sid',          false},

		quest			    = {'table_quest',			    'qid',			false},
		master_road			= {'table_master_road',			'rid',			false},
        table_tamer_title	= {'table_tamer_title',			'title_id',		false},
        table_google_quest	= {'table_google_quest',	    'gqid',			false},

        anc_floor_reward    = {'table_ancient_reward',      'stage',		false},
        anc_weak_debuff     = {'table_ancient_debuff',	    'var',		    false},
        stage_mission       = {'table_stage_mission',		'key',			false},
        calendar            = {'table_calendar',		    'month',		false},
        table_option        = {'table_option',		        'option',		false},
        table_slime         = {'table_slime',		        'slime',		false},
        table_slime_exp     = {'table_slime_exp',           'eid',  		false},

		broadcast           = {'table_broadcast',		    'type',		    true},

		loading_guide       = {'table_loading_guide',		'gid',		    false},
        table_colosseum_buff= {'table_colosseum_buff',		'wins',		    false},
        table_inventory     = {'table_inventory',		    'lv',		    false},
        package_bundle      = {'table_package_bundle',		'bid',		    false},

        -- 드래곤 관리 관련
        grade_info          = {'table_dragon_grade_info',    'grade',        false},
        dragon_evolution    = {'table_dragon_evolution',     'did',          false},
        evolution_info      = {'table_dragon_evolution_info','evolution',    false},
        enemy_move          = {'table_enemy_move',           'type',         true},
        table_rune_set      = {'table_rune_set',             'set_id',       false},
        table_dragon_phrase = {'table_dragon_phrase',        'did',          false},

        scenario_resource   = {'scenario/scenario_resource', 'key',         false},

		mail_template		  = {'table_mail_template',		 'mail_type',	false},
        table_help		      = {'table_help',		         'help_id',	    false},
        table_ban_word_chat	  = {'table_ban_word_chat',		 'wid',         false},
        table_ban_word_naming = {'table_ban_word_naming',    'wid',         false},
        table_ui_location     = {'table_ui_location',        'location_name', false},

        table_highbrow		  = {'table_highbrow',		     'id',	    false},

        table_forest_stuff_type = {'table_forest_stuff_type', 'stuff_type', false},
        table_forest_stuff_info = {'table_forest_stuff_info', 'id', false},

        table_clan_mark = {'table_clan_mark', 'unique_id', false},
        table_clan_reward = {'table_clan_reward', 'rank_id', false},
    }

-------------------------------------
-- table TableInfo_fromServer
-------------------------------------
local TableInfo_fromServer = {
        -- ['csv 테이블 이름'] = {'테이블 약어', 'key'},
        ['table_rune_enhance'] = {'table_rune_enhance', 'rune_lv'},
        ['table_rune_grade'] = {'table_rune_grade', 'grade'},
        ['table_rune_mopt_status'] = {'table_rune_mopt_status', 'vid'},
        ['table_rune_opt'] = {'table_rune_opt', 'slot_id'},
        ['table_req_gold'] = {'table_req_gold', 'lv'},
        ['table_stamina_info'] = {'table_stamina_info', 'stamina_type'},
        ['table_exploration_list'] = {'table_exploration_list', 'epr_id'},
        ['table_colosseum'] = {'table_colosseum', 'tid'},
        ['table_content_lock'] = {'table_content_lock', 'content_name'},
        ['table_clan_reward'] = {'table_clan_reward', 'rank_id'},

        --  친밀도
        ['table_dragon_friendship'] = {'table_dragon_friendship', 'friendship'},
        ['table_dragon_friendship_variables'] = {'table_dragon_friendship_variables', 'var'},

        -- 아이템 관련
        ['table_item_rand'] = {'table_item_rand', 'rand_item_id'},

        -- 드래곤 가차
        ['table_gacha_probability'] = {'table_gacha_probability', 'item_id'},

        -- 진화재료 조합
        ['table_item_evolution_combine'] = {'table_item_evolution_combine', 'id'},
        ['table_package_levelup'] = {'table_package_levelup', 'level'}, -- 레벨업 패키지 레벨별 보상 리스트
    }

-------------------------------------
-- function getServerTableInfo
-------------------------------------
function TABLE:getServerTableInfo()
    return TableInfo_fromServer
end

-------------------------------------
-- function makeLuaTableFromCSV
-- @brief csv 또는 tsv 을 읽은 문자열을 루아 테이블로 변환
-------------------------------------
function TABLE:makeLuaTableFromCSV(content, key)
    local header = {}
    local tables = {}

    local handle = csv.openstring(content, {})
    local is_first_line = true
    for r in handle:lines() do
        -- 해더 셋팅    
        if is_first_line then
            for i,v in ipairs(r) do
                header[i] = v
            end

            if (not key) then
                key = header[1]
            end

            is_first_line = false
        else
            local t = {}
            for i,v in ipairs(r) do
                local v_number = tonumber(v)
                if v_number then
                    v = v_number
                else
                    v = string.gsub(v, '\\\\n', '\n')
                end
                t[header[i]] = v
            end

            tables[t[key]] = t
        end
    end

    handle:close()

    return tables
end

-------------------------------------
-- function loadCSVTable
-------------------------------------
function TABLE:loadCSVTable(filename, tablename, key, toString)

    -- lua파일에서 읽는 부분 테스트
    if (isAndroid and isAndroid()) or (isIos and isIos()) then
        local tables = nil
        local headers = nil
        local function load_func()
            local _data = require ('table/' .. filename)

            -- csv to lua로 변환된 데이터에서 해더 정보가 있는지 여부 체크
            if _data['__data'] and _data['__header'] then
                tables = _data['__data']
                headers = _data['__header']

                -- 테이블 값에 nil이 있을 경우 ''로 대체
                for _,head in pairs(headers) do
                    for _,v in pairs(tables) do
                        if (v[head] == nil) then
                            v[head] = ''
                        end
                    end
                end
            else
                tables = _data
            end

            if tablename then
                TABLE[tablename] = tables
            end
        end

        local function error_handler(msg)
            --cclog('msg : ' .. tostring(msg))
        end
        
        local status, msg = xpcall(load_func, error_handler)
        if status and tables then
            return tables
        end
    end

    -- window
    local content = TABLE:loadTableFile(filename, '.csv')
    if (content == nil) then
        cclog('failed to load table file(' .. filename .. ')')
        return
    end

    local tables = TABLE:makeLuaTableFromCSV(content, key)
    if tablename then
        TABLE[tablename] = tables
    end
    return tables
end

-------------------------------------
-- function isFileExist
-------------------------------------
function TABLE:isFileExist(filename, extension)
    local is_exist = false

    -- 윈도우가 아닐 경우 data_dat에서 먼저 검사
    if isWin32() == false then
        local dat_path = 'data_dat/' .. filename .. '.dat'
        if LuaBridge:isFileExist(dat_path) then
            is_exist = true
        end
    end

    -- data에서 검사
    if not is_exist then
        local path = 'data/' .. filename .. extension
        if LuaBridge:isFileExist(path) then
            is_exist = true
        end
    end

    -- data에 없을 경우 data_dat에서 한번 더 검사
    if not is_exist then
        local dat_path = 'data_dat/' .. filename .. '.dat'
        if LuaBridge:isFileExist(dat_path) then
            is_exist = true
        end
    end

    return is_exist
end

-------------------------------------
-- function loadTableFile
-------------------------------------
function TABLE:loadTableFile(filename, extension)
    local content

    -- 윈도우가 아닐 경우 data_dat에서 테이블 로드
    if isWin32() == false then
        local dat_path = 'data_dat/' .. filename .. '.dat'
        if LuaBridge:isFileExist(dat_path) then
            content = PerpUtils:GetEncrypedFileData(dat_path)
        end
    end

    -- data에서 파일 로드
    if not content then
        local path = 'data/' .. filename .. extension
        if LuaBridge:isFileExist(path) then
            local filePath = LuaBridge:fullPathForFilename(path)
            if (filePath ~= path) then
                content = LuaBridge:getStringFromFile(filePath)
            end
        end
    end

    -- data에서 파일 로드 실패 시 data_dat에서 파일 로드
    if not content then
        local dat_path = 'data_dat/' .. filename .. '.dat'
        if LuaBridge:isFileExist(dat_path) then
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
-- function loadStageScript
-------------------------------------
function TABLE:loadStageScript(filename, extention, remove_comment)
    local filename = 'stage/' .. filename
    return self:loadJsonTable(filename, extention, remove_comment)
end

-------------------------------------
-- function loadMapScript
-------------------------------------
function TABLE:loadMapScript(filename, extention, remove_comment)
    local filename = 'map/' .. filename
    return self:loadJsonTable(filename, extention, remove_comment)
end

-------------------------------------
-- function loadPatternScript
-------------------------------------
function TABLE:loadPatternScript(filename, extention, remove_comment)
    local filename = 'pattern/' .. filename
    return ScriptCache:get(filename, extention, remove_comment)
    --return self:loadJsonTable(filename, extention, remove_comment)
end

-------------------------------------
-- function loadSkillScript
-------------------------------------
function TABLE:loadSkillScript(filename, extention, remove_comment)
    local filename = 'skill/' .. filename
    return ScriptCache:get(filename, extention, remove_comment)
    --return self:loadJsonTable(filename, extention, remove_comment)
end

-------------------------------------
-- function setServerTable
-------------------------------------
function TABLE:setServerTable(table_name, table_data)
    if (not table_data) then
        return
    end

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

    -- 테이블이 로드되어 있지 않은 경우 로드 시도
    if (not self[name]) then
        local t_info = TableInfo[name]
        if t_info then
            --cclog('TABLE:get() first load : ' .. name)
            TABLE:loadCSVTable(t_info[1], name, t_info[2], t_info[3])
        end
    end

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
            local path = LuaBridge:fullPathForFilename('data_dat/' .. name .. '.dat')
            local md5 = CppFunctions:getMd5(path)
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
    --TableDragonSkill:initGlobal()
    --TableMonsterSkill:initGlobal()

    -- 드래곤 스킬 레벨업 테이블 테스트
    --[[
    local table = TableDragon().m_orgTable
    for k, v in pairs(table) do
        TestDragonSkillManager(k)
    end
    ]]--
end

-------------------------------------
-- function reloadForGame
-------------------------------------
function TABLE:reloadForGame()
    -- 인게임 데이터 관련 테이블
    local l_table = {
        'dragon',
        'dragon_skill',
        'dragon_skill_modify',
        'monster',
        'monster_skill',
        'tamer',
        'tamer_skill',
        'status',
        'status_effect',
        'stage_data',
        'drop',
    }

    for _, k in ipairs(l_table) do
        local v = TableInfo[k]
        if (v) then
            TABLE:loadCSVTable(v[1], k, v[2], v[3])
        end
    end

    TableDragonSkill:initGlobal()
    TableMonsterSkill:initGlobal()
    TableStatusEffect:initGlobal()
end

-------------------------------------
-- function reloadSkillSoundTable
-------------------------------------
function TABLE:reloadSkillSoundTable()
    local k = 'skill_sound'
    local v = TableInfo[k]
    if (v) then
        TABLE:loadCSVTable(v[1], k, v[2], v[3])
    end
end

-------------------------------------
-- function getTableInfo
-------------------------------------
function TABLE:getTableInfo()
    return TableInfo
end