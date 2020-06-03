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
-- function init_statusEffect
-------------------------------------
function StatusEffect_AttributeChange:init_statusEffect(char)
	self.m_owner = char
	self.m_targetAttribute = getAttrDisadvantage(char:getAttribute())
end

-------------------------------------
-- function onStart
-------------------------------------
function StatusEffect_AttributeChange:onStart()
    self.m_owner:changeAttribute(self.m_targetAttribute)
	self:setAttributeColor(self.m_targetAttribute)
end

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_AttributeChange:onEnd()
    self.m_owner:changeAttribute(nil)
end

-------------------------------------
-- function setAttributeColor
-------------------------------------
function StatusEffect_AttributeChange:setAttributeColor(attr)
	local attr_color = getAttributeColor(attr)
	self.m_animator:setColor(attr_color)
	self.m_topEffect:setColor(attr_color)
end