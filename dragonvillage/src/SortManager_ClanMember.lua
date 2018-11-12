local PARENT = SortManager

-------------------------------------
-- class SortManager_ClanMember
-- @breif 클랜 맴버 정렬 관리자
-------------------------------------
SortManager_ClanMember = class(PARENT, {
        m_mMemberTypeSortLevel = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_ClanMember:init()
    -- 맴버 타입 정렬 레벨
    self.m_mMemberTypeSortLevel = {}
    self.m_mMemberTypeSortLevel[''] = 0
    self.m_mMemberTypeSortLevel['member'] = 1
    self.m_mMemberTypeSortLevel['manager'] = 2
    self.m_mMemberTypeSortLevel['master'] = 3

    self:addSortType('active_time', false, function(a, b, ascending) return self:sort_active_time(a, b, ascending) end)
    self:addSortType('level', false, function(a, b, ascending) return self:sort_level(a, b, ascending) end)
    self:addSortType('member_type', false, function(a, b, ascending) return self:sort_memberType(a, b, ascending) end)
	self:addSortType('contribute_exp', false, function(a, b, ascending) return self:sort_contributeExp(a, b, ascending) end)
    self:setDefaultSortFunc(function(a, b, ascending) return self:sort_uid(a, b, ascending) end)
end


-------------------------------------
-- function sort_memberType
-- @brief 맴버 타입
-------------------------------------
function SortManager_ClanMember:sort_memberType(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:getMemberType() or ''
    local b_value = b_data:getMemberType() or ''

    a_value = self.m_mMemberTypeSortLevel[a_value]
    b_value = self.m_mMemberTypeSortLevel[b_value]

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
-- function sort_level
-- @brief 레벨
-------------------------------------
function SortManager_ClanMember:sort_level(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:getLv()
    local b_value = b_data:getLv()

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
-- function sort_active_time
-- @brief 마지막 활동 시간
-------------------------------------
function SortManager_ClanMember:sort_active_time(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:getLastActiveTime()
    local b_value = b_data:getLastActiveTime()

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
-- function sort_uid
-- @brief uid로 정렬
-------------------------------------
function SortManager_ClanMember:sort_uid(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:getUid()
    local b_value = b_data:getUid()

    -- 최종 정렬 조건으로 사용하기때문에 같은 경우에도 리턴함
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end

-------------------------------------
-- function sort_contributeExp
-- @brief 기여도로 정렬
-------------------------------------
function SortManager_ClanMember:sort_contributeExp(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:getClanContributionExp()
    local b_value = b_data:getClanContributionExp()

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

