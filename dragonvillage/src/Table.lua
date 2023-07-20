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
        mastery_skill       = {'table_mastery_skill',       'msid',         false},
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
        exp_tamer           = {'table_user_level',          'ulv',          false},
        item                = {'table_item',                'item',         false},
		item_type           = {'table_item_type',           'type',			false},
        fruit               = {'table_fruit',               'fid',          false},
        friendbuff          = {'table_dragon_friendbuff',   'rarity',       false},

        first_reward        = {'table_first_reward',        'stage_id',     false},
        attribute           = {'table_attribute',           'attr_id',      false},
        status              = {'table_status',              'type',         false},
        status_effect       = {'table_status_effect',       'name',         false},
        formation           = {'table_formation',           'fmid',         false},
        formation_arena     = {'table_arena_formation',     'fmid',         false},
        team_bonus          = {'table_team_bonus',          'id',           false},
        skill_sound         = {'table_skill_sound',         'sid',          false},

		quest			    = {'table_quest',			    'qid',			false},
		master_road			= {'table_master_road',			'rid',			false},
        dragon_diary		= {'table_dragon_diary',		'rid',			false},
        table_tamer_title	= {'table_tamer_title',			'title_id',		false},
        table_google_quest	= {'table_google_quest',	    'gqid',			false},

        anc_weak_debuff     = {'table_ancient_debuff',	    'var',		    false},
        stage_mission       = {'table_stage_mission',		'key',			false},
        calendar            = {'table_calendar',		    'month',		false},
        table_option        = {'table_option',		        'option',		false},
        table_slime         = {'table_slime',		        'slime',		false},
        table_slime_exp     = {'table_slime_exp',           'eid',  		false},

		broadcast           = {'table_broadcast',		    'type',		    true},

		loading_guide       = {'table_loading_guide',		'gid',		    false},
        table_colosseum_buff= {'table_colosseum_buff',		'wins',		    false},

        -- 드래곤 관리 관련
        grade_info          = {'table_dragon_grade_info',    'grade',        false},
        dragon_evolution    = {'table_dragon_evolution',     'did',          false},
        evolution_info      = {'table_dragon_evolution_info','evolution',    false},
        enemy_move          = {'table_enemy_move',           'type',         true},
        table_rune_set      = {'table_rune_set',             'set_id',       false},
        table_dragon_phrase = {'table_dragon_phrase',        'did',          false},
        table_dragon_recommend = {'table_dragon_recommend',  'did',          false},

        -- 소환체
        summon_object        = {'table_summon_object',        'sobj_id',      false},

        scenario_resource   = {'scenario/scenario_resource', 'key',         false},

		mail_template		  = {'table_mail_template',		 'mail_type',	false},
        table_help		      = {'table_help',		         'help_id',	    false},
        table_ban_word_chat	  = {'table_ban_word_chat',		 'wid',         false},
        table_ui_location     = {'table_ui_location',        'location_name', false},

        table_highbrow		  = {'table_highbrow',		     'id',	    false},

        table_forest_stuff_type = {'table_forest_stuff_type', 'stuff_type', false},
        table_forest_stuff_info = {'table_forest_stuff_info', 'id', false},

        table_clan_mark = {'table_clan_mark', 'unique_id', false},
		table_clan_mark_custom = {'table_clan_mark_custom', 'id', false},

		table_pick_dragon = {'table_pick_dragon', 'itemid', false},
        table_pick_item = {'table_pick_item', 'id', false},

        table_collection_reward = {'table_collection_reward', 'birthgrade', false}, -- 도감에서 최초 획득 보상 정보 (해치, 해츨링, 성룡 최초 획득 시 다이아 보상 수량)
        table_mastery = {'table_mastery', 'id', false}, -- 특성

        table_rune_grind = {'table_rune_grind', 'rarity', false},
        table_clan_dungeon_buff = {'table_clan_dungeon_buff', 'stage', false}, -- 클랜 버프 테이블
        table_clan_dungeon = {'table_clan_dungeon', 'stage', false}, -- 클랜 던전 정보

        table_illusion = {'table_illusion', 'event_id', false}, -- 환상던전 이벤트 정보
        table_illusion_buff = {'table_illusion_buff', 'idx', false}, -- 환상던전 드래곤 버프 정보

        table_content_help = {'table_content_help', 'content_name', false}, -- 컨텐츠 오픈 도움말 테이블
		table_halloffame_rank = {'table_halloffame_rank', 'rank_id', false}, -- 명예의 전당 도움말 테이블

        table_arena_rank = {'table_arena_rank', 'rank_id', false}, -- 콜로세움 랭킹 보상
        table_arena = {'table_arena', 'tid', false}, -- 티어 정보 표기하는데 사용

        table_arena_new_rank = {'table_arena_new_rank', 'tier_id', false}, -- 콜로세움 개선 후 랭킹 보상
        --table_arena_new = {'table_arena_new', 'id', false}, -- 콜로세움 개선 후 돌파 보상

        table_clanwar_group = {'table_clanwar_group', 'idx', true}, -- 클랜전 조별리그 매치 방식
        anc_floor_reward = {'table_ancient_reward', 'stage', false}, -- 고대의 탑(시험의 탑)
        table_fevertime = {'table_fevertime', 'type', false}, -- 핫타임

        -- 소원 구슬 이벤트
        table_lucky_fortune_bag = {'table_lucky_fortune_bag', 'id', false},
        table_lucky_fortune_bag_rank = {'table_lucky_fortune_bag_rank', 'rank_id', false},

        table_talk_deet = {'table_talk_deet', 'text_id', false},

        -- 레이드 
        table_league_raid_data = {'table_league_raid_data', 'lv', false},

        -- 드래곤 스킨
        dragon_skin = {'table_dragon_skin', 'skin_id', false},

        -- 아이템 교체 테이블
        table_item_display = {'table_item_display', 'id', false},

        -- 이벤트 퀘스트
        table_event_quest  = {'table_event_quest',	'qid',	false},

        -- 룬 필터 
        table_rune_filter_point = {'table_rune_filter_point', 'enhance_id', false},
    }

-------------------------------------
-- table TableInfo_fromServer
-------------------------------------
local TableInfo_fromServer = {
        -- ['csv 테이블 이름'] = {'테이블 약어', 'key'},
		-- 룬 
        ['table_rune'] = {'table_rune', 'rune_id'},
        ['table_rune_enhance'] = {'table_rune_enhance', 'rune_lv'},
        ['table_rune_grade'] = {'table_rune_grade', 'grade'},
        ['table_rune_mopt_status'] = {'table_rune_mopt_status', 'vid'},
        ['table_rune_opt'] = {'table_rune_opt', 'slot_id'},

		-- 모드 관련
        ['table_exploration_list'] = {'table_exploration_list', 'epr_id'},
        ['table_colosseum'] = {'table_colosseum', 'tid'}, -- 랭킹 보상
		['table_colosseum_reward'] = {'table_colosseum_reward', 'win'}, -- 주간 보상
        ['table_arena_reward'] = {'table_arena_reward', 'play_cnt'}, -- 주간 보상
        ['table_content_lock'] = {'table_content_lock', 'content_name'},
        ['table_clan_reward'] = {'table_clan_reward', 'rank_id'},

		-- 기타
        ['table_req_gold'] = {'table_req_gold', 'lv'},
        ['table_stamina_info'] = {'table_stamina_info', 'stamina_type'},
        ['table_naver_article'] = {'table_naver_article', 'article'},

        --  친밀도
        ['table_dragon_friendship'] = {'table_dragon_friendship', 'friendship'},
        ['table_dragon_friendship_variables'] = {'table_dragon_friendship_variables', 'var'},

        -- 아이템 관련
        ['table_item_rand'] = {'table_item_rand', 'rand_item_id'},

        -- 드래곤 가차
        ['table_gacha_probability'] = {'table_gacha_probability', 'item_id'},

        -- 드래곤 픽업 스케줄
        ['table_pickup_schedule'] = {'table_pickup_schedule', 'pickup_id'},

        -- 진화재료 조합
        ['table_item_evolution_combine'] = {'table_item_evolution_combine', 'id'},

        -- 외형변환 재료
        ['table_transform'] = {'table_dragon_transform', 'd_grade'},

		-- 레벨업 패키지 레벨별 보상 리스트
        ['table_package_levelup'] = {'table_package_levelup_01', 'level'}, 
        ['table_package_levelup_02'] = {'table_package_levelup_02', 'level'}, 
        ['table_package_levelup_03'] = {'table_package_levelup_03', 'level'}, 
        ['table_package_levelup_04'] = {'table_package_levelup_04', 'level'}, 
        -- 모험 돌파 패키지 보상 리스트
        ['table_package_stage'] = {'table_package_stage_01', 'stage'}, 
        ['table_package_stage_02'] = {'table_package_stage_02', 'stage'}, 
        ['table_package_stage_03'] = {'table_package_stage_03', 'stage'}, 
        ['table_package_stage_04'] = {'table_package_stage_04', 'stage'}, 
        -- 시험의 탑 정복 선물 패키지
        ['table_package_attr_tower'] = {'table_package_attr_tower', 'product_id'},
        ['table_package_attr_tower_reward'] = {'table_package_attr_tower_reward', 'floor'},

		-- 드래곤 강화
		['table_dragon_reinforce'] = {'table_dragon_reinforce', 'id'},

		-- 데일리 미션
		['table_daily_mission'] = {'table_daily_mission', 'id'},

        -- 패키지
        ['table_package_bundle'] = {'table_package_bundle', 'bid'},

        -- 가방
        ['table_inventory'] = {'table_inventory', 'lv'},

        -- 마을 팝업
        ['table_lobby_popup'] = {'table_lobby_popup', 'key'},

        -- 마을 가이드
        ['table_lobby_guide'] = {'table_lobby_guide', 'key'},

        -- 만드라고라의 모험
        ['table_mandragora_quest_event'] = {'table_mandragora_quest_event', 'qid'},

        ['table_alphabet_event'] = {'table_alphabet_event', 'id'}, -- 알파벳 이벤트

		['table_spot_sale'] = {'table_spot_sale', 'id'}, -- 깜짝 세일 
        ['table_personalpack'] = {'table_personalpack', 'ppid'}, -- 깜짝 세일 

        ['table_capsule_box_schedule'] = {'table_capsule_box_schedule', 'day'}, -- 캡슐 뽑기 스케쥴,

        ['table_rune_opt_status'] = {'table_rune_opt_status', 'id'}, -- 옵션 최대치
        ['table_supply'] = {'table_supply', 'supply_id'}, -- 보급소(정액제)
        ['table_newcomer_shop'] = {'table_newcomer_shop', 'ncm_id'}, -- 초보자 선물(신규 유저 전용 상점)
        ['table_flea_market'] = {'table_flea_market', 'ncm_id'}, -- 벼룩시장

        -- 배틀패스
        ['table_battle_pass'] = {'table_battle_pass', 'index'},
        ['table_battle_pass_reward'] = {'table_battle_pass_reward', 'id'},

        -- 시련 (차원문)
        ['table_dmgate_stage'] = {'table_dmgate_stage', 'stage_id'}, -- 스테이지 정보
        ['table_dmgate_buff_schedule'] = {'table_dmgate_buff_schedule', 'week'},

        ['table_package_achievement'] = {'table_package_achievement', 'package_id'},

        ['table_battlepass_clan_earth'] = {'table_battlepass_clan_earth', 'package_id'},
        ['table_battlepass_clan_water'] = {'table_battlepass_clan_water', 'package_id'},
        ['table_battlepass_clan_fire'] = {'table_battlepass_clan_fire', 'package_id'},
        ['table_battlepass_clan_light'] = {'table_battlepass_clan_light', 'package_id'},
        ['table_battlepass_clan_dark'] = {'table_battlepass_clan_dark', 'package_id'},
        ['table_arena_new'] = {'table_arena_new', 'id'}, -- 콜로세움 개선 후 돌파 보상
        ['table_cross_promotion'] = {'table_cross_promotion', 'event_id'}, -- 콜로세움 개선 후 돌파 보상

        -- 드래곤 획득 패키지
        ['table_get_dragon_package'] = {'table_get_dragon_package', 'product_id'},

        -- 스토리 던전 이벤트 테이블
        ['table_story_dungeon_event'] = {'table_story_dungeon_event', 'season_id'},
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

    -- lua stand alone에서 사용할 경우
    if (not content) then
        local path = filename .. extension
        if LuaBridge:isFileExist(path) then
            local filePath = LuaBridge:fullPathForFilename(path)
            if (filePath ~= path) then
                content = LuaBridge:getStringFromFile(filePath)
            end
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
    for _, v in pairs(table_data) do
        if v['ignore_row'] ~= 1 then
            tables[v[tablekey]] = v
        end
    end

    TABLE[tablename] = tables
end

-------------------------------------
-- function setTable
-------------------------------------
function TABLE:replaceTable(table_name, table_data)
    if (not table_name) or (not table_data) then return end

    if self[table_name] then
        self[table_name] = table_data
    end
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

    --TableGradeInfo:initGlobal()
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
    TableTamerSkill:initGlobal()
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