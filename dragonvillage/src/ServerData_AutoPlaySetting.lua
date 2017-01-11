-------------------------------------
-- class ServerData_AutoPlaySetting
-------------------------------------
ServerData_AutoPlaySetting = class({
        m_serverData = 'ServerData',
        m_bAutoPlay = 'boolean',
        m_autoPlayCnt = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AutoPlaySetting:init(server_data)
    self.m_serverData = server_data

    local t_auto_play_setting = self.m_serverData:get('auto_play_setting')

    if (not t_auto_play_setting) then
        t_auto_play_setting = {}

        -- 패배시 연속 모험 종료
        t_auto_play_setting['stop_condition_lose'] = true
        -- 드래곤의 현재 승급 상태 중 레벨MAX가 되면 연속 모험 종료
        t_auto_play_setting['stop_condition_dragon_lv_max'] = true
        -- 드래곤의 인벤토리가 가득차면 연속 모험 종료
        t_auto_play_setting['stop_condition_dragon_inventory_max'] = true
        -- 룬 인벤토리가 가득차면 연속 모험 종료
        t_auto_play_setting['stop_condition_rune_inventory_max'] = true
        -- 레이드 보스 등장시 연속 모험 종료
        t_auto_play_setting['stop_condition_raid_appeared'] = true

        do 
            -- 드래곤 공격 스킬 사용
            t_auto_play_setting['dragon_atk_skill'] = 'at_cool' or 'at_event'

            -- 드래곤 치유 스킬 사용
            t_auto_play_setting['dragon_heal_skill'] = 'at_cool' or 'at_event'

            -- 테이머 스킬 사용
            t_auto_play_setting['tamer_skill'] = 1 or 2 or 3
        end
        self.m_serverData:applyServerData(t_auto_play_setting, 'auto_play_setting')
    end

    self.m_bAutoPlay = false
    self.m_autoPlayCnt = 1
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_AutoPlaySetting:get(key)
    return self.m_serverData:get('auto_play_setting', key)
end

-------------------------------------
-- function set
-------------------------------------
function ServerData_AutoPlaySetting:set(key, data)
    return self.m_serverData:applyServerData(data, 'auto_play_setting', key)
end

-------------------------------------
-- function setAutoPlay
-------------------------------------
function ServerData_AutoPlaySetting:setAutoPlay(auto_play)
    self.m_bAutoPlay = auto_play
    if auto_play then
        self.m_autoPlayCnt = 1
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