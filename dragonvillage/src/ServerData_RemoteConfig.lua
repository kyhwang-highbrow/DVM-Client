-------------------------------------
-- class ServerData_RemoteConfig
-- @brief 원격 설정
--        각종 설정 값을 서버에서 전달 받아서 적용하기 위한 데이터 관리 클래스
-- @instance g_remoteConfig
-------------------------------------
ServerData_RemoteConfig = class({
        m_remoteConfigData = 'table',

        ------------------------------------------------------------------------------------------------------
        -- key                      type            desc
        -- skip_ad_play             boolean         광고 재생 생략 여부
        -- skip_ad_aos_7_later      boolean         aos 7 이상에서 광고 생략 여부
        -- skip_scenario_playback   boolean         시나리오 재생 생략 여부
        ------------------------------------------------------------------------------------------------------
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_RemoteConfig:init()
    self.m_remoteConfigData = {}
end

-------------------------------------
-- function getRemoteConfig
-------------------------------------
function ServerData_RemoteConfig:getRemoteConfig(key)
    if (not self.m_remoteConfigData) then
        return nil
    end

    local data = self.m_remoteConfigData[key]
    return data
end

-------------------------------------
-- function applyRemoteConfig
-- @brief /users/login, /users/title API에서 remote_config키로 data가 전달됨
-------------------------------------
function ServerData_RemoteConfig:applyRemoteConfig(data)
    if (type(data) == 'table') then
        self.m_remoteConfigData = data
    end
end

-------------------------------------
-- function isSkipScenarioPlayback
-- @brief 시나리오 재생 생략 여부
-- @return boolean
-------------------------------------
function ServerData_RemoteConfig:isSkipScenarioPlayback()
    local skip_scenario_playback = g_remoteConfig:getRemoteConfig('skip_scenario_playback')
    
    if (skip_scenario_playback == true) then
        return true
    else
        return false
    end
end