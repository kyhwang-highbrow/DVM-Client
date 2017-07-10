-------------------------------------
-- class ErrorTracker
-- @brief Error, Bug 관련 정보 수집
-------------------------------------
ErrorTracker = class({
	lastScene = 'get_set_gen',
	lastUI = 'get_set_gen',
	lastAPI = 'get_set_gen',
	lastFailedRes = 'get_set_gen',
    lastStage = 'get_set_gen',
})

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function ErrorTracker:init()

    -- @ generator
    -- getsetGenerator(ErrorTracker, 'ErrorTracker')

end

-------------------------------------
-- function getInstance
------------------------------------- 
function ErrorTracker:getInstance()
    if g_errorTracker then
        return g_errorTracker
    end

    g_errorTracker = ErrorTracker()
    return g_errorTracker
end

-------------------------------------
-- function getTrackerText
------------------------------------- 
function ErrorTracker:getTrackerText(msg)
    local os = getTargetOSName()
    local uid = g_userData:get('uid')
    local nick = g_userData:get('nick')
    local ver = PatchData:getInstance():getAppVersionAndPatchIdxString()
	local last_scene = self:get_lastScene()
	local last_ui = self:get_lastUI()
	local last_api = self:get_lastAPI()
	local last_failed_res = self:get_lastFailedRes()
    local last_stage = self:get_lastStage()
    local msg = msg or 'kkami'

	local templete = 
[[
==============DV BUG REPORT==============
nick : %s
uid : %d
os : %s
info : %s
last scene : %s
last ui : %s
last api : %s
last failed res : %s
last stage : %s
=========================================
%s
]]

	local text = string.format(templete, nick, uid, os, ver, last_scene, last_ui, last_api, last_failed_res, last_stage, msg)

	return text
end

-------------------------------------
-- function set_lastScene
------------------------------------- 
function ErrorTracker:set_lastScene(s)
    self.lastScene = s
end

-------------------------------------
-- function get_lastScene
------------------------------------- 
function ErrorTracker:get_lastScene()
    return self.lastScene
end

-------------------------------------
-- function set_lastUI
------------------------------------- 
function ErrorTracker:set_lastUI(s)
    self.lastUI = s
end

-------------------------------------
-- function get_lastUI
------------------------------------- 
function ErrorTracker:get_lastUI()
    return self.lastUI
end

-------------------------------------
-- function set_lastAPI
------------------------------------- 
function ErrorTracker:set_lastAPI(s)
    self.lastAPI = s
end

-------------------------------------
-- function get_lastAPI
------------------------------------- 
function ErrorTracker:get_lastAPI()
    return self.lastAPI
end

-------------------------------------
-- function set_lastFailedRes
------------------------------------- 
function ErrorTracker:set_lastFailedRes(s)
    self.lastFailedRes = s
end

-------------------------------------
-- function get_lastFailedRes
------------------------------------- 
function ErrorTracker:get_lastFailedRes()
    return self.lastFailedRes
end

-------------------------------------
-- function set_lastStage
------------------------------------- 
function ErrorTracker:set_lastStage(s)
    self.lastStage = s
end

-------------------------------------
-- function get_lastStage
------------------------------------- 
function ErrorTracker:get_lastStage()
    return self.lastStage
end