-------------------------------------
-- class ServerData_Inventory
-------------------------------------
ServerData_Inventory = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Inventory:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_itemSell
-- @brief
-------------------------------------
function ServerData_Inventory:request_itemSell(rune_oids, evolution_stones, fruits, cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_itemSell(ret, cb)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/inventory/sell')
    ui_network:setParam('uid', uid)
    ui_network:setParam('rune_oids', rune_oids)
    ui_network:setParam('evolution_stones', evolution_stones)
    ui_network:setParam('fruits', fruits)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function response_itemSell
-- @brief
-------------------------------------
function ServerData_Inventory:response_itemSell(ret, cb)
    -- server_info 정보를 갱신 (gold, evolution_stones, fruits)
    g_serverData:networkCommonRespone(ret)

    if ret['deleted_rune_oids'] then
        g_runesData:deleteRuneData_list(ret['deleted_rune_oids'])
    end

    if cb then
        cb(ret)
    end
end