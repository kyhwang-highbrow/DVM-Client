-------------------------------------
-- class ServerData_Shop
-------------------------------------
ServerData_Shop = class({
        m_serverData = 'ServerData',
		m_tableQuest = 'TableQuest',

		m_workedData = 'table',

		m_bDirtyQuestInfo = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Shop:init(server_data)
    self.m_serverData = server_data
	self.m_tableQuest = TableQuest()
	self.m_workedData = {}

	self.m_bDirtyQuestInfo = true

end
