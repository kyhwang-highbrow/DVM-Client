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
    local appId = 'com.perplelab.dragonvillagem.kr'
    if isIos() then
        -- AppStore App ID
    end
    self:sendEvent('app_gotoStore', appId)
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
