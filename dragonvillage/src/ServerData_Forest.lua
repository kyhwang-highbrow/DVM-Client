-------------------------------------
-- class ServerData_Forest
-------------------------------------
ServerData_Forest = class({
        m_serverData = 'ServerData',
        m_happyRate = 'number',
        m_tStuffInfo = 'table',
        m_tDragonStruct = 'table',
    })


local _instance = nil
-------------------------------------
-- function getInstance
-------------------------------------
function ServerData_Forest:getInstance(server_data)
    if _instance then
        return _instance
    end

    _instance = ServerData_Forest(server_data)
    return _instance
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_Forest:init(server_data)
    --self.m_serverData = server_data
    self.m_tStuffInfo = {}
    self.m_tDragonStruct = {}
end

-------------------------------------
-- function makeMyUserInfo
-------------------------------------
function ServerData_Forest:getMyUserInfo()
    local t_user_info = 
    {
        ['lv'] = g_userData:get('lv'),
        ['tamer'] = g_tamerData:getCurrTamerID(),
        ['tamer_title'] = g_userData:getTitleID(),
        ['nick'] = g_userData:get('nick'),
        ['leader'] = g_dragonsData:getLeaderDragon()
    }

    return StructUserInfoForest:create(t_user_info)
end

-------------------------------------
-- function makeMyUserInfo
-------------------------------------
function ServerData_Forest:getMyDragons()
    return self.m_tDragonStruct
end

-------------------------------------
-- function getHappy
-------------------------------------
function ServerData_Forest:getHappy()
    return self.m_happyRate
end

-------------------------------------
-- function getMaxDragon
-------------------------------------
function ServerData_Forest:getMaxDragon()
    return 20
end










-------------------------------------
-- function request_myForestInfo
-------------------------------------
function ServerData_Forest:request_myForestInfo(finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        self:applyForestInfo(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/forest/get/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_myForestInfo
-------------------------------------
function ServerData_Forest:applyForestInfo(t_ret)
    -- 공용 드래곤의 숲 정보
    self.m_happyRate = t_ret['forest_info']['happy']
        
    -- 드래곤의 숲 오브젝트
    local stuff
    for i, t_stuff in pairs(t_ret['forest_stuffs']) do
        stuff = t_stuff['stuff']
        self.m_tStuffInfo[stuff] = t_stuff
    end
    
    -- 드래곤의 숲 드래곤 정보
    local doid, struct_dragon 
    for i, t_dragon_info in pairs(t_ret['forest_dragons']) do
        doid = t_dragon_info['doid']
        struct_dragon = g_dragonsData:getDragonDataFromUid(doid)
        struct_dragon.happy_at = t_dragon_info['happy_at'] or 0
        self.m_tDragonStruct[doid] = struct_dragon
    end 
end

-------------------------------------
-- function request_myForestInfo
-------------------------------------
function ServerData_Forest:request_setDragons(doids, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        self.m_tDragonStruct = {}

        -- 드래곤의 숲 드래곤 정보
        local doid, struct_dragon 
        for i, t_dragon_info in pairs(ret['forest_dragons']) do
            doid = t_dragon_info['doid']
            struct_dragon = g_dragonsData:getDragonDataFromUid(doid)
            struct_dragon.happy_at = t_dragon_info['happy_at'] or 0
            self.m_tDragonStruct[doid] = struct_dragon
        end 

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/forest/set/dragons')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doids)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function request_myForestInfo
-------------------------------------
function ServerData_Forest:request_dragonHappy(doid, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        -- 공용 드래곤의 숲 정보
        self.m_happyRate = t_ret['forest_info']['happy']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/forest/dragon/happy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end