-------------------------------------
-- class LogRecorder
-------------------------------------
LogRecorder = class({
		m_logTable = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function LogRecorder:init()
	self.m_logTable = {}
end

-------------------------------------
-- function recordStaticAllLog
-------------------------------------
function LogRecorder:recordStaticAllLog()
end

-------------------------------------
-- function applyDataInTable
-------------------------------------
function LogRecorder:applyDataInTable(table, key, value)
	if (not key) then return end
	local table = table or self.m_logTable
	local value = value or 1

	if (table[key]) then
		table[key] = table[key] + value
	else
		table[key] = value
	end
end

-------------------------------------
-- function getLog
-------------------------------------
function LogRecorder:getLog(key)
	self:initCharLog(dragon_id)

	local t_log = self.m_tCharLogTable[dragon_id]

	if (t_log[key]) then
		return t_log[key]
	else
		return 0
	end
end

-------------------------------------
-- function setLog
-------------------------------------
function LogRecorder:setLog(key, value)

end

-------------------------------------
-- function printRecord
-- @brief 전체 로그를 출력
-------------------------------------
function LogRecorder:printRecord()
end