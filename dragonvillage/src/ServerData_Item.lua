-------------------------------------
-- class ServerData_Item
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
    local l_item_str_list = TableClass:seperate(package_item_str, ',')

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
-- function parsePackageItemStrIndivisual
-- @brief 아이템 1종류를 표현하는 문자열 분석
-------------------------------------
function ServerData_Item:parsePackageItemStrIndivisual(package_item_str)
    local l_item_list = TableClass:seperate(package_item_str, ';')
    
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
    elseif isExistValue(first_data, 'fruit', 'evolution_stone', 'rune', 'dragon') then
        item_id = second_data
        count = third_data or 1 --입력 안하면 1개로 처리
    
    -- item_id를 직접 입력한 경우 '702049;10 == 702049 아이템 10개
    else
        item_id = first_data
        count = second_data or 1 --입력 안하면 1개로 처리
    end

    return tonumber(item_id), tonumber(count)
end