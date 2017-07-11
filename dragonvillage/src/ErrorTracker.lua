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

    m_lAPIList = 'list<string>',
})

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function ErrorTracker:init()
    self.m_lAPIList = {}
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
	local last_api = self:get_lastAPI()
	local last_failed_res = self:get_lastFailedRes()
    local last_stage = self:get_lastStage()
    local msg = msg or 'kkami'

	--local last_ui = self:get_lastUI()
	local ui_stack = self:getUIStack()
    local api_stack = self:getAPIStack()

    local template = 
[[
=============[DVM BUG REPORT]==============
1. info
    # nick : %s
    # uid : %d
    # os : %s
    # info : %s
    # last scene : %s
    # last failed res : %s
    # last stage : %s
 
2. ui stack list
%s
 
3. recent called api list (5)
%s
 
============[ERROR TRACEBACK]==============
%s
]]

	local text = string.format(template, 
        nick, uid, os, ver, last_scene, last_failed_res, last_stage, ui_stack, api_stack, msg)

	return text
end


-------------------------------------
-- function getUIStack
------------------------------------- 
function ErrorTracker:getUIStack()
    local ui_str = ''

    for _, ui in pairs(table.reverse(UIManager.m_uiList)) do
        ui_str = ui_str .. '    - ' .. ui.m_uiName .. ' / ' .. ui.m_resName .. '\n'
    end

    return ui_str
end

-------------------------------------
-- function getAPIStack
------------------------------------- 
function ErrorTracker:getAPIStack()
    local str = ''

    for _, t_api in pairs(table.reverse(self.m_lAPIList)) do
        str = str .. '    - ' .. t_api['time'] .. ' : ' .. t_api['api'] .. '\n'
    end

    return str
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

    local time = Timer:getServerTime()
    time = datetime.strformat(time)
    table.insert(self.m_lAPIList, {api = s, time = time})
    if (#self.m_lAPIList > 5) then
        table.remove(self.m_lAPIList, 1)
    end
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