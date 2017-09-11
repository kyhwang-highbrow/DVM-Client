-------------------------------------
-- class ServerData_Highlight
-------------------------------------
ServerData_Highlight = class({
        m_serverData = 'ServerData',

        m_lastUpdateTime = '',

        -- 서버에서 넘겨받는 값
        ----------------------------------------------
        attendance_reward = '',
        attendance_event_reward = '',
        quest_reward = '',
        explore_reward = '',
        summon_free = '',
        new_mail = '',
        invite = '',
        fpoint_send = '',
        ----------------------------------------------

        ----------------------------------------------
        m_newDoidMap = '',
        ----------------------------------------------
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Highlight:init(server_data)
    self.m_serverData = server_data

    self.attendance_reward = 0
    self.attendance_event_reward = 0
    self.quest_reward = 0
    self.explore_reward = 0
    self.summon_free = 0
    self.new_mail = 0
end

-------------------------------------
-- function request_highlightInfo
-------------------------------------
function ServerData_Highlight:request_highlightInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        self:applyHighlightInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/status')
    ui_network:setParam('uid', uid)

    -- 접속시간 저장
    local save_time = g_accessTimeData:getSaveTime()
    if (save_time) then
        ui_network:setParam('access_time', save_time)
    end

    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function applyHighlightInfo
-------------------------------------
function ServerData_Highlight:applyHighlightInfo(ret)
    local t_highlight = ret['highlight']

    if (ret == 'new_mail') then
        self['new_mail'] = 1
    end

    if (not t_highlight) then
        return
    end
    
    for key,value in pairs(t_highlight) do
        if (type(value) == 'boolean') then
            if value then
                self[key] = 1
            else
                self[key] = 0
            end
        else
            self[key] = value
        end
    end

    self.m_lastUpdateTime = Timer:getServerTime()
end

-------------------------------------
-- function isHighlightExploration
-------------------------------------
function ServerData_Highlight:isHighlightExploration()
    return (0 < self['explore_reward'])
end

-------------------------------------
-- function isHighlightDragonSummonFree
-------------------------------------
function ServerData_Highlight:isHighlightDragonSummonFree()
    return (0 < self['summon_free'])
end

-------------------------------------
-- function isHighlightQuest
-------------------------------------
function ServerData_Highlight:isHighlightQuest()
    return (0 < self['quest_reward'])
end

-------------------------------------
-- function isHighlightMail
-------------------------------------
function ServerData_Highlight:isHighlightMail()
    return (0 < self['new_mail'])
end

-------------------------------------
-- function isHighlightFpointSend
-------------------------------------
function ServerData_Highlight:isHighlightFpointSend()
    return (0 < self['fpoint_send'])
end

-------------------------------------
-- function isHighlightFrinedInvite
-------------------------------------
function ServerData_Highlight:isHighlightFrinedInvite()
    return (0 < self['invite'])
end

-------------------------------------
-- function isHighlightDragon
-------------------------------------
function ServerData_Highlight:isHighlightDragon()
    local cnt = table.count(self.m_newDoidMap)

    if (0 < cnt) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getNewDoidMapFileName
-------------------------------------
function ServerData_Highlight:getNewDoidMapFileName()
    local file = 'new_doid_map.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end


-------------------------------------
-- function cleanNewDoidMap
-- @brief 로그인 시점에서 드래곤 정보를 받아올 때
--        m_newDoidMap이 nil이어야 새로운 드래곤으로 취급하지 않음
-------------------------------------
function ServerData_Highlight:cleanNewDoidMap()
    self.m_newDoidMap = nil
end

-------------------------------------
-- function loadNewDoidMap
-------------------------------------
function ServerData_Highlight:loadNewDoidMap()
    self.m_newDoidMap = {}

    local ret_json, success_load = LoadLocalSaveJson(self:getNewDoidMapFileName())
    if (success_load == true) then
        self.m_newDoidMap = ret_json
    end

    local dragons_map = g_dragonsData:getDragonsListRef()
    local curr_time = Timer:getServerTime()

    -- 24시간
    local valid_sec = 60 * 60 * 24

    -- 신규 드래곤이라고 관리되는 doid의 드래곤이 삭제되었을 경우를 위해 보정
    for doid,_ in pairs(self.m_newDoidMap) do
        local t_dragon_data = dragons_map[doid]

        -- 드래곤 정보가 없는 경우 삭제
        if (not t_dragon_data) then
            self.m_newDoidMap[doid] = nil

        -- 드래곤 생성 시간 확인
        elseif t_dragon_data['created_at'] then
            local _created_at = (t_dragon_data['created_at'] / 1000)

            -- 24시간이 지난 드래곤은 new를 붙이지 않음
            if (_created_at + valid_sec) <= curr_time then
                self.m_newDoidMap[doid] = nil
            end
        end
    end
    self:saveNewDoidMap()

    self.m_lastUpdateTime = Timer:getServerTime()
end

-------------------------------------
-- function saveNewDoidMap
-------------------------------------
function ServerData_Highlight:saveNewDoidMap()
    return SaveLocalSaveJson(self:getNewDoidMapFileName(), self.m_newDoidMap)
end

-------------------------------------
-- function addNewDoid
-------------------------------------
function ServerData_Highlight:addNewDoid(doid, created_at)
    -- 로그인 시점에서 드래곤 정보를 받아올 때
    -- m_newDoidMap이 nil이어야 새로운 드래곤으로 취급하지 않음
    if (not self.m_newDoidMap) then
        return
    end
    
    local curr_time = Timer:getServerTime()

    -- 생성 시간 정보가 있는 경우
    if created_at then
        local _created_at = (created_at / 1000)

        -- 24시간
        local valid_sec = 60 * 60 * 24
        
        -- 24시간이 지난 드래곤은 new를 붙이지 않음
        if (_created_at + valid_sec) <= curr_time then
            return
        end
    end

    self.m_newDoidMap[doid] = true
    self:saveNewDoidMap()
    self.m_lastUpdateTime = curr_time
end

-------------------------------------
-- function removeNewDoid
-------------------------------------
function ServerData_Highlight:removeNewDoid(doid)
    if (not self.m_newDoidMap) then
        return
    end

    self.m_newDoidMap[doid] = nil
    self:saveNewDoidMap()

    self.m_lastUpdateTime = Timer:getServerTime()
end

-------------------------------------
-- function isNewDoid
-------------------------------------
function ServerData_Highlight:isNewDoid(doid)
    if (not self.m_newDoidMap) then
        return false
    end

    if self.m_newDoidMap[doid] then
        return true
    else
        return false
    end
end

-------------------------------------
-- function setLastUpdateTime
-------------------------------------
function ServerData_Highlight:setLastUpdateTime()
    self.m_lastUpdateTime = Timer:getServerTime()
end

-------------------------------------
-- function setHighlightMail
-------------------------------------
function ServerData_Highlight:setHighlightMail()
    if (self['new_mail'] <= 0) then
        self['new_mail'] = 1
        self:setLastUpdateTime()
    end
end