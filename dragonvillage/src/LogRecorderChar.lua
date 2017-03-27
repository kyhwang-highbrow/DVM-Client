local PARENT = LogRecorder

-------------------------------------
-- class LogRecorderChar
-------------------------------------
LogRecorderChar = class(PARENT, {
		m_charID = 'str',
     })

-------------------------------------
-- function init
-------------------------------------
function LogRecorderChar:init(char_id)
	self.m_charID = char_id
end

-------------------------------------
-- function getLog
-------------------------------------
function LogRecorderChar:getLog(key)
	if (self.m_logTable[key]) then
		return self.m_logTable[key]
	else
		return 0
	end
end

-------------------------------------
-- function recordLog
-------------------------------------
function LogRecorderChar:recordLog(key, value)
	self:applyDataInTable(self.m_logTable, key, value)
end

-------------------------------------
-- function printRecord
-- @brief 전체 로그를 출력
-------------------------------------
function LogRecorderChar:printRecord()
	local t_print = self.m_logTable
	ccdump(t_print)
end