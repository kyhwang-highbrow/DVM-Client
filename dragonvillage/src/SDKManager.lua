-------------------------------------
-- table SDKManager
-------------------------------------
SDKManager = {}

-------------------------------------
-- function sendEvent
-- @brief 
-------------------------------------
function SDKManager:sendEvent(id, arg0, arg1, func)
    local id = id or ''
    local arg0 = arg0 or ''
    local arg1 = arg1 or ''
    local func = func or function() end
    PerpSocial:SDKEvent(id, arg0, arg1, func)
end



-- 기기정보 관련
-------------------------------------
-- function deviceInfo
-- @brief 
-- @param cb_func function(ret, info) end
-------------------------------------
function SDKManager:deviceInfo(cb_func)
    self:sendEvent('app_deviceInfo', '', '', cb_func)
end

-- 광고 식별자
-------------------------------------
-- function getAdvertisingID
-- @brief 
-- @param cb_func function(ret, advertising_id) end
-------------------------------------
function SDKManager:getAdvertisingID(cb_func)
    self:sendEvent('advertising_id', '', '', cb_func)
end



-- 로컬푸시 관련
-------------------------------------
-- function addPush
-- @brief 
-------------------------------------
function SDKManager:addPush(push_msg)
    self:sendEvent('localpush_add', push_msg)
end

-------------------------------------
-- function clearPush
-- @brief 
-------------------------------------
function SDKManager:clearPush()
    self:sendEvent('localpush_cancel')
end

-------------------------------------
-- function registerPush
-- @brief 
-------------------------------------
function SDKManager:registerPush()
    self:sendEvent('localpush_register')
end

-------------------------------------
-- function setPushColor
-- @brief 
-------------------------------------
function SDKManager:setPushColor(color_str)
    self:sendEvent('localpush_setColor', color_str)
end

-------------------------------------
-- function setPushUrl
-- @brief 
-------------------------------------
function SDKManager:setPushUrl(url_str)
    self:sendEvent('localpush_setLinkUrl', color_str)
end



-- APK EXPANSION
-------------------------------------
-- function apkExpansionCheck
-- @brief 
-------------------------------------
function SDKManager:apkExpansionCheck(param_str, md5, cb_func)
    self:sendEvent('apkexp_check', param_str, md5, cb_func)
end

-------------------------------------
-- function apkExpansionStart
-- @brief 
-------------------------------------
function SDKManager:apkExpansionStart(param_str, md5, cb_func)
    self:sendEvent('apkexp_start', param_str, md5, cb_func)
end

-------------------------------------
-- function apkExpansionPause
-- @brief 
-------------------------------------
function SDKManager:apkExpansionPause()
    self:sendEvent('apkexp_pause')
end

-------------------------------------
-- function apkExpansionContinue
-- @brief 
-------------------------------------
function SDKManager:apkExpansionContinue()
    self:sendEvent('apkexp_continue')
end



-- 기타
-------------------------------------
-- function copyOntoClipBoard
-- @brief 
-------------------------------------
function SDKManager:copyOntoClipBoard(copy_str)
    self:sendEvent('clipboard_setText', copy_str)
end

-------------------------------------
-- function goToWeb
-- @brief 
-------------------------------------
function SDKManager:goToWeb(url)
    self:sendEvent('app_gotoWeb', url)
end

-------------------------------------
-- function goToAppStore
-- @brief 
-------------------------------------
function SDKManager:goToAppStore()
    -- xsolla
    if (PerpleSdkManager:xsollaIsAvailable()) then
        self:goToWeb(URL['DVM_XSOLLA_DOWNLOAD'])

    -- onestore
    elseif (PerpleSdkManager:onestoreIsAvailable()) then
        -- 참고 링크 : https://github.com/ONE-store/inapp-sdk/wiki/Tools-Developer-Guide
        -- https://www.onestore.co.kr/userpoc/game/view?pid=0000746979
        -- https://onesto.re/0000746979
        self:goToWeb(URL['DVM_ONESTORE_DOWNLOAD'])

        -- local pid = '0000746979'
        -- self:sendEvent('app_gotoStore', pid)

    -- google, apple
    else
        local appId = 'com.perplelab.dragonvillagem.kr'
        -- 왜 not으로 했을까?
        --if (not CppFunctions:isIos()) then
        if (CppFunctions:isIos()) then
            -- AppStore App ID
            appId = '1281873988'
        end
        self:sendEvent('app_gotoStore', appId)
    end
end

-------------------------------------
-- function sendMail
-- @brief 
-------------------------------------
function SDKManager:sendMail(info)
    -- info
    -- recipient;title;body
    self:sendEvent('app_sendMail', info)
end


-------------------------------------
-- function app_checkPermission
-- @brief 
-- @param permission_name ex) 'android.permission.READ_EXTERNAL_STORAGE'
-- @param cb_func function(ret, info) end
-------------------------------------
function SDKManager:app_checkPermission(permission_name, cb_func)
    self:sendEvent('app_checkPermission', permission_name, '', cb_func)

    -- function cb_func(result)
    --     if (result   == 'denied') then
    --     elseif (result   == 'granted') then
    --     end
    -- end
end

-------------------------------------
-- function app_isInstalled
-- @brief 
-- @param package_name ex) 'com.bigstack.rise'
-- @param cb_func function(ret, info) end
-------------------------------------
function SDKManager:app_isInstalled(package_name, cb_func)
    self:sendEvent('isInstalled', package_name, '', cb_func)
end

-------------------------------------
-- function app_requestPermission
-- @brief 
-- @param permission_name 'android.permission.READ_EXTERNAL_STORAGE'
-------------------------------------
function SDKManager:app_requestPermission(permission_name, cb_func)
    self:sendEvent('app_requestPermission', permission_name, '', cb_func)

    -- function cb_func(result)
    --     if (result   == 'denied') then
    --     elseif (result   == 'granted') then
    --     end
    -- end
end

-------------------------------------
-- function app_requestAppSetting
-------------------------------------
function SDKManager:app_requestAppSetting(cb_func)
    self:sendEvent('app_requestAppSetting', '', '', cb_func)
end

-------------------------------------
-- function requestTrackingAuthorization
-- @brief 2020.09.04 iOS14 대응으로 추가 / Android는 사용하지 않음
--[[
     function cb_func(result, status)
         if (result   == 'success') then
         elseif (result   == 'fail') then
         end
     end

     // status
     authorized
     denied
     notDetermined
     restricted
]]
-------------------------------------
function SDKManager:requestTrackingAuthorization(cb_func)
    if (not CppFunctions:isIos()) then
        cb_func()
    end

    self:sendEvent('request_tracking_authorization', '', '', cb_func)
end

-------------------------------------
-- function isTrackingAuthorized
-- @brief 2020.09.04 iOS14 대응으로 추가 / Android는 사용하지 않음
-------------------------------------
function SDKManager:isTrackingAuthorized(cb_func)
    self:sendEvent('tracking_authorized', '', '', cb_func)

    -- function cb_func(result)
    --     if (result   == 'success') then
    --     elseif (result   == 'fail') then
    --     end
    -- end
end

-------------------------------------
-- function isTrackingNotDetermined
-- @brief 2020.09.04 iOS14 대응으로 추가 / Android는 사용하지 않음
-------------------------------------
function SDKManager:isTrackingNotDetermined(cb_func)
    self:sendEvent('tracking_not_determined', '', '', cb_func)

    -- function cb_func(result)
    --     if (result   == 'success') then
    --     elseif (result   == 'fail') then
    --     end
    -- end
end

-------------------------------------
-- function requestAndroidPushPermission
-- @brief 2023.03.23 Android 13 대응 - Push Permission / iOS는 사용하지 않음
-------------------------------------
function SDKManager:requestAndroidPushPermission(force_inquiry, func_next)
    local permission_name = 'android.permission.POST_NOTIFICATIONS'
    local check = nil
    local check_cb = nil
    local request = nil
    local request_cb = nil


    -- 안드로이드가 아니면 다음 단계로 스킵
    if isAndroid() == false then 
        func_next()
        return
    end

    -- 1.4.1 부터 대응이 되어있다. 아니면 스킵
    if (getAppVerNum() < 1004001) then
        func_next()
        return
    end

    -- 이전에 이미 거부하였다면 
    local permission_replied = g_localData:get('local', 'push_permission')
    if permission_replied == 'denied' and force_inquiry ~= true then
        func_next()
        return
    end

    -- 퍼미션이 필요한지 확인
    check = function()
        cclog('## 1. 퍼미션이 필요한지 확인')
        SDKManager:app_checkPermission(permission_name, check_cb)
    end

    -- 퍼미션 확인 결과
    check_cb = function(result)
        cclog('## 2. 퍼미션 확인 결과')
        -- 퍼미션 필요한 경우
        if (result == 'denied') then
            request()
        -- 퍼미션이 필요하지 않은 경우
        elseif (result == 'granted') then
            func_next()
        end
    end
    
    -- 퍼미션 요청
    request = function()
        cclog('## 3. 퍼미션 요청')
        SDKManager:app_requestPermission(permission_name, request_cb)
    end

    -- 퍼미션 요청 결과
    request_cb = function(result)
        cclog('## 4. 퍼미션 요청 결과 : ' .. tostring(result))
        -- 푸시 퍼미션은 선택 사항이기 때문에 거절을 하더라도 다음 단계로 넘어가야 함
        -- result == 'denied' or 'granted'
        -- 거절한 경우 다시 요청 팝업이 뜨지 않도록 하기 위해 로컬에 저장
        g_localData:applyLocalData(result, 'local', 'push_permission')
        -- 다음 단계로 넘어감
        func_next()
    end

    check()
end


-------------------------------------
-- function checkAndroidPermission
-- @brief 2023.03.23 Android 13 대응 - Push Permission / iOS는 사용하지 않음
-------------------------------------
function SDKManager:checkAndroidPushPermission(func_next)
    local permission_name = 'android.permission.POST_NOTIFICATIONS'
    local check = nil
    local check_cb = nil
    local info_popup = nil
    local request = nil
    local request_cb = nil


    -- 안드로이드가 아니면 다음 단계로 스킵
    if isAndroid() == false then 
        func_next()
        return
    end

    -- 1.4.1 부터 대응이 되어있다. 아니면 스킵
    if (getAppVerNum() < 1004001) then
        func_next()
        return
    end

    -- 퍼미션이 필요한지 확인
    check = function()
        cclog('## 1. 퍼미션이 필요한지 확인')
        SDKManager:app_checkPermission(permission_name, check_cb)
    end

    -- 퍼미션 확인 결과
    check_cb = function(result)
        cclog('## 2. 퍼미션 확인 결과')
        -- 퍼미션 필요한 경우
        if (result == 'denied') then
            info_popup()
        else
            func_next()
        end
    end

    -- 퍼미션 안내 팝업
    info_popup = function()
        cclog('## 3. 퍼미션 안내 팝업')
        local msg = Str('현재 드빌M의 알림 설정이 비활성화된 상태입니다.')
        local submsg =  Str('드빌M의 풍성한 이벤트와 소식들을 제공받기 위해서는 알림 활성화가 필요합니다.\n지금 앱 정보에서 알림 상태를 확인하시겠습니까?')
        MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, request)
    end

    -- 퍼미션 요청
    request = function()
        SDKManager:app_requestAppSetting(request_cb)
    end

    check()
end