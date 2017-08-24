-------------------------------------
-- class ServerData_EvolutionStone
-------------------------------------
ServerData_EvolutionStone = class({
        m_serverData = 'ServerData',
    })

-- item_id 에서 두자리로 구분
local STONE_TYPE = {
    EVOLUTION = 1,
    EARTH = 11,
    WATER = 12,
    FIRE = 13,
    LIGHT = 14, 
    DARK = 15,
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_EvolutionStone:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getEvolutionStoneList
-- @brief 테이블뷰 진화재료 맵 형태 반환해줌 (개별)
-------------------------------------
function ServerData_EvolutionStone:getEvolutionStoneList()
    local table_item = TableItem()
    local l_evolution_stone = table_item:filterTable('type', 'evolution_stone')

    local map_ev_stone = {}

    for stone_id, v in pairs(l_evolution_stone) do
        map_ev_stone[stone_id] = {}
        map_ev_stone[stone_id]['esid'] = stone_id
        map_ev_stone[stone_id]['count'] = self:getCount(stone_id)
    end

    return map_ev_stone
end

-------------------------------------
-- function getEvolutionStoneListWithType
-- @brief 테이블뷰 진화재료 맵 형태 반환해줌 (type별 묶음)
-------------------------------------
function ServerData_EvolutionStone:getEvolutionStoneListWithType()
    local table_item = TableItem()
    local l_evolution_stone = table_item:filterTable('type', 'evolution_stone')

    local map_ev_stone = {}
    for _, type in pairs(STONE_TYPE) do
        local id = tostring(type)
        map_ev_stone[id] = {}

        local name = ''
        if (type == STONE_TYPE.EVOLUTION) then name = Str('진화의 보석')
        elseif (type == STONE_TYPE.EARTH) then name = Str('땅의 정기')
        elseif (type == STONE_TYPE.WATER) then name = Str('물의 정기')
        elseif (type == STONE_TYPE.FIRE)  then name = Str('불의 정기')
        elseif (type == STONE_TYPE.LIGHT) then name = Str('빛의 정기')
        elseif (type == STONE_TYPE.DARK)  then name = Str('어둠의 정기') end

        map_ev_stone[id]['name'] = name
    end

    for stone_id, v in pairs(l_evolution_stone) do
        local id = self:getType(stone_id)
        local target_map = map_ev_stone[id]
        if (target_map) then
            target_map['attr'] = v['attr']
            if (not target_map['data']) then
                target_map['data'] = {}
            end

            table.insert(target_map['data'], stone_id)
        end
    end

    return map_ev_stone
end

-------------------------------------
-- function getType
-- @brief item_id 에서 두자리로 구분
-------------------------------------
function ServerData_EvolutionStone:getType(stone_id)
    return tostring(getDigit(stone_id, 10, 2))
end

-------------------------------------
-- function getCount
-------------------------------------
function ServerData_EvolutionStone:getCount(stone_id)
    local my_items = g_userData:getEvolutionStoneList()
    for _, v in ipairs(my_items) do
        if (v['esid'] == stone_id) then
            return v['count']
        end
    end
    return 0
end

-------------------------------------
-- function request_combine
-------------------------------------
function ServerData_EvolutionStone:request_combine(stone_id, multi, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/combine/evolution_stone')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', 'combine')
    ui_network:setParam('item_id', stone_id)
    ui_network:setParam('item_cnt', multi)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_division
-------------------------------------
function ServerData_EvolutionStone:request_division(stone_id, multi, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/combine/evolution_stone')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', 'divide')
    ui_network:setParam('item_id', stone_id)
    ui_network:setParam('item_cnt', multi)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

