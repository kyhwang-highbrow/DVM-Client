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

-------------------------------------
-- function setAlignment
-------------------------------------
function UIC_LabelTTF:setAlignment(text_alignment_h, text_alignment_v)
    return self.m_node:setAlignment(text_alignment_h, text_alignment_v)
end

-------------------------------------
-- function getStringWidth
-------------------------------------
function UIC_LabelTTF:getStringWidth()
    return self.m_node:getStringWidth()
end

-------------------------------------
-- function setLineBreakWithoutSpace
-- @brief ������ ���� ��쿡�� ������ ��Ų��.
-------------------------------------
function UIC_LabelTTF:setLineBreakWithoutSpace(b)
    return self.m_node:setLineBreakWithoutSpace(b)
end

-------------------------------------
-- function getCommonLineHeight
-- @brief font�� height
-------------------------------------
function UIC_LabelTTF:getCommonLineHeight()
	--[[
		���������δ� fontAtlass�� ���� ������ font�� maxHeight�� �״�� ���޹޾� ��ȯ�ϴ°�
		LabelTextFormatter::createStringSprites(Label *theLabel)����
		unsigned int totalHeight    = theLabel->_commonLineHeight * theLabel->_currNumLines;
		�� ���� label�� ��ü ���̸� ���Ҷ� ����Ѵ�.
		
	]]
	local font_height = self.m_node:getCommonLineHeight()
	local scale = self.m_node:getScale()
    return font_height * scale
end

-------------------------------------
-- function getStringNumLines
-------------------------------------
function UIC_LabelTTF:getStringNumLines()
	-- updateContent�� ���Ͽ� ComputeStringNumLines�� ȣ��Ǿ�� currLineNum �� �����ǹǷ� ���ο��� ȣ�����ش�.
	self.m_node:updateContent()	
    return self.m_node:getStringNumLines()
end

-------------------------------------
-- function getTotalHeight
-- @brief font�� height
-------------------------------------
function UIC_LabelTTF:getTotalHeight()
	local line_height = self:getCommonLineHeight()
	local line_num = self:getStringNumLines()
    return line_height * line_num
end