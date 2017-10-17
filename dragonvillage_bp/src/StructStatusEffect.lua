-------------------------------------
-- class StructStatusEffect
-------------------------------------
StructStatusEffect = class({
		m_type = 'str',
		m_targetType = 'str',
        m_targetCount = 'num',
		m_trigger = 'str',
		m_duration = 'num',	
		m_rate = 'num',
		m_value = 'num',
		m_source = 'str',
	})

    -------------------------------------
    -- function init
    -------------------------------------
    function StructStatusEffect:init(data)
	    self.m_type = data['type']
	    self.m_targetType = data['target_type']
        self.m_targetCount = data['target_count']
	    self.m_trigger = data['trigger']
	    self.m_duration = tonumber(data['duration'])
	    self.m_rate = data['rate']
	    self.m_value = data['value']
        self.m_source = data['source']
    end