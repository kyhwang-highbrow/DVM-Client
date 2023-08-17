-------------------------------------
-- class ServerData_Lair
-------------------------------------
ServerData_Lair = class({
    m_serverData = 'ServerData',
    m_lairStats = 'list<number>',
    m_lairSlotDids = 'list<number>',
    m_lairSlotFinishCount = 'number',
    m_lairRegisterMap = 'map<number>',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_Lair:init(server_data)
    self.m_serverData = server_data
    self.m_lairStats = {}
    self.m_lairSlotDids = {}
    self.m_lairRegisterMap = {}
    self.m_lairSlotFinishCount = 0
end

-------------------------------------
-- function getLairStats
-------------------------------------
function ServerData_Lair:getLairStats()
    return self.m_lairStats
end

-------------------------------------
-- function getLairSlotDidList
-------------------------------------
function ServerData_Lair:getLairSlotDidList()
    return self.m_lairSlotDids
end

-------------------------------------
-- function isInSlotDidList
-------------------------------------
function ServerData_Lair:isInSlotDidList(did)
    return table.find(self.m_lairSlotDids, did) ~= nil
end

-------------------------------------
-- function getLairSlotFinishCount
-------------------------------------
function ServerData_Lair:getLairSlotFinishCount()
    return self.m_lairSlotFinishCount
end

-------------------------------------
-- function isLairSlotComplete
-------------------------------------
function ServerData_Lair:isLairSlotComplete()
    for _, did in ipairs(self.m_lairSlotDids) do
        if self:isRegisterLairDid(did) == false then
            return false
        end
    end

    return true
end

-------------------------------------
-- function isRegisterLairDid
-------------------------------------
function ServerData_Lair:isRegisterLairDid(did)
    return self.m_lairRegisterMap[did] ~= nil
end

-------------------------------------
-- function getRegisterLairInfo
-------------------------------------
function ServerData_Lair:getRegisterLairInfo(did)
    return self.m_lairRegisterMap[did]
end

-------------------------------------
-- function getLairStatsStringData
-------------------------------------
function ServerData_Lair:getLairStatsStringData()
    if #self.m_lairStats == 0 then
        return ''
    end

    local str = table.concat(self.m_lairStats, ',')
    return ',' .. str
end

-------------------------------------
-- function applyLairInfo
-------------------------------------
function ServerData_Lair:applyLairInfo(t_ret)
    if t_ret == nil then
        return
    end

    if t_ret['slot'] ~= nil then
        self.m_lairSlotDids = t_ret['slot']
    end

    if t_ret['ticket'] ~= nil then
        g_serverData:applyServerData(t_ret['ticket'], 'user', 'blessing_ticket')
    end

    if t_ret['listCnt'] ~= nil then
        self.m_lairSlotFinishCount = t_ret['listCnt']
    end

    if t_ret['list'] ~= nil then
        local t_list = t_ret['list']
        for k, v in pairs(t_list) do
            self.m_lairRegisterMap[tonumber(k)] = v
        end
    end
end

-------------------------------------
-- function applyDragonData
-------------------------------------
function ServerData_Lair:applyDragonData(t_dragon_data)
    local doid = t_dragon_data['id']

    if t_dragon_data['lair'] == false then
        -- 둥지 리스트에서 삭제
        self:delDragonData(doid)
        -- 드래곤 리스트로 옮김
        g_dragonsData:applyDragonData(t_dragon_data)
    else

        local dragon_obj = StructDragonObject(t_dragon_data)
        self.m_serverData:applyServerData(dragon_obj, 'lair_dragons', doid)
    end
end

-------------------------------------
-- function delDragonData
-------------------------------------
function ServerData_Lair:delDragonData(doid)
    if self.m_serverData:getRef('lair_dragons', doid) then
        self.m_serverData:applyServerData(nil, 'lair_dragons', doid)
    end
end

-------------------------------------
-- function getDragonDataFromUid
-- @brief doid 로 드래곤 정보를 얻음
-------------------------------------
function ServerData_Lair:getDragonDataFromUid(doid)
    local dragon_obj = self.m_serverData:getRef('lair_dragons', doid)

    if dragon_obj then
        return clone(dragon_obj)
    end
end

-------------------------------------
-- function getDragonsListRef
-------------------------------------
function ServerData_Lair:getDragonsListRef()
    return self.m_serverData:getRef('lair_dragons') or {}
end

-------------------------------------
-- function request_lairInfo
-------------------------------------
function ServerData_Lair:request_lairInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:applyLairInfo(ret['lair'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/lair/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_lairAdd
-------------------------------------
function ServerData_Lair:request_lairAdd(doid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        -- 반드시 룬을 먼저 갱신하고 dragon을 갱신할 것
        if ret['modified_runes'] then
            g_runesData:applyRuneData_list(ret['modified_runes'])
        end
        
        -- 반드시 룬을 먼저 갱신하고 dragon을 갱신할 것
		if (ret['modified_dragons']) then
			for _, t_dragon in ipairs(ret['modified_dragons']) do
				g_dragonsData:applyDragonData(t_dragon)
			end
		end

        -- 티켓 차감
        self:applyLairInfo(ret['lair'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/lair/list/add')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_lairRemove
-------------------------------------
function ServerData_Lair:request_lairRemove(doid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        
        -- 반드시 룬을 먼저 갱신하고 dragon을 갱신할 것
        if ret['modified_runes'] then
            g_runesData:applyRuneData_list(ret['modified_runes'])
        end
        
        -- 반드시 룬을 먼저 갱신하고 dragon을 갱신할 것
		if (ret['modified_dragons']) then
			for _, t_dragon in ipairs(ret['modified_dragons']) do
				g_dragonsData:applyDragonData(t_dragon)
			end
		end
    
        -- 티켓 차감
        self:applyLairInfo(ret['lair'])
        

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/lair/list/remove')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_lairReload
-------------------------------------
function ServerData_Lair:request_lairReload(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        self:applyLairInfo(ret['lair'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/lair/slot/reload')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_lairComplete
-------------------------------------
function ServerData_Lair:request_lairComplete(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        self:applyLairInfo(ret['lair'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/lair/slot/complete')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end