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
        -- hide_coupon_btn_in_ios   boolean         ios에서 쿠폰 입력 버튼 숨김
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


-------------------------------------
-- function hideCouponBtn
-- @brief 쿠폰 입력 버튼 숨김 여부
--        ios의 경우 apple의 정책상 버튼을 숨겨야 해서 remote config로 관리한다.
-- @return boolean
-------------------------------------
function ServerData_RemoteConfig:hideCouponBtn()

    if CppFunctions:isIos() then
        local hide_coupon_btn_in_ios = g_remoteConfig:getRemoteConfig('hide_coupon_btn_in_ios')
        
        -- 값이 false일 경우에만 hide하지 않음
        if (hide_coupon_btn_in_ios == false) then
            return false

        -- 명시적으로 true로 설정된 경우
        elseif (hide_coupon_btn_in_ios == true) then
            return true

        -- 값이 설정되지 않아서 nil이거나 비 정상적인 값일 경우에도 숨김
        else--if (hide_coupon_btn_in_ios == nil) then
            return true
        end
    end


    return false
end