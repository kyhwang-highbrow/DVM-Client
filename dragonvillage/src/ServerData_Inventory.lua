local MAX_ITEMS_CNT = 100

-------------------------------------
-- class ServerData_Inventory
-------------------------------------
ServerData_Inventory = class({
        m_serverData = 'ServerData',

        m_bItemCountDirty = 'boolean',
        m_itemCount = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Inventory:init(server_data)
    self.m_serverData = server_data
    self.m_bItemCountDirty = true
    self.m_itemCount = 0
end

-------------------------------------
-- function request_itemSell
-- @brief
-------------------------------------
function ServerData_Inventory:request_itemSell(rune_oids, evolution_stones, fruits, tickets, cb)
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
    ui_network:setParam('tickets', tickets)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
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

-------------------------------------
-- function getItemCount
-------------------------------------
function ServerData_Inventory:getItemCount()
    if self.m_bItemCountDirty then
        self:calcItemCount()
    end

    self.m_bItemCountDirty = true
    return self.m_itemCount
end

-------------------------------------
-- function calcItemCount
-------------------------------------
function ServerData_Inventory:calcItemCount()
    local rune_count = g_runesData:getUnequippedRuneCount()
    local fruit_count = g_userData:getFruitPackCount()
    local evolution_stone_count = g_userData:getEvolutionStonePackCount()
    local ticket_count = g_userData:getTicketPackCount()

    self.m_itemCount = (rune_count + fruit_count + evolution_stone_count + ticket_count)
    --self.m_bItemCountDirty = true
end

-------------------------------------
-- function checkMaximumItems
-------------------------------------
function ServerData_Inventory:checkMaximumItems(ignore_func, manage_func)
    local items_cnt = self:getItemCount()
    
    if (items_cnt < MAX_ITEMS_CNT) then
        if ignore_func then
            ignore_func()
        end
    else
        UI_NotificationFullInventoryPopup('inventory', items_cnt, MAX_ITEMS_CNT, ignore_func, manage_func)
    end
end