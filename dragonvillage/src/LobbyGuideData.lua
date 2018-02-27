---------------------------------------------------------------------------------------------------------------
-- @brief 로비에서 마스터의 길 UI를 활용한 각종 안내에 사용되는 데이터 저장 장소
-- @date 2018.02.27 sgkim
---------------------------------------------------------------------------------------------------------------

-------------------------------------
-- class LobbyGuideData
-------------------------------------
LobbyGuideData = class({
        m_rootTable = 'table',
        m_rootTableDefault = 'table',

        m_nLockCnt = 'number',
        m_bDirtyDataTable = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuideData:init()
    self.m_rootTable = nil
    self.m_rootTableDefault = nil
    self.m_nLockCnt = 0
    self.m_bDirtyDataTable = false
end

-------------------------------------
-- function getInstance
-------------------------------------
function LobbyGuideData:getInstance()
    if g_LobbyGuideData then
        return g_LobbyGuideData
    end
    
    g_LobbyGuideData = LobbyGuideData()
    g_LobbyGuideData:loadLobbyGuideDataFile()

    return g_LobbyGuideData
end

-------------------------------------
-- function getLobbyGuideDataSaveFileName
-------------------------------------
function LobbyGuideData:getLobbyGuideDataSaveFileName()
    local file = 'lobby_guide_data.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadLobbyGuideDataFile
-------------------------------------
function LobbyGuideData:loadLobbyGuideDataFile()
    local ret_json, success_load = LoadLocalSaveJson(self:getLobbyGuideDataSaveFileName())

    if (success_load == true) then
        self.m_rootTable = ret_json
    else
        self.m_rootTable = self:makeDefaultLobbyGuideData()
        self:saveLobbyGuideDataFile()
    end

    self.m_rootTableDefault = self:makeDefaultLobbyGuideData()
end

-------------------------------------
-- function makeDefaultLobbyGuideData
-------------------------------------
function LobbyGuideData:makeDefaultLobbyGuideData()
    local root_table = {}
    return root_table
end

-------------------------------------
-- function saveLobbyGuideDataFile
-------------------------------------
function LobbyGuideData:saveLobbyGuideDataFile()
    if (self.m_nLockCnt > 0) then
        self.m_bDirtyDataTable = true
        return
    end

    return SaveLocalSaveJson(self:getLobbyGuideDataSaveFileName(), self.m_rootTable, true) -- param : filename, t_data, skip_xor)
end

-------------------------------------
-- function clearLobbyGuideDataFile
-------------------------------------
function LobbyGuideData:clearLobbyGuideDataFile()
    os.remove(self:getLobbyGuideDataSaveFileName())
end


-------------------------------------
-- function applyLobbyGuideData
-- @brief 서버로부터 받은 정보로 세이브 데이터를 갱신
-------------------------------------
function LobbyGuideData:applyLobbyGuideData(data, ...)
    local args = {...}
    local cnt = #args

    local dirty = false

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                container[key] = {}
                dirty = true
            end
            container = container[key]
        else
            if (container[key] ~= data) then
                if (data ~= nil) then
                    container[key] = clone(data)
                else
                    container[key] = nil
                end
                dirty = true
            end
        end
    end

    -- 변경사항이 있을 때에만 저장
    if dirty then
        self:saveLobbyGuideDataFile()
    end
end

-------------------------------------
-- function getFunc
-- @brief
-------------------------------------
function LobbyGuideData:getFunc(target_table, ...)
    local args = {...}
    local cnt = #args

    if (not target_table) then
        return nil
    end

    local container = target_table
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return clone(container[key])
            end
        end
    end

    return nil
end

-------------------------------------
-- function get
-- @brief
-------------------------------------
function LobbyGuideData:get(...)
    local ret = self:getFunc(self.m_rootTable, ...)

    if (ret == nil) then
        return self:getFunc(self.m_rootTableDefault, ...)
    end

    return ret
end

-------------------------------------
-- function getRef
-- @brief
-------------------------------------
function LobbyGuideData:getRef(...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return container[key]
            end
        end
    end

    return nil
end

-------------------------------------
-- function lockSaveData
-- @breif
-------------------------------------
function LobbyGuideData:lockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt + 1)
end

-------------------------------------
-- function unlockSaveData
-- @breif
-------------------------------------
function LobbyGuideData:unlockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt -1)

    if (self.m_nLockCnt <= 0) then
        if self.m_bDirtyDataTable then
            self:saveLobbyGuideDataFile()
        end
        self.m_bDirtyDataTable = false
    end
end

-------------------------------------
-- function getLobbyGuideSeen
-- @breif
-------------------------------------
function LobbyGuideData:getLobbyGuideSeen(guide_mode)
    return self:get('lobby_guide_seen', guide_mode)
end

-------------------------------------
-- function setLobbyGuideSeen
-- @breif
-------------------------------------
function LobbyGuideData:setLobbyGuideSeen(guide_mode)
    self:applyLobbyGuideData(true, 'lobby_guide_seen', guide_mode)
end

-------------------------------------
-- function clearDataList
-- @breif
-------------------------------------
function LobbyGuideData:clearDataList(key)
	local list = g_LobbyGuideData:get(key)
	if (not list) then 
		return
	end

    for k, v in pairs(list) do
        g_LobbyGuideData:applyLobbyGuideData(false, key, k)
    end
end

-------------------------------------
-- function clearDataListDaily
-- @breif
-------------------------------------
function LobbyGuideData:clearDataListDaily()
	self:lockSaveData()
	self:clearDataList('lobby_guide_seen')
	self:unlockSaveData()
end