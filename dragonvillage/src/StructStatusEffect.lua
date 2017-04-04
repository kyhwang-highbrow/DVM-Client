-------------------------------------
-- class StructStatusEffect
-------------------------------------
StructStatusEffect = class({
		m_type = 'str',
		m_targetType = 'str',
		m_trigger = 'str',
		m_duration = 'num',	
		m_rate = 'num',
		m_value1 = 'num',
		m_value2 = 'num',
	})

-------------------------------------
-- function init
-------------------------------------
function StructStatusEffect:init(data)
	self.m_type = data['type']
	self.m_targetType = data['target_type']
	self.m_trigger = data['trigger']
	self.m_duration = tonumber(data['duration'])
	self.m_rate = tonumber(data['rate'])
	self.m_value1 = tonumber(data['value1'])
	self.m_value2 = tonumber(data['value2'])
end