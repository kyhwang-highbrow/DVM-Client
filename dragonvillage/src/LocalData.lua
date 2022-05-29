-------------------------------------
-- class LocalData
-------------------------------------
LocalData = class({
        m_rootTable = 'table',
        m_rootTableDefault = 'table',

        m_nLockCnt = 'number',
        m_bDirtyDataTable = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function LocalData:init()
    self.m_rootTable = nil
    self.m_rootTableDefault = nil
    self.m_nLockCnt = 0
    self.m_bDirtyDataTable = false
end

-------------------------------------
-- function getInstance
-------------------------------------
function LocalData:getInstance()
    if g_localData then
        return g_localData
    end
    
    g_localData = LocalData()
    g_localData:loadLocalDataFile()

    return g_localData
end

-------------------------------------
-- function getLocalDataSaveFileName
-------------------------------------
function LocalData:getLocalDataSaveFileName()
    local file = 'local_data.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadLocalDataFile
-------------------------------------
function LocalData:loadLocalDataFile()
    local ret_json, success_load = LoadLocalSaveJson(self:getLocalDataSaveFileName())

    if (success_load == true) then
        self.m_rootTable = ret_json
    else
        self.m_rootTable = self:makeDefaultLocalData()
        self:saveLocalDataFile()
    end

    self.m_rootTableDefault = self:makeDefaultLocalData()
end

-------------------------------------
-- function makeDefaultLocalData
-------------------------------------
function LocalData:makeDefaultLocalData()
    local root_table = {}
    return root_table
end

-------------------------------------
-- function saveLocalDataFile
-------------------------------------
function LocalData:saveLocalDataFile()
    if (self.m_nLockCnt > 0) then
        self.m_bDirtyDataTable = true
        return
    end

    return SaveLocalSaveJson(self:getLocalDataSaveFileName(), self.m_rootTable)
end

-------------------------------------
-- function clearLocalDataFile
-------------------------------------
function LocalData:clearLocalDataFile()
    os.remove(self:getLocalDataSaveFileName())
end


-------------------------------------
-- function applyLocalData
-- @brief 서버로부터 받은 정보로 세이브 데이터를 갱신
-------------------------------------
function LocalData:applyLocalData(data, ...)
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
        self:saveLocalDataFile()
    end
end

-------------------------------------
-- function getFunc
-- @brief
-------------------------------------
function LocalData:getFunc(target_table, ...)
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
function LocalData:get(...)
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
function LocalData:getRef(...)
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
function LocalData:lockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt + 1)
end

-------------------------------------
-- function unlockSaveData
-- @breif
-------------------------------------
function LocalData:unlockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt -1)

    if (self.m_nLockCnt <= 0) then
        if self.m_bDirtyDataTable then
            self:saveLocalDataFile()
        end
        self.m_bDirtyDataTable = false
    end
end

-------------------------------------
-- function isGooglePlayConnected
-- @breif
-------------------------------------
function LocalData:isGooglePlayConnected()
    if isAndroid() then
        return (self:get('local', 'googleplay_connected') == 'on')
    else
        return false
    end
end

-------------------------------------
-- function setGooglePlayConnected
-- @breif
-------------------------------------
function LocalData:setGooglePlayConnected(b)
	if (b) then
		self:applyLocalData('on', 'local', 'googleplay_connected')
	else
		self:applyLocalData('off', 'local', 'googleplay_connected')
	end
end

-------------------------------------
-- function isGuestAccount
-- @breif
-------------------------------------
function LocalData:isGuestAccount()
	local account_info = g_localData:get('local', 'account_info') or 'Guest'
	return (account_info == 'Guest')
end

-------------------------------------
-- function isAdInactive
-- @breif
-------------------------------------
function LocalData:isAdInactive()
	return self:get('ad_inactive')
end

-------------------------------------
-- function isInAppReview
-- @breif
-------------------------------------
function LocalData:isInAppReview()
	local b = (CppFunctions:isIos() and self:get('in_app_review'))
	return b
end

-------------------------------------
-- function setLang
-- @breif
-------------------------------------
function LocalData:setLang(lang)
	self:applyLocalData(lang, 'lang')
end

-------------------------------------
-- function getLang
-- @breif
-------------------------------------
function LocalData:getLang()
	return self:get('lang')
end

-------------------------------------
-- function setServerName
-- @breif
-- @param string 'Korea', 'America', 'Asia', 'Japan', 'Global', 'Europe', 'DEV', 'QA'
-------------------------------------
function LocalData:setServerName(server)
	self:applyLocalData(server, 'local', 'server')
end

-------------------------------------
-- function getServerName
-- @breif
-- @return string 'Korea', 'America', 'Asia', 'Japan', 'Global', 'Europe', 'DEV', 'QA'
-------------------------------------
function LocalData:getServerName()
	return self:get('local', 'server')
end

-------------------------------------
-- function setAuth
-- @breif
-------------------------------------
function LocalData:setAuth(auth)
	self:applyLocalData(auth, 'local', 'platform_id')
end

-------------------------------------
-- function getAuth
-- @breif
-------------------------------------
function LocalData:getAuth()
	return self:get('local', 'platform_id') or 'firebase'
end

-------------------------------------
-- function isGoogleLogin
-- @breif
-------------------------------------
function LocalData:isGoogleLogin()
	return (self:getAuth() == 'google.com')
end

-------------------------------------
-- function isShowHighbrowShop
-- @breif 하이브로 전용관 노출 여부 (드빌 전용관은 한국서버에서만 노출)
-------------------------------------
function LocalData:isShowHighbrowShop()
	local server = self:getServerName()
    if (server == SERVER_NAME.KOREA) then
    elseif (server == SERVER_NAME.DEV) then
    elseif (server == SERVER_NAME.QA) then
    else
        return false
    end

    return true
end

-------------------------------------
-- function isShowContractBtn
-- @breif 청약 철회 버튼, 문구 노출 여부
-------------------------------------
function LocalData:isShowContractBtn()
    -- 한국 서버
    if (self:isKoreaServer() == false) then
        return false
    end

    -- 한국어(게임 언어)
    if (g_localData:getLang() ~= 'ko') then
        return false
    end

    return true
end



-------------------------------------
-- function isKoreaServer
-- @breif 한국 서버 (QA, DEV 포함)
-------------------------------------
function LocalData:isKoreaServer()
	local server = self:getServerName()
    if (server == SERVER_NAME.KOREA) then
    elseif (server == SERVER_NAME.DEV) then
    elseif (server == SERVER_NAME.QA) then
    else
        return false
    end

    return true
end

-------------------------------------
-- function isGlobalServer
-- @breif 글로벌 서버 (QA, DEV 포함)
-------------------------------------
function LocalData:isGlobalServer()
	local server = self:getServerName()
    if (server == SERVER_NAME.GLOBAL) then
    elseif (server == SERVER_NAME.DEV) then
    elseif (server == SERVER_NAME.QA) then
    else
        return false
    end

    return true
end

-------------------------------------
-- function isAmericaServer
-- @breif 미국 서버
-------------------------------------
function LocalData:isAmericaServer()
	local server = self:getServerName()
    if (server == SERVER_NAME.AMERICA) then
        return true
    else
        return false
    end
end