-------------------------------------
-- class ErrorTracker
-- @brief Error, Bug 관련 정보 수집
-------------------------------------
ErrorTracker = class({
	lastScene = 'get_set_gen',
    lastStage = 'get_set_gen',

    m_lSkillHistoryList = 'list<table>',
    m_lAPIList = 'list<table>',
    m_lFailedResList = 'list<string>',
})

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function ErrorTracker:init()
    self.m_lSkillHistoryList = {}
    self.m_lAPIList = {}
    self.m_lFailedResList = {}
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
-- function getTrackerText_
------------------------------------- 
function ErrorTracker:getTrackerText_(msg)
    -- 시간 기록
    local date = datetime.strformat(TimeLib:initInstance():getServerTime()) or ''

    -- 닉네임 기록
    local nick = ''
    if (g_userData and g_userData.get) then
        nick = g_userData:get('nick') or ''
    end

    -- UID 기록
    local uid = ''
    if (g_userData and g_userData.get) then
        uid = tostring(g_userData:get('uid')) or ''
    end

    -- OS 기록
    local os = ''
    if getTargetOSName then
        os = getTargetOSName() or ''
    end
    
    -- 버전 기록
    local ver = ''
    ver = PatchData:getInstance():getAppVersionAndPatchIdxString() or ''

    -- 마지막 플레이 스테이지
    local last_stage = self:get_lastStage() or ''

    -- 마지막 사용 스킬
    local skill_stack = self:getSkillHistoryStack() or ''

    -- 마지막 사용 UI
	local ui_stack = self:getUIStack() or ''

    -- 마지막 사용 API
    local api_stack = self:getAPIStack() or ''
    
    -- 마지막 리소스 로드 실패
    local res_stack = self:getFailedResStack() or ''

    local msg = msg or 'error'
   
    local template = 
[[
=============[DVM BUG REPORT]==============
1. info
    - date : %s
    - nick : %s
    - uid : %s
    - os : %s
    - info : %s
 
2. ingame
    - stage_id : %s
    - skill use history : %s
 
3. UI list
%s
 
4. recent called API list
%s
 
5. failed res list
%s
 
============[ERROR TRACEBACK]==============
%s
]]

	local text = string.format(template, 
        date, nick, uid, os, ver, 
        last_stage, skill_stack, 
        ui_stack, 
        api_stack, 
        res_stack, 
        msg)

	return text
end

-------------------------------------
-- function getTrackerText
------------------------------------- 
function ErrorTracker:getTrackerText(msg)

    -- 기본적으로 넘어온 메시지를 출력
    local error_msg = msg

    local function func()
        -- 디테일한 에러 메시지를 받아옴
        error_msg = self:getTrackerText_(msg)
    end

    -- 디테일한 에러 메시지를 받아오는 과정에서 에러가 발생했을 때 처리
    local status, msg = xpcall(func, __G__TRACKBACK__)
    if (not status) then
    end

    return error_msg
end

-------------------------------------
-- function getSkillHistoryStack
------------------------------------- 
function ErrorTracker:getSkillHistoryStack()
    if (#self.m_lSkillHistoryList == 0) then
        return ''
    end

    local ui_str = '\n'

    for _, t_history in pairs(table.reverse(self.m_lSkillHistoryList)) do
        ui_str = ui_str .. '        - ' .. t_history['name'] .. ' : ' .. t_history['id'] .. '\n'
    end

    return ui_str
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
-- function getFailedResStack
------------------------------------- 
function ErrorTracker:getFailedResStack()
    local str = ''

    for _, res in pairs(table.reverse(self.m_lFailedResList)) do
        str = str .. '    - ' .. res .. '\n'
    end

    return str
end

-------------------------------------
-- function appendSkillHistory
------------------------------------- 
function ErrorTracker:appendSkillHistory(skill_id, char_name)
    table.insert(self.m_lSkillHistoryList, {id = skill_id, name = char_name})
    if (#self.m_lSkillHistoryList > 5) then
        table.remove(self.m_lSkillHistoryList, 1)
    end
end

-------------------------------------
-- function appendAPI
------------------------------------- 
function ErrorTracker:appendAPI(s)
    local time = Timer:getServerTime()
    time = datetime.strformat(time)

    table.insert(self.m_lAPIList, {api = s, time = time})
    if (#self.m_lAPIList > 5) then
        table.remove(self.m_lAPIList, 1)
    end
end

-------------------------------------
-- function appendFailedRes
------------------------------------- 
function ErrorTracker:appendFailedRes(s)
    table.insert(self.m_lFailedResList, s)
    if (#self.m_lFailedResList > 5) then
        table.remove(self.m_lFailedResList, 1)
    end
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


-------------------------------------
-- function appendSkillHistory
------------------------------------- 
function ErrorTracker:cleanupIngameLog()
    self.lastStage = ''
    self.m_lSkillHistoryList = {}
end

