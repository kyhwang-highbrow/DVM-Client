-------------------------------------
-- class ServerData_Lair
-------------------------------------
ServerData_Lair = class({
    m_serverData = 'ServerData',

    m_lairStats = 'list<number>',
    m_lairStatsInfoMap = 'list<number>',

    m_lairSlotDids = 'list<number>',
    m_lairSlotCompleteCount = 'number',
    m_lairRegisterMap = 'map<number>',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_Lair:init(server_data)
    self.m_serverData = server_data
    self.m_lairStats = {}
    self.m_lairStatsInfoMap = {}
    self.m_lairSlotDids = {}
    self.m_lairRegisterMap = {}
    self.m_lairSlotCompleteCount = 0

    self:makeLairStatInfo()
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
-- function getLairSlotCompleteCount
-------------------------------------
function ServerData_Lair:getLairSlotCompleteCount()
    return self.m_lairSlotCompleteCount
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
-- function makeLairStatInfo
-------------------------------------
function ServerData_Lair:makeLairStatInfo()
    self.m_lairStatsInfoMap = {}
    
    local id_list = TableLair:getInstance():getLairIdListAll()

    for _, id in ipairs(id_list) do
        local struct_lair_stat = StructLairStat()
        struct_lair_stat:initVariables()
        self.m_lairStatsInfoMap[id] = struct_lair_stat
    end
end

-------------------------------------
-- function getLairStatInfo
-------------------------------------
function ServerData_Lair:getLairStatInfo(buff_id)
    return self.m_lairStatsInfoMap[buff_id]
end

-------------------------------------
-- function getLairStatBlessTargetIdList
-------------------------------------
function ServerData_Lair:getLairStatBlessTargetIdList(type)
    local id_list = TableLair:getInstance():getLairIdListByType(type, true)
    local curr_count = self:getLairSlotCompleteCount()
    local result_id_list = {}

    for _, lair_id in ipairs(id_list) do
        local req_count = TableLair:getInstance():getLairRequireCount(lair_id)
        local struct_lair_stat = self:getLairStatInfo(lair_id)

        if curr_count >= req_count and struct_lair_stat:isStatLock() == false then
            table.insert(result_id_list, lair_id)
        end
    end

    return result_id_list, #result_id_list
end

-------------------------------------
-- function getLairStatIdList
-------------------------------------
function ServerData_Lair:getLairStatIdList(type)
    local id_list = TableLair:getInstance():getLairIdListByType(type, true)
    local result_id_list = {}

    for _, stat_id in ipairs(id_list) do
        local struct_lair_stat = self:getLairStatInfo(stat_id)
        if struct_lair_stat:getStatId() > 0 then
            table.insert(result_id_list, struct_lair_stat:getStatId())
        end
    end

    return result_id_list, #result_id_list
end


-------------------------------------
-- function isRegisterLairDid
-------------------------------------
function ServerData_Lair:isRegisterLairDid(did)
    return self.m_lairRegisterMap[did] ~= nil
end

-------------------------------------
-- function isRegisterLairByDoid
-------------------------------------
function ServerData_Lair:isRegisterLairByDoid(did, doid)
    local info = self.m_lairRegisterMap[did]

    if info == nil then
        return false
    end

    return info['doid'] == doid
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
        self.m_lairSlotCompleteCount = t_ret['listCnt']
    end

    if t_ret['list'] ~= nil then
        local t_list = t_ret['list']
        for k, v in pairs(t_list) do
            self.m_lairRegisterMap[tonumber(k)] = v
        end
    end

    if t_ret['buff'] ~= nil then
        local t_list = t_ret['buff']
        for k, v in pairs(t_list) do
            self.m_lairStatsInfoMap[tonumber(k)] = StructLairStat(v)
        end
    end

    if t_ret['removed_buff'] ~= nil then
        local t_list = t_ret['removed_buff']
        for _, id in ipairs(t_list) do
            local struct_lair_stat = self.m_lairStatsInfoMap[id]
            if struct_lair_stat ~= nil then
                struct_lair_stat:initVariables()
            end
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
-- function getLairTargetDragonMap
-------------------------------------
function ServerData_Lair:getLairTargetDragonMap()
    local l_ret = {}

    local table_dragon = TableDragon()
    for i, v in pairs(table_dragon.m_orgTable) do
        -- 개발 중인 드래곤은 도감에 나타내지 않는다.
        if (not g_dragonsData:isReleasedDragon(v['did'])) then
        -- 위 조건들에 해당하지 않은 경우만 추가
        else
            local did = v['did']
			local key = did
			
			-- 자코는 진화하지 않으므로
			if (table_dragon:isUnderling(did) == false) then
                local t_dragon = {}
                --t_dragon['id'] = 'none'
                t_dragon['did'] = did
                t_dragon['evolution'] = 3
                t_dragon['grade'] = 6
                t_dragon['lv'] = 60
                l_ret[key] = StructDragonObject(t_dragon)
			end
        end
    end

    return l_ret
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

-------------------------------------
-- function request_lairStatPick
-------------------------------------
function ServerData_Lair:request_lairStatPick(ids, finish_cb, fail_cb)
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
    ui_network:setUrl('/lair/buff/pick')
    ui_network:setParam('uid', uid)
    ui_network:setParam('ids', ids)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_lairStatLock
-------------------------------------
function ServerData_Lair:request_lairStatLock(ids, lock, finish_cb, fail_cb)
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
    ui_network:setUrl('/lair/buff/lock')
    ui_network:setParam('uid', uid)
    ui_network:setParam('ids', ids)
    ui_network:setParam('lock', lock)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end


-------------------------------------
-- function request_lairStatReset
-------------------------------------
function ServerData_Lair:request_lairStatReset(ids, finish_cb, fail_cb)
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
    ui_network:setUrl('/lair/buff/reset')
    ui_network:setParam('uid', uid)
    ui_network:setParam('ids', ids)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_lairSeasonResetManage
-------------------------------------
function ServerData_Lair:request_lairSeasonResetManage(finish_cb, fail_cb)
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
    ui_network:setUrl('/manage/lair/reset')
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
-- function request_lairAddBlessingTicketManage
-------------------------------------
function ServerData_Lair:request_lairAddBlessingTicketManage(count, finish_cb, fail_cb)
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
    ui_network:setUrl('/manage/lair/ticket/set')
    ui_network:setParam('uid', uid)
    ui_network:setParam('ticket', count)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_lairAutoReloadManage
-------------------------------------
function ServerData_Lair:request_lairAutoReloadManage(dids, finish_cb, fail_cb)
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
    ui_network:setUrl('/manage/lair/slot/set')
    ui_network:setParam('uid', uid)
    ui_network:setParam('dids', dids)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end