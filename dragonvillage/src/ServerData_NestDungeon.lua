-------------------------------------
-- class ServerData_NestDungeon
-------------------------------------
ServerData_NestDungeon = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_NestDungeon:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function applyNestDungeonInfo
-------------------------------------
function ServerData_NestDungeon:applyNestDungeonInfo(data)
    self.m_serverData:applyServerData(data, 'nest_info')
end

-------------------------------------
-- function getNestDungeonInfo
-------------------------------------
function ServerData_NestDungeon:getNestDungeonInfo()
    local l_nest_info = self.m_serverData:getRef('nest_info')

    local l_ret = clone(l_nest_info)

    return l_ret
end

-------------------------------------
-- function requestNestDungeonInfo
-------------------------------------
function ServerData_NestDungeon:requestNestDungeonInfo(cb_func)
    local uid = g_userData:get('uid')

    local function success_cb(ret)

        if ret['nest_info'] then
            self:applyNestDungeonInfo(ret['nest_info'])
        end

        if cb_func then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/nest/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end