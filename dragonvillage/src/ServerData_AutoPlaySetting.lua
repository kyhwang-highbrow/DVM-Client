-------------------------------------
-- class ServerData_AutoPlaySetting
-------------------------------------
ServerData_AutoPlaySetting = class({
        m_autoMode = 'string',              -- 콜로세움과 나머지를 구분
        m_bAutoPlay = 'boolean',        -- 연속 모드
        m_autoPlayCnt = 'number',

        m_bDirty = 'boolean',
    })

AUTO_NORMAL = 'normal'
AUTO_COLOSSEUM = 'colosseum'
-------------------------------------
-- function init
-------------------------------------
function ServerData_AutoPlaySetting:init()
    local t_auto_play_setting = g_localData:get('auto_play_setting')

    if (not t_auto_play_setting) then
        t_auto_play_setting = {}
        
        local l_mode = {AUTO_NORMAL, AUTO_COLOSSEUM}
        for _, mode in pairs(l_mode) do
            self:setDefaultSetting(mode, t_auto_play_setting)
        end
        
        g_localData:applyLocalData(t_auto_play_setting, 'auto_play_setting')
    end

    self.m_autoMode = AUTO_NORMAL
    self.m_bAutoPlay = false
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
        -- 드래곤의 가방이 가득차면 연속 모험 종료
        ['stop_condition_dragon_inventory_max'] = true,
        -- 룬 가방이 가득차면 연속 모험 종료
        ['stop_condition_rune_inventory_max'] = true,
        -- 인연던전 발견 시 연속 모험 종료
        ['stop_condition_find_rel_dungeon'] = true,

        -- 드래곤 공격 스킬 사용
        ['dragon_atk_skill'] = 'at_cool',

        -- 드래곤 치유 스킬 사용
        ['dragon_heal_skill'] = 'at_cool',

        -- 자동 모드 사용
        ['auto_mode'] = false,

        -- 빠른 모드 사용
        ['quick_mode'] = false,

        -- 패널 사용
        ['dragon_panel'] = true,

        -- 연출 스킵 모드 사용
        ['skip_mode'] = false
    }
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
    local ret = g_localData:get('auto_play_setting', self.m_autoMode, key)
    return ret
end

-------------------------------------
-- function set
-------------------------------------
function ServerData_AutoPlaySetting:set(key, data)
    return g_localData:applyLocalData(data, 'auto_play_setting', self.m_autoMode, key)
end

-------------------------------------
-- function setWithoutSaving
-------------------------------------
function ServerData_AutoPlaySetting:setWithoutSaving(key, data)
    local t_auto_play_setting = g_localData:getRef('auto_play_setting')

    if (not t_auto_play_setting[self.m_autoMode]) then
        self:setDefaultSetting(self.m_autoMode, t_auto_play_setting)
    end

    t_auto_play_setting[self.m_autoMode][key] = data

    self.m_bDirty = true
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