local PARENT = SortManager

-------------------------------------
-- class SortManager_Transform
-- @breif 외형 변환 정렬 관리자
-------------------------------------
SortManager_Transform = class(PARENT, {
        m_tableItem = 'TableItem',
        m_mAttrSortLevel = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_Transform:init()
    self.m_tableItem = TableItem()

    -- 속성별 정렬 레벨
    self.m_mAttrSortLevel = {}
    self.m_mAttrSortLevel[''] = -2
    self.m_mAttrSortLevel['display'] = -1
    self.m_mAttrSortLevel['reset'] = 0
    self.m_mAttrSortLevel['dark'] = 1
    self.m_mAttrSortLevel['light'] = 2
    self.m_mAttrSortLevel['fire'] = 3
    self.m_mAttrSortLevel['water'] = 4
    self.m_mAttrSortLevel['earth'] = 5
    self.m_mAttrSortLevel['global'] = 6

    self:addSortType('attr', false, function(a, b, ascending) return self:sort_attr(a, b, ascending) end)
    self:setDefaultSortFunc(function(a, b, ascending) return self:sort_fid(a, b, ascending) end)
end


-------------------------------------
-- function sort_attr
-- @brief 속성
-------------------------------------
function SortManager_Transform:sort_attr(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_item = self.m_tableItem:get(a_data['mid'])
    local b_item = self.m_tableItem:get(b_data['mid'])

    local a_value = a_item['attr']
    local b_value = b_item['attr']

    a_value = self.m_mAttrSortLevel[a_value]
    b_value = self.m_mAttrSortLevel[b_value]

    if (a_value == b_value) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end

-------------------------------------
-- function sort_fid
-- @brief 외형변환 ID
-------------------------------------
function SortManager_Transform:sort_fid(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    -- 최종 정렬 조건으로 사용하기때문에 같은 경우에도 리턴함
    if ascending then
        return a_data['mid'] < b_data['mid']
    else
        return a_data['mid'] > b_data['mid']
    end
end