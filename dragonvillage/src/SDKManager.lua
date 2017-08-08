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
    self:sendEvent('app_gotoStore')
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