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
-- function getString
-------------------------------------
function UIC_LabelTTF:getString()
    return self.m_node:getString()
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
    

    -- label의 getStringWidth() 함수는 개행을 하지 않은 상태의 넓이를 리텀함
    local str_width = self.m_node:getStringWidth()

    -- str_width가 contentSize의 width보다 클 경우 개행을 고려해서
    -- contentSize의 width를 리턴하게 함
    local size = self:getContentSize()
    local ret_str_width = math_min(size['width'], str_width)
    return ret_str_width
end

-------------------------------------
-- function setLineBreakWithoutSpace
-- @brief 공백이 없는 경우에도 개행을 시킨다.
-------------------------------------
function UIC_LabelTTF:setLineBreakWithoutSpace(b)
    return self.m_node:setLineBreakWithoutSpace(b)
end

-------------------------------------
-- function getCommonLineHeight
-- @brief font의 height
-------------------------------------
function UIC_LabelTTF:getCommonLineHeight()
	--[[
		내부적으로는 fontAtlass를 통해 생성된 font의 maxHeight를 그대로 전달받아 반환하는것
		LabelTextFormatter::createStringSprites(Label *theLabel)에서
		unsigned int totalHeight    = theLabel->_commonLineHeight * theLabel->_currNumLines;
		와 같이 label의 전체 높이를 구할때 사용한다.
		
	]]
	local font_height = self.m_node:getCommonLineHeight()
	local scale = self.m_node:getScaleY()
    return font_height * scale
end

-------------------------------------
-- function getStringNumLines
-------------------------------------
function UIC_LabelTTF:getStringNumLines()
	-- updateContent를 통하여 ComputeStringNumLines가 호출되어야 currLineNum 이 설정되므로 내부에서 호출해준다.
	self.m_node:updateContent()	
    return self.m_node:getStringNumLines()
end

-------------------------------------
-- function getTotalHeight
-- @brief font의 height
-------------------------------------
function UIC_LabelTTF:getTotalHeight()
	local line_height = self:getCommonLineHeight()
	local line_num = self:getStringNumLines()
    return line_height * line_num
end

-------------------------------------
-- function setDimension
-- @brief
-------------------------------------
function UIC_LabelTTF:setDimensions(width, height)
    return self.m_node:setDimensions(width, height)
end

-------------------------------------
-- function setTextColor
-- @brief
-------------------------------------
function UIC_LabelTTF:setTextColor(color)
    return self.m_node:setTextColor(color)
end

