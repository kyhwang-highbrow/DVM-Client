-------------------------------------
-- table BattleStatisticsHelper
-- @brief 스킬 사용에 전역적으로 필요한 함수 모음
-------------------------------------
BattleStatisticsHelper = {}

-------------------------------------
-- function findBestValue
-- @breif 최고의 누적 수치를 찾는다.
-------------------------------------
function BattleStatisticsHelper:findBestValue(l_item, log_key)
	local best_value = 1

	for _, item in pairs(l_item) do
		local log_recorder = item.m_charLogRecorder
		local sum_value = log_recorder:getLog(log_key)
		if (best_value < sum_value) then
			best_value = sum_value
		end
	end

	return best_value
end

-------------------------------------
-- function sortByValue
-- @breif 특정 값 순서대로 정렬한다 -> 값 0인 경우 공격력 순으로 정렬
-------------------------------------
function BattleStatisticsHelper:sortByValue(l_item, log_key)
	table.sort(l_item, function(a, b)
		local a_value = a and a.m_charLogRecorder:getLog(log_key) or 0
		local b_value = b and b.m_charLogRecorder:getLog(log_key) or 0
		if (a_value == 0) and (b_value == 0) then
			return nil
		else
			return a_value > b_value
		end
	end)
end

-------------------------------------
-- function findBestValueForTable
-- @breif 테이블뷰 아이템리스트 전용
-------------------------------------
function BattleStatisticsHelper:findBestValueForTable(l_item, log_key)
	local best_value = 1

	for _, item in pairs(l_item) do
		local char = item['data']
		local log_recorder = char.m_charLogRecorder
		local sum_value = log_recorder:getLog(log_key)
		if (best_value < sum_value) then
			best_value = sum_value
		end
	end

	return best_value
end

-------------------------------------
-- function sortByValueForTable
-- @breif 테이블뷰 아이템리스트 전용
-------------------------------------
function BattleStatisticsHelper:sortByValueForTable(l_item, log_key)
	table.sort(l_item, function(a, b)
		local a_char = a['data']
		local b_char = b['data']
		local a_value = a_char.m_charLogRecorder:getLog(log_key)
		local b_value = b_char.m_charLogRecorder:getLog(log_key)
		if (a_value == 0) and (b_value == 0) then
			local a_atk = a_char:getStat('atk')
			local b_atk = b_char:getStat('atk')
			return a_atk > b_atk
		else
			return a_value > b_value
		end
	end)
end
