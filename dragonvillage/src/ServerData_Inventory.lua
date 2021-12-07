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
function ServerData_Inventory:request_itemSell(rune_oids, items, cb)
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
    ui_network:setParam('items', items)
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
    -- 아이템은 룬만 취급함
    local rune_count = g_runesData:getUnequippedRuneCount()
    self.m_itemCount = rune_count
    --self.m_bItemCountDirty = true
end

-------------------------------------
-- function checkMaximumItems
-------------------------------------
function ServerData_Inventory:checkMaximumItems(ignore_func, manage_func)
    local items_cnt = self:getItemCount()
    local inven_type = 'rune'
    local max_cnt = self:getMaxCount(inven_type)

    if (items_cnt < max_cnt) then
        if ignore_func then
            ignore_func()
        end
    else
        UI_NotificationFullInventoryPopup('inventory', items_cnt, max_cnt, ignore_func, manage_func)
    end
end

-------------------------------------
-- function getCount
-- @param invent_type : rune, dragon
-------------------------------------
function ServerData_Inventory:getCount(inven_type)
    if (inven_type ~= 'rune') and (inven_type ~= 'dragon') then return 0 end
    local inven_count

    if (inven_type == 'dragon') then
        inven_count = g_dragonsData:getDragonsCnt()
    else
        inven_count = g_inventoryData:getItemCount()
    end

    return inven_count
end

-------------------------------------
-- function getMaxCount
-- @param invent_type : rune, dragon
-------------------------------------
function ServerData_Inventory:getMaxCount(inven_type)
    if (inven_type ~= 'rune') and (inven_type ~= 'dragon') then return 0 end

    local t_inven = TABLE:get('table_inventory')
    local key_lv = (inven_type == 'rune') and 'r_slotlv' or 'd_slotlv'
    local key_slot = inven_type .. '_slot'

    local lv = g_userData:get(key_lv)
    local curr_slot = 0

    -- 인벤토리 레벨이 변경되기 전 생성된 계정을 위한 예외처리
    for _lv=lv, 0, -1 do
        if t_inven[_lv] and t_inven[_lv][key_slot] then
            curr_slot = t_inven[_lv][key_slot]
            break
        end
    end

    return curr_slot
end

-------------------------------------
-- function extendInventory
-- @param invent_type : rune, dragon
-------------------------------------
function ServerData_Inventory:extendInventory(inven_type, finish_cb)
    if (inven_type ~= 'rune') and (inven_type ~= 'dragon') then return end
    
    local t_inven = TABLE:get('table_inventory')
    local key_lv = (inven_type == 'rune') and 'r_slotlv' or 'd_slotlv'
    local key_slot = inven_type .. '_slot'
    local key_price = inven_type .. '_lvup_price'

    local lv = g_userData:get(key_lv)
    local curr_slot = t_inven[lv][key_slot]

    -- 드래곤과 룬쪽 최대 확장이 다를 수 있어서 수정
    local next_info = t_inven[(lv + 1)]
    if (not next_info) then
        UIManager:toastNotificationRed(Str('더 이상 확장할 수 없습니다.'))
        return
    end
    local next_slot = next_info[key_slot]
    if (not next_slot) or (next_slot == '') then
        UIManager:toastNotificationRed(Str('더 이상 확장할 수 없습니다.'))
        return
    end

    local lvup_price = t_inven[lv][key_price]
    local l_str = seperate(lvup_price, ';')
    local price = tonumber(l_str[2])
    local add_slot = next_slot - curr_slot

    local function ok_btn_cb()
        -- 캐쉬가 충분히 있는지 확인
        if (not ConfirmPrice('cash', price)) then
            return
        end

        self:request_extendInventory(inven_type, finish_cb)
    end

    local str_target = self:getTargetInventoryName(inven_type)
    local msg = Str('다이아 {1}개를 사용하여 {2} 가방을 {3}칸\n확장하시겠습니까?', comma_value(price), str_target, add_slot)
    UI_ConfirmPopup('cash', price, msg, ok_btn_cb)
end

-------------------------------------
-- function getTargetInventoryName
-------------------------------------
function ServerData_Inventory:getTargetInventoryName(inven_type)
    local str_target = ''

    if (inven_type == 'rune') then
        str_target = Str('룬')

    elseif (inven_type == 'dragon') then
        str_target = Str('드래곤')

    end

    return str_target
end

-------------------------------------
-- function request_extendInventory
-------------------------------------
function ServerData_Inventory:request_extendInventory(inven_type, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    
    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        local desc = (inven_type == 'dragon') and '인벤 확장 (드래곤)' or '인벤 확장 (룬)'
        Analytics:trackUseGoodsWithRet(ret, desc)

        g_serverData:networkCommonRespone(ret)

        local str_target = self:getTargetInventoryName(inven_type)
        UIManager:toastNotificationGreen(Str('{1} 가방이 확장되었습니다.', str_target))

        -- 인벤 슬롯 레벨 갱신
        if ret['r_slotlv'] then
            g_userData:applyServerData(ret['r_slotlv'], 'r_slotlv')
        end

        if ret['d_slotlv'] then
            g_userData:applyServerData(ret['d_slotlv'], 'd_slotlv')
        end

        if finish_cb then
            finish_cb()
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/inven_extend')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', inven_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end