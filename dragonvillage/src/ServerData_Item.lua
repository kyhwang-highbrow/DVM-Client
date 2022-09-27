-------------------------------------
---@class ServerData_Item
---@return ServerData_Item
-------------------------------------
ServerData_Item = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Item:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function parsePackageItemStr
-- @brief item테이블에 item을 지급하는 문자열 분석(package아이템과 우편함 등에 사용)
-- ex) 'cash;1000, gold;5000, fruit;702049;10, dragon;780294;1, rune:713305,1'
-------------------------------------
function ServerData_Item:parsePackageItemStr(package_item_str)
    -- 테스트 문자열
    --local package_item_str = 'cash;1000, gold;5000,\n\n fruit;702049;10, dragon;780294;1, rune;713305;1, 713305;1, 713305'

    -- 공백 제거
    package_item_str = string.gsub(package_item_str, ' ', '')

    -- 개행 제거
    package_item_str = string.gsub(package_item_str, '\n', '')

    -- ','로 분리
    local l_item_str_list = pl.stringx.split(package_item_str, ',')

    -- ','로 분리된 아이템 개별의 문자열을 분석
    local l_item_list = {}
    for i,v in ipairs(l_item_str_list) do
        local item_id, count = self:parsePackageItemStrIndivisual(v)
        local t_item = {item_id=item_id, count=count}
        table.insert(l_item_list, t_item)
    end

    return l_item_list
end

-------------------------------------
-- function getPackageItemFullStr
-- @brief 구성품 전체 문자열 반환 
-------------------------------------
function ServerData_Item:getPackageItemFullStr(package_item_str, is_merge)
    local full_str = ''
    local is_merge = is_merge or false

    local l_item_list = self:parsePackageItemStr(package_item_str)

    if (is_merge) then
        -- 아이템 합산
        local t_item_table = {}
        for idx, data in ipairs(l_item_list) do
            local item_id = data['item_id']
            local cnt = data['count']
            
            if (t_item_table[item_id] == nil) then
                t_item_table[item_id] = {['item_id'] = item_id, ['count'] = 0}
            end

            t_item_table[item_id]['count'] = t_item_table[item_id]['count'] + cnt
        end
        
        -- 기존 순서대로 정렬
        local temp_item_list = {}
        local already_insert = {}
        for idx, data in ipairs(l_item_list) do
            local item_id = data['item_id']
            if (already_insert[item_id] == nil) then
                already_insert[item_id] = true                
                table.insert(temp_item_list, t_item_table[item_id])
            end
        end

        l_item_list = temp_item_list
    end

    for idx, data in ipairs(l_item_list) do
        local name = TableItem:getItemName(data['item_id'])
        local cnt = data['count']

        local str =  Str('\n{1} {2}개', name, comma_value(cnt))
        full_str = full_str ~= '' and full_str .. str or str
    end

    return full_str
end

-------------------------------------
-- function parsePackageItemStrIndivisual
-- @brief 아이템 1종류를 표현하는 문자열 분석
-------------------------------------
function ServerData_Item:parsePackageItemStrIndivisual(package_item_str)
    local l_item_list = pl.stringx.split(package_item_str, ';')

    if (#l_item_list <= 1) then
        l_item_list = TableClass:seperate(package_item_str, ':')
    end
    
    local first_data = l_item_list[1]
    local second_data = l_item_list[2]
    local third_data = l_item_list[3]

    local item_id
    local count
    
    -- 항목 예외처리
    if (first_data == 'package') then
        error('package아이템은 package아이템을 포함할 수 없습니다.')
    end

    -- 단순 재화를 입력한 경우 'cash;1000' == 1000캐시
    if TableItem:getItemIDFromItemType(first_data) then
        item_id = TableItem:getItemIDFromItemType(first_data)
        count = second_data or 1 --입력 안하면 1개로 처리

    -- 기타 아이템을 입력한 경우 'fruit;702049;10' == 702049열매 10개
    elseif isExistValue(first_data, 'fruit', 'evolution_stone', 'rune', 'dragon', 'egg', 'relation_point') then
        item_id = second_data
        count = third_data or 1 --입력 안하면 1개로 처리
    
    -- item_id를 직접 입력한 경우 '702049;10 == 702049 아이템 10개
    else
        item_id = first_data
        count = second_data or 1 --입력 안하면 1개로 처리
    end

    return tonumber(item_id), tonumber(count)
end


-------------------------------------
-- function parseAddedItems_itemList
-- @brief
-------------------------------------
function ServerData_Item:parseAddedItems_itemList(added_items)
    if (not added_items) then
        return
    end

    if (not added_items['items_list']) then
        return
    end

    local table_item = TableItem()

    for i,v in pairs(added_items['items_list']) do
        local item_id = v['item_id']
        local type = table_item:getValue(item_id, 'type')
        v['type'] = type
    end

    return added_items
end

-------------------------------------
-- function parseAddedItems_firstItem
-- @brief
-------------------------------------
function ServerData_Item:parseAddedItems_firstItem(added_items)
    added_items = self:parseAddedItems_itemList(added_items)

    local first_item = added_items['items_list'][1]
    local t_sub_data = nil

    if (first_item['type'] == 'dragon') then
        local oid = first_item['oids'][1]
        for i,v in pairs(added_items['dragons']) do
            if (oid == v['id']) then
                t_sub_data = StructDragonObject(v)
                break
            end
        end

    elseif (first_item['type'] == 'rune') then
        local oid = first_item['oids'][1]
        for i,v in pairs(added_items['runes']) do
            if (oid == v['id']) then
                t_sub_data = StructRuneObject(v)
                break
            end
        end
    end

    return first_item['item_id'], first_item['count'], t_sub_data
end


-------------------------------------
-- function parseAddedItems
-- @brief
-------------------------------------
function ServerData_Item:parseAddedItems(added_items)
    local items_list = added_items and added_items['items_list']
    if (not items_list) then
        return {}
    end

    -- 아이템 ID별 갯수 리스트
    local t_item_id_cnt = {}
    for i,v in pairs(items_list) do
        local item_id = v['item_id']
        local count = v['count']
        if (not t_item_id_cnt[item_id]) then
            t_item_id_cnt[item_id] = 0
        end

        t_item_id_cnt[item_id] = t_item_id_cnt[item_id] + count
    end

    -- 아이템 Type별 갯수 리스트
    local t_iten_type_cnt = {}
    for i,v in pairs(t_item_id_cnt) do
        local key = TableItem:getItemTypeFromItemID(i) or i
        t_iten_type_cnt[key] = v
    end


    return t_item_id_cnt, t_iten_type_cnt
end

-------------------------------------
-- function getItemCountFromPackageItemString
-- @brief 'amor;1,gold;10000'와 같은 아이템 정의 문자열에서 특정 아이템의 수량을 리턴
-------------------------------------
function ServerData_Item:getItemCountFromPackageItemString(package_item_str, item_id)
    local l_item_list = self:parsePackageItemStr(package_item_str)
    
    -- item_id가 아닌 item_type이 넘어왔을 경우
    if (type(item_id) == 'string') then
        item_id = TableItem:getItemIDFromItemType(item_id)
    end

    for i,v in pairs(l_item_list) do
        if (v['item_id'] == item_id) then
            return (v['count'] or 0)
        end
    end

    return 0
end

-------------------------------------
-- function request_useItem
-- @param item_id : 사용하려는 아이템 아이디
-- @param count : 아이템 사용 수량
-------------------------------------
function ServerData_Item:request_useItem(item_id, count, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local item_id = item_id
    local count = count

    -- 성공 콜백
    local function success_cb(ret)
        -- 기본 재화 갱신
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/item_use')
    ui_network:setParam('uid', uid)
    ui_network:setParam('item_id', item_id)
	ui_network:setParam('count', count)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end