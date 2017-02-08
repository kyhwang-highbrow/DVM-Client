local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_AttributeChange
-------------------------------------
StatusEffect_AttributeChange = class(PARENT, {
		m_targetAttribute = 'str',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_AttributeChange:init(file_name, body)
end

-------------------------------------
-- function init_skill
-------------------------------------
function StatusEffect_AttributeChange:init_statusEffect(char, tar_attr)
	self.m_owner = char
	self.m_targetAttribute = char.m_targetChar:getAttribute()
end

-------------------------------------
-- function onStart_StatusEffect
-------------------------------------
function StatusEffect_AttributeChange:onStart_StatusEffect()
	self.m_owner:changeAttribute(self.m_targetAttribute)
end

-------------------------------------
-- function onEnd_StatusEffect
-------------------------------------
function StatusEffect_AttributeChange:onEnd_StatusEffect()
	self.m_owner:changeAttribute(nil)
end
