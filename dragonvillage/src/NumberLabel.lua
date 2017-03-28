-------------------------------------
-- class NumberLabel
-------------------------------------
NumberLabel = class({
        m_label = 'cc.Label',
        m_actionDuration = 'number',
        m_number = 'number',
        m_orgColor = 'c3b',
        m_orgScaleX = 'number',
        m_orgScaleY = 'number',

		m_isScaleAction = 'boolean',
		m_isTintAction = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function NumberLabel:init(label, number, actionDuration)
    self.m_label = label
    self.m_number = (number or 0)
    self.m_actionDuration = (actionDuration or 1)
    self.m_orgColor = label:getColor()
    self.m_orgScaleX = label:getScaleX()
    self.m_orgScaleY = label:getScaleY()
	self.m_isScaleAction = false
	self.m_isTintAction = false

    label:setString(self.getNumberStr(self.m_number))
end

-------------------------------------
-- function setNumber
-------------------------------------
function NumberLabel:setNumber(number, immediately)
    if (self.m_number == number) then
        return
    end

    local prev_number = self.m_number
    local curr_number = number
    self.m_number = number

    self.m_label:stopAllActions()

    -- 숫자 변화
    if immediately then
        self.m_label:setString(self.getNumberStr(curr_number))
        return
    elseif (self.m_actionDuration <= 0) then
        self.m_label:setString(self.getNumberStr(curr_number))
    else
        local tween = cc.ActionTweenForLua:create(self.m_actionDuration, prev_number, curr_number, NumberLabel.tweenCallback)
        self.m_label:runAction(tween)
    end

    -- 색상 변화
	if (self.m_isTintAction) then
		if (prev_number < curr_number) then
			self.m_label:setColor(cc.c3b(0, 255, 0))
		else
			self.m_label:setColor(cc.c3b(255, 0, 0))
		end
		local action = cc.TintTo:create(self.m_actionDuration, self.m_orgColor['r'], self.m_orgColor['g'], self.m_orgColor['b'])
		self.m_label:runAction(action)
	end

    -- 크기 변화
	if (self.m_isScaleAction) then
		local scale_action = cc.Sequence:create(cc.ScaleTo:create(0.1, self.m_orgScaleX * 1.2, self.m_orgScaleY * 1.2), cc.ScaleTo:create(0.1, self.m_orgScaleX * 1, self.m_orgScaleY * 1))
		self.m_label:runAction(scale_action)
	end
end

-------------------------------------
-- function tweenCallback
-------------------------------------
function NumberLabel.tweenCallback(number, label)
    label:setString(NumberLabel.getNumberStr(number))
end

-------------------------------------
-- function getNumberStr
-------------------------------------
function NumberLabel.getNumberStr(number)
    local number = math_floor(number)
    local number_str = comma_value(number)
    return number_str
end

-------------------------------------
-- function setScaleAction
-------------------------------------
function NumberLabel:setScaleAction(b)
	self.m_isScaleAction = b
end

-------------------------------------
-- function setTintAction
-------------------------------------
function NumberLabel:setTintAction(b)
	self.m_isTintAction = b
end