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
