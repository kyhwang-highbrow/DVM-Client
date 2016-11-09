-------------------------------------
-- class ServerData_User
-------------------------------------
ServerData_User = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_User:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_User:get(...)
    return self.m_serverData:get('user', ...)
end

-------------------------------------
-- function getFruitCount
-- @brief 보유???�매??�?���?리턴
-------------------------------------
function ServerData_User:getFruitCount(fruit_id)
    local fruit_id = tostring(fruit_id)
    local count = self:get('fruits', fruit_id) or 0
    return count
end

-------------------------------------
-- function setFruitCount
-- @brief 보유???�매??�?���??�??
-------------------------------------
function ServerData_User:setFruitCount(fruit_id, count)
    local fruit_id = tostring(fruit_id)
    self.m_serverData:applyServerData(count, 'user', 'fruits', fruit_id)
end