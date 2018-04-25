-------------------------------------
-- class NumberLabelWithSpriteFrame
-------------------------------------
NumberLabelWithSpriteFrame = class({
    m_node = 'cc.Node',

    m_mSprNumber = 'table',
    m_number = 'number',

    m_curValue = '',
    m_destValue = '',
    m_stepValue = '',

    m_hAlignment = '',
})

-------------------------------------
-- function init
-------------------------------------
function NumberLabelWithSpriteFrame:init(node, number, h_alignment)
    self.m_node = node
    self.m_mSprNumber = {}

    self.m_curValue = number or 0
    self.m_destValue = number or 0
    self.m_stepValue = 0

    self.m_hAlignment = h_alignment
    
    self.m_node:setCascadeOpacityEnabled(true)
    self.m_node:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function setNumber
-------------------------------------
function NumberLabelWithSpriteFrame:setNumber(number, time)
    if (self.m_destValue == number) then
        return
    end

    local time = time or 0

    self.m_destValue = number
    	
    if (time <= 0) then
        self.m_stepValue = self.m_destValue - self.m_curValue
    else
        self.m_stepValue = (self.m_destValue - self.m_curValue) / time
    end
end

-------------------------------------
-- function update
-------------------------------------
function NumberLabelWithSpriteFrame:update(dt)
    if (self.m_curValue == self.m_destValue) then return end

    local addValue = dt * self.m_stepValue
    self.m_curValue = self.m_curValue + addValue    

    if (self.m_stepValue < 0 and self.m_curValue <= self.m_destValue) then
        self.m_stepValue = 0
        self.m_curValue = self.m_destValue
    elseif (self.m_stepValue >= 0 and self.m_curValue >= self.m_destValue) then
        self.m_stepValue = 0
        self.m_curValue = self.m_destValue
    end

    self:refresh(math_floor(self.m_curValue))
end

-------------------------------------
-- function refresh
-------------------------------------
function NumberLabelWithSpriteFrame:refresh(number)
    if (self.m_number == number) then
        return
    end

    self.m_number = number

    local str = comma_value(number)
    local length = #str
    local x_offset = 0
    local dock_point = CENTER_POINT

    if (self.m_hAlignment == cc.TEXT_ALIGNMENT_LEFT) then
        dock_point = cc.p(0, 0.5)
    elseif (self.m_hAlignment == cc.TEXT_ALIGNMENT_RIGHT) then
        dock_point = cc.p(1, 0.5)
    end

    for _, sprite in pairs(self.m_mSprNumber) do
        sprite:setVisible(false)
    end

    for i = 1, length do
        local v

        if (self.m_hAlignment == cc.TEXT_ALIGNMENT_RIGHT) then
            v = str:sub(length - i + 1, length - i + 1)
        else
            v = str:sub(i, i)
        end
        
        local sprite = self.m_mSprNumber[i]
        local res_name

        if (v == ',') then  -- comma
            res_name = 'ingame_damage_comma.png'
        else
            res_name = 'ingame_damage_'.. v.. '.png'
        end

        if (sprite) then
            sprite:setSpriteFrame(res_name)
            sprite:setVisible(true)
        else
            sprite = cc.Sprite:createWithSpriteFrameName(res_name)

            sprite:setDockPoint(dock_point)
	        sprite:setAnchorPoint(CENTER_POINT)
            sprite:setScale(0.3)
            self.m_node:addChild(sprite)

            self.m_mSprNumber[i] = sprite
        end

        sprite:setPosition(x_offset, 0)

        if (self.m_hAlignment == cc.TEXT_ALIGNMENT_RIGHT) then
            x_offset = x_offset - (sprite:getContentSize()['width'] / 4)
        else
            x_offset = x_offset + (sprite:getContentSize()['width'] / 4)
        end
    end
end