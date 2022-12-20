-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure

-------------------------------------
---@class StructItem:Structure
-- @instance struct_item
-------------------------------------
StructItem = Class(PARENT, {
    id = 'number', -- item ID

    count = 'number', -- 개수
    exchange = 'number', -- 현재 가지고 있는 개수 중 거래소에서 산 개수
    gift = 'number', -- 현재 가지고 있는 개수 중 선물받은 개수

    stared = 'boolean', -- 즐겨찾기 여부
    lock = 'boolean', -- 잠금
    new = 'boolean', -- 새로운 아이템인지

    reward_lv = 'number', -- 보상인 경우 보상 레벨 (API response의 ret['rewarded_result'])
    updated_at = 'timestamp',
    -- created_at = 'timestamp',
    -- played_at = 'timestamp',
    subdivision_idx = 'number', -- 가방 등에서 소분한 인덱스
})

local THIS = StructItem

-------------------------------------
-- virtual function getClassName override
-------------------------------------
function StructItem:getClassName()
    return 'StructItem'
end

-------------------------------------
-- virtual function getThis override
-------------------------------------
function StructItem:getThis()
    return THIS
end

-------------------------------------
-- function init
-------------------------------------
function StructItem:init()
    self.id = -1
    self.count = 0
    self.exchange = 0
    self.gift = 0
    self.stared = false
    self.lock = false
    self.new = false
    self.reward_lv = 0
    self.updated_at = 0
    self.subdivision_idx = 1
end

-------------------------------------
-- function create
-------------------------------------
function StructItem:create(t_data)
    local struct_item = StructItem()

    -- 서버에서 전달 받은 key를 클라이언트 데이터에 적합하게 변경
    local t_key_change = {}

    struct_item:applyTableData(t_data, t_key_change)
    return struct_item
end

-------------------------------------
-- function createSimple
-- @brief item(골드, 보석) 아이템을 간단하게 structItem 형태로 변환하기
---@param item_id number
---@param count number
---@return StructItem
-------------------------------------
function StructItem:createSimple(item_id, count)
    self = StructItem()

    self.id = item_id
    self.count = count

    return self
end

-------------------------------------
-- function createFromString
-- @brief itemid:count 데이터를 StructItem으로 만들어 줌
---@param item_string string
---@return StructItem
-------------------------------------
function StructItem:createFromString(item_string)
    item_string = item_string or ''

    item_string = string.split(item_string, ':')

    if (#item_string ~= 2) then
        error('잘못된 데이터.')
    end

    local ticket_id = tonumber(item_string[1])
    local ticket_count = tonumber(item_string[2])
    local struct_item = StructItem:createSimple(ticket_id, ticket_count)

    return struct_item
end

-------------------------------------
-- function createListWithResultResponse
-- @brief ret['rewarded_result']를 받아서 list(StructItem)으로 반환
-------------------------------------
function StructItem:createListWithResultResponse(result)
    local result = result or {}
    local struct_item_map = {}
    for idx, t_result_data in ipairs(result) do
        if (t_result_data['itemid'] ~= nil) then
            local item_id = t_result_data['itemid']
            local item_cnt = t_result_data['cnt']
            local reward_lv = (t_result_data['r_level'] or 0)
            if (struct_item_map[item_id] == nil) then
                local struct_item = StructItem:createSimple(item_id, item_cnt)
                struct_item:setRewardLevel(reward_lv)
                struct_item_map[item_id] = struct_item
            else
                struct_item_map[item_id]:modifyItemCount(item_cnt)
            end
        end
    end

    local struct_item_list = {}
    for item_id, struct_item in pairs(struct_item_map) do
        table.insert(struct_item_list, struct_item)
    end

    -- 정렬은 아이템 ID 순
    table.sort(struct_item_list, function(a, b)
        return (a:getItemId() < b:getItemId())
    end)

    return struct_item_list
end


-------------------------------------
-- function filterByItemType
-- @brief 아이템 타입으로 필터
-------------------------------------
function StructItem:filterByItemType(struct_item_list, ...)
    local list = {...}
    local result_list = {}

    for _, struct_item in ipairs(struct_item_list) do
        if isExistValue(struct_item:getItemType(), table.unpack(list)) ~= true then
            table.insert(result_list, struct_item)
        end
    end

    return result_list
end

-------------------------------------
-- function createListWithResultResponse_Seperation
-- @brief ret['rewarded_result']를 받아서 list(StructItem)으로 반환, 같은 아이템 ID라도 별개의 StructItem으로 반환함
-------------------------------------
function StructItem:createListWithResultResponse_Seperation(result)
    local result = result or {}
    local struct_item_list = {}
    for idx, t_result_data in ipairs(result) do
        if (t_result_data['itemid'] ~= nil) then
            if (t_result_data['cnt'] > 0) then
                local item_id = t_result_data['itemid']
                local item_cnt = t_result_data['cnt']
                local reward_lv = (t_result_data['r_level'] or 0)
                local struct_item = StructItem:createSimple(item_id, item_cnt)
                struct_item:setRewardLevel(reward_lv)
                table.insert(struct_item_list, struct_item)
            end
        end
    end

    return struct_item_list
end

-------------------------------------
-- function createListWithItemIdList
-- @brief 아이템 ID 리스트로부터 StructItem List로 생성 후 반환
-------------------------------------
function StructItem:createListWithItemIdList(item_id_list)
    local item_id_list = item_id_list or {}
    local struct_item_list = {}
    for _, item_id in ipairs(item_id_list) do
        local struct_item = StructItem:createSimple(item_id, 1)
        table.insert(struct_item_list, struct_item)
    end
    return struct_item_list
end

-------------------------------------
-- function createMapWithItemIdList
-- @brief 아이템 ID 리스트로부터 StructItem Map 생성 후 반환
-------------------------------------
function StructItem:createMapWithItemIdList(item_id_list)
    local item_id_list = item_id_list or {}
    local struct_item_map = {}
    for _, item_id in ipairs(item_id_list) do
        local struct_item = StructItem:createSimple(item_id, 1)
        struct_item_map[item_id] = struct_item
    end
    return struct_item_map
end

-------------------------------------
-- function getItemId
-- @return item ID (table_item - id)
-------------------------------------
function StructItem:getItemId()
    return self.id
end

-------------------------------------
-- function getItemName
-- @return name(string)
-------------------------------------
function StructItem:getItemName()
    local name = TableItem:getInstance():getItemName(self.id)
    return name
end

-------------------------------------
-- function getItemNameWithCount
-- @return name(string) '보석 2개'
-------------------------------------
function StructItem:getItemNameWithCount()
    local item_id = self:getItemId()
    local item_count = self:getItemCount()

    -- 일반 아이템
    return TableItem:getInstance():getItemNameWithCount(item_id, item_count)
end

-------------------------------------
-- function getItemType
-- @return type(string)
-------------------------------------
function StructItem:getItemType()
    local type = TableItem:getInstance():getItemType(self.id)
    return type
end

-------------------------------------
-- function getInvenVisible
-- @return type(string)
-------------------------------------
function StructItem:getInvenVisible()
    local is_visible = TableItem:getInstance():getInvenVisible(self.id)
    return is_visible
end

-------------------------------------
-- function getItemDesc
-- @brief 아이템 설명
-------------------------------------
function StructItem:getItemDesc()
    local str = TableItem:getInstance():getItemDesc(self.id)
    return str
end

-------------------------------------
-- function getItemTooltipDesc
-- @return desc(string) 아이템 이름과 설명 이쁘게 반환
-------------------------------------
function StructItem:getItemTooltipDesc()
    local str = TableItem:getInstance():getItemTooltip(self.id)
    return str
end

-------------------------------------
-- function getIconRes
-- @return icon sprite resource name
-------------------------------------
function StructItem:getIconRes()
    local item_id = self:getItemId()
    if (TableItem:getInstance():exists(item_id) == false) then
        error('## 존재하지 않는 ITEM ID : ' .. item_id)
    end

    local res = TableItem:getInstance():getItemResName(item_id)

    if res == nil then
        res = string.format('res/temp/DEV.png', item_id)
    else
        res = string.format('res/icon/item/%s.png', res)
    end

    -- 없는 경우
    if (cc.FileUtils:getInstance():isFileExist(res) == false) then
        res = 'res/temp/DEV.png'
    end


    return res
end

------------------------------------
-- function getItemSmallIcon
-- @brief item 아이콘 작은 거로 Animator 생성 후 반환
-------------------------------------
function StructItem:getItemSmallIconRes()
    local item_id = self:getItemId()
    local res_name = TableItem:getInstance():getItemResName(item_id)
    local res = string.format('res/icon/item_small/%s.png', res_name)
    return res
end

-------------------------------------
-- function getIcon
-- @return icon(Animator)
-------------------------------------
function StructItem:getIcon()
    local item_icon_res = self:getIconRes()
    local animator = MakeAnimator(item_icon_res)
    return animator
end

-------------------------------------
-- function getIcon
-- @return icon(Animator)
-------------------------------------
function StructItem:getSmallIcon()
    local item_icon_res = self:getItemSmallIconRes()
    local animator = MakeAnimator(item_icon_res)
    return animator
end

-------------------------------------
-- function getElemental
-- @return 속성 (fire, earth, wind, water, light, dark), 속성이 없는 경우 none 반환
-------------------------------------
function StructItem:getElemental()
    local item_id = self:getItemId()
    local elemental = TableItem:getInstance():getItemElemental(item_id)
    return elemental
end

-------------------------------------
-- function isStared
-- @return true면 즐겨찾기 중
-------------------------------------
function StructItem:isStared()
    return self.stared
end

-------------------------------------
-- function isLock
-- @return true면 잠금 중
-------------------------------------
function StructItem:isLock()
    return self.lock
end

-------------------------------------
-- function isNew
-- @return true면 새로운 아이템
-------------------------------------
function StructItem:isNew()
    return self.new
end

-------------------------------------
-- function setNew
-- @param b_is_new 새로운 아이템인지 설정
-------------------------------------
function StructItem:setNew(b_is_new)
    self.new = b_is_new
end

-------------------------------------
-- function setRewardLevel
-------------------------------------
function StructItem:setRewardLevel(reward_lv)
    self.reward_lv = reward_lv
end

-------------------------------------
-- function getItemRewardLevel
-------------------------------------
function StructItem:getItemRewardLevel()
    if (self.reward_lv == nil) then
        self.reward_lv = 0
    end
    local reward_lv = self.reward_lv
    return reward_lv
end

-------------------------------------
-- function hasMore
-- @brief 해당 아이템 struct의 개수 이상으로 내가 가지고 있는지 판단
-------------------------------------
function StructItem:hasMore()
    local item_id = self:getItemId()
    local count = self:getItemCount()

    return ServerData_Items:getInstance():hasMoreItem(item_id, count)
end

-------------------------------------
-- function isItemAvailableDot
-- @brief true 반환하면 사용이 가능한 아이템
-------------------------------------
function StructItem:isItemAvailableDot()
    local is_usable = self:isUsable()
    local item_type = self:getItemType()
    local item_count = self:getMyItemCount()
    -- 보패 제작권 예외 처리
    if is_usable == true then
        if string.find(item_type, 'make_charm') ~= nil then
            if TableContents:getInstance():isContentsUnlock('charm') == false then
                return false
            end
            if (item_count == 0) then
                return false
            end
        end
    end

    return is_usable
end

-------------------------------------
-- function isUsable
-- @brief true 반환하면 사용이 가능한 아이템
-------------------------------------
function StructItem:isUsable()
    local item_id = self:getItemId()
    local is_usable = TableItem:getInstance():getItemUsable(item_id)
    return is_usable ~= 'FALSE'
end

-------------------------------------
-- function isBundleUsable
-- @brief true 반환하면 사용이 가능한 아이템
-------------------------------------
function StructItem:isBundleUsable()
    local item_id = self:getItemId()
    local is_usable = TableItem:getInstance():getItemUsable(item_id)
    return is_usable == 'bundle'
end

-------------------------------------
-- function getUsableCount
-- @brief 해당 아이템을 사용이 몇번 가능한지 반환
-------------------------------------
function StructItem:getUsableCount()
    local item_id = self:getItemId()
    local item_type = self:getItemType()
    local item_cnt = 50 --self:getItemCount()
    return item_cnt
end

-------------------------------------
-- function getItemCount
-- @brief 아이템 개수 반환
-------------------------------------
function StructItem:getItemCount(except_exchange, except_gift)
    local count = self.count
    if (except_exchange == true) then
        count = count - self.exchange
    end

    if (except_gift == true) then
        count = count - self.gift
    end
    return count
end

-------------------------------------
-- function getMyItemCount
-- @brief 내가 가진 아이템 개수 반환
-------------------------------------
function StructItem:getMyItemCount()
    local item_id = self:getItemId()
    local count = ServerData_Items:getInstance():getItem(item_id)
    return count
end

-------------------------------------
-- function getNeedItemCountStr
-- @brief '%d/%d' 의 스트링 형식으로 반환
-------------------------------------
function StructItem:getNeedItemCountStr(use_red)
    local item_id = self:getItemId()
    local my_count = self:getMyItemCount()
    local need_count = self.count
    local is_use_red = use_red or true

    if is_use_red == true and my_count < need_count then
        return string.format('{@RED}%s{@}/%s', FormatSIPostFixKo(my_count), FormatSIPostFixKo(need_count))

    else
        return string.format('%s/%s', FormatSIPostFixKo(my_count), FormatSIPostFixKo(need_count))
    end
end

-------------------------------------
-- function isNeedItemCountEnough
-------------------------------------
function StructItem:isNeedItemCountEnough(use_toast)
    local is_use_toast = use_toast or false
    local item_id = self:getItemId()
    local my_count = self:getMyItemCount()
    local need_count = self.count
    local is_enough = my_count >= need_count

    if is_enough == false and is_use_toast == true then
        UIManager:toastNotificationRed(Str('{1}이(가) 부족합니다.', self:getItemName()))
    end

    return is_enough
end

-------------------------------------
-- function isNeedItemCountSyncWithServer
-- @brief   현재 내가 가진 아이템 카운트가 순찰로 인해 증가됬지만 서버와 싱크가 안맞는데
--          하필이면 그 갯수가 필요 아이템 갯수를 충족시킬 때 순찰 동기화 요청용 체크
--          그 후 순찰 동기화 요청을 하고 재화 소모 요청을 한번 무시함(버튼 반응 없음)
-------------------------------------
function StructItem:isNeedItemCountSyncWithServer()
    local item_id = self:getItemId()
    local specific_count = self:getItemCount()
    local need_exp_update = ServerData_Items:getInstance():isNeedSyncItem(item_id, specific_count)
    return need_exp_update
end

-------------------------------------
-- function fillNeedItem
-------------------------------------
function StructItem:fillNeedItem(item_node, label_node)
    if item_node ~= nil then
        local animator = self:getSmallIcon()
        item_node:removeAllChildren()
        item_node:addChild(animator.m_node)
    end

    if label_node ~= nil then
        local str = self:getNeedItemCountStr()
        label_node:setString(str)
    end

    CenterAlignNode({ item_node, label_node })
end

-------------------------------------
-- function getItemCountFromExchange
-- @brief 거래소에서 획득한 아이템 개수 반환
-------------------------------------
function StructItem:getItemCountFromExchange()
    return self.exchange
end

-------------------------------------
-- function getItemCountFromGift
-- @brief 선물로 획득한 아이템 개수 반환
-------------------------------------
function StructItem:getItemCountFromGift()
    return self.gift
end

-------------------------------------
-- function setItemCount
-- @brief 아이템 개수 설정
-------------------------------------
function StructItem:setItemCount(new_count)
    self.count = new_count
end

-------------------------------------
-- function setItemCountFromGift
-- @brief 선물에서 획득한 아이템 개수 설정
-------------------------------------
function StructItem:setItemCountFromGift(new_count)
    self.gift = new_count
end

-------------------------------------
-- function modifyItemCount
-- @brief 아이템 개수 +-
-------------------------------------
function StructItem:modifyItemCount(diff)
    self.count = self.count + diff
end

-------------------------------------
-- function getItemCountWithSIPostFix
-- @brief 아이템 개수를 SI PostFix 활용하여 반환 (3200 -> 3.20K)
-------------------------------------
function StructItem:getItemCountWithSIPostFix()
    local count = self:getItemCount()
    local str = TableItem:getInstance():getItemCountWithSIPostFix(count)
    return str
end

------------------------------------
-- function isProfileIconItem
-- @brief 프로필 아이콘인지 반환
-------------------------------------
function StructItem:isProfileIconItem()
    local item_id = self:getItemId()
    return TableItem:getInstance():isProfileIconItem(item_id)
end

-------------------------------------
-- function isProfileFrameItem
-- @brief 프로필 프레임인지 반환
-------------------------------------
function StructItem:isProfileFrameItem()
    local item_id = self:getItemId()
    return TableItem:getInstance():isProfileFrameItem(item_id)
end

-------------------------------------
-- function hasKeyword
-- @brief 특정 키워드로 검색했을때 연관이 있는지
-------------------------------------
function StructItem:hasKeyword(keyword)
    local item_id = self:getItemId()
    return TableItem:getInstance():hasKeyword(item_id, keyword)
end

-------------------------------------
-- function getUpdatedTime
-- @brief 업데이트된 타임 스탬프 반환
-------------------------------------
function StructItem:getUpdatedTime()
    return self.updated_at
end

-------------------------------------
-- function getSubdivisionMap
-- @brief 아이템 카드 상한 개수에 맞춰 여러 개로 소분한 map 반환
-- @comment 가방 등 개수에 따라 여러 개로 나눠야 할 때 사용
-- @param max_count_per(number) 상한 개수
-- @return map[id .. '#' .. idx] = StructItemSubdivision,
-- @example 만약 item_count가 2000개라면 다음과 같이 반환 map = {[item_id#1] = {id = item_id, count = 999}, [item_id#2] = {id = item_id, count = 999}, [item_id#3] = {id = item_id, count = 2}}
-- @example 만약 item_count가 0이라면 {} 빈 데이터 반환
-------------------------------------
function StructItem:getSubdivisionMap(max_count_per)
    local l_sub_item_list = self:getSubdivisionList(max_count_per)

    local m_sub_item_map = {}
    for _, struct_item_sub in ipairs(l_sub_item_list) do
        local sub_id = struct_item_sub:getSubdivisionId()
        m_sub_item_map[sub_id] = struct_item_sub
    end

    return m_sub_item_map
end

-------------------------------------
-- function getSubdivisionList
-- @brief 아이템 카드 상한 개수에 맞춰 여러 개로 소분한 list 반환
-- @comment 가방 등 개수에 따라 여러 개로 나눠야 할 때 사용
-- @param max_count_per(number) 상한 개수
-- @return map[id .. '#' .. idx] = StructItemSubdivision,
-- @example 만약 item_count가 2000개라면 다음과 같이 반환 map = {[item_id#1] = {id = item_id, count = 999}, [item_id#2] = {id = item_id, count = 999}, [item_id#3] = {id = item_id, count = 2}}
-- @example 만약 item_count가 0이라면 {} 빈 데이터 반환
-------------------------------------
function StructItem:getSubdivisionList(max_count_per)
    local l_result_list = {}
    local item_id = self:getItemId()
    local item_count = self:getItemCount()
    local item_type = self:getItemType()

    -- 소분하는 아이템 타입이 아닌 경우
    if (TableItem:getInstance():isRandomPieceItem(item_id) == true) then
    elseif ((item_count > 0) or (max_count_per == nil)) then
        local struct_item_sub = StructItemSubdivision:create(self)
        return { struct_item_sub }
    end

    -- 아이템이 차지할 카드 수
    local total_card_count = math_floor(item_count / max_count_per)
    local last_count = item_count % max_count_per
    if (last_count ~= 0) then
        total_card_count = total_card_count + 1

    else
        last_count = max_count_per
    end

    for idx = 1, total_card_count do
        local curr_item_count
        if (idx == total_card_count) then
            curr_item_count = last_count
        else
            curr_item_count = max_count_per
        end

        local struct_item_sub = StructItemSubdivision:create(self)
        struct_item_sub:setSubdivisionIdx(idx)
        struct_item_sub:setItemCount(curr_item_count)

        table.insert(l_result_list, struct_item_sub)
    end

    return l_result_list
end

-------------------------------------
-- function openDetailUI
-- @brief 아이템 정보창 열기
-- @param l_item_id (좌우 이동할 아이템 아이디 리스트)
-- @return UI
-------------------------------------
function StructItem:openDetailUI(l_item_id, ignore_ui_actions)
    local type = self:getItemType()
    if (self:isBundleUsable() == true) then
        require('UI_BundleItemDetailPopup')
        local item_id = self:getItemId()
        return UI_BundleItemDetailPopup(item_id, l_item_id, ignore_ui_actions or false)
    else
        local item_id = self:getItemId()
        return UI_ItemDetailPopup(item_id, l_item_id, ignore_ui_actions or false)
    end
end

-------------------------------------
-- function fillUI
-- @brief 아이콘 유아이 정보 채우기
-------------------------------------
function StructItem:fillUI(vars, isPosix)
    -- 아이콘
    do
        local node = vars['itemNode']
        if node ~= nil then
            local animator = self:getIcon()
            node:removeAllChildren()
            node:addChild(animator.m_node)
        end
    end

    -- 스몰 아이콘
    do
        local node = vars['itemSmallNode']
        if node ~= nil then
            local animator = self:getSmallIcon()
            node:removeAllChildren()
            node:addChild(animator.m_node)
        end
    end

    -- 갯수
    do
        local node = vars['itemCountLabel']
        if node ~= nil then
            local count = self:getItemCount()
            local str
            if (isPosix == true) then
                str = Str('x{1}', self:getItemCountWithSIPostFix())
            else
                str = Str('x{1}', comma_value(count))
            end
            node:setString(str)
        end
    end
end
