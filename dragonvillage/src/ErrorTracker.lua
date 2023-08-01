-------------------------------------
---@class ErrorTracker
-- @brief Error, Bug 관련 정보 수집
-------------------------------------
ErrorTracker = class({
	lastScene = 'get_set_gen',
    lastStage = 'get_set_gen',

    m_lSkillHistoryList = 'list<table>',
    
    m_lAPIList = 'list<table>',
    m_lFailedResList = 'list<string>',
    m_tDeviceInfo = 'table',
    m_bErrorPopupOpen = 'bool',

    m_lBattleHistoryList = 'list<table>',
    m_battleLogHistoryTime = 'number',

    m_msgAutoLoginFailedMsg = 'string',
})

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function ErrorTracker:init()
    self.lastStage = 0
    self.m_battleLogHistoryTime = 0
    self.m_lSkillHistoryList = {}
    self.m_lBattleHistoryList = {}
    self.m_lAPIList = {}
    self.m_lFailedResList = {}
    self.m_bErrorPopupOpen = false

    -- @ generator
    -- getsetGenerator(ErrorTracker, 'ErrorTracker')
end

-------------------------------------
-- function getInstance
---@return ErrorTracker
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
    local date = datetime.strformat(ServerTime:getInstance():getCurrentTimestampSeconds()) or ''

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
============[ERROR TRACEBACK]==============
%s

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
-------------------------------------------
]]

	local text = string.format(
        template,
        msg,
        date, nick, uid, os, ver, 
        last_stage, skill_stack, 
        ui_stack, 
        api_stack, 
        res_stack
        )

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
-- function getBattleSkillHistoryStack
------------------------------------- 
function ErrorTracker:getBattleSkillHistoryStack()
    if (#self.m_lBattleHistoryList == 0) then
        return ''
    end

    local ui_str = '\n'

    for _, t_history in pairs(table.reverse(self.m_lBattleHistoryList)) do
        ui_str = ui_str .. '        - ' .. t_history .. '\n'
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
-- function getUIStackForPayRoute
------------------------------------- 
function ErrorTracker:getUIStackForPayRoute()
    local ui_str = ''

    local max_count = 5
    local count = 1

    for i = #UIManager.m_uiList, 1, -1 do
        local ui = UIManager.m_uiList[i]
        if (ui.m_uiName == 'UI_BlockPopup') 
            or (ui.m_uiName == 'UI_Network') 
            or (ui.m_uiName == 'UI_ObtainToastPopup') 
            or (ui.m_uiName == 'untitled') then
        else
            if (count > max_count) then
                break
            end
            ui_str = ui.m_uiName .. '/' .. ui_str
			count = count + 1
        end
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
-- function appendBattleSkillHistory
------------------------------------- 
function ErrorTracker:appendBattleSkillHistory(t_skill, char_name, sec)
    local sec = math_floor(sec)
    local m = math_floor(sec / 60)
    local s = sec % 60
    local str = string.format('[%02d:%02d]', m, s)
    local skill_type = t_skill['r_s_name'] or '몬스터 스킬'

    local msg = string.format('%s %s[%s:%d] 시전자[%s]',str, skill_type, t_skill['t_name'], tonumber(t_skill['sid']), char_name)
    self:appendBattleHistory(msg)
end

-------------------------------------
-- function appendBattleKeyInputHistory
------------------------------------- 
function ErrorTracker:appendBattleKeyInputHistory(input_type, sec)
    local sec = math_floor(sec)
    local m = math_floor(sec / 60)
    local s = sec % 60
    local str = string.format('[%02d:%02d]', m, s)
    local msg = string.format('%s 터치이벤트[%s]',str, input_type)
    self:appendBattleHistory(msg)
end

-------------------------------------
-- function appendBattleHistory
------------------------------------- 
function ErrorTracker:appendBattleHistory(msg)
    table.insert(self.m_lBattleHistoryList, msg)
    if (#self.m_lBattleHistoryList > 60) then
        table.remove(self.m_lBattleHistoryList, 1)
    end
end

-------------------------------------
-- function appendAPI
------------------------------------- 
function ErrorTracker:appendAPI(s)
    local time = ServerTime:getInstance():getCurrentTimestampSeconds()
    time = os.date('%Y-%m-%d %H:%M:%S', time)

    table.insert(self.m_lAPIList, {api = s, time = time})
    if (#self.m_lAPIList > 10) then
        table.remove(self.m_lAPIList, 1)
    end
end

-------------------------------------
-- function appendFailedRes
------------------------------------- 
function ErrorTracker:appendFailedRes(s)
    table.insert(self.m_lFailedResList, s)
    if (#self.m_lFailedResList > 10) then
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
    if (type(s) == 'number') then
        self.lastStage = s
    end
end

-------------------------------------
-- function get_lastStage
------------------------------------- 
function ErrorTracker:get_lastStage()
    return self.lastStage
end

-------------------------------------
-- function cleanupIngameLog
------------------------------------- 
function ErrorTracker:cleanupIngameLog()
    self.lastStage = 0
    self.m_lSkillHistoryList = {}
    self.m_bErrorPopupOpen = false
end

-------------------------------------
-- function cleanupIngameBattleLog
------------------------------------- 
function ErrorTracker:cleanupIngameBattleLog()
    self.m_lBattleHistoryList = {}
    self.m_battleLogHistoryTime = 0
end

-------------------------------------
-- function openErrorPopup
------------------------------------- 
function ErrorTracker:openErrorPopup(error_msg)
    cclog('############## openErrorPopup start')

    -- 패치 또는 모듈 로딩 시 없을 수 있음
    if (not UI_ErrorPopup) or (not UI_ErrorPopup_Live) then
        return
    end

    -- 이미 열려있는 경우 중복 호출 막음
    if (self.m_bErrorPopupOpen) then
        return
    end

    -- 중복 호출 막도록 설정
    self.m_bErrorPopupOpen = true
    
    -- UI 종료 시 다시 호출 가능 상태로 전환
    local function close_cb()
        self.m_bErrorPopupOpen = false
    end

    -- 테스트 모드일 경우 상세 정보 출력
    if (IS_TEST_MODE()) then
        local msg = self:getTrackerText(error_msg)
		UI_ErrorPopup(msg):setCloseCB(close_cb)
        
    -- 라이브일 경우
    else
        local msg = error_msg
        UI_ErrorPopup_Live(error_msg):setCloseCB(close_cb)

    end
    cclog('############## openErrorPopup end')
end

-------------------------------------
-- LIVE 용
-------------------------------------

-------------------------------------
-- function sendErrorLog
------------------------------------- 
function ErrorTracker:sendErrorLog(msg, success_cb, msg_key)
    -- device info는 추려서 넣도록 함
    if (not self.m_tDeviceInfo) then
        self.m_tDeviceInfo = {}
    end

	local device_str = self:getDeviceStr()

    local uid = 'nil'
    local nick = 'nil'

    if g_userData then
        uid = tostring(g_userData:get('uid'))
        nick = tostring(g_userData:get('nick'))
    elseif g_localData then
        uid = tostring(g_localData:get('local', 'uid'))
        nick = tostring(g_localData:get('local', 'nick'))
    end

    local curr_memory = collectgarbage('count') or 0
    curr_memory = math.floor(curr_memory / 1024)
    curr_memory = tonumber(curr_memory) or 0
    local global_var = table.count(_G)

    -- 파라미터 셋팅
    local t_json = {
        ['id'] = HMAC('sha1', msg_key or msg, CONSTANT['HMAC_KEY'], false), -- HMAC으로 고유ID 생성
        ['uid'] = uid,
        ['nick'] = nick,
        ['os'] = getTargetOSName(),
        ['ver_info'] = PatchData:getInstance():getAppVersionAndPatchIdxString(),
        ['date'] = datetime.strformat(ServerTime:getInstance():getCurrentTimestampSeconds()),
        
        ['error_stack'] = msg,
        ['error_stack_header'] = self:getStackHeader(msg),        
        
        ['device'] = device_str,
        ['memory(MB)'] = curr_memory,
        ['global_var'] = global_var,

        ['failed_res_list'] = self.m_lFailedResList,
        
        ['api_call_list'] = self:getAPIStack_Kibana(),
        ['ui_list'] = self:getUINameList_Kibana(),
        
        ['last_scene'] = self.lastScene,
        ['last-stage'] = self.lastStage,
    } 

    local t_data = {
        ['json_str'] = dkjson.encode(t_json)
    }

    -- 요청 정보 설정
    local t_request = {}
    t_request['url'] = '/crashlog'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    -- 성공 시 콜백 함수
    t_request['success'] = function(ret)
        if (success_cb) then
            success_cb(ret)
        end
    end

    -- 실패 시 콜백 함수
    t_request['fail'] = function(ret)
        if (success_cb) then
            success_cb(ret)
        end
    end

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function getAPIStack_Kibana
------------------------------------- 
function ErrorTracker:getAPIStack_Kibana()
    local l_ret = {}
    for i, t_api in pairs(self.m_lAPIList) do
        table.insert(l_ret, string.format('%s : %s', t_api['time'], t_api['api']))
    end
    return l_ret
end

-------------------------------------
-- function getUINameList_Kibana
------------------------------------- 
function ErrorTracker:getUINameList_Kibana()
    local l_ret = {}
    for i, ui in pairs(UIManager.m_uiList) do
        table.insert(l_ret, string.format('%s (%s)', ui.m_uiName, ui.m_resName))
    end
    return l_ret
end

-------------------------------------
-- function getStackHeader
------------------------------------- 
function ErrorTracker:getStackHeader(msg)
    local l_stack = plSplit(msg, '\n')
    if (l_stack) and (type(l_stack) == 'table') then
        return l_stack[1]
    end
    return nil
end

-------------------------------------
-- function callDeviceInfo
-- @brief 기기 정보 가져옴
------------------------------------- 
function ErrorTracker:callDeviceInfo()
    if (not self.m_tDeviceInfo) then
        if (SDKManager) then
            local function cb_func(ret, info)
                self.m_tDeviceInfo = json_decode(info)
            end
            SDKManager:deviceInfo(cb_func)
        end
    end
end

-------------------------------------
-- function getDeviceStr
------------------------------------- 
function ErrorTracker:getDeviceStr()
    local model, os_ver
    if (CppFunctions:isIos()) then
        model = self.m_tDeviceInfo['device']
        os_ver = self.m_tDeviceInfo['systemVersion']
    else
        model = self.m_tDeviceInfo['MODEL']
        os_ver = self.m_tDeviceInfo['VERSION_RELEASE']
    end
    return string.format('model : %s // os_ver : %s', tostring(model), tostring(os_ver))
end

-------------------------------------
-- function getDevice
------------------------------------- 
function ErrorTracker:getDevice()
    local model
    if (CppFunctions:isIos()) then
        model = self.m_tDeviceInfo['device']
    else
        model = self.m_tDeviceInfo['MODEL']
    end

    return model
end

-------------------------------------
-- function setAutoLoginFailedMsg
------------------------------------- 
function ErrorTracker:setAutoLoginFailedMsg(msg)
    self.m_msgAutoLoginFailedMsg = msg
end

-------------------------------------
-- function sendErrorLog_AutoLoginFailed
-- @brief 자동 로그인 풀린다는 유저 제보 확인용 에러 로그(확인 후 제거할 예정)
------------------------------------- 
function ErrorTracker:sendErrorLog_AutoLoginFailed()
    if self.m_msgAutoLoginFailedMsg == nil then
        return
    end

    local uid = g_userData:get('uid')
    -- 해당 유저가 아니면 에러 로그를 남기지 않음
    if uid ~=  'jEleYjqjPSfOk5ylW1rGZZVM2vO2' then
        return
    end

    self:sendErrorLog(self.m_msgAutoLoginFailedMsg)
    self.m_msgAutoLoginFailedMsg = nil
end

-------------------------------------
-- function sendErrorLog_RaidBattleLogHistory
-- @brief 레이드 이상 점수 확인용 로그
------------------------------------- 
function ErrorTracker:sendErrorLog_RaidBattleLogHistory(sec)
    if (#self.m_lBattleHistoryList == 0) then
        return
    end

    local log_time = 60 * 15 -- 15분
    if self.m_battleLogHistoryTime == 0 then
        self.m_battleLogHistoryTime = log_time
        return
    end

    -- id : d5e9132291b3ea4a1ba74df0d5b6fbb4f6b04253 로 검색
    if sec > self.m_battleLogHistoryTime then
       local msg = self:getBattleSkillHistoryStack()
       self:sendErrorLog(msg, nil, 'ErrorTracker:sendErrorLog_RaidBattleLogHistory()')
       --cclog(msg)
       self.m_battleLogHistoryTime = sec + log_time
    end
end

-------------------------------------
-- function sendIncompletePurchaseLog
-- @brief 미지급 결제건에 대한 처리 로그
------------------------------------- 
function ErrorTracker:sendIncompletePurchaseLog(sku, order_id, purchase_token , success_cb)
    -- device info는 추려서 넣도록 함
    if (not self.m_tDeviceInfo) then
        self.m_tDeviceInfo = {}
    end

	local device_str = self:getDeviceStr()
    local uid = 'nil'
    local nick = 'nil'

    if g_userData then
        uid = tostring(g_userData:get('uid'))
        nick = tostring(g_userData:get('nick'))
    elseif g_localData then
        uid = tostring(g_localData:get('local', 'uid'))
        nick = tostring(g_localData:get('local', 'nick'))
    end

    local curr_memory = collectgarbage('count') or 0
    curr_memory = math.floor(curr_memory / 1024)
    curr_memory = tonumber(curr_memory) or 0
    local global_var = table.count(_G)

    -- 파라미터 셋팅
    local t_json = {
        ['id'] = HMAC('sha1', msg_key or msg, CONSTANT['HMAC_KEY'], false), -- HMAC으로 고유ID 생성
        ['uid'] = uid,
        ['nick'] = nick,
        ['os'] = getTargetOSName(),
        ['ver_info'] = PatchData:getInstance():getAppVersionAndPatchIdxString(),
        ['date'] = datetime.strformat(ServerTime:getInstance():getCurrentTimestampSeconds()),
        
        ['order_id'] = order_id,
        ['purchase_token'] = purchase_token,
        ['sku'] = sku,
        
        ['device'] = device_str,
        ['memory(MB)'] = curr_memory,
        ['global_var'] = global_var,
    }

    local t_data = {
        ['json_str'] = dkjson.encode(t_json)
    }

    -- 요청 정보 설정
    local t_request = {}
    t_request['url'] = '/incomplete_purchase'
    t_request['method'] = 'POST'
    t_request['data'] = t_data

    -- 성공 시 콜백 함수
    t_request['success'] = function(ret)
        if (success_cb) then
            success_cb(ret)
        end
    end

    -- 실패 시 콜백 함수
    t_request['fail'] = function(ret)
        if (success_cb) then
            success_cb(ret)
        end
    end

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
end
