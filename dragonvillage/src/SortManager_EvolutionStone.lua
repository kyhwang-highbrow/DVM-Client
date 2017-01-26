local PARENT = SortManager

-------------------------------------
-- class SortManager_EvolutionStone
-- @breif 열매 정렬 관리자
-------------------------------------
SortManager_EvolutionStone = class(PARENT, {
        m_tableItem = 'TableItem',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_EvolutionStone:init()
    self.m_tableItem = TableItem()

    self:addSortType('rarity', false, function(a, b, ascending) return self:sort_rarity(a, b, ascending) end)
    self:addSortType('attr', false, function(a, b, ascending) return self:sort_attr(a, b, ascending) end)
    self:setDefaultSortFunc(function(a, b, ascending) self:sort_esid(a, b, ascending) end)
end


-------------------------------------
-- function sort_attr
-- @brief 속성으로 정렬
-------------------------------------
function SortManager_EvolutionStone:sort_attr(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_item = self.m_tableItem:get(a_data['esid'])
    local b_item = self.m_tableItem:get(b_data['esid'])

    -- 속성
    if (a_item['attr'] == b_item['attr']) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_item['attr'] < b_item['attr']
    else
        return a_item['attr'] > b_item['attr']
    end
end

-------------------------------------
-- function sort_rarity
-- @brief 등급으로 정렬
-------------------------------------
function SortManager_EvolutionStone:sort_rarity(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_item = self.m_tableItem:get(a_data['esid'])
    local b_item = self.m_tableItem:get(b_data['esid'])

    -- 등급
    if (a_item['rarity'] == b_item['rarity']) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_item['rarity'] < b_item['rarity']
    else
        return a_item['rarity'] > b_item['rarity']
    end
end

-------------------------------------
-- function sort_esid
-- @brief 열매 ID
-------------------------------------
function SortManager_EvolutionStone:sort_esid(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    -- 최종 정렬 조건으로 사용하기때문에 같은 경우에도 리턴함
    if ascending then
        return a_data['esid'] < b_data['esid']
    else
        return a_data['esid'] > b_data['esid']
    end
end