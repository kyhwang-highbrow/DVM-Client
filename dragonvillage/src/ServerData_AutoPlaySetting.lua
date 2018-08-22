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
-------------------------------------
-- function init
-------------------------------------
function ServerData_AutoPlaySetting:init()
    local t_auto_play_setting = g_settingData:get('auto_play_setting')

    if (not t_auto_play_setting) then
        t_auto_play_setting = {}
        
        local l_mode = {AUTO_NORMAL, AUTO_COLOSSEUM}
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
        ['stop_condition_dragon_lv_max'] = true,
		-- 인연던전 발견 시 연속 모험 종료
        ['stop_condition_find_rel_dungeon'] = true,
		-- 고대의탑 / 시험의탑 다음 층 도전
		['tower_next_floor'] = false,
		
		-- 쫄작시 6성 드래곤만 스킬 사용
        ['dragon_farming_mode'] = false,

	    -- 자동 모드 사용
        ['auto_mode'] = false,
        -- 빠른 모드 사용
        ['quick_mode'] = true,
        -- DPS 패널 사용
        ['dps_panel'] = true,
        -- 연출 스킵 모드 사용
        ['skip_mode'] = false
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
-- @brief 연속 전투 시에만 활성화
-------------------------------------
function ServerData_AutoPlaySetting:isFarmingOptionOn()
    return (self.m_bAutoPlay and self:get('dragon_farming_mode'))
end