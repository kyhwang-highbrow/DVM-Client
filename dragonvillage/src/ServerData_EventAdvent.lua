-------------------------------------
-- class ServerData_EventAdvent
-------------------------------------
ServerData_EventAdvent = class({
        -- 깜짝 출현 did list
        m_adventDidList = 'table',

		-- 하루에 얻을 수 있는 크리마용 알 최대치
		m_dailyEggMax = 'number',
		-- 하루에 얻을 수 있는 크리마용 알
		m_dailyEggGet = 'number',
    })
-------------------------------------
-- function init
-------------------------------------
function ServerData_EventAdvent:init()
end

-------------------------------------
-- function setAdventDidList
-------------------------------------
function ServerData_EventAdvent:setAdventDidList(list_str)
    self.m_adventDidList = {}
    local l_ret = plSplit(list_str[1], ',')
    for i, v in ipairs(l_ret) do
        table.insert(self.m_adventDidList, tonumber(v))
    end
end

-------------------------------------
-- function getAdventDidList
-------------------------------------
function ServerData_EventAdvent:getAdventDidList()
    return self.m_adventDidList
end

-------------------------------------
-- function responseDailyAdventEggInfo
-------------------------------------
function ServerData_EventAdvent:responseDailyAdventEggInfo(ret)
    if (ret['egg_max']) then
		self.m_dailyEggMax = ret['egg_max']
	end
	
	if (ret['egg_get']) then
		self.m_dailyEggGet = ret['egg_get']
	end
end

-------------------------------------
-- function getDailyAdventEggMax
-------------------------------------
function ServerData_EventAdvent:getDailyAdventEggMax()
	return self.m_dailyEggMax or 0
end

-------------------------------------
-- function getDailyAdventEggGet
-------------------------------------
function ServerData_EventAdvent:getDailyAdventEggGet()
	return self.m_dailyEggGet or 0
end

-------------------------------------
-- function getAdventTitle
-- @brief 깜짝 출현 타이틀
-------------------------------------
function ServerData_EventAdvent:getAdventTitle()
    if (not self.m_adventDidList) and (not self.m_adventDidList[1]) then
        return Str('드래곤')
    end

    local dragon_name = TableDragon:getDragonName(self.m_adventDidList[1])
    return Str('{1} 깜짝 출현!', dragon_name)
end

-------------------------------------
-- function getAdventStageCount
-- @brief 깜짝 출현 던전 개수
-------------------------------------
function ServerData_EventAdvent:getAdventStageCount()
    if (not self.m_adventDidList) and (not self.m_adventDidList[1]) then
        return 0
    end

    return #self.m_adventDidList
end

-------------------------------------
-- function isAdventEventItem
-- @brief 깜짝 출현에서 특별히 얻을 수 있는 아이템 강조
-- @brief @jhakim 20191212 깜짝 출현 이벤트에 크리마용을 데려가야 5-6등급 룬 주기 때문에 이벤트 표시가 들어감
-------------------------------------
function ServerData_EventAdvent:isAdventEventItem(item_id)
	if (not item_id) then
		return false
	end

	-- 5-6등급 룬
	if (item_id >= 704101) and (item_id <= 704112) then
		return true
	end

	return false
end