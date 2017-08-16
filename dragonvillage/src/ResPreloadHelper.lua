local PRELOAD_FILE_NAME = '../data/preload.txt'

-------------------------------------
-- function countSkillResListFromScript
-- @brief 해당 스킬 타입의 스크립트에 포함된 리소스명을 list의 테이블에 포함시킴
-------------------------------------
local function countSkillResListFromScript(list, type, attr)
    local script = TABLE:loadSkillScript(type)
    if (not list or not script) then return end

    local script_data = script[type]
    if (not script_data) then return end
    
    local tAttackValueBase = script_data['attack_value']
    local count = 1

    while (tAttackValueBase[count]) do
        local res = tAttackValueBase[count]['res']
        if (res) then
            local res_name = string.gsub(res, '@', attr)
            table.insert(list, res_name)
        end

        count = count + 1
    end
end

-------------------------------------
-- function loadPreloadFile
-------------------------------------
function loadPreloadFile()
    --cclog('loadPreloadFile')

    local filename = string.gsub(PRELOAD_FILE_NAME, '%.txt', '')
    local content = TABLE:loadTableFile(filename, '.txt')
    if not content then return end

    local preloadList = json_decode(content)
    return preloadList
end

-------------------------------------
-- function savePreloadFile
-------------------------------------
function savePreloadFile()
    --cclog('savePreloadFile')
    
    -- 1. 스테이지별 리스트를 생성
    local preloadList = {}
    local t_stage_desc = TABLE:get('stage_desc')

    for stageID, _ in pairs(t_stage_desc) do
        local stageName = string.format('stage_%s', stageID)
        preloadList[stageName] = makeResListForGame(stageName, true)
    end

    -- 2. 파일로 저장
    local path = cc.FileUtils:getInstance():fullPathForFilename(PRELOAD_FILE_NAME)
    local f = io.open(path, 'wb')
    local contents = dkjson.encode(preloadList, {indent=true})
    f:write(contents)
    f:close()
end

-------------------------------------
-- function makeResListForGame
-- @brief 게임 관련 리소스 목록을 얻음
-------------------------------------
function makeResListForGame(stageName, bOnlyStage)
    local ret = {}
    local temp = {}

    -- 공용 리소스
    if not bOnlyStage then
        local tList = getPreloadList_Common()
        for _, k in ipairs(tList) do
            temp[k] = true
        end
    end

    -- 테이머 관련 리소스
    if not bOnlyStage then
        local tList = getPreloadList_Tamer()
        for _, k in ipairs(tList) do
            temp[k] = true
        end
    end

    -- 아군 관련 리소스
    if not bOnlyStage then
        local tList = getPreloadList_HeroDeck()
        for _, k in ipairs(tList) do
            temp[k] = true
        end
    end
    
    -- 스테이지(적군) 관련 리소스
    if stageName then
        local tList = getPreloadList_Stage(stageName)
        for _, k in ipairs(tList) do
            temp[k] = true
        end
    end

    -- 인덱스형 테이블로 변환
    for k, _ in pairs(temp) do
        table.insert(ret, k)
    end

    return ret
end

-------------------------------------
-- function resCaching
-- @brief 해당 리소스를 메모리에 상주시킴
-------------------------------------
function resCaching(res_name)
    if (not res_name) or (string.len(res_name) == 0) then return end

    local b = false

    -- plist
    if string.match(res_name, '%.plist') then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(res_name)

        b = true

    -- vrp
	elseif string.match(res_name, '%.vrp') then
		local res_name = string.gsub(res_name, '%.vrp', '')
		
        --[[
		-- loadPlistFiles함수에서 자동으로 load되기때문에 주석처리
		local plist_name = res_name .. '.plist'
		if cc.FileUtils:getInstance():isFileExist(plist_name) then
			cc.SpriteFrameCache:getInstance():addSpriteFrames(plist_name)
		end
        ]]--

		-- vrp를 생성(VRP 캐싱)
		local node = cc.AzVRP:create(res_name .. '.vrp')
        if node then
            node:loadPlistFiles('')
		    node:buildSprite('')

            b = true
        else
            cclog('## ERROR!! resCaching() file not exist', res_name)
        end

    -- spine
    elseif string.match(res_name, '%.spine') then
		local res_name = string.gsub(res_name, '%.spine', '')
		
		local node = sp.SkeletonAnimation:create(res_name .. '.json', res_name ..  '.atlas', 1)
        if node then
            b = true
        else
            cclog('## ERROR!! resCaching() file not exist', res_name)
        end
	end

    if b and DEVELOPMENT_KSJ then
        cclog('resCaching ' .. res_name)
    end

    return b
end

-------------------------------------
-- function getPreloadList_Common
-------------------------------------
function getPreloadList_Common()
    local ret = {
        'res/effect/effect_melee_charge/effect_melee_charge.plist',
        'res/effect/effect_missile_charge/effect_missile_charge.plist',
        'res/effect/effect_hit_01/effect_hit_01.plist',
        'res/effect/effect_skillcasting_dragon/effect_skillcasting_dragon.plist',
        'res/effect/effect_skillcasting/effect_skillcasting.plist',
        'res/effect/effect_passive_common/effect_passive_common.plist',
        'res/effect/effect_skillcut_dragon/effect_skillcut_dragon.plist',

        'res/indicator/indicator_effect_target/indicator_effect_target.plist',
        'res/ui/a2d/enemy_skill_speech/enemy_skill_speech.plist',
        'res/ui/a2d/ingame_enemy/ingame_enemy.plist',
        'res/effect/effect_monsterdragon/effect_monsterdragon.plist',
    }
    return ret
end

-------------------------------------
-- function getPreloadList_Tamer
-------------------------------------
function getPreloadList_Tamer()
	local ret = {
        g_tamerData:getCurrTamerTable('res_sd'),

        'res/effect/tamer_magic_1/tamer_magic_1.plist',
        'res/effect/effect_tamer_shield/effect_tamer_shield.plist',
        'res/effect/cutscene_tamer_a_type/cutscene_tamer_a_type_t.plist',
    }
    
    return ret
end

-------------------------------------
-- function getPreloadList_HeroDeck
-------------------------------------
function getPreloadList_HeroDeck()
    local ret = {}

    local l_deck = g_deckData:getDeck()
    for _, v in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
        if (t_dragon_data) then
            local list = getPreloadList_Dragon(t_dragon_data)
            for i, v in ipairs(list) do
                table.insert(ret, v)
            end
        end
    end

    return ret
end

-------------------------------------
-- function getPreloadList_Dragon
-------------------------------------
function getPreloadList_Dragon(t_dragon_data)
    local did = t_dragon_data['did']
    local evolution = t_dragon_data['evolution']
    local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	
    local ret = {}

    -- 영웅
    local t_dragon = TableDragon():get(did)
    if (not t_dragon) then return ret end

    local evolution = evolution or 1
    local attr = t_dragon['attr']

    local res_name = AnimatorHelper:getDragonResName(t_dragon['res'], evolution, attr)
    table.insert(ret, res_name)
     
    -- 스킬
    local t_skillIdx = { 'Leader', 'Basic', 0, 1, 2, 3 }

	for _, idx in pairs(t_skillIdx) do
        local skill_indivisual_info = skill_mgr:getSkillIndivisualInfo_usingIdx(idx)
        if (skill_indivisual_info) then
            local t_skill = skill_indivisual_info:getSkillTable()
            
            if t_skill['skill_form'] == 'script' then
                countSkillResListFromScript(ret, t_skill['skill_type'], attr)
            else
                for i = 1, 3 do
                    if (t_skill['res_' .. i] ~= '') then
                        local res_name = string.gsub(t_skill['res_' .. i], '@', attr)
                        table.insert(ret, res_name)
                    end
                end
            end
            
            -- 상태효과
            for i = 1, 2 do
                local type = t_skill['add_option_type_' .. i]
                if (type ~= '') then
                    local t_status_effect = TableStatusEffect():get(type)
                    if (t_status_effect) then
                        if (t_status_effect['res'] ~= '') then
                            local res_name = t_status_effect['res']
                            table.insert(ret, res_name)
                        end
                    end
                end
            end
        end
    end

    return ret
end

-------------------------------------
-- function getPreloadList_Stage
-------------------------------------
function getPreloadList_Stage(stageName)
    local ret = {}

    local t_skillList = { 'skill_basic' }
    for i = 1, 9 do
        table.insert(t_skillList, 'skill_' .. i)
    end

    -- 스테이지 공통 리소스
    table.insert(ret, 'res/effect/effect_attack_ready/effect_attack_ready.plist')

    local script = TABLE:loadStageScript(stageName)
    if script and script['wave'] then
        for _, v in pairs(script['wave']) do
            if v['wave'] then
                for _, a in pairs(v['wave']) do
                    for _, data in pairs(a) do
                        local l_str = seperate(data, ';')
                        local enemy_id = tonumber(l_str[1])   -- 적군 ID

                        local t_enemy
                        if enemy_id then
                            if isDragon(enemy_id) then
                                t_enemy = TableDragon():get(enemy_id)
                            else
                                t_enemy = TableMonster():get(enemy_id)
                            end
                        end

                        if t_enemy then
                            -- 적군
                            local attr = t_enemy['attr']

                            local res_name

                            if isDragon(enemy_id) then
                                -- 스테이지에서 등장하는 적 드래곤은 모두 성룡이라고 가정(고대의 탑)
                                res_name = AnimatorHelper:getDragonResName(t_enemy['res'], 3, attr)
                            else
                                res_name = AnimatorHelper:getMonsterResName(t_enemy['res'], attr)
                            end
                            table.insert(ret, res_name)

                            -- 스킬
                            for _, k in pairs(t_skillList) do
                                local t_skill = TABLE:get('monster_skill')[t_enemy[k]]
                                if t_skill then
                                    if t_skill['skill_form'] == 'script' then
                                        countSkillResListFromScript(ret, t_skill['skill_type'], attr)
                                    else
                                        for i = 1, 3 do
                                            if (t_skill['res_' .. i] ~= 'x') then
                                                local res_name = string.gsub(t_skill['res_' .. i], '@', attr)
                                                table.insert(ret, res_name)
                                            end
                                        end
                                    end

                                    -- 상태효과
                                    for i = 1, 2 do
                                        local type = t_skill['add_option_type_' .. i]
                                        if (type ~= '') then
                                            local t_status_effect = TableStatusEffect():get(type)
                                            if (t_status_effect) then
                                                if (t_status_effect['res'] ~= '') then
                                                    local res_name = t_status_effect['res']
                                                    table.insert(ret, res_name)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return ret
end