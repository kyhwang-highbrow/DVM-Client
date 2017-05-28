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
	self.m_targetAttribute = getAttrDisadvantage(char:getAttribute())
end

-------------------------------------
-- function onApplyCommon
-------------------------------------
function StatusEffect_AttributeChange:onApplyCommon()
    local b = PARENT.onApplyCommon(self)

    if (b) then
        self.m_owner:changeAttribute(self.m_targetAttribute)
	    self:setAttributeColor(self.m_targetAttribute)
    end

    return b
end

-------------------------------------
-- function onUnapplyCommon
-------------------------------------
function StatusEffect_AttributeChange:onUnapplyCommon()
    local b = PARENT.onUnapplyCommon(self)

    if (b) then
        self.m_owner:changeAttribute(nil)
    end

    return b
end

-------------------------------------
-- function setAttributeColor
-------------------------------------
function StatusEffect_AttributeChange:setAttributeColor(attr)
	local attr_color = getAttributeColor(attr)
	self.m_animator:setColor(attr_color)
	self.m_topEffect:setColor(attr_color)
end