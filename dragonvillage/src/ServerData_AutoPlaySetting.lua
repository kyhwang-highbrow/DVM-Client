-------------------------------------
-- class ServerData_AutoPlaySetting
-------------------------------------
ServerData_AutoPlaySetting = class({
        m_autoMode = 'string',              -- 콜로세움과 나머지를 구분
        m_bAutoPlay = 'boolean',            -- 연속 모드
        m_autoPlayCnt = 'number',

        -- 연속 전투 활성화된 상태에서 전투 시작 ~ 끝까지 아무 액션도 안취한 경우 true
        -- 유저들의 온전한 연속 전투 로그를 남기기 위해 체크
        m_bSequenceAutoPlay = 'boolean',   
         
        m_bDirty = 'boolean',
    })

AUTO_NORMAL = 'normal'
AUTO_COLOSSEUM = 'colosseum'
AUTO_GRAND_ARENA = 'grand_arena'
AUTO_CLAN_WAR = 'clan_war'
-------------------------------------
-- function init
-------------------------------------
function ServerData_AutoPlaySetting:init()
    local t_auto_play_setting = g_settingData:get('auto_play_setting')

    if (not t_auto_play_setting) then
        t_auto_play_setting = {}
        
        local l_mode = {AUTO_NORMAL, AUTO_COLOSSEUM, AUTO_GRAND_ARENA, AUTO_CLAN_WAR}
        for _, mode in pairs(l_mode) do
            self:setDefaultSetting(mode, t_auto_play_setting)
        end
        
        g_settingData:applySettingData(t_auto_play_setting, 'auto_play_setting')
    end

    self.m_autoMode = AUTO_NORMAL
    self.m_bAutoPlay = false
    self.m_bSequenceAutoPlay = false
    self.m_autoPlayCnt = 1
end

-------------------------------------
-- function setDefaultSetting
-------------------------------------
function ServerData_AutoPlaySetting:setDefaultSetting(mode, t_auto_play_setting)
    t_auto_play_setting[mode] = {
        -- 패배시 연속 모험 종료
        ['stop_condition_lose'] = true,
        -- 드래곤의 현재 승급 상태 중 레벨MAX가 되면 연속 모험 종료
        ['stop_condition_dragon_lv_max'] = false, -- @sgkim 2020.09.27 기본값을 ture에서 false로 변경
		-- 인연던전 발견 시 연속 모험 종료
        ['stop_condition_find_rel_dungeon'] = false, -- @sgkim 2020.09.27 기본값을 ture에서 false로 변경
		-- 고대의탑 / 시험의탑 다음 층 도전
		['tower_next_floor'] = false,
		
		-- 쫄작시 6성 드래곤만 스킬 사용
        ['dragon_farming_mode'] = false,
        -- 모험 자동 진행
        ['adv_next_stage'] = false,

	    -- 자동 모드 사용
        ['auto_mode'] = false,
        -- 빠른 모드 사용
        ['quick_mode'] = false,
        -- 빠른 모드 사용(4배속까지) {1, 1.5, 3}
        ['quick_mode_time_scale'] = 1, -- ARENA_NEW test용

        -- DPS 패널 사용
        ['dps_panel'] = true,
        -- 연출 스킵 모드 사용
        ['skip_mode'] = false,

        -- 고대의 탑, 저장되어 있는 베스트 덱 사용
        ['load_best_deck'] = false
    }

    do -- 룬 자동 판매
        local t_setting = t_auto_play_setting[mode]
        t_setting['rune_auto_sell'] = false
        t_setting['rune_auto_sell_grade1'] = false
        t_setting['rune_auto_sell_grade2'] = false
        t_setting['rune_auto_sell_grade3'] = false
        t_setting['rune_auto_sell_grade4'] = false
        t_setting['rune_auto_sell_grade5'] = false
        t_setting['rune_auto_sell_grade6'] = false
    end
end

-------------------------------------
-- function setMode
-------------------------------------
function ServerData_AutoPlaySetting:setMode(mode)
    self.m_autoMode = mode
    self.m_bDirty = false
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_AutoPlaySetting:get(key)
    -- 차원문에서는 오토모드 항상 false
    if (key == 'auto_mode') then
        if (g_gameScene and g_gameScene.m_gameMode == GAME_MODE_DIMENSION_GATE) then return false end
    end

    local ret = g_settingData:get('auto_play_setting', self.m_autoMode, key)
    return ret
end

-------------------------------------
-- function set
-------------------------------------
function ServerData_AutoPlaySetting:set(key, data)
    return g_settingData:applySettingData(data, 'auto_play_setting', self.m_autoMode, key)
end

-------------------------------------
-- function setWithoutSaving
-------------------------------------
function ServerData_AutoPlaySetting:setWithoutSaving(key, data)
    local t_auto_play_setting = g_settingData:getRef('auto_play_setting')

    if (not t_auto_play_setting[self.m_autoMode]) then
        self:setDefaultSetting(self.m_autoMode, t_auto_play_setting)
    end

    t_auto_play_setting[self.m_autoMode][key] = data

    self.m_bDirty = true

    -- 연속 전투 활성화된 상태에서 자동전투 해제시 m_bSequenceAutoPlay : false
    if (self.m_bSequenceAutoPlay) and (key == 'auto_mode') and (data == false) then
        self.m_bSequenceAutoPlay = false
    end
end

-------------------------------------
-- function save
-------------------------------------
function ServerData_AutoPlaySetting:save()
    if (self.m_bDirty) then
        self.m_bDirty = false

        g_localData:saveLocalDataFile()
    end
end

-------------------------------------
-- function setAutoPlay
-------------------------------------
function ServerData_AutoPlaySetting:setAutoPlay(auto_play)
    self.m_bAutoPlay = auto_play
    if auto_play then
        self.m_autoPlayCnt = 1

        -- 연속 전투가 활성화되면 자동모드도 같이 활성화시킴
        self:set('auto_mode', true)
    end

    -- 연속 전투 활성화된 상태에서 해제시 m_bSequenceAutoPlay : false
    if (self.m_bSequenceAutoPlay) and (auto_play == false) then
        self.m_bSequenceAutoPlay = false
    end
end

-------------------------------------
-- function isAutoPlay
-------------------------------------
function ServerData_AutoPlaySetting:isAutoPlay()
    return self.m_bAutoPlay
end

-------------------------------------
-- function getAutoPlayCnt
-------------------------------------
function ServerData_AutoPlaySetting:getAutoPlayCnt()
    return self.m_autoPlayCnt
end

-------------------------------------
-- function setSequenceAutoPlay
-- @brief 전투 시작시 호출
-------------------------------------
function ServerData_AutoPlaySetting:setSequenceAutoPlay()
    self.m_bSequenceAutoPlay = (self.m_bAutoPlay) and true or false
end

-------------------------------------
-- function getSequenceAutoPlay
-- @brief 전투 종료시 호출
-------------------------------------
function ServerData_AutoPlaySetting:getSequenceAutoPlay()
    return self.m_bSequenceAutoPlay
end

-------------------------------------
-- function isFarmingOptionOn
-- @brief 6성 드래곤만 스킬 사용
--        연속 전투 시에만 활성화
-- @kwkang 2020-11-12 업데이트로 인해 항상 false 반환
-------------------------------------
function ServerData_AutoPlaySetting:isFarmingOptionOn()
    --return (self.m_bAutoPlay and self:get('dragon_farming_mode'))
    return false
end

-------------------------------------
-- function isRuneAutoSell
-- @brief 룬 자동 판매 기능
--        연속 전투 시에만 활성화
-------------------------------------
function ServerData_AutoPlaySetting:isRuneAutoSell()
    return (self.m_bAutoPlay and self:get('rune_auto_sell'))
end

-------------------------------------
-- function getRuneAutoSellValue
-- @brief 룬 자동 판매 설정이 담긴 값 리턴
--        1xxxxx 6등급 룬 판매 여부
--         1xxxx 5등급 룬 판매 여부
--          1xxx 4등급 룬 판매 여부
--           1xx 3등급 룬 판매 여부
--            1x 2등급 룬 판매 여부
--             1 1등급 룬 판매 여부
--        이 값을 2진법으로 변환해서 사용
-------------------------------------
function ServerData_AutoPlaySetting:getRuneAutoSellValue(t_setting)
    local sell_value = 0
    local grade_1, grade_2, grade_3, grade_4, grade_5, grade_6
    if t_setting then
        grade_1 = t_setting[1] or false
        grade_2 = t_setting[2] or false
        grade_3 = t_setting[3] or false
        grade_4 = t_setting[4] or false
        grade_5 = t_setting[5] or false
        grade_6 = t_setting[6] or false
    else
        grade_1 = self:get('rune_auto_sell_grade1')
        grade_2 = self:get('rune_auto_sell_grade2')
        grade_3 = self:get('rune_auto_sell_grade3')
        grade_4 = self:get('rune_auto_sell_grade4')
        grade_5 = self:get('rune_auto_sell_grade5')
        --grade_6 = self:get('rune_auto_sell_grade6')
        grade_6 = false -- 2018.08.22 6성은 무조건 false로 설정
    end
    if (grade_6 == true) then sell_value = sell_value + 100000 end
    if (grade_5 == true) then sell_value = sell_value + 10000 end
    if (grade_4 == true) then sell_value = sell_value + 1000 end
    if (grade_3 == true) then sell_value = sell_value + 100 end
    if (grade_2 == true) then sell_value = sell_value + 10 end
    if (grade_1 == true) then sell_value = sell_value + 1 end
    sell_value = tonumber(sell_value, 2) -- 2진법으로 변환 (서버에서 요구하는 형태)
    return sell_value
end
