-------------------------------------
-- table SortType
-- @breif
-------------------------------------
SortType = {}
SortType['name'] = 'none'       -- 정렬 타입 이름
SortType['ascending'] = false   -- 오름차순 여부
SortType['sort_func'] = 'function'

-------------------------------------
-- class SortManager
-- @breif 정렬 관리자
-------------------------------------
SortManager = class({
        m_mSortType = 'map[t_sort_type]',
        m_lSortOrder = 'list',
        m_defaultSortFunc = 'function',
        m_defaultSortAscending ='boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager:init()
    self.m_mSortType = {}
    self.m_lSortOrder = {}
end

-------------------------------------
-- function addSortType
-------------------------------------
function SortManager:addSortType(name, ascending, sort_func)
    local t_sort_type = clone(SortType)
    t_sort_type['name'] = name
    t_sort_type['ascending'] = ascending
    t_sort_type['sort_func'] = sort_func
    --table.insert(self.m_mSortType, t_sort_type)
    self.m_mSortType[name] = t_sort_type

    self:pushSortOrder(name)
end

-------------------------------------
-- function pushSortOrder
-------------------------------------
function SortManager:pushSortOrder(name)
    local idx = table.find(self.m_lSortOrder, name)

    if idx then
        table.remove(self.m_lSortOrder, idx)
    end

    table.insert(self.m_lSortOrder, 1, name)
end

-------------------------------------
-- function sortExecution
-------------------------------------
function SortManager:sortExecution(list, sort_type)
    if sort_type then
        self:pushSortOrder(sort_type)
    end

    local function sort_function(a, b)
        return self:sortFunction(a, b)
    end

    table.sort(list, sort_function)
end

-------------------------------------
-- function sortFunction
-------------------------------------
function SortManager:sortFunction(a, b)
    for _,sort_type in ipairs(self.m_lSortOrder) do
        local t_sort_type = self.m_mSortType[sort_type]
        local sort_func = t_sort_type['sort_func']
        local ascending = t_sort_type['ascending']

        local ret = sort_func(a, b, ascending)

        if (ret ~= nil) then
            return ret
        end
    end

    return self.m_defaultSortFunc(a, b, self.m_defaultSortAscending)
end

-------------------------------------
-- function setDefaultSortFunc
-------------------------------------
function SortManager:setDefaultSortFunc(sort_func, ascending)
    self.m_defaultSortFunc = sort_func
    self.m_defaultSortAscending = (ascending or false)
end

-------------------------------------
-- function setAllAscending
-- @brief 모든 정렬 타입의 오름차순(내림차순)을 설정
-------------------------------------
function SortManager:setAllAscending(ascending)
    for _,t_sort_type in pairs(self.m_mSortType) do
        t_sort_type['ascending'] = ascending
    end

    self.m_defaultSortAscending = ascending
end