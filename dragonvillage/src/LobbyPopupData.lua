---------------------------------------------------------------------------------------------------------------
-- @brief 로비에서 팝업 조건을 관리하는 데이터 저장 장소
-- @date 2018.05.29 sgkim
---------------------------------------------------------------------------------------------------------------

-------------------------------------
-- class LobbyPopupData
-------------------------------------
LobbyPopupData = class({
        m_rootTable = 'table',
        m_rootTableDefault = 'table',

        m_nLockCnt = 'number',
        m_bDirtyDataTable = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyPopupData:init()
    self.m_rootTable = nil
    self.m_rootTableDefault = nil
    self.m_nLockCnt = 0
    self.m_bDirtyDataTable = false
end

-------------------------------------
-- function getInstance
-------------------------------------
function LobbyPopupData:getInstance()
    if g_lobbyPopupData then
        return g_lobbyPopupData
    end
    
    g_lobbyPopupData = LobbyPopupData()
    g_lobbyPopupData:loadLobbyPopupDataFile()

    return g_lobbyPopupData
end

-------------------------------------
-- function getLobbyPopupDataSaveFileName
-------------------------------------
function LobbyPopupData:getLobbyPopupDataSaveFileName()
    local file = 'lobby_popup_data.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadLobbyPopupDataFile
-------------------------------------
function LobbyPopupData:loadLobbyPopupDataFile()
    local ret_json, success_load = LoadLocalSaveJson(self:getLobbyPopupDataSaveFileName())

    if (success_load == true) then
        self.m_rootTable = ret_json
    else
        self.m_rootTable = self:makeDefaultLobbyPopupData()
        self:saveLobbyPopupDataFile()
    end

    self.m_rootTableDefault = self:makeDefaultLobbyPopupData()
end

-------------------------------------
-- function makeDefaultLobbyPopupData
-------------------------------------
function LobbyPopupData:makeDefaultLobbyPopupData()
    local root_table = {}

    root_table['last_date'] = {}
    root_table['last_date']['day_str'] = '2018-01-01'
    root_table['last_date']['week_str'] = '0'
    root_table['last_date']['month_str'] = '2018-01'

    root_table['daily'] = {}
    root_table['weekly'] = {}
    root_table['monthly'] = {}
    root_table['timestamp'] = {}
    root_table['today_fix_popup'] = {}

    return root_table
end

-------------------------------------
-- function saveLobbyPopupDataFile
-------------------------------------
function LobbyPopupData:saveLobbyPopupDataFile()
    if (self.m_nLockCnt > 0) then
        self.m_bDirtyDataTable = true
        return
    end

    return SaveLocalSaveJson(self:getLobbyPopupDataSaveFileName(), self.m_rootTable, true) -- param : filename, t_data, skip_xor)
end

-------------------------------------
-- function clearLobbyPopupDataFile
-------------------------------------
function LobbyPopupData:clearLobbyPopupDataFile()
    os.remove(self:getLobbyPopupDataSaveFileName())
end


-------------------------------------
-- function applyLobbyPopupData
-- @brief 서버로부터 받은 정보로 세이브 데이터를 갱신
-------------------------------------
function LobbyPopupData:applyLobbyPopupData(data, ...)
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
        self:saveLobbyPopupDataFile()
    end
end

-------------------------------------
-- function getFunc
-- @brief
-------------------------------------
function LobbyPopupData:getFunc(target_table, ...)
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
function LobbyPopupData:get(...)
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
function LobbyPopupData:getRef(...)
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
function LobbyPopupData:lockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt + 1)
end

-------------------------------------
-- function unlockSaveData
-- @breif
-------------------------------------
function LobbyPopupData:unlockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt -1)

    if (self.m_nLockCnt <= 0) then
        if self.m_bDirtyDataTable then
            self:saveLobbyPopupDataFile()
        end
        self.m_bDirtyDataTable = false
    end
end

-------------------------------------
-- function getServerTimeDate
-- @breif
-------------------------------------
function LobbyPopupData:getServerTimeDate()
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()   -- 서버에서 사용하는 timestamp 가져옴(단위:초)
    local tzone = Timer:getUTCHour() * 60 * 60  -- 표준시를 초 단위로 환산
    local fake_local_time = (server_time + tzone)
    local date = pl.Date(fake_local_time)
    return date
end

-------------------------------------
-- function checkDaily
-- @breif "2018-03-01"의 형태의 값을 저장해서 날짜가 변경했는지 확인
-------------------------------------
function LobbyPopupData:checkDaily()
    local day_str = self:get('last_date', 'day_str')

    local date = self:getServerTimeDate()
    local date_format = pl.Date.Format('yyyy-mm-dd')
    local curr_day_str = date_format:tostring(date)

    if (not day_str) or (day_str ~= curr_day_str) then
        self:applyLobbyPopupData({}, 'daily')
        self:applyLobbyPopupData(curr_day_str, 'last_date', 'day_str')
        self:applyLobbyPopupData({}, 'today_fix_popup')
    end
end

-------------------------------------
-- function checkWeekly
-- @breif 접속한 시점의 주의 일요일 날짜를
--        올해의 몇일째인지를 저장하여 주차가 변경한 것을 확인
-------------------------------------
function LobbyPopupData:checkWeekly()
    local week_str = self:get('last_date', 'week_str')

    local date = self:getServerTimeDate()

    -- 오늘 날짜가 올해의 몇일째인지 얻어옴
    local day_of_year = date:yday()

    -- 오늘 요일을 얻어옴
    local weekday_name = date:weekday_name()

    -- 일요일이 되려면 몇일이 더 필요한지 얻어옴
    local add_day = 0
    if (weekday_name == 'Mon') then
        add_day = 6
    elseif (weekday_name == 'Tue') then
        add_day = 5
    elseif (weekday_name == 'Wed') then
        add_day = 4
    elseif (weekday_name == 'Thu') then
        add_day = 3
    elseif (weekday_name == 'Fri') then
        add_day = 2
    elseif (weekday_name == 'Sat') then
        add_day = 1
    elseif (weekday_name == 'Sun') then
        add_day = 0
    end

    -- 이번 주 일요일이 올해의 몇일째인지를 계산
    local curr_week_str = tostring(day_of_year + add_day)

    if (not week_str) or (week_str ~= curr_week_str) then
        self:applyLobbyPopupData({}, 'weekly')
        self:applyLobbyPopupData(curr_week_str, 'last_date', 'week_str')
    end
end


-------------------------------------
-- function checkMonthly
-- @breif "2018-03"의 형태의 값을 저장해서 달이 변경되었는지 확인
-------------------------------------
function LobbyPopupData:checkMonthly()
    local month_str = self:get('last_date', 'month_str')

    local date = self:getServerTimeDate()
    local date_format = pl.Date.Format('yyyy-mm')
    local curr_month_str = date_format:tostring(date)

    if (not month_str) or (month_str ~= curr_month_str) then
        self:applyLobbyPopupData({}, 'monthly')
        self:applyLobbyPopupData(curr_month_str, 'last_date', 'month_str')
    end
end

-------------------------------------
-- function getDailySeen
-- @breif
-------------------------------------
function LobbyPopupData:getDailySeen(key)
    self:checkDaily()
    return self:get('daily', key)
end

-------------------------------------
-- function setDailySeen
-- @breif
-------------------------------------
function LobbyPopupData:setDailySeen(key)
    self:applyLobbyPopupData(true, 'daily', key)
end

-------------------------------------
-- function getTodayFixPopup
-- @breif
-------------------------------------
function LobbyPopupData:getTodayFixPopup(key)
    self:checkDaily()
    return self:get('today_fix_popup', key)
end

-------------------------------------
-- function setTodayFixPopup
-- @breif
-------------------------------------
function LobbyPopupData:setTodayFixPopup(key)
    self:applyLobbyPopupData(true, 'today_fix_popup', key)
end

-------------------------------------
-- function getWeeklySeen
-- @breif
-------------------------------------
function LobbyPopupData:getWeeklySeen(key)
    self:checkWeekly()
    return self:get('weekly', key)
end

-------------------------------------
-- function setWeeklySeen
-- @breif
-------------------------------------
function LobbyPopupData:setWeeklySeen(key)
    self:applyLobbyPopupData(true, 'weekly', key)
end

-------------------------------------
-- function getMonthlySeen
-- @breif
-------------------------------------
function LobbyPopupData:getMonthlySeen(key)
    self:checkMonthly()
    return self:get('monthly', key)
end

-------------------------------------
-- function setMonthlySeen
-- @breif
-------------------------------------
function LobbyPopupData:setMonthlySeen(key)
    self:applyLobbyPopupData(true, 'monthly', key)
end

-------------------------------------
-- function getTimestamp
-- @breif
-------------------------------------
function LobbyPopupData:getTimestamp(key)
    return self:get('timestamp', key)
end

-------------------------------------
-- function setTimestamp
-- @breif
-------------------------------------
function LobbyPopupData:setTimestamp(key)
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    return self:applyLobbyPopupData(server_time, 'timestamp', key)
end