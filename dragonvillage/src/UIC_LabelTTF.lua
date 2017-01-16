local PARENT = UIC_Node

-------------------------------------
-- class UIC_LabelTTF
-------------------------------------
UIC_LabelTTF = class(PARENT, {
        m_strokeTickness = 'number',
        m_shadowOffset = 'cc.Size',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_LabelTTF:init(node)
    self.m_strokeTickness = 1
    self.m_shadowOffset = cc.size(0, 0)
end

-------------------------------------
-- function setString
-------------------------------------
function UIC_LabelTTF:setString(str)
    return self.m_node:setString(str)
end

-------------------------------------
-- function enableOutline
-------------------------------------
function UIC_LabelTTF:enableOutline(color, stroke_tickness)
    stroke_tickness = (stroke_tickness or self.m_strokeTickness)
    self.m_strokeTickness = stroke_tickness

    return self.m_node:enableOutline(color, stroke_tickness)
end

-------------------------------------
-- function enableShadow
-------------------------------------
function UIC_LabelTTF:enableShadow(color, shadow_offset, blurRadius)
    shadow_offset = (shadow_offset or self.m_shadowOffset)
    self.m_shadowOffset = shadow_offset

    blurRadius = (blurRadius or 0)

    return self.m_node:enableShadow(color, shadow_offset, blurRadius)
end