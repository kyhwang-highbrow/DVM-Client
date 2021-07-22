-------------------------------------
-- class ServerData_Highlight
-------------------------------------
ServerData_Highlight = class({
        m_serverData = 'ServerData',

		m_isDirtyHighlight = 'bool',

        -- 서버에서 넘겨받는 값
        ----------------------------------------------
        attendance_reward = '',
        attendance_event_reward = '',
        quest_reward = '',
        explore_reward = '',
        summon_free = '',
        new_mail = '',
        new_notice = '',
        invite = '',
        fpoint_send = '',
		daily_mission_clan = '',
        ----------------------------------------------

        ----------------------------------------------
        m_newOidMap = 'map',
        m_bDirtyNewOidMapDragon = 'boolean',
		m_bDirtyNewOidMapRune = 'boolean',

        m_bRequestingHighlight = 'boolean',
        ----------------------------------------------
    })

local NEW_OID_TYPE_DRAGON = 'dragon'
local NEW_OID_TYPE_RUNE = 'rune'
local DAY_TO_SEC = 60 * 60 * 24

-------------------------------------
-- function init
-------------------------------------
function ServerData_Highlight:init(server_data)
    self.m_serverData = server_data

	self.m_isDirtyHighlight = true

    self.attendance_reward = 0
    self.attendance_event_reward = 0
    self.quest_reward = 0
    self.explore_reward = 0
    self.summon_free = 0
    self.new_mail = 0
end

-------------------------------------
-- function isDirty
-------------------------------------
function ServerData_Highlight:isDirty()
	return self.m_isDirtyHighlight
end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_Highlight:setDirty(b)
	self.m_isDirtyHighlight = b
end

-------------------------------------
-- function request_highlightInfo
-------------------------------------
function ServerData_Highlight:request_highlightInfo(finish_cb, fail_cb)
    if (self.m_bRequestingHighlight) then return end

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_bRequestingHighlight = false

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

    self.m_bRequestingHighlight = true

    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
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

    self:setDirty(false)
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
    -- 퀘스트 받을 보상이 있다면 노티
	if (0 < self['quest_reward']) then
		return true
	end

	-- 퀘스트 받을 보상이 없다면 컨텐츠 퀘스트 부분도 확인
	if (g_contentLockData:isRewardableContentQuest()) then
		return true
	end

	return false
end

-------------------------------------
-- function isHighlightMail
-------------------------------------
function ServerData_Highlight:isHighlightMail()
    local new_mail = self['new_mail']
    local new_notice = (self['new_notice'] - g_mailData.m_excludedNoticeCnt)

    return (0 < new_mail) or (0 < new_notice)
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
-- function isHighlighDailyMissionClan
-------------------------------------
function ServerData_Highlight:isHighlighDailyMissionClan()
    return (0 < self['daily_mission_clan'])
end

-------------------------------------
-- function isHighlightDragon
-------------------------------------
function ServerData_Highlight:isHighlightDragon()
	if (not self.m_newOidMap[NEW_OID_TYPE_DRAGON]) then
		return false
	end

    local cnt = table.count(self.m_newOidMap[NEW_OID_TYPE_DRAGON])

    if (0 < cnt) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function isHighlightRune
-------------------------------------
function ServerData_Highlight:isHighlightRune()
	if (not self.m_newOidMap[NEW_OID_TYPE_RUNE]) then
		return false
	end

    local cnt = table.count(self.m_newOidMap[NEW_OID_TYPE_RUNE])

    if (0 < cnt) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getNewRuneSlotTable
-------------------------------------
function ServerData_Highlight:getNewRuneSlotTable()
	if (not self.m_newOidMap[NEW_OID_TYPE_RUNE]) then
		return false
	end

	local t_ret = {}
	for roid, b in pairs(self.m_newOidMap[NEW_OID_TYPE_RUNE]) do
		local struct_rune = g_runesData:getRuneObject(roid)
		if (struct_rune) then
			local slot = struct_rune['slot']
			t_ret[slot] = true
		end
	end

	return t_ret
end

-------------------------------------
-- function getNewOidMapFileName
-------------------------------------
function ServerData_Highlight:getNewOidMapFileName(oid_type)
    local file = string.format('new_oid_map_%s.json', oid_type)
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
    self.m_bDirtyNewOidMapDragon = false
	self.m_bDirtyNewOidMapRune = false
end

-------------------------------------
-- function setDirtyNewOidMap
-------------------------------------
function ServerData_Highlight:setDirtyNewOidMap(oid_type)
	if (oid_type == 'dragon') then
		self.m_bDirtyNewOidMapDragon = true
	elseif (oid_type == 'rune') then
		self.m_bDirtyNewOidMapRune = true
	end
end

-------------------------------------
-- function loadNewDoidMap
-------------------------------------
function ServerData_Highlight:loadNewDoidMap()
    self.m_newOidMap = {
		[NEW_OID_TYPE_DRAGON] = {},
		[NEW_OID_TYPE_RUNE] = {}
	}
    self.m_bDirtyNewOidMapDragon = false
	self.m_bDirtyNewOidMapRune = false

    local ret_json_dragon, success_load_d = LoadLocalSaveJson(self:getNewOidMapFileName(NEW_OID_TYPE_DRAGON))
	local ret_json_rune, success_load_r = LoadLocalSaveJson(self:getNewOidMapFileName(NEW_OID_TYPE_RUNE))

    if (success_load_d) then
        self.m_newOidMap[NEW_OID_TYPE_DRAGON] = ret_json_dragon
	end
	if (success_load_r) then
		self.m_newOidMap[NEW_OID_TYPE_RUNE] = ret_json_rune
	end

	-- 변수 선언
    local dragons_map = g_dragonsData:getDragonsListRef()
	local runes_map = g_runesData:getRuneList()
    local curr_time = Timer:getServerTime()

    -- 신규 오브젝트가 삭제 되었을 경우를 체크하여 보정
    for oid_type, t_oid in pairs(self.m_newOidMap) do
		for oid, _ in pairs(t_oid) do
			local object_data 
			if (oid_type == NEW_OID_TYPE_DRAGON) then
				object_data = dragons_map[oid]
			elseif (oid_type == NEW_OID_TYPE_RUNE) then
				object_data = runes_map[oid]

                -- 드래곤에 장착된 룬이라면 new를 붙이지 않음
                if (object_data and object_data:isEquippedRune()) then
                    self.m_newOidMap[oid_type][oid] = nil
                end
			end

			-- 드래곤 정보가 없는 경우 삭제
			if (not object_data) then
				self.m_newOidMap[oid_type][oid] = nil

			-- 드래곤 생성 시간 확인
			elseif object_data['created_at'] then
				local _created_at = (object_data['created_at'] / 1000)

				-- 24시간이 지난 드래곤은 new를 붙이지 않음
				if (_created_at + DAY_TO_SEC) <= curr_time then
					self.m_newOidMap[oid_type][oid] = nil
				end
			end
		end
    end
end

-------------------------------------
-- function saveNewDoidMap
-------------------------------------
function ServerData_Highlight:saveNewDoidMap()
	if (self.m_bDirtyNewOidMapDragon) then
		SaveLocalSaveJson(self:getNewOidMapFileName(NEW_OID_TYPE_DRAGON), self.m_newOidMap[NEW_OID_TYPE_DRAGON])
		self.m_bDirtyNewOidMapDragon = false
	end
	if (self.m_bDirtyNewOidMapRune) then
		SaveLocalSaveJson(self:getNewOidMapFileName(NEW_OID_TYPE_RUNE), self.m_newOidMap[NEW_OID_TYPE_RUNE])
		self.m_bDirtyNewOidMapRune = false
	end

	-- 로비 노티 갱신 : 신규 룬 또는 드래곤 획득 시
	self:setDirty(true)
end

-------------------------------------
-- function addNewDoid
-------------------------------------
function ServerData_Highlight:addNewDoid(oid, created_at)
	self:addNewOid(NEW_OID_TYPE_DRAGON, oid, created_at)
end

-------------------------------------
-- function addNewRoid
-------------------------------------
function ServerData_Highlight:addNewRoid(oid, created_at)
	self:addNewOid(NEW_OID_TYPE_RUNE, oid, created_at)
end

-------------------------------------
-- function addNewOid
-------------------------------------
function ServerData_Highlight:addNewOid(oid_type, oid, created_at)
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

        -- 24시간이 지난 드래곤은 new를 붙이지 않음
        if (_created_at + DAY_TO_SEC) <= curr_time then
            return
        end
    end

    if (self.m_newOidMap[oid_type][oid] == true) then
        return
    end

    self.m_newOidMap[oid_type][oid] = true
    self:setDirtyNewOidMap(oid_type)
end

-------------------------------------
-- function removeNewDoid
-------------------------------------
function ServerData_Highlight:removeNewDoid(oid)
	self:removeNewOid(NEW_OID_TYPE_DRAGON, oid)
end

-------------------------------------
-- function removeNewRoid
-------------------------------------
function ServerData_Highlight:removeNewRoid(oid)
	self:removeNewOid(NEW_OID_TYPE_RUNE, oid)
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
    self:setDirtyNewOidMap(oid_type)

	-- 로비 노티 갱신 : 신규 룬 또는 드래곤 해제 시
	self:setDirty(true)
end

-------------------------------------
-- function isNewDoid
-------------------------------------
function ServerData_Highlight:isNewDoid(oid)
    return self:isNewOid(NEW_OID_TYPE_DRAGON, oid)
end

-------------------------------------
-- function isNewRoid
-------------------------------------
function ServerData_Highlight:isNewRoid(oid)
    return self:isNewOid(NEW_OID_TYPE_RUNE, oid)
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
-- function setHighlightMail
-------------------------------------
function ServerData_Highlight:setHighlightMail()
    if (self['new_mail'] <= 0) then
        self['new_mail'] = 1
		self:setDirty(true)
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
-- function clearNewOidMapFile
-------------------------------------
function ServerData_Highlight:clearNewOidMapFile()
	-- 신규 드래곤 정보 삭제
	local path_dragon = self:getNewOidMapFileName(NEW_OID_TYPE_DRAGON)
	os.remove(path_dragon)

	-- 신규 룬 정보 삭제
	local path_rune = self:getNewOidMapFileName(NEW_OID_TYPE_RUNE)
	os.remove(path_rune)
end