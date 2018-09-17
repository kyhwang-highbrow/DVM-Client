local PARENT = UIC_Node

-------------------------------------
-- class UIC_LabelTTF
-------------------------------------
UIC_LabelTTF = class(PARENT, {
        m_strokeTickness = 'number',
        m_shadowOffset = 'cc.Size',
        m_orgFontSize = 'number',
        m_orgFontScaleX = 'number',
        m_orgFontScaleY = 'number',
         
        m_isVerified = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_LabelTTF:init(node)
    self.m_strokeTickness = 1
    self.m_shadowOffset = cc.size(0, 0)

    local ttfInfo = self.m_node:getTTFConfig()
    self.m_orgFontSize = ttfInfo.fontSize

    self.m_orgFontScaleX = self:getScaleX()
    self.m_orgFontScaleY = self:getScaleY()

    -- 테스트 모드일때 동작하도록 설정
    self.m_isVerified = not IS_TEST_MODE() 

    --ui에 text가 들어있는경우 때문에
    local org = node:getString()
    self:setString( "" )
    self:setString( org )
end

-------------------------------------
-- function setString
-------------------------------------
function UIC_LabelTTF:setString(str)
    self.m_node:setString(str)
    --self:applyBoxWithScale(str)
	self:verifySize()
end

-------------------------------------
-- function verifySize
-------------------------------------
function UIC_LabelTTF:verifySize()
	-- 테스트 모드에서만 활성화됩니다.
	local str = self.m_node:getString()
    if (not self.m_isVerified) and (str ~= '') then
        self.m_isVerified = true
        if (self:isOutOfBound(str)) then
			self:setTextColor(COLOR['proofreading'])
        end
    end
end

-------------------------------------
-- function applyBoxWithScale
-------------------------------------
function UIC_LabelTTF:applyBoxWithScale(str)
    
    --local stopwatch = Stopwatch()
    --stopwatch:start()

    local function checkTextArea()        
        local sizeDimensions = self.m_node:getDimensions()
        local stringWith = self.m_node:getStringWidth()
        
        if sizeDimensions.width < stringWith then        
            local oldScaleX = self:getScaleX()
            local oldScaleY = self:getScaleY()            
            local rate = sizeDimensions.width / stringWith
            local newScaleX, newScaleY
            --원래 스케일의 최대 70%만 작아지도록
            newScaleX = math_max( oldScaleX * rate, 0.7 )
            newScaleY = math_max( oldScaleY * rate, 0.7 )

            if oldScaleX ~= newScaleX or oldScaleY ~= newScaleY then
                --cclog('===============================')
                --cclog(string.format('scaleX : %f -> %f', oldScaleX, newScaleX ) )
                --cclog(string.format('scaleY : %f -> %f', oldScaleY, newScaleY ) )
                --cclog(str)
                --cclog('===============================')
                
                self.m_orgFontScaleX = newScaleX
                self.m_orgFontScaleY = newScaleY
                self.m_node:setScaleX( newScaleX )
                self.m_node:setScaleY( newScaleY )
            end
            
            return true
        end

        return false
    end

    if checkTextArea() == false then
        local oldScaleX = self:getScaleX()
        local oldScaleY = self:getScaleY()            
        if oldScaleX ~= self.m_orgFontScaleX or oldScaleY ~= self.m_orgFontScaleY then
            self.m_orgFontScaleX ,self.m_orgFontScaleY = Translate:getFontScaleRate()
            self.m_node:setScaleX( self.m_orgFontScaleX )
            self.m_node:setScaleY( self.m_orgFontScaleY )

            --한번더
            checkTextArea()
        end
    end

    --stopwatch:record('textArea' .. str)
    --stopwatch:stop()
    --stopwatch:print()

end

-------------------------------------
-- function applyBoxWithFontSize
-------------------------------------
function UIC_LabelTTF:applyBoxWithFontSize(str)
    ---[[
    local function checkTextArea()        
        local sizeDimensions = self.m_node:getDimensions()
        local stringWith = self.m_node:getStringWidth()
        
        if sizeDimensions.width < stringWith then        
            local ttfInfo = self.m_node:getTTFConfig()
            local oldFontSize = ttfInfo.fontSize
            local rate = sizeDimensions.width / stringWith
            local newFontSize
            --원래 폰트크기의 최대 70%만 작아지도록
            newFontSize = math_floor( math_max( oldFontSize * rate, self.m_orgFontSize * 0.7 ) )

            if oldFontSize ~= newFontSize then                
                cclog('===============================')
                cclog(string.format('fontsize : %d -> %d', oldFontSize, newFontSize ) )
                cclog(str)
                cclog('===============================')
                ttfInfo.fontSize = newFontSize
                self.m_node:setTTFConfig( ttfInfo )
            end
            --[[
            cclog('===============================')            
            cclog('sizeDimension : ' .. luadump(sizeDimensions) )
            cclog('string : ' .. self:getString() )
            cclog(string.format('fontsize : %d -> %d', oldFontSize, newFontSize ) )
            cclog(debug.traceback())
            cclog('===============================')
            --]]

            return true
        end

        return false
    end

    --local stopwatch = Stopwatch()
    --stopwatch:start()

    if checkTextArea() == false then
        local ttfInfo = self.m_node:getTTFConfig()
        local oldFontSize = ttfInfo.fontSize
        if oldFontSize ~= self.m_orgFontSize then
            --[[
            cclog('===============================')
            cclog('self.m_orgFontSize ~= oldFontSize' )        
            cclog('string : ' .. self:getString() )
            cclog(string.format('fontsize : %d -> %d', oldFontSize, self.m_orgFontSize ) )
            cclog('===============================')
            --]]

            ttfInfo.fontSize = self.m_orgFontSize
            self.m_node:setTTFConfig( ttfInfo )

            --한번더
            checkTextArea()
        end
    end

    --stopwatch:record('textArea' .. str)
    --stopwatch:stop()
    --stopwatch:print()
    --]]
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
-- function setVerticalAlignment
-------------------------------------
function UIC_LabelTTF:setVerticalAlignment(text_alignment_v)
    return self.m_node:setVerticalAlignment(text_alignment_v)
end

-------------------------------------
-- function setHorizontalAlignment
-------------------------------------
function UIC_LabelTTF:setHorizontalAlignment(text_alignment_h)
    return self.m_node:setHorizontalAlignment(text_alignment_h)
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

-------------------------------------
-- function setFontSize
-- @brief 폰트크기변경은 이걸 통해서 해주세요.
-------------------------------------
function UIC_LabelTTF:setFontSize(fontSize)    
    local ttfInfo = self.m_node:getTTFConfig()
    local oldFontSize = ttfInfo.fontSize
    if oldFontSize == fontSize then
        return;
    end

    ttfInfo.fontSize = fontSize
    self.m_orgFontSize = fontSize
    self.m_node:setTTFConfig( ttfInfo )
end

-------------------------------------
-- function setFontSizeScale
-- @brief 폰트크기변경은 이걸 통해서 해주세요.
-------------------------------------
function UIC_LabelTTF:setFontSizeScale(scale)    
    if scale == 1 then
        return;
    end

    local ttfInfo = self.m_node:getTTFConfig()
    local old_font_size = ttfInfo.fontSize
    
	ttfInfo.fontSize = old_font_size * scale

    self.m_orgFontSize = fontSize
    self.m_node:setTTFConfig( ttfInfo )
end

-------------------------------------
-- function setScaleX
-- @brief 폰트스케일 변경은 이걸 통해서 해주세요.
-------------------------------------
function UIC_LabelTTF:setScaleX(scale)        
    self.m_node:setScaleX( scale * self.m_orgFontScaleX )
end

-------------------------------------
-- function setScaleY
-- @brief 폰트스케일 변경은 이걸 통해서 해주세요.
-------------------------------------
function UIC_LabelTTF:setScaleY(scale)         
    self.m_node:setScaleY( scale * self.m_orgFontScaleY )
end

-------------------------------------
-- function setScale
-- @brief 폰트스케일 변경은 이걸 통해서 해주세요.
-------------------------------------
function UIC_LabelTTF:setScale(scale)        
    self.m_node:setScaleX( scale * self.m_orgFontScaleX )
    self.m_node:setScaleY( scale * self.m_orgFontScaleY )
end

-------------------------------------
-- function isOutOfBound
-- @brief 텍스트가 영역을 벗어나는지 체크
-------------------------------------
function UIC_LabelTTF:isOutOfBound(str)
    local dimension_size = self.m_node:getDimensions()
    local content_size = self.m_node:getContentSize()

	if (content_size['height'] > dimension_size['height']) or (content_size['width'] > dimension_size['width']) then
		--ccdump({['str'] = str, ['cotent'] = content_size, ['dimension'] = dimension_size})
		return true
	end

    return false
end
