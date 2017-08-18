-------------------------------------
-- class ServerData_AutoItemPick
-------------------------------------
ServerData_AutoItemPick = class({
        m_serverData = 'ServerData',
        m_autoItemPickList = 'list',
        m_scheduleHandlerID = 'number',
        m_countLabel = 'LabelTTF',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AutoItemPick:init(server_data)
    self.m_serverData = server_data
    self.m_scheduleHandlerID = nil
    self.m_autoItemPickList = {}
end

-------------------------------------
-- function applyAutoItemPickData
-------------------------------------
function ServerData_AutoItemPick:applyAutoItemPickData(data)
    -- 2017-07-28 sgkim
    --  "auto_item_pick":[{
    --      "expired":1504796400000,
    --      "type":"subscription"
    --    }],
    self.m_autoItemPickList = data
end

-------------------------------------
-- function isActiveAutoItemPick
-------------------------------------
function ServerData_AutoItemPick:isActiveAutoItemPick()
    local expired = self:getAutoItemPickExpired()

    -- 만료 시간이 없으면 비활성 상태
    if (not expired) then
        return false
    end
    
    -- 만료 시간이 지났는지 체크
    expired = (expired / 1000)
    local curr_time = Timer:getServerTime()
    if (expired < curr_time) then
        return false
    end

    return true
end

-------------------------------------
-- function getAutoItemPickExpired
-------------------------------------
function ServerData_AutoItemPick:getAutoItemPickExpired()
    local expired = nil

    for i,v in pairs(self.m_autoItemPickList) do
        if (not expired) or (expired < v['expired']) then
            expired = v['expired']
        end
    end

    return expired
end

-------------------------------------
-- function setCountLabel
-------------------------------------
function ServerData_AutoItemPick:setCountLabel(label)
    self.m_countLabel = label
end

-------------------------------------
-- function updateAutoItemInfo
-- @brief 남은 시간 정보를 갱신
-------------------------------------
function ServerData_AutoItemPick:updateAutoItemInfo()
    -- 남은 시간
    local expired = self:getAutoItemPickExpired()
    if (not expired) then
        return
    end

    -- 서버상의 시간을 얻어옴
    local server_time = Timer:getServerTime()

    if (self.m_countLabel) then
        local time = (expired/1000 - server_time)
        
        if (time > 0) then
            local show_second = true
            local first_only = true
            local str = Str('{1} 남음', datetime.makeTimeDesc(time, show_second, first_only))
            self.m_countLabel:setString(str)
        else
            
        end
    end
end

-------------------------------------
-- function update
-- @brief 남은 시간 표시
-------------------------------------
function ServerData_AutoItemPick:update(dt)
    if (not self:isActiveAutoItemPick()) then
        return
    end

    self:updateAutoItemInfo()
end

-------------------------------------
-- function updateOn
-------------------------------------
function ServerData_AutoItemPick:updateOn()
    self:update()

    if (self.m_scheduleHandlerID) then
        return
    end

    local function update(dt)
        self:update(dt)
    end
    
    self.m_scheduleHandlerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) return update(dt) end, 0, false)
end

-------------------------------------
-- function updateOff
-------------------------------------
function ServerData_AutoItemPick:updateOff()
    if self.m_scheduleHandlerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduleHandlerID)
        self.m_scheduleHandlerID = nil
        self.m_countLabel = nil
    end
end