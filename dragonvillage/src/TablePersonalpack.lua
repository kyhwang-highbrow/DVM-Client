local PARENT = TableClass

-------------------------------------
-- class TablePersonalpack
-- @breif 특별 제안
-------------------------------------
TablePersonalpack = class(PARENT, {
    })

local THIS = TablePersonalpack
-------------------------------------
-- function init
-------------------------------------
function TablePersonalpack:init()
    self.m_tableName = 'table_personalpack' 
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-- ppid	pid_list	group	active_hour	cooldown	start_date	end_date	money_min	money_max	days_after_join	package_res
-- start_date	end_date는 timestamp로 변환해서 받는다.

-------------------------------------
-- function getActivatedDateList
-- @brief date만 검사한다
-------------------------------------
function TablePersonalpack:getActivatedDateList()
    if (self == THIS) then
        self = THIS()
    end

    local table_personalpack = self.m_orgTable

    local t_ret = {}

    -- table_personalpack에서 start_date, end_date 값에 알맞는 상품만 판매 시작
    for pid, t_data in pairs(table_personalpack) do
        -- 단말기(local) 기준으로 계산
        local cur_time = os.time() * 1000
        local start_time = t_data['start_date']
        local end_time = t_data['end_date']
        local b
        -- 시작 종료 시간 모두 걸려있는 경우
        if (start_time) and (end_time) then
            b = (start_time < cur_time and cur_time < end_time)

        -- 시작 시간만 걸려있는 경우
        elseif (start_time) then
            b = (start_time < cur_time)

        -- 종료 시간만 걸려있는 경우
        elseif (end_time) then
            b = (cur_time < end_time)
        end

        if (b) then
            t_ret[pid] = t_data
        end
    end

    -- 정렬을 위해 list형태로 변환
    local l_ret = table.MapToList(t_ret)

    -- priority가 낮은 순서로 정렬
	function sortByPriority(a, b)
		return a['ppid'] < b['ppid']
	end
	table.sort(l_ret, sortByPriority)
	return l_ret
end

-------------------------------------
-- function getSumMoneyMinMax
-- @brief 깜짝 할인 상품 발동 필요 레벨
-------------------------------------
function TablePersonalpack:getSumMoneyMinMax(ppid)
    if (self == THIS) then
        self = THIS()
    end

    local min = self:getValue(ppid, 'money_min')
    local max = self:getValue(ppid, 'money_max')
    if (max == '') then
        max = 2000000000 -- 20억
    end
    return min, max
end

-------------------------------------
-- function getProductIdList
-- @brief 깜짝 할인 상품의 product_id list
-------------------------------------
function TablePersonalpack:getProductIdList(ppid)
    if (self == THIS) then
        self = THIS()
    end

    local str = self:getValue(ppid, 'pid_list')
    return pl.stringx.split(str, ',')
end

-------------------------------------
-- function getGroup
-- @brief group
-------------------------------------
function TablePersonalpack:getGroup(ppid)
    if (self == THIS) then
        self = THIS()
    end
    return self:getValue(ppid, 'group')
end

-------------------------------------
-- function getDaysAfterJoin
-- @brief days_after_join
-------------------------------------
function TablePersonalpack:getDaysAfterJoin(ppid)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(ppid, 'days_after_join')
end

-------------------------------------
-- function getPackageRes
-- @brief package_res
-------------------------------------
function TablePersonalpack:getPackageRes(ppid)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(ppid, 'package_res')
end

-------------------------------------
-- function getMainLocation
-- @brief main_loc
-------------------------------------
function TablePersonalpack:getMainLocation(ppid)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(ppid, 'main_loc')
end

-------------------------------------
-- function getPriority
-- @brief priority
-------------------------------------
function TablePersonalpack:getPriority(ppid)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(ppid, 'priority')
end