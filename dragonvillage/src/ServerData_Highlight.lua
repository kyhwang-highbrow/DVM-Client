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
        m_newOidMap = 'map',
        m_bDirtyNewOidMap = 'boolean',
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
	if (not self.m_newOidMap['dragon']) then
		return false
	end

    local cnt = table.count(self.m_newOidMap['dragon'])

    if (0 < cnt) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getNewOidMapFileName
-------------------------------------
function ServerData_Highlight:getNewOidMapFileName()
    local file = 'new_oid_map.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function cleanNewDoidMap
-- @brief 로그인 시점에서 드래곤 정보를 받아올 때
--        m_newOidMap이 nil이어야 새로운 드래곤으로 취급하지 않음
-------------------------------------
function ServerData_Highlight:cleanNewDoidMap()
    self.m_newOidMap = nil
    self.m_bDirtyNewOidMap = false
end

-------------------------------------
-- function setDirtyNewDoidMap
-------------------------------------
function ServerData_Highlight:setDirtyNewDoidMap()
    self.m_bDirtyNewOidMap = true
end

-------------------------------------
-- function loadNewDoidMap
-------------------------------------
function ServerData_Highlight:loadNewDoidMap()
    self.m_newOidMap = {}
    self.m_bDirtyNewOidMap = false

    local ret_json, success_load = LoadLocalSaveJson(self:getNewOidMapFileName())
    if (success_load == true) then
        self.m_newOidMap = ret_json
	else
		self.m_newOidMap = {
			['dragon'] = {},
			['rune'] = {}
		}
    end

	-- 변수 선언
    local dragons_map = g_dragonsData:getDragonsListRef()
	local runes_map = g_runesData:getRuneList()
    local curr_time = Timer:getServerTime()
    local valid_sec = 60 * 60 * 24 -- 24시간

    -- 신규 오브젝트가 삭제 되었을 경우를 체크하여 보정
    for oid_type, t_oid in pairs(self.m_newOidMap) do
		for oid, _ in pairs(t_oid) do
			local object_data 
			if (oid_type == 'dragon') then
				object_data = dragons_map[oid]
			elseif (oid_type == 'rune') then
				object_data = runes_map[oid]
			end

			-- 드래곤 정보가 없는 경우 삭제
			if (not object_data) then
				self.m_newOidMap[oid] = nil

			-- 드래곤 생성 시간 확인
			elseif object_data['created_at'] then
				local _created_at = (object_data['created_at'] / 1000)

				-- 24시간이 지난 드래곤은 new를 붙이지 않음
				if (_created_at + valid_sec) <= curr_time then
					self.m_newOidMap[oid] = nil
				end
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
    if (not self.m_bDirtyNewOidMap) then
        return false
    end

    local ret = SaveLocalSaveJson(self:getNewOidMapFileName(), self.m_newOidMap)
    self.m_bDirtyNewOidMap = false
    return ret
end

-------------------------------------
-- function addNewDoid
-------------------------------------
function ServerData_Highlight:addNewDoid(oid_type, oid, created_at)
    -- 로그인 시점에서 드래곤 정보를 받아올 때
    -- m_newOidMap이 nil이어야 새로운 드래곤으로 취급하지 않음
    if (not self.m_newOidMap) then
        return
    end
    if (not self.m_newOidMap[oid_type]) then
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

    if (self.m_newOidMap[oid_type][oid] == true) then
        return
    end

    self.m_newOidMap[oid_type][oid] = true
    self:setDirtyNewDoidMap()
    self.m_lastUpdateTime = curr_time
end

-------------------------------------
-- function removeNewDoid
-------------------------------------
function ServerData_Highlight:removeNewDoid(oid)
	self:removeNewOid('dragon', oid)
end

-------------------------------------
-- function removeNewRoid
-------------------------------------
function ServerData_Highlight:removeNewRoid(oid)
	self:removeNewOid('rune', oid)
end

-------------------------------------
-- function removeNewOid
-------------------------------------
function ServerData_Highlight:removeNewOid(oid_type, oid)
    if (not self.m_newOidMap) then
        return
    end
	if (not self.m_newOidMap[oid_type]) then
		return
	end
    if (not self.m_newOidMap[oid_type][oid]) then
        return
    end

    self.m_newOidMap[oid_type][oid] = nil
    self:setDirtyNewDoidMap()

    self.m_lastUpdateTime = Timer:getServerTime()
end

-------------------------------------
-- function isNewDoid
-------------------------------------
function ServerData_Highlight:isNewDoid(oid)
    return self:isNewOid('dragon', oid)
end

-------------------------------------
-- function isNewRoid
-------------------------------------
function ServerData_Highlight:isNewRoid(oid)
    return self:isNewOid('rune', oid)
end

-------------------------------------
-- function isNewOid
-------------------------------------
function ServerData_Highlight:isNewOid(oid_type, oid)
    if (not self.m_newOidMap) then
        return false
    end
	if (not self.m_newOidMap[oid_type]) then
		return false
	end

    if self.m_newOidMap[oid_type][oid] then
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

-------------------------------------
-- function onChangeScene
-- @brief Scene이 변경될 때 호출
-------------------------------------
function ServerData_Highlight:onChangeScene()
    self:saveNewDoidMap()
end

-------------------------------------
-- function setLastUpdateTime
-- @brief
-------------------------------------
function ServerData_Highlight:setLastUpdateTime()
    self.m_lastUpdateTime = Timer:getServerTime()
end