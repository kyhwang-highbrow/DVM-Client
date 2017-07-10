USER_DATA_VER = '1.2.5'

-------------------------------------
-- class UserData
-------------------------------------
UserData = class({
        m_userData = '',
        m_masterData = '',
        m_cache = '',

        m_bDirtyLocalSaveData = 'boolean', -- 로컬 세이브 데이터 변경 여부
    })

-------------------------------------
-- function init
-------------------------------------
function UserData:init()
    self.m_cache = {}
    self.m_bDirtyLocalSaveData = false
end

-------------------------------------
-- function getInstance
-------------------------------------
function UserData:getInstance()
    if g_userDataOld then
        return g_userDataOld
    end

    g_userDataOld = UserData()
    g_userDataOld:loadMasterFile()

    return g_userDataOld
end

-------------------------------------
-- function clearServerDataFile
-------------------------------------
function UserData:clearServerDataFile()
    os.remove(self:getMasterFileName())
    os.remove(self:getUserDataFile())
end

-------------------------------------
-- function loadMasterFile
-------------------------------------
function UserData:loadMasterFile()
    local f = io.open(self:getMasterFileName(), 'r')

    local success_load = false
    if f then
        local content = f:read('*all')
        f:close()

        if (#content > 0) then
            self.m_masterData = json_decode(content)
            success_load = true
        end
    end

    -- 초기화
    if (success_load == false) then
        self.m_masterData = {}

        self.m_masterData['data_cnt'] = 1
        self.m_masterData['data'] = 'user_data_1.json'
        self.m_masterData['data_list'] = {'user_data_1.json'}

        self:saveMasterFile()
    end

    self:loadUserDataFile()
end

-------------------------------------
-- function saveMasterFile
-------------------------------------
function UserData:saveMasterFile()
    local f = io.open(self:getMasterFileName(),'w')
    if not f then return false end

    -- cclog(luadump(self.m_data))
    local content = dkjson.encode(self.m_masterData, {indent=true})
    f:write(content)
    f:close()

    return true
end

-------------------------------------
-- function getMasterFileName
-------------------------------------
function UserData:getMasterFileName()
    local file = 'master_file.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end


-------------------------------------
-- function loadUserDataFile
-------------------------------------
function UserData:loadUserDataFile()
    local f = io.open(self:getUserDataFile(), 'r')

    if f then
        local content = f:read('*all')

        if (#content > 0) then
            self.m_userData = json_decode(content)
        end
        f:close()

        if (self.m_userData['ver'] ~= USER_DATA_VER) then
            self.m_userData = nil
        end
    end
    
    if (self.m_userData) then
        self:afterLoadUserDataFile()
    else
        self.m_userData = {}

        -- @ 세이브데이터 버전
        self.m_userData['ver'] = USER_DATA_VER

        -- @ 유저 정보
        self.m_userData['lv'] = 1           -- 레벨
        self.m_userData['exp'] = 0          -- 경험치
        self.m_userData['nickname'] = 'dragon'  -- 닉네임

        -- @ 재화 정보
        self.m_userData['gold'] = 5000
        self.m_userData['cash'] = 0

        -- @ 행동력(stamina)
        -- scenario
        -- arena
        self.m_userData['stamina'] = {}
        self.m_userData['stamina']['st_ad'] = {10, os.time()}

        -- 설정
        self.m_userData['setting'] = {}  

        self:afterLoadUserDataFile()
        self:setDirtyLocalSaveData()
    end
end

-------------------------------------
-- function afterLoadUserDataFile
-------------------------------------
function UserData:afterLoadUserDataFile()
end

-------------------------------------
-- function getdragonList
-------------------------------------
function UserData:getdragonList()
    local list = {}
    
    for i,v in pairs(self.m_userData['dragon']) do
        table.insert(list, v)
    end

    return list
end

-------------------------------------
-- function saveUserDataFile
-------------------------------------
function UserData:saveUserDataFile()
    local f = io.open(self:getUserDataFile(),'w')
    if not f then return false end

    -- cclog(luadump(self.m_data))
    local content = dkjson.encode(self.m_userData, {indent=true})
    f:write(content)
    f:close()

    return true
end

-------------------------------------
-- function getUserDataFile
-------------------------------------
function UserData:getUserDataFile()
    local file = self.m_masterData['data']
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function update
-------------------------------------
function UserData:update(dt)
    if self.m_bDirtyLocalSaveData then
        self.m_bDirtyLocalSaveData = false
        self:saveUserDataFile()
    end
end

-------------------------------------
-- function setDirtyLocalSaveData
-------------------------------------
function UserData:setDirtyLocalSaveData(immediately)
    if immediately then
        self:saveUserDataFile()
    else
        self.m_bDirtyLocalSaveData = true
    end
end

-------------------------------------
-- function addCumulativePurchasesLog
-- @biref 누적 구매 로그 추가
-------------------------------------
function UserData:addCumulativePurchasesLog(type, cnt)
    if (not self.m_userData['log']) then
        self.m_userData['log'] = {}
    end

    if (not self.m_userData['log'][type]) then
        self.m_userData['log'][type] = 0
    end

    self.m_userData['log'][type] = self.m_userData['log'][type] + cnt

    self:setDirtyLocalSaveData()
end

-------------------------------------
-- function getCumulativePurchasesLog
-- @biref 누적 구매 로그
-------------------------------------
function UserData:getCumulativePurchasesLog(type)
    if (not self.m_userData['log']) then
        return 0
    end

    if (not self.m_userData['log'][type]) then
        return 0
    end

    return tonumber(self.m_userData['log'][type])
end

-------------------------------------
-- function initTamer
-- @TEST
-------------------------------------
function UserData:initTamer()
    self.m_userData['lv'] = 1
    self.m_userData['exp'] = 0

    self:setDirtyLocalSaveData(true)
end