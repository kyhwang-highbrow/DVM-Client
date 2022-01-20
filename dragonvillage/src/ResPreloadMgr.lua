-------------------------------------
-- class ResPreloadMgr
-------------------------------------
ResPreloadMgr = class({
    m_stageId             = 'number',
    m_bCompletedPreload     = 'boolean',
    m_bPreparedPreloadList  = 'boolean',
    m_lPreloadList          = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function ResPreloadMgr:init()
    self.m_stageId = ''
    self.m_bCompletedPreload = false
    self.m_bPreparedPreloadList = false
    self.m_lPreloadList = {}
end

L_PRELOAD_LIST = nil
-------------------------------------
-- function loadPreloadFile
-------------------------------------
function ResPreloadMgr:loadPreloadFile()
    if (L_PRELOAD_LIST) then
        return L_PRELOAD_LIST
    end

    -- 프리로드 파일이 존재하는지 확인 한 후에 불러온다.
    if (LuaBridge:isFileExist('ps/table/preload.ps') or LuaBridge:isFileExist('src/table/preload.lua')) then
        L_PRELOAD_LIST = require 'table/preload'
    elseif (isWin32()) then
        cclog('## not exist preload lua')
        L_PRELOAD_LIST = {
            ['common'] = {
                'res/ui/a2d/ingame_status_effect/ingame_status_effect.plist'
            }
        }
    else
        cclog('## not exist preload lua')
        L_PRELOAD_LIST = {}
    end

    return L_PRELOAD_LIST
end

-------------------------------------
-- function loadFromStageId
--@brief 해당 스테이지 관련 리소스를 프리로드
-------------------------------------
function ResPreloadMgr:loadFromStageId(stage_id)
    
    if (self.m_bCompletedPreload and self.m_stageId == stage_id) then
        -- 이미 프리로드된 경우
        return true
    end

    if (not self.m_bPreparedPreloadList or self.m_stageId ~= stage_id) then
        self.m_stageId = stage_id
        self.m_bCompletedPreload = false
        self.m_bPreparedPreloadList = true

        -- 프리로드 리스트 초기화
        self.m_lPreloadList = nil

        -- 스테이지에 관련된 것들을 제외한 나머지 리소스들을 추가
        local game_mode = getDigit(self.m_stageId, 100000, 2)

        if (game_mode == GAME_MODE_INTRO) then
            self.m_lPreloadList = self:makeResListForIntro()
        elseif (game_mode == GAME_MODE_CLAN_RAID or game_mode == GAME_MODE_ANCIENT_RUIN) then
            self.m_lPreloadList = self:makeResListForDoubleTeam(game_mode)
        elseif (game_mode == GAME_MODE_EVENT_ARENA) then
            self.m_lPreloadList = self:makeResListForDoubleTeam(game_mode)
        else
            self.m_lPreloadList = self:makeResListForGame()
        end

        -- @TODO: 친구 유닛에 대한 리소스를 추가

        -- 해당 스테이지 관련 리소스 추가
        do
            local l_preload_full_list = self:loadPreloadFile()
            if (l_preload_full_list) then
                local l_common = l_preload_full_list['common']
                local l_stage = l_preload_full_list[stage_id]
                
                -- 공통 리소스
                if (l_common) then
                    self.m_lPreloadList = table.merge(self.m_lPreloadList, l_common)
                end
                
                -- 스테이지 리소스
                if (l_stage) then
                    self.m_lPreloadList = table.merge(self.m_lPreloadList, l_stage)
                end
            end
        end

        return false
    end

    self.m_bCompletedPreload = self:_loadRes()
    return self.m_bCompletedPreload
end

-------------------------------------
-- function loadForColosseum
--@brief 콜로세움 관련 리소스를 프리로드
-------------------------------------
function ResPreloadMgr:loadForColosseum(t_enemy)
    if (self.m_bCompletedPreload) then
        -- 이미 프리로드된 경우
        return true
    end

    if (not self.m_bPreparedPreloadList) then
        self.m_bCompletedPreload = false
        self.m_bPreparedPreloadList = true

        -- 프리로드 리스트 초기화
        self.m_lPreloadList = nil

        -- 스테이지에 관련된 것들을 제외한 나머지 리소스들을 추가
        do
            self.m_lPreloadList = self:makeResListForGame()
        end

        -- @TODO: 상대편 유닛에 대한 리소스를 추가

        -- 공통 리소스 
        local l_preload_full_list = self:loadPreloadFile()
        if (l_preload_full_list) then
            local l_common = l_preload_full_list['common']
            if (l_common) then
                self.m_lPreloadList = table.merge(self.m_lPreloadList, l_common)
            end
        end

        return false
    end

    self.m_bCompletedPreload = self:_loadRes()
    return self.m_bCompletedPreload
end

-------------------------------------
-- function _loadRes
-------------------------------------
function ResPreloadMgr:_loadRes()
    local limitedCount = 10  -- 프레임마다 처리될 리소스 수
    local count = 0
    local t_remove = {}

    for i, v in ipairs(self.m_lPreloadList) do
        self:resCaching(v)
        count = count + 1

        table.insert(t_remove, 1, i)

        if (count >= limitedCount) then break end
    end

    for _, v in ipairs(t_remove) do
		table.remove(self.m_lPreloadList, v)
	end

    return (#self.m_lPreloadList == 0)
end

-------------------------------------
-- function resCaching
-- @brief 해당 리소스를 메모리에 상주시킴
-------------------------------------
function ResPreloadMgr:resCaching(res_name)
    if (not res_name) or (string.len(res_name) == 0) then return end

    local b = false

    -- plist
    if string.match(res_name, '%.plist') then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(res_name)

        b = true

    -- vrp
	elseif string.match(res_name, '%.vrp') then
		local animator = MakeAnimator(res_name)
        if animator.m_node then
            b = true
        else
            cclog('## ERROR!! resCaching() file not exist', res_name)
        end

    -- spine
    elseif string.match(res_name, '%.spine') then
		local animator

        if (AnimatorHelper:isIntegratedSpineResName(res_name)) then
            animator = MakeAnimatorSpineToIntegrated(res_name)
        else
            animator = MakeAnimator(res_name)
        end
        
        if animator.m_node then
            b = true
        else
            cclog('## ERROR!! resCaching() file not exist', res_name)
        end
	end

    return b
end

-------------------------------------
-- function makeResListForGame
-- @brief 게임 관련 리소스 목록을 얻음
-------------------------------------
function ResPreloadMgr:makeResListForGame()
    local l_ret = {}
    local t_temp = {}

    -- 아군 관련 리소스
    local l_res = self:getPreloadList_MyDragon()
    for _, k in ipairs(l_res) do
        t_temp[k] = true
    end

    -- 인덱스형 테이블로 변환
    for k, _ in pairs(t_temp) do
        table.insert(l_ret, k)
    end

    return l_ret
end

-------------------------------------
-- function makeResListForIntro
-- @brief 인트로 게임 관련 리소스 목록을 얻음
-------------------------------------
function ResPreloadMgr:makeResListForIntro()
    local l_ret = {}
    local t_temp = {}
    
    -- 아군 관련 리소스
    for _, did in ipairs({ 120011, 120102, 120431, 120223, 120294 }) do
        local t_dragon_data = StructDragonObject()

        t_dragon_data['did'] = did
        t_dragon_data['grade'] = 6
        t_dragon_data['lv'] =  60
        t_dragon_data['evolution'] = 3
        t_dragon_data['skill_0'] = 1
		t_dragon_data['skill_1'] = 1
		t_dragon_data['skill_2'] = 1
		t_dragon_data['skill_3'] = 1
        
        local l_res = self:getPreloadList_Dragon(t_dragon_data)

        for _, k in ipairs(l_res) do
            t_temp[k] = true
        end
    end
    
    -- 인덱스형 테이블로 변환
    for k, _ in pairs(t_temp) do
        table.insert(l_ret, k)
    end
    
    return l_ret
end

-------------------------------------
-- function makeResListForDoubleTeam
-- @brief 클랜 던전 게임 관련 리소스 목록을 얻음
-------------------------------------
function ResPreloadMgr:makeResListForDoubleTeam(game_mode)
    local l_ret = {}
    local t_temp = {}
    local g_data

    if (game_mode == GAME_MODE_CLAN_RAID) then
        local attr = TableStageData:getStageAttr(self.m_stageId) 
        g_data = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)

    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        g_data = MultiDeckMgr(MULTI_DECK_MODE.ANCIENT_RUIN)

    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (game_mode == GAME_MODE_EVENT_ARENA) then
        g_data = MultiDeckMgr(MULTI_DECK_MODE.EVENT_ARENA)
    end
    
    -- 아군 관련 리소스

    do  -- 상단 덱
        local l_deck = g_deckData:getDeck(g_data:getDeckName('up'))
        local l_res = self:getPreloadList_HeroDeck(l_deck)
        for _, k in ipairs(l_res) do
            t_temp[k] = true
        end
    end

    do  -- 하단 덱
        local l_deck = g_deckData:getDeck(g_data:getDeckName('down'))
        local l_res = self:getPreloadList_HeroDeck(l_deck)
        for _, k in ipairs(l_res) do
            t_temp[k] = true
        end
    end

    -- 인덱스형 테이블로 변환
    for k, _ in pairs(t_temp) do
        table.insert(l_ret, k)
    end
    
    return l_ret
end

-------------------------------------
-- function getPreloadList_Tamer
-------------------------------------
function ResPreloadMgr:getPreloadList_Tamer()
	local ret = {
        g_tamerData:getCurrTamerTable('res'),
        g_tamerData:getCurrTamerTable('res_sd'),
    }
    
    return ret
end

-------------------------------------
-- function getPreloadList_MyDragon
-------------------------------------
function ResPreloadMgr:getPreloadList_MyDragon()
    local ret = {}

    local l_deck = g_deckData:getDeck()
    for _, v in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
        if (t_dragon_data) then
            local list = self:getPreloadList_Dragon(t_dragon_data)
            for i, v in ipairs(list) do
                table.insert(ret, v)
            end
        end
    end

    return ret
end

-------------------------------------
-- function getPreloadList_HeroDeck
-------------------------------------
function ResPreloadMgr:getPreloadList_HeroDeck(l_deck)
    local ret = {}

    for _, v in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
        if (t_dragon_data) then
            local list = self:getPreloadList_Dragon(t_dragon_data)
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
function ResPreloadMgr:getPreloadList_Dragon(t_dragon_data)
    local did = t_dragon_data['did']
    local evolution = t_dragon_data['evolution']
    local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	
    local ret = {}

    -- 영웅
    local t_dragon = TableDragon():get(did)
    if (not t_dragon) then return ret end

    local evolution = evolution or 1
    local attr = t_dragon['attr']

    -- 드래곤 테이블에서 드래곤의 res(spine)를 가져온다.
    local res_name = AnimatorHelper:getDragonResName(t_dragon['res'], evolution, attr)
    table.insert(ret, res_name)
     
    -- 스킬 테이블에서 해당 드래곤의 스킬들 res를 가져온다.
    local t_skillIdx = { 'Leader', 'Basic', 0, 1, 2, 3 }

    local func_register_skill_res = function(t_skill)
        if t_skill['skill_form'] == 'script' then
            self:countSkillResListFromScript(ret, t_skill['skill_type'], attr)
        else
            for i = 1, 3 do
                if (t_skill['res_' .. i] ~= '') then
                    local res_name = string.gsub(t_skill['res_' .. i], '@', attr)
                    table.insert(ret, res_name)
                end
            end
        end
            
        -- 스킬에서 사용되는 상태효과의 res를 가져온다.
        for i = 1, 5 do
            local type = t_skill['add_option_type_' .. i]
            if (type and type ~= '') then
                local t_status_effect = TableStatusEffect():get(type)
                if (t_status_effect) then
                    if (t_status_effect['res'] ~= '') then
                        local res_name = string.gsub(t_status_effect['res'], '@', attr)
                        table.insert(ret, res_name)
                    end
                end
            end
        end
    end

	for _, idx in pairs(t_skillIdx) do
        local skill_indivisual_info = skill_mgr:getSkillIndivisualInfo_usingIdx(idx)
        if (skill_indivisual_info) then
            local t_skill = skill_indivisual_info:getSkillTable()
            func_register_skill_res(t_skill)

            -- 변신 후 스킬이 존재한다면 추가
            if (skill_indivisual_info.m_metamorphosisSkillInfo) then
                local t_metamorphosis_skill = skill_indivisual_info.m_metamorphosisSkillInfo:getSkillTable()
                func_register_skill_res(t_metamorphosis_skill)
            end
        end
    end

    return ret
end

-------------------------------------
-- function countSkillResListFromScript
-- @brief 해당 스킬 타입의 스크립트에 포함된 리소스명을 list의 테이블에 포함시킴
-------------------------------------
function ResPreloadMgr:countSkillResListFromScript(list, type, attr)
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