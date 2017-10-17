-------------------------------------
-- class ServerData_AutoItemPick
-------------------------------------
ServerData_AutoItemPick = class({
        m_serverData = 'ServerData',
        m_autoItemPickList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AutoItemPick:init(server_data)
    self.m_serverData = server_data
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

