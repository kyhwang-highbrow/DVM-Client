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

-- @ generator
getsetGenerator(ErrorTracker, 'ErrorTracker')
