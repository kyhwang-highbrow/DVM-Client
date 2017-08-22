-------------------------------------
-- class ServerData_AutoPlaySetting
-------------------------------------
ServerData_AutoPlaySetting = class({
        m_serverData = 'ServerData',
        m_bAutoPlay = 'boolean',        -- 연속 모드
        m_autoPlayCnt = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AutoPlaySetting:init(server_data)
    self.m_serverData = server_data

    local t_auto_play_setting = g_localData:get('auto_play_setting')

    if (not t_auto_play_setting) then
        t_auto_play_setting = {}

        -- 패배시 연속 모험 종료
        t_auto_play_setting['stop_condition_lose'] = true
        -- 드래곤의 현재 승급 상태 중 레벨MAX가 되면 연속 모험 종료
        t_auto_play_setting['stop_condition_dragon_lv_max'] = true
        -- 드래곤의 가방이 가득차면 연속 모험 종료
        t_auto_play_setting['stop_condition_dragon_inventory_max'] = true
        -- 룬 가방이 가득차면 연속 모험 종료
        t_auto_play_setting['stop_condition_rune_inventory_max'] = true
        -- 인연던전 발견 시 연속 모험 종료
        t_auto_play_setting['stop_condition_find_rel_dungeon'] = true

        do 
            -- 드래곤 공격 스킬 사용
            t_auto_play_setting['dragon_atk_skill'] = 'at_cool' or 'at_event'

            -- 드래곤 치유 스킬 사용
            t_auto_play_setting['dragon_heal_skill'] = 'at_cool' or 'at_event'
        end

        -- 자동 모드 사용
        t_auto_play_setting['auto_mode'] = false

        -- 빠른 모드 사용
        t_auto_play_setting['quick_mode'] = false

        -- 패널 사용
        t_auto_play_setting['dragon_panel'] = true

        -- 연출 스킵 모드 사용
        t_auto_play_setting['skip_mode'] = false

        g_localData:applyLocalData(t_auto_play_setting, 'auto_play_setting')
    end

    self.m_bAutoPlay = false
    self.m_autoPlayCnt = 1
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_AutoPlaySetting:get(key)
    local ret = g_localData:get('auto_play_setting', key)

    if (ret == nil) then
        if (key == 'dragon_panel') then
            self:set(key, true)
        elseif (key == 'skip_level') then
            self:set(key, 0)
        end
    end

    return ret
end

-------------------------------------
-- function set
-------------------------------------
function ServerData_AutoPlaySetting:set(key, data)
    return g_localData:applyLocalData(data, 'auto_play_setting', key)
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