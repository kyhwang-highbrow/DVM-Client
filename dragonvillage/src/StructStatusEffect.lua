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
	    self.m_rate = tonumber(data['rate'])
	    self.m_value = tonumber(data['value'])
        self.m_source = data['source']
    end

-------------------------------------
-- class StructStatusEffectValue
-------------------------------------
StructStatusEffectValue = class({
        m_type = 'str',

        m_value = 'num',
        m_valueType = 'str',
        
        m_bUseTargetStat = 'boolean',
    })

    -------------------------------------
    -- function init
    -------------------------------------
    function StructStatusEffectValue:init(value, value_type, bUseTargetStat)
        
        self.m_value = value
        self.m_valueType = value_type or 'atk'

        self.m_bUseTargetStat = bUseTargetStat or false
    end